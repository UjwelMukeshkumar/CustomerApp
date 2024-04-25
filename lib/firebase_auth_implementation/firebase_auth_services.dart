import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuthServices {
  FirebaseAuth firebaseAuth = FirebaseAuth.instance;

  String Address = 'search';

  Future<User?> signinWithEmailAndPassword(
      String email, String password, BuildContext context) async {
    try {
      UserCredential userCredential =
          await firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? user = userCredential.user;

      if (user != null) {
        String photoURL = user.photoURL ??
            'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTf6_jeCeVDiMDqJ9DIobNO3Uu4EppEmf-64fuSwh5KAGeYYt3PoSM03rPUNjIuAeD5XXY&usqp=CAU';
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        bool loginCompleted =
            userDoc.exists ? userDoc['loginCompleted'] : false;
        if (loginCompleted) {
          Navigator.pushNamedAndRemoveUntil(
              context, 'productPage', (route) => false);
        } else {
          // Navigator.pushNamedAndRemoveUntil(
          //     context, 'infoPage', (route) => false);
        }

        return user;
      }
    } catch (e) {
      if (e is FirebaseAuthException) {
        if (e.code == 'user-not-found' || e.code == 'wrong-password') {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Invalid email or password.'),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('An error occurred: ${e.message}'),
            ),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('An error occurred: $e'),
          ),
        );
      }
    }
    return null;
  }

  // Future<User?> signupWithEmailAndPassword(
  //     String email, String password, BuildContext context) async {
  //   try {
  //     UserCredential userCredential = await firebaseAuth
  //         .createUserWithEmailAndPassword(email: email, password: password);

  //     User? user = userCredential.user;

  //     if (user != null) {
  //       String photoURL =
  //           'https://example.com/default-profile-image.jpg';

  //       await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
  //         'email': email,
  //         'photoURL': photoURL,
  //       });

  //       Navigator.pushNamedAndRemoveUntil(
  //           context, 'infoPage', (route) => false);

  //       return user;
  //     }
  //   } catch (e) {
  //     if (e is FirebaseAuthException) {
  //       if (e.code == 'email-already-in-use') {
  //         ScaffoldMessenger.of(context).showSnackBar(
  //           SnackBar(
  //             content: Text('This email is already in use.'),
  //           ),
  //         );
  //       } else {
  //         ScaffoldMessenger.of(context).showSnackBar(
  //           SnackBar(
  //             content: Text('An error occurred: ${e.message}'),
  //           ),
  //         );
  //       }
  //     } else {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(
  //           content: Text('An error occurred: $e'),
  //         ),
  //       );
  //     }
  //   }
  //   return null;
  // }

  Future<void> signInWithGoogle(BuildContext context) async {
    // Google sign-in implementation
  }

  Future<void> signOutOfGoogle(BuildContext context) async {
    // Google sign-out implementation
  }
}
