const functions = require("firebase-functions");
const admin = require("firebase-admin");
const axios = require("axios");
const { google } = require("googleapis");

admin.initializeApp();

const EMAILJS_SERVICE_ID = process.env.EMAILJS_SERVICE_ID;
const EMAILJS_TEMPLATE_ID = process.env.EMAILJS_TEMPLATE_ID;
const EMAILJS_USER_ID = process.env.EMAILJS_USER_ID;
const EMAILJS_PRIVATE_KEY = process.env.EMAILJS_PRIVATE_KEY;

exports.sendOtpEmail = functions.https.onCall(async (data, context) => {
  const payload = data.email ? data : (data.data || {});
  const email = payload.email;
  const otp = payload.otp;

  if (!email || !otp) {
    throw new functions.https.HttpsError('invalid-argument', 'Email e OTP são obrigatórios.');
  }

  try {
    await axios.post('https://api.emailjs.com/api/v1.0/email/send', {
      service_id: EMAILJS_SERVICE_ID,
      template_id: EMAILJS_TEMPLATE_ID,
      user_id: EMAILJS_USER_ID,
      accessToken: EMAILJS_PRIVATE_KEY,
      template_params: {
        to_email: email,
        otp: otp,
      }
    });
    return { success: true };
  } catch (error) {
    console.error("Erro no EmailJS:", error.response ? error.response.data : error.message);
    throw new functions.https.HttpsError('internal', 'Falha ao enviar o e-mail pela API externa.');
  }
});

async function verifyAndroidPurchase(productId, token) {
  const auth = new google.auth.GoogleAuth({
    scopes: ['https://www.googleapis.com/auth/androidpublisher']
  });
  const authClient = await auth.getClient();
  const playPublisher = google.androidpublisher({ version: 'v3', auth: authClient });

  try {
    const response = await playPublisher.purchases.products.get({
      packageName: 'com.matheussilvagarcia.anotherrunner',
      productId: productId,
      token: token,
    });

    return response.data.purchaseState === 0;
  } catch (error) {
    console.error("Erro na API do Google Play:", error.message);
    return false;
  }
}

async function verifyIOSPurchase(token) {
  const isSandbox = true;
  const url = isSandbox ? 'https://sandbox.itunes.apple.com/verifyReceipt' : 'https://buy.itunes.apple.com/verifyReceipt';
  const password = process.env.APPLE_SHARED_SECRET || "COLOQUE_AQUI_SUA_SENHA_DA_APPLE_SE_TIVER_IOS";

  try {
    const response = await axios.post(url, {
      'receipt-data': token,
      'password': password
    });
    return response.data.status === 0;
  } catch (error) {
    console.error("Erro na API da Apple:", error.message);
    return false;
  }
}

exports.verifyPurchase = functions.https.onCall(async (data, context) => {
  if (!context.auth) {
    throw new functions.https.HttpsError('unauthenticated', 'Apenas usuários logados podem validar compras.');
  }

  const uid = context.auth.uid;
  const productId = data.productId;
  const token = data.verificationData;
  const source = data.source;

  if (productId !== 'charts') {
    throw new functions.https.HttpsError('invalid-argument', 'Produto não reconhecido.');
  }

  if (!token || !source) {
    throw new functions.https.HttpsError('invalid-argument', 'Faltam dados do recibo para validação.');
  }

  let isValid = false;
  if (source === 'google_play') {
    isValid = await verifyAndroidPurchase(productId, token);
  } else if (source === 'app_store') {
    isValid = await verifyIOSPurchase(token);
  } else {
    throw new functions.https.HttpsError('invalid-argument', 'Loja de aplicativos desconhecida.');
  }

  if (!isValid) {
    throw new functions.https.HttpsError('permission-denied', 'Recibo de compra inválido, falso ou pagamento pendente.');
  }

  try {
    await admin.firestore().collection('users').doc(uid).update({
      isPremium: true,
      premiumUpdatedAt: admin.firestore.FieldValue.serverTimestamp()
    });

    return { success: true };
  } catch (error) {
    console.error("Erro ao atualizar banco após validação:", error);
    throw new functions.https.HttpsError('internal', 'Compra válida, mas erro ao salvar no banco.');
  }
});