importScripts('https://www.gstatic.com/firebasejs/10.7.0/firebase-app-compat.js');
importScripts('https://www.gstatic.com/firebasejs/10.7.0/firebase-messaging-compat.js');

firebase.initializeApp({
  apiKey: 'AIzaSyCwyKGsOw2yg1-AdeoAmNoKDEDkKn4--bA',
  appId: '1:69890170136:web:98908030b9444a3184d26d',
  messagingSenderId: '69890170136',
  projectId: 'courseflutter-cb19d',
  authDomain: 'courseflutter-cb19d.firebaseapp.com',
  storageBucket: 'courseflutter-cb19d.firebasestorage.app',
});

const messaging = firebase.messaging();

messaging.onBackgroundMessage((payload) => {
  console.log('Received background message', payload);
});
