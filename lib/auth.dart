// import 'package:cloud_firestore/cloud_firestore.dart';

// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:fluttertoast/fluttertoast.dart';
// import 'package:geocoding/geocoding.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:google_fonts/google_fonts.dart';

// import 'package:google_sign_in/google_sign_in.dart';
// import 'package:quickfillcustomer/color.dart';
// import 'package:quickfillcustomer/storeInfo.dart';

// class AuthServices {
//   GoogleSignIn googleSignIn = GoogleSignIn();
//   FirebaseAuth firebaseAuth = FirebaseAuth.instance;

//   String location = 'Null, Press Button';
//   // ignore: non_constant_identifier_names
//   String Address = 'search';

//   // ignore: non_constant_identifier_names
//   Future<void> GetAddressFromLatLong(Position position) async {
//     List<Placemark> placemarks =
//         await placemarkFromCoordinates(position.latitude, position.longitude);

//     Placemark place = placemarks[0];
//     Address =
//         '${place.street}, ${place.subLocality}, ${place.locality}, ${place.postalCode}, ${place.country}';
//   }

//   //exact accuarcy
//   Future<Position> getGeoLocationPosition() async {
//     return await Geolocator.getCurrentPosition(
//         desiredAccuracy: LocationAccuracy.best);
//   }
//   //till here

//   Future<void> signInWithGoogle(BuildContext context) async {
//     try {
//       GoogleSignInAccount? googleSignInAccount = await googleSignIn.signIn();
//       if (googleSignInAccount != null) {
//         GoogleSignInAuthentication googleSignInAuthentication =
//             await googleSignInAccount.authentication;
//         AuthCredential credential = GoogleAuthProvider.credential(
//           idToken: googleSignInAuthentication.idToken,
//           accessToken: googleSignInAuthentication.accessToken,
//         );
//         UserCredential userCredential =
//             await firebaseAuth.signInWithCredential(credential);
//         User? user = userCredential.user;

//         if (user != null) {
//           // Get the user's location and address
//           Position position = await getGeoLocationPosition();
//           await GetAddressFromLatLong(position);

//           String photoURL = user.photoURL ??
//               'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTf6_jeCeVDiMDqJ9DIobNO3Uu4EppEmf-64fuSwh5KAGeYYt3PoSM03rPUNjIuAeD5XXY&usqp=CAU';

//           // Check if the user's document already exists
//           DocumentSnapshot userDoc = await FirebaseFirestore.instance
//               .collection('customers')
//               .doc(user.uid)
//               .get();

//           // If the document does not exist, create it
//           if (!userDoc.exists) {
//             await FirebaseFirestore.instance
//                 .collection('customers')
//                 .doc(user.uid)
//                 .set({
//               'name': user.displayName,
//               'cus_id': user.uid,
//               'email': user.email,
//               'photoURL': photoURL,
//               'phone': user.phoneNumber,
//               'address': Address,
//               'store_id': Constants.liveid,
//               'loginCompleted':
//                   false, // Update 'loginCompleted' to true upon successful login
//               'paid': false,
//               'trial': false,
//             });
//           }

//           bool loginCompleted =
//               userDoc.exists ? userDoc['loginCompleted'] : false;
//           if (loginCompleted == false) {
//             // ignore: use_build_context_synchronously
//             showModalBottomSheet(
//               isScrollControlled: true,
//               context: context,
//               builder: (context) {
//                 final h = MediaQuery.of(context).size.height;
//                 final w = MediaQuery.of(context).size.width;

