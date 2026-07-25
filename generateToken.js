const { GoogleAuth } = require('google-auth-library');
const serviceAccount = require('C:/Users/pixel/major-project-d0c57-firebase-adminsdk-fbsvc-7a15cb8957.json');

async function getAccessToken() {
    const auth = new GoogleAuth({
        credentials: serviceAccount,
        scopes: ['https://www.googleapis.com/auth/firebase.messaging'],
    });

    const client = await auth.getClient();
    const token = await client.getAccessToken();
    return token;
}

getAccessToken().then((token) => {
    console.log('Access Token:', token);
}).catch((err) => {
    console.error('Error:', err);
});
