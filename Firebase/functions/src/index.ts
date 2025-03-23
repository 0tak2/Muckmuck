import * as logger from "firebase-functions/logger";
import {initializeApp} from "firebase-admin/app";

// Firestroe
import {getFirestore, Timestamp} from "firebase-admin/firestore";
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
          title: "새로운 반응",
          body: `${senderNickname}님이 ${receiverNickname}님의 먹태그에 반응을 남겼어요. 
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

export const notifyMuckTag = onDocumentCreated("muckTags/{muckTagId}",
  async (event) => {
    try {
    // muckTags 콜렉션에 새 문서가 생성되는 경우 실행
      const muckTagData = event.data?.data();
      if (!muckTagData) {
        logger.error("No muckTag data found");
        return;
      }

      const {createdBy: authorId} = muckTagData;

      // 글쓴이 정보 조회
      const authorDoc = await db.collection("users").doc(authorId).get();
      if (!authorDoc.exists) {
        logger.error("Author not found");
        return;
      }

      // 모든 유저 조회 (글쓴이 제외)
      const usersSnapshot = await db.collection("users").get();
      const messages: any[] = [];

      usersSnapshot.forEach((userDoc) => {
        const userData = userDoc.data();
        if (userDoc.id !== authorId && userData.notificationToken) {
          let typeTitle: string;
          if (muckTagData?.type === "bob") {
            typeTitle = "밥";
          } else if (muckTagData?.type === "cafe") {
            typeTitle = "카페";
          } else if (muckTagData?.type === "drink") {
            typeTitle = "술";
          } else {
            typeTitle = "기타";
          }

          const availableUntilRaw = muckTagData?.availableUntil as Timestamp;
          const availableUntilDate = availableUntilRaw?.toDate();
          let availableUntilString = "";
          if (availableUntilDate) {
            availableUntilString = formatKoreanTime(availableUntilDate);
          }

          messages.push({
            token: userData.notificationToken,
            notification: {
              title: "새로운 먹태그",
              body: `${muckTagData?.region} / ` +
                    `${typeTitle} / ${availableUntilString}`,
            },
            data: {
              muckTagId: event.params.muckTagId,
              authorId,
            },
          });
        }
      });

      if (messages.length > 0) {
        await Promise.all(messages.map((message) => messaging.send(message)));
        logger.info("Notification sent successfully");
      }
    } catch (error) {
      logger.error("Error sending notification", error);
    }
  });

/**
 * 한국 시간(KST)을 기준으로 현재 시간을 포맷팅하는 함수
 * 오늘 날짜면 "오후 2시 35분" 형식으로 반환
 * 다른 날짜면 "3월 23일 오후 2시 35분" 형식으로 반환
 *
 * @param {Date} [date=new Date()] - 변환할 Date 객체
 * @return {string} 포맷팅된 한국 시간 문자열
 */
function formatKoreanTime(date = new Date()) {
  // KST는 UTC+9
  const kstDate = new Date(date.getTime() + (9 * 60 * 60 * 1000));

  // 현재 날짜의 KST 기준 00시 00분 00초를 구함
  const now = new Date();
  const todayKST = new Date(now.getTime() + (9 * 60 * 60 * 1000));
  const todayMidnightKST = new Date(Date.UTC(
    todayKST.getUTCFullYear(),
    todayKST.getUTCMonth(),
    todayKST.getUTCDate(),
    0, 0, 0
  ));

  // 시간 포맷팅을 위한 변수들
  const month = kstDate.getUTCMonth() + 1;
  const day = kstDate.getUTCDate();
  let hours = kstDate.getUTCHours();
  const minutes = kstDate.getUTCMinutes();

  // 오전/오후 구분
  const ampm = hours < 12 ? "오전" : "오후";

  // 12시간제로 변환
  hours = hours % 12;
  hours = hours === 0 ? 12 : hours; // 0시는 12시로 표시

  // 결과 문자열 생성
  let result = `${ampm} ${hours}시 ${minutes}분`;

  // 오늘 날짜가 아닌 경우 날짜 정보 추가
  if (kstDate.getTime() < todayMidnightKST.getTime() ||
        kstDate.getTime() >=
          todayMidnightKST.getTime() + (24 * 60 * 60 * 1000)) {
    result = `${month}월 ${day}일 ${result}`;
  }

  return result;
}
