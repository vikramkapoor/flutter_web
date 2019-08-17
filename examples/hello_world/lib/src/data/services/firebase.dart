import 'package:firebase/firebase.dart' as fb;
import 'package:firebase/firestore.dart';

final auth = fb.auth();
bool _ready = false;
  // Your web app's Firebase configuration
  var firebaseConfig = {

  };

void init() {
  if (!_ready) {
    
   /* fb.initializeApp(
    apiKey: "AIzaSyB6bvNK9RZ964Adx2XxIaHTLA7LMZIf_0A",
    authDomain: "rakshak-b1b11.firebaseapp.com",
    databaseURL: "https://rakshak-b1b11.firebaseio.com",
    projectId: "rakshak-b1b11",
    storageBucket: "rakshak-b1b11.appspot.com",
    messagingSenderId: "995372369195",
    );*/
    
    _ready = true;
  }
}

Future<fb.User> registerUser(String email, String password) async {
  init();
  if (email.isNotEmpty && password.isNotEmpty) {
    var trySignin = false;
    try {
      // Modifies persistence state. More info: https://firebase.google.com/docs/auth/web/auth-state-persistence
      var selectedPersistence = 'local';
      await auth.setPersistence(selectedPersistence);
      final _user = await auth.createUserWithEmailAndPassword(email, password);
      if (_user != null) return _user.user;
    } catch (e) {
      if (e.code == "auth/email-already-in-use") {
        trySignin = true;
      } else {
        throw e;
      }
    }

    if (trySignin) {
      try {
        final _user = await auth.signInWithEmailAndPassword(email, password);
        if (_user != null) return _user.user;
      } catch (e) {
        throw e;
      }
    }
  } else {
    throw "Please fill correct e-mail and password.";
  }
  throw 'Error Communicating with Firebase';
}

Future<fb.User> startAsGuest() async {
  init();
  try {
    var selectedPersistence = 'local';
    await auth.setPersistence(selectedPersistence);
    final _user = await auth.signInAnonymously();
    if (_user != null) return _user.user;
  } catch (e) {
    throw e.toString();
  }
  throw 'Error Communicating with Firebase';
}

Future forgotPassword(String email) async {
  init();
  try {
    var selectedPersistence = 'local';
    await auth.setPersistence(selectedPersistence);
    await auth.sendPasswordResetEmail(email);
  } catch (e) {
    throw e.toString();
  }
}

Future logout() async {
  init();
  try {
    await auth.signOut();
  } catch (e) {
    throw e.toString();
  }
  throw 'Error Communicating with Firebase';
}

Future<fb.User> checkUser() async {
  init();
  try {
    var selectedPersistence = 'local';
    await auth.setPersistence(selectedPersistence);
    final _user = await auth.currentUser;
    if (_user != null) return _user;
  } catch (e) {
    throw e.toString();
  }
  throw 'Error Communicating with Firebase';
}

Future<fb.User> googleSignIn() async {
  try {
    var selectedPersistence = 'local';
    await auth.setPersistence(selectedPersistence);
    final _user = await auth.signInWithPopup(fb.GoogleAuthProvider());
    if (_user != null) return _user.user;
  } catch (e) {
    throw e.toString();
  }
  throw 'Error Communicating with Firebase';
}

Future<List<DocumentSnapshot>> getList(String collection,
    {String orderBy}) async {
  init();
  try {
    final ref = fb.firestore().collection(collection);
    final _data = await ref.get();
    return _data.docs;
  } catch (e) {
    throw 'Error Getting Snapshots';
  }
}
