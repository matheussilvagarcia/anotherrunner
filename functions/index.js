const functions = require("firebase-functions");
const admin = require("firebase-admin");
const axios = require("axios");
const { google } = require("googleapis");

admin.initializeApp();

exports.sendOtpEmail = functions.https.onCall(async (data, context) => {
  const payload = data.email ? data : (data.data || {});
  const email = payload.email;
  const otp = payload.otp;
  const time = payload.time;

  if (!email || !otp || !time) {
    throw new functions.https.HttpsError('invalid-argument', 'Email, OTP e tempo sao obrigatorios.');
  }

  const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
  if (!emailRegex.test(email)) {
    throw new functions.https.HttpsError('invalid-argument', 'Formato de email invalido.');
  }

  try {
    await axios.post('https://api.emailjs.com/api/v1.0/email/send', {
      service_id: process.env.EMAILJS_SERVICE_ID,
      template_id: process.env.EMAILJS_TEMPLATE_ID,
      user_id: process.env.EMAILJS_USER_ID,
      accessToken: process.env.EMAILJS_PRIVATE_KEY,
      template_params: {
        to_email: email,
        passcode: otp,
        time: time,
      }
    });
    return { success: true };
  } catch (error) {
    throw new functions.https.HttpsError('internal', 'Erro interno ao processar a solicitacao.');
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
    return false;
  }
}

async function verifyIOSPurchase(token) {
  const password = process.env.APPLE_SHARED_SECRET || "";
  const prodUrl = 'https://buy.itunes.apple.com/verifyReceipt';
  const sandboxUrl = 'https://sandbox.itunes.apple.com/verifyReceipt';

  try {
    let response = await axios.post(prodUrl, {
      'receipt-data': token,
      'password': password
    });

    if (response.data.status === 21007) {
      response = await axios.post(sandboxUrl, {
        'receipt-data': token,
        'password': password
      });
    }

    return response.data.status === 0;
  } catch (error) {
    return false;
  }
}

exports.verifyPurchase = functions.https.onCall(async (data, context) => {
  if (!context.auth) {
    throw new functions.https.HttpsError('unauthenticated', 'Apenas usuarios logados podem validar compras.');
  }

  const uid = context.auth.uid;
  const productId = data.productId;
  const token = data.verificationData;
  const source = data.source;

  if (productId !== 'charts') {
    throw new functions.https.HttpsError('invalid-argument', 'Produto nao reconhecido.');
  }

  if (!token || !source) {
    throw new functions.https.HttpsError('invalid-argument', 'Faltam dados do recibo para validacao.');
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
    throw new functions.https.HttpsError('permission-denied', 'Recibo de compra invalido.');
  }

  try {
    await admin.firestore().collection('users').doc(uid).update({
      isPremium: true,
      premiumUpdatedAt: admin.firestore.FieldValue.serverTimestamp()
    });
    return { success: true };
  } catch (error) {
    throw new functions.https.HttpsError('internal', 'Erro ao salvar no banco.');
  }
});