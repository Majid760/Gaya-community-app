//importScripts("https://www.gstatic.com/firebasejs/8.4.1/firebase-app.js");
//importScripts("https://www.gstatic.com/firebasejs/8.4.1/firebase-messaging.js");
//
//
//const firebaseConfig = {
//     apiKey: "AIzaSyDMUbvC7tODkadWx8k32HT4hPnysjAx80w",
//           authDomain: "gaya-5876c.firebaseapp.com",
//           databaseURL: "https://gaya-5876c-default-rtdb.europe-west1.firebasedatabase.app",
//           projectId: "gaya-5876c",
//           storageBucket: "gaya-5876c.appspot.com",
//           messagingSenderId: "353177936887",
//           appId: "1:353177936887:web:18930368f17435e797c4f2",
//           measurementId: "G-GYC29R375X"
//};
//firebase.initializeApp(firebaseConfig);
//const messaging = firebase.messaging();
//
///*messaging.onMessage((payload) => {
//  console.log('Message received. ', payload);*/
//messaging.onBackgroundMessage(function (payload) {
//  console.log("Received background message ", payload);
//  const notificationTitle = payload.notification.title;
//  // console.log("this is fucking title:=>", notificationTitle);
//  // console.log("this is fucking body:=>", payload.notification.body);
//  // console.log("this is fucking notificaiton:=>", payload.notification);
//  const notificationOptions = {
//    body: payload.notification.body,
//  };
//
//  self.registration.showNotification(notificationTitle, notificationOptions);
//});