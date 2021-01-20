import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';
import { KoidFactory } from 'koid';
admin.initializeApp(functions.config().firebase);
export const Register = functions.auth.user().onCreate((user) => {
  const customClaims = {
    "admin": true,
    "https://hasura.io/jwt/claims": {
      'x-hasura-default-role': 'user',
      'x-hasura-allowed-roles': ['user'],
      'x-hasura-user-id': user.uid,
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


export const registerUser =  functions.https.onRequest( async (req, resp) => {
 
  // const key = functions.config().registeruser.key;
  // console.log(key);
  // if (key === req.header('ACTION_KEY'))
  if (true)
   {const email = req.body.email;
    const password = req.body.password;
    const displayName = req.body.displayName;
    const server = req.body.server;
   const koid = KoidFactory({node:server,epoch:(2020-1970)*31536000*1000});
  const uid = koid.nextBigint;
    if (email === null || password === null || displayName === null) {
        throw new functions.https.HttpsError("invalid-argument", 'missing information');
    }
    console.log(uid);
   console.log('valid info');
    // try {
    //     const userRecord = await admin.auth().createUser({
    //         email: email,
    //         password: password,
    //         displayName: displayName,
    //         uid: uid.toString(),
    //     });
  
    //     // const customClaims = {
    //     //     "https://hasura.io/jwt/claims": {
    //     //         "x-hasura-default-role": "user",
    //     //         "x-hasura-allowed-roles": ["user"],
    //     //         "x-hasura-user-id": uid,
    //     //     },
    //     // };
  
    //     // await admin.auth().setCustomUserClaims(userRecord.uid, customClaims);
    //     resp.json(userRecord.toJSON());
  
    // } catch (e) {
    //     throw new functions.https.HttpsError("unauthenticated", JSON.stringify(Error, undefined, 2));
    // }


  } 


else {
    resp.status(400).send('Error 400: Bad key');
}
 
});

export const setCustomClaim =  functions.https.onRequest( async (req, resp) => {
  // const key = functions.config().registeruser.key;
  // console.log(key);
  // if (key === req.header('ACTION_KEY'))
  if (true)
   {
     
  
    // const uid = req.body.uid;
    const server = req.body.server;
    const koid = KoidFactory({node:server,epoch:(2020-1970)*31536000*1000});
    const uid = koid.nextBigint;
    try {
        const customClaims = {
            "https://hasura.io/jwt/claims": {
                "x-hasura-default-role": "user",
                "x-hasura-allowed-roles": ["user"],
                "x-hasura-user-id": uid,
            },
        };
  
  await admin.auth().setCustomUserClaims(uid.toString(), customClaims);
        resp.send('done');
    } catch (e) {
        throw new functions.https.HttpsError("unimplemented", JSON.stringify(Error, undefined, 2));
    }


  } 


else {
    resp.status(400).send('Error 400: Bad key');
}
 
});