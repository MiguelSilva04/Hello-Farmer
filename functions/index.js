import { onRequest } from "firebase-functions/v2/https";

export const sendNotification = onRequest(async (req, res) => {
  const { token, title, body, data: notificationData } = req.body;

  try {
    const message = {
      token,
      notification: { title, body },
      data: notificationData || {},
    };

    const response = await admin.messaging().send(message);
    res.status(200).send({ success: true, response });
  } catch (error) {
    logger.error("Erro ao enviar notificação:", error);
    res.status(500).send({ success: false, error: error.message });
  }
});
