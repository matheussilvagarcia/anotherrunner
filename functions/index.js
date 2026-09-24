const functions = require("firebase-functions");
const admin = require("firebase-admin");
const axios = require("axios");

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

  const db = admin.firestore();
  const normalizedEmail = email.toLowerCase();
  const rateLimitRef = db.collection('otp_rate_limits').doc(normalizedEmail);

  const doc = await rateLimitRef.get();
  const now = Date.now();

  if (doc.exists) {
    const lastRequest = doc.data().lastTimestamp;
    if (now - lastRequest < 60000) {
      throw new functions.https.HttpsError('resource-exhausted', 'Aguarde 1 minuto para solicitar novo codigo.');
    }
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

    await rateLimitRef.set({
      lastTimestamp: now,
      createdAt: admin.firestore.FieldValue.serverTimestamp()
    });

    return { success: true };
  } catch (error) {
    throw new functions.https.HttpsError('internal', 'Erro interno ao processar a solicitacao.');
  }
});