const { onDocumentCreated } = require("firebase-functions/v2/firestore");
const { initializeApp } = require("firebase-admin/app");
const { getFirestore } = require("firebase-admin/firestore");
const { getMessaging } = require("firebase-admin/messaging");

initializeApp();

const db = getFirestore();

/**
 * Jab bhi notifications collection mein naya document aaye,
 * us user/manager ko FCM push notification bhejo.
 */
exports.sendPushNotification = onDocumentCreated(
  "notifications/{notifId}",
  async (event) => {
    const data = event.data?.data();
    if (!data) return;

    const { title, body, type, userId, managerId } = data;

    // Recipient UID decide karo
    const recipientUid = type === "manager" ? managerId : userId;
    if (!recipientUid) return;

    try {
      // User ka FCM token Firestore se fetch karo
      const userDoc = await db.collection("users").doc(recipientUid).get();
      const fcmToken = userDoc.data()?.fcmToken;

      if (!fcmToken) {
        console.log(`No FCM token for uid: ${recipientUid}`);
        return;
      }

      // FCM message bhejo
      await getMessaging().send({
        token: fcmToken,
        notification: {
          title: title ?? "PlaySphere",
          body: body ?? "",
        },
        android: {
          notification: {
            channelId: "playsphere_channel",
            priority: "high",
            sound: "default",
          },
          priority: "high",
        },
        apns: {
          payload: {
            aps: {
              sound: "default",
              badge: 1,
            },
          },
        },
      });

      console.log(`Push sent to ${recipientUid}`);
    } catch (err) {
      console.error("FCM send error:", err);
    }
  }
);
