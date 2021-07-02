import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';
import * as graphqlReq from "graphql-request";


admin.initializeApp(functions.config().firebase);
import BillingLimiter from "firebase-billing-limiter";

exports.BillingLimiter = BillingLimiter({
    disableProjectAmount: 5000, // The amount that will trigger the disabling (in your project billing currency).
    topicId: "billing", // The topicid created on the quotas.
});

const db = admin.firestore();

export const Register = functions.auth.user().onCreate(async (user) => {
    const data = await db.collection('auth').orderBy('user_id', 'desc').limit(1).get();

    let uid: number = 0;
    data.docs.forEach(doc => {
        uid = doc.data().user_id + 1
    });
    if (uid === 0) {
        return;      //show error or retry
    }
    const customClaims = {
        "https://hasura.io/jwt/claims": {
            "x-hasura-default-role": "user",
            "x-hasura-allowed-roles": ["user"],
            "x-hasura-user-id": uid.toString(),
        },
    };
    return admin
        .auth()
        .setCustomUserClaims(user.uid, customClaims)
        .then(() => {
            return db.collection('auth').doc(user.uid).set({ 'user_id': uid, 'refresh_time': new Date().getTime(), 'uid': user.uid });

        });
});






export const notification = functions.https.onRequest(async (req, resp) => {
    console.log(req.body.event.data.new);
    const messageData = req.body.event.data.new;
    const imgUrl = messageData.data.image;
    const body = messageData.data.body;
    const title = messageData.data.title;
    const token = messageData.token;

    const message1 = {
        "token": token + '',
        "notification": {
            "title": title + '',
            "body": body + '',
        },
    };
    const message2 = {
        "token": messageData.token + '',

        "notification": {
            "title": messageData.data.title + '',
            "imageUrl": imgUrl + '',
        },
        "apns": {
            "payload": {
                "aps": {
                    "mutable-content": 1,
                },
            },
            "fcm_options": {
                "image": imgUrl + '',
            },
        },

    };

    console.log(message2);
    if (body !== null) {
        await admin.messaging().send(message1);
    }

    if (imgUrl !== null) {
        await admin.messaging().send(message2);
    }
    resp.status(200).send("Notification sent successfully");


});




const client = new graphqlReq.GraphQLClient('https://app.stark.social/v1/graphql', {
    headers: {
        "content-type": "application/json",
        "x-hasura-admin-secret": "Tay13Utk12",
    },
})

exports.PostsCron = functions.pubsub.schedule('*/5 * * * *')
    .timeZone('America/New_York') // Users can choose timezone - default is America/Los_Angeles
    .onRun(async (context) => {
        const mutation = `mutation{
        insert_cron_one(object:{type:"posts",args:{off:0, lim:1000}}){
         __typename
       }
       }`;

        await client.request(mutation);


        console.log('This will be run every 5 minutes!');
        return null;
    });


exports.PostsCron1 = functions.pubsub.schedule('*/50 * * * *')
    .timeZone('America/New_York') // Users can choose timezone - default is America/Los_Angeles
    .onRun(async (context) => {
        const mutation = `mutation{
        insert_cron_one(object:{type:"posts",args:{off:1000, lim:10000}}){
         __typename
       }
       }`;

        await client.request(mutation);


        console.log('This will be run every 50 minutes!');
        return null;
    });

exports.TagsCron = functions.pubsub.schedule('5 11 * * *')
    .timeZone('America/New_York') // Users can choose timezone - default is America/Los_Angeles
    .onRun(async (context) => {
        const mutation = `mutation{
        insert_cron_one(object:{type:"tags"}){
         __typename
       }
       }`;

        await client.request(mutation);


        console.log('This will be run everydat at 5:11 AM!');
        return null;
    });