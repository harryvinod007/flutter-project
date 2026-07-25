const { getFirestore } = require('firebase-admin/firestore');
const { onDocumentUpdated } = require('firebase-functions/v2/firestore');
const admin = require('firebase-admin');

admin.initializeApp();

exports.sendScheduledMeetingNotification = onDocumentUpdated(
  'complaints/{complaintId}', // Firestore collection path
  async (event) => {
    const beforeData = event.data.before.data();
    const afterData = event.data.after.data();

    const beforeStatus = beforeData.chatSession?.status;
    const afterStatus = afterData.chatSession?.status;
    const aStatus = afterData.status?.resolution;
    const bStatus = beforeData.status?.resolution; 
    console.log("Before Status:", beforeStatus);
    console.log("After Status:", afterStatus);

    // Check if the status has changed to 'Scheduled'
    if (beforeStatus !== 'scheduled' && afterStatus === 'scheduled') {
      const complaintId = event.params.complaintId;
      const reporterToken = afterData.reporterToken;
      const scheduledTime = afterData.chatSession?.scheduledTime;
  
      let formattedDate = "N/A"; // Default value
      if (scheduledTime) {
          const date = new Date(scheduledTime);
          const day = String(date.getDate()).padStart(2, '0');
          const month = String(date.getMonth() + 1).padStart(2, '0');
          const year = date.getFullYear();
          const hours = String(date.getHours()).padStart(2, '0');
          const minutes = String(date.getMinutes()).padStart(2, '0');
          formattedDate = `${day}/${month}/${year} ${hours}:${minutes}`;
          console.log(formattedDate);
      } else {
          console.log("Scheduled time is not available.");
      }
  
      console.log("token :", reporterToken);
      if (reporterToken) {
          const payload = {
              notification: {
                  title: `Complaint #${complaintId}`,
                  body: `The panel has scheduled a meeting for ${formattedDate}.`,
              },
          };
  
          admin.messaging().send({
              token: reporterToken,
              notification: payload.notification,
          })
            .then((response) => {
                console.log('Notification sent successfully:', response);
            })
            .catch((error) => {
                console.error('Error sending notification:', error);
            });
      }
  }

    // Check if resolution under status has data and send a notification if updated from an empty state
    if (bStatus === "" && aStatus && aStatus !== "") {  // Check if aStatus has content after being empty
      const complaintId = event.params.complaintId;
      const reporterToken = afterData.reporterToken;

      if (reporterToken) {
        const payload = {
          notification: {
            title: `Complaint #${complaintId}`,
            body: `Resolved`,  // Including the resolution data
          },
        };

        admin.messaging().send({
          token: reporterToken,
          notification: payload.notification,
        })
          .then((response) => {
            console.log('Notification sent successfully:', response);
          })
          .catch((error) => {
            console.error('Error sending notification:', error);
          });
      }
    }
  }
);