//                 return Padding(
//                   padding: MediaQuery.of(context).viewInsets,
//                   child: Container(
//                     color: Colors.transparent,
//                     height: h * 0.33,
//                     width: w * 0.95,
//                     child: ClipRRect(
//                       borderRadius: BorderRadius.only(
//                         topLeft: Radius.circular(20.0),
//                         topRight: Radius.circular(20.0),
//                       ),
//                       child: Container(
//                         color: Colors.black, // Set the desired background color
//                         // Your bottom sheet UI goes here
//                         child: Column(
//                           children: [
//                             SizedBox(
//                               height: h * 0.05,
//                             ),
//                             Padding(
//                               padding: const EdgeInsets.only(left: 48.0),
//                               child: Align(
//                                 alignment: Alignment.centerLeft,
//                                 child: RichText(
//                                   text: TextSpan(
//                                     children: <TextSpan>[
//                                       TextSpan(
//                                         text: 'Your \n',
//                                         style: TextStyle(
//                                             fontWeight: FontWeight.w500,
//                                             fontSize: w * 0.065,
//                                             color: AppColors.primaryColor),
//                                       ),
//                                       TextSpan(
//                                         text: 'Phoned number',
//                                         style: TextStyle(
//                                             fontWeight: FontWeight.w500,
//                                             fontSize: w * 0.065,
//                                             color: AppColors.secondaryColor),
//                                       ),
//                                     ],
//                                   ),
//                                 ),
//                               ),
//                             ),
//                             SizedBox(
//                               height: h * 0.02,
//                             ),
//                             Container(
//                               decoration: BoxDecoration(
//                                 borderRadius: BorderRadius.circular(6),
//                                 color: AppColors.fourthtextColor,
//                                 border: Border.all(
//                                   color: AppColors.secondaryColor,
//                                 ),
//                               ),
//                               width: w * 0.7,
//                               child: Padding(
//                                 padding: EdgeInsets.only(left: w * 0.03),
//                                 child: TextField(
//                                   keyboardType: TextInputType.number,
//                                   controller: phoneNumberController,
//                                   style: TextStyle(
//                                     fontSize: w * 0.05,
//                                     color: AppColors
//                                         .thirdtextColor, // Set the text color to your primary color
//                                   ),
//                                   decoration: InputDecoration(
//                                     border: InputBorder.none,
//                                     hintText: '  phone no here',
//                                     hintStyle: TextStyle(
//                                         color: AppColors.secondarytextColor,
//                                         fontSize: w * 0.04,
//                                         fontWeight: FontWeight.w300),
//                                   ),
//                                 ),
//                               ),
//                             ),
//                             SizedBox(
//                               height: h * 0.015,
//                             ),
//                             Padding(
//                               padding: const EdgeInsets.all(5),
//                               child: Container(
//                                 width: w * 0.7,
//                                 height: h * 0.07,
//                                 decoration: BoxDecoration(
//                                   borderRadius:
//                                       BorderRadius.circular(10), // small curve
//                                 ),
//                                 child: ElevatedButton(
//                                   onPressed: () {
//                                     String currentUserId =
//                                         FirebaseAuth.instance.currentUser!.uid;

//                                     // Save the data to Firestore under the current user's document
//                                     FirebaseFirestore.instance
//                                         .collection('customers')
//                                         .doc(currentUserId)
//                                         .set({
//                                       'phone': phoneNumberController.text,
//                                       'loginCompleted': true,
//                                       // Add more fields as needed
//                                       // For example, store the image URL if the image is uploaded to storage
//                                     }, SetOptions(merge: true));

//                                     Navigator.pushNamedAndRemoveUntil(context,
//                                         'productPage', (route) => false);
//                                   },
//                                   style: ElevatedButton.styleFrom(
//                                     backgroundColor: AppColors
//                                         .secondaryColor, // background color
//                                     shape: RoundedRectangleBorder(
//                                       borderRadius: BorderRadius.circular(
//                                           100), // small curve
//                                     ),
//                                   ),
//                                   child: Text(
//                                     'Confirm',
//                                     style: GoogleFonts.inter(
//                                       color: AppColors.primaryColor,
//                                       fontSize: w * 0.06,
//                                       fontWeight: FontWeight.w600,
//                                     ),
//                                   ),
//                                 ),
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//                   ),
//                 );
//               },
//             );
//             ;
//           } else {
//             Navigator.pushNamedAndRemoveUntil(
//                 context, 'productPage', (route) => false);
//           }
//         }
//       } else {
//         const snackBar =
//             SnackBar(content: Text('Error signing in with Google'));
//         ScaffoldMessenger.of(context).showSnackBar(snackBar);
//       }
//     } catch (e) {
//       final snackBar = SnackBar(content: Text('$e'));
//       // ignore: use_build_context_synchronously
//       ScaffoldMessenger.of(context).showSnackBar(snackBar);
//     }
//   }

//   TextEditingController phoneNumberController = TextEditingController();

//   Future<void> signOutOfGoogle(BuildContext context) async {
//     try {
//       googleSignIn.signOut();
//       firebaseAuth.signOut();
//       Navigator.pushNamedAndRemoveUntil(context, 'loginPage', (route) => false);
//     } catch (e) {
//       final snackBar = SnackBar(content: Text('$e'));
//       ScaffoldMessenger.of(context).showSnackBar(snackBar);
//     }
//   }

//   void _showToast() {
//     Fluttertoast.showToast(
//       msg: 'Please fill in all the details.',
//       toastLength: Toast.LENGTH_SHORT,
//       gravity: ToastGravity.BOTTOM,
//       timeInSecForIosWeb: 1,
//       backgroundColor: Colors.black,
//       textColor: Colors.white,
//       fontSize: 16.0,
//     );
//   }
// }
