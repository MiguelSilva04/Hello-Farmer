/**
 * Import function triggers from their respective submodules:
 *
 * const {onCall} = require("firebase-functions/v2/https");
 * const {onDocumentWritten} = require("firebase-functions/v2/firestore");
 *
 * See a full list of supported triggers at https://firebase.google.com/docs/functions
 */

const {onCall} = require("firebase-functions/v2/https");
const logger = require("firebase-functions/logger");

const admin = require("firebase-admin");
admin.initializeApp();

exports.sendNotification = onCall(async (request) => {
  const {token, title, body, data: notificationData} = request.data;

  try {
    const message = {
      token: token,
      notification: {
        title: title,
        body: body,
      },
      data: notificationData || {},
    };

    const response = await admin.messaging().send(message);
    return {success: true, response};
  } catch (error) {
    logger.error("Erro ao enviar notificação:", error);
    throw new Error(error.message);
  }
});

// Create and deploy your first functions
// https://firebase.google.com/docs/functions/get-started

// exports.helloWorld = onRequest((request, response) => {
//   logger.info("Hello logs!", {structuredData: true});
//   response.send("Hello from Firebase!");
// });
