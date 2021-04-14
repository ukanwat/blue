import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';
admin.initializeApp(functions.config().firebase);
import BillingLimiter from "firebase-billing-limiter";

exports.BillingLimiter = BillingLimiter({
    disableProjectAmount: 100, // The amount that will trigger the disabling (in your project billing currency).
    topicId: "billing", // The topicid created on the quotas.
  });

const db = admin.firestore();
export const Register = functions.auth.user().onCreate(async (user) => {
    const data = await db.collection('auth').orderBy('user_id','desc').limit(1).get();
   
    let uid:number = 0;
 data.docs.forEach(doc => { uid = doc.data().user_id +1
});
     if(uid === 0){
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
    return db.collection('auth').doc(user.uid).set({'user_id':uid, 'refresh_time': new Date().getTime(),'uid': user.uid });
    
    });
});


const notification_options = {
    priority: "high",
    timeToLive: 60 * 60 * 24,
  };
export const messageNotification = functions.https.onRequest(async (req, resp) => {
    const messageData = req.body.event.data.new;
    const message = {
        notification: {
           title: 'Someone just commented on your Post',
           body: messageData.data,
               },
        };
    const options =  notification_options;
      admin.messaging().sendToDevice(messageData.payload.token, message, options)
      .then( ()=>{

       resp.status(200).send("Notification sent successfully")
       
      })
      .catch( error => {
          console.log(error);
      });
  
  });

  export const commentReplyNotification = functions.https.onRequest((req, resp) => {
    console.log(req.body.event.data.new);
    const options =  notification_options;
    const messageData = req.body.event.data.new;
    const message = {
        notification: {
           title: 'Someone just Messaged you',
           body: messageData.data,

               },
        };
      admin.messaging().sendToDevice(messageData.payload.token, message, options)
      .then( ()=>{
       resp.status(200).send("Notification sent successfully")
      })
      .catch( error => {
          console.log(error);
      });
  });


  export const commentNotification = functions.https.onRequest((req, resp) => {
    console.log(req.body.event.data.new);
    const options =  notification_options;
    const messageData = req.body.event.data.new;
    const message = {
        notification: {
           title: 'Someone just commented on yout post',
           body: messageData.data,
               },
        };
      admin.messaging().sendToDevice(messageData.payload.token, message, options)
      .then( ()=>{

       resp.status(200).send("Notification sent successfully")
       
      })
      .catch( error => {
          console.log(error);
      });
  });