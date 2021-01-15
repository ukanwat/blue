import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';
import * as request from 'graphql-request';
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
      return metadataRef.set({ refreshTime: new Date().getTime() });
    });
});


exports.checkAnswer = functions.https.onRequest( async (_request, response) => {
  const client = new request.GraphQLClient('https://hasura-test-project.hasura.app/v1/graphql', {
    headers: {
        "content-type": "application/json",
        "x-hasura-admin-secret": "qwertyuiop", 
    },
  })



  const answerID = _request.body.event.data.new.answer_id;
  // const userID = _request.body.event.data.new.user_id;

  const answerQuery = `
  queryAnswer($answerID: uuid!) {
      question_answers(where: {id: {_eq: $answerID}}) {
        is_correct
      }
  }`;

  // const incrementMutation = `
  // mutationScore($userID: String!) {
  //     update_users(where: {id: {_eq: $userID}}, _inc: {score: 10}) {
  //         affected_rows
  //     }
  // }`;

  try {
      const data = await client.request(answerQuery, {
          answerID: answerID,
      })
      


      const isCorrect = data["question_answers"][0]["is_correct"];
      if (!isCorrect) {}
          response.send("correct");
          return;
      // else {
      //     await client.request(incrementMutation, { userID: userID })
      //     response.send("correct");
      // }

  } catch (e) {
      // throw new functions.https.HttpsError(e,'error');
  }
});
