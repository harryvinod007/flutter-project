const admin = require('firebase-admin');
admin.initializeApp();

const payload = {
  notification: {
    title: 'Test Notification',
    body: 'This is a test notification.',
  },
};

// Use your actual device token
const token = 'ePIVXY_7SD-qaFmkMcP6KA:APA91bFCGjlI3SiC9ECnyL1Xh3sWITUqhXOs8XO6rD1HbdPR5Z3-u43Z_GIxLMggkRsXhJkuihHufnK70cGpSYqi9bqTcsDVN1pRqVuW0NjYEElKt0ktZBg';

admin.messaging().send({
  token: token,
  notification: payload.notification,
})
  .then((response) => {
    console.log('Notification sent successfully:', response);
  })
  .catch((error) => {
    console.error('Error sending notification:', error);
  });
