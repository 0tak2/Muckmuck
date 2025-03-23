import * as logger from "firebase-functions/logger";
import {initializeApp} from "firebase-admin/app";

// Firestroe
import {getFirestore} from "firebase-admin/firestore";
import {onDocumentCreated} from "firebase-functions/firestore";

// FCM
import {getMessaging} from "firebase-admin/messaging";

initializeApp();
const db = getFirestore();
const messaging = getMessaging();

export const notifyReaction = onDocumentCreated("muckReactions/{reactionId}",
  async (event) => {
    try {
    // muckReactions 콜렉션에 새 문서가 생성되는 경우 실행
      const reactionData = event.data?.data();
      if (!reactionData) {
        logger.error("No reaction data found");
        return;
      }

      const {createdBy: senderId, muckTagId: muckTagId} = reactionData;

      const muckTagDoc = await db.collection("muckTags").doc(muckTagId).get();
      const receiverId = muckTagDoc.data()?.createdBy;
      if (!receiverId) {
        logger.error("Receiver id is undefined");
      }

      logger.info(`New reaction from ${senderId} to ${receiverId}`);

      // sender와 receiver의 정보 조회
      const senderDoc = await db.collection("users").doc(senderId).get();
      const receiverDoc = await db.collection("users").doc(receiverId).get();

      if (!senderDoc.exists || !receiverDoc.exists) {
        logger.error("Sender or receiver not found");
        return;
      }

      const senderData = senderDoc.data();
      const receiverData = receiverDoc.data();
      if (!senderData || !receiverData) {
        logger.error("Sender or receiver data is undefined");
        return;
      }

      const senderNickname = senderData.nickname;
      const receiverNickname = receiverData.nickname;
      const notificationToken = receiverData.notificationToken;

      if (!notificationToken) {
        logger.warn("Receiver has no notification token");
        return;
      }

      const message = {
        token: notificationToken,
        notification: {
          title: "새로운 반응 알림",
          body: `${senderNickname}님이 ${receiverNickname}님의 먹태그에 관심을 보였어요. 
확인하고 먹먹한 사이가 되어보세요.`,
        },
        data: {
          senderId,
          receiverId,
        },
      };

      await messaging.send(message);
      logger.info("Notification sent successfully");
    } catch (error) {
      logger.error("Error sending notification", error);
    }
  });
