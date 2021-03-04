import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';
import { KoidFactory } from 'koid';
admin.initializeApp(functions.config().firebase);
export const Register = functions.auth.user().onCreate((user) => {
    const koid = KoidFactory({node:1,epoch:(2020-1970)*31536000*1000});
    const uid = koid.nextBigint;
        const customClaims = {
            "uid": uid,
            "https://hasura.io/jwt/claims": {
                "x-hasura-default-role": "user",
                "x-hasura-allowed-roles": ["user"],
                "x-hasura-user-id": uid,
            },
        };
  return admin
    .auth()
    .setCustomUserClaims(user.uid, customClaims)
    .then(() => {
      const metadataRef = admin.database().ref(`metadata/${user.uid}`);
      return metadataRef.set({ refreshTime: new Date().getTime()});
    });
});


const notification_options = {
    priority: "high",
    timeToLive: 60 * 60 * 24,
  };
export const messageNotification = functions.https.onRequest(async (req, resp) => {
    console.log(req.body);
    const { event: {op, data}, table: {name, schema} } = req.body;
    console.log(name);
    console.log(schema);
    console.log(op);
    const { token, sender_id}= data.new;
    console.log(token);
    const message = {
        notification: {
           title: 'received a new message',
           body: sender_id,
               },
        };
    const options =  notification_options;
      admin.messaging().sendToDevice("civ6SqwQSLWD0R_Bjja3yS:APA91bEtgKDtdW0ve6ZNjOBQO5PWFBO-O8yNIxJpMvpub8oqj6ISy-FRUBC9bCNd-DU8s-2PvBl60RXGubw-eo7_B5mAm-mQssuXYJEmQfWACV5iu5IAwE7rESu4b_ERMgRga-snQAbZ", message, options)
      .then( ()=>{

       resp.status(200).send("Notification sent successfully")
       
      })
      .catch( error => {
          console.log(error);
      });
  
  });
