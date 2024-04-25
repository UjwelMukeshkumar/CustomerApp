// import 'package:cloud_firestore/cloud_firestore.dart';

// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:fluttertoast/fluttertoast.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:lottie/lottie.dart';
// import 'package:quickfillcustomer/auth.dart';
// import 'package:quickfillcustomer/firebase_auth_implementation/firebase_auth_services.dart';
// import '../../color.dart';

// class loginPagetest extends StatefulWidget {
//   const loginPagetest({super.key});

//   @override
//   State<loginPagetest> createState() => _loginPagetestState();
// }

// class _loginPagetestState extends State<loginPagetest> {
//   AuthServices authServices = AuthServices();
//   bool _isLoading = false;
//   @override
//   void initState() {
//     super.initState();
//     getCurrentUser();
//   }

//   Future<void> _checkLocationPermissionAndSignIn() async {
//     setState(() {
//       _isLoading = true;
//     });

//     LocationPermission permission = await Geolocator.requestPermission();

//     if (permission == LocationPermission.always ||
//         permission == LocationPermission.whileInUse) {
//       try {
//         await authServices.signInWithGoogle(context);

//         // After successful sign-in
//         // You can navigate to the next page or perform other actions here.
//         // If you are showing a modal or bottom sheet for loading, you should close it here.
//       } catch (e) {
//         // If sign-in fails, show an error message
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Failed to sign in. Please try again later.')),
//         );
//       }
//     } else {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Location permission is required to proceed.')),
//       );
//     }

//     // Set isLoading to false regardless of the sign-in outcome.
//     if (!mounted) return;
//     setState(() {
//       _isLoading = false;
//     });
//   }

//   final FirebaseAuth _auth = FirebaseAuth.instance;
//   String? currentUserId;

//   String? storeId; // Change late to nullable

//   Future<void> getCurrentUser() async {
//     final user = _auth.currentUser;
//     if (user != null) {
//       DocumentSnapshot userDoc = await FirebaseFirestore.instance
//           .collection('customers')
//           .doc(user.uid)
//           .get();

//       if (userDoc.exists) {
//         setState(() {
//           currentUserId = user.uid;
//           storeId = userDoc.get('store_id');
//           print(storeId);
//         });
//       }
//     }
//   }

// // Revised getStoreName method
//   Future<DocumentSnapshot> getStoreName() async {
//     if (storeId != null) {
//       return FirebaseFirestore.instance.collection('users').doc(storeId).get();
//     }
//     throw Exception('Store ID is null');
//   }

//   @override
//   Widget build(BuildContext context) {
//     final double w = MediaQuery.of(context).size.width;
//     final double h = MediaQuery.of(context).size.height;

//     return MediaQuery(
//       data: MediaQuery.of(context)
//           .copyWith(textScaler: const TextScaler.linear(1.0)),
//       child: Scaffold(
//         body: SafeArea(
//           child: Column(
//             children: [
//               SizedBox(
//                 height: h * 0.07,
//               ),
//               Spacer(),
//               Spacer(),
//               Spacer(),
//               Spacer(),
//               Spacer(),
//               Spacer(),
//               Spacer(),
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   FutureBuilder<DocumentSnapshot>(
//                     future: getStoreName(),
//                     builder: (BuildContext context,
//                         AsyncSnapshot<DocumentSnapshot> snapshot) {
//                       if (snapshot.connectionState == ConnectionState.waiting) {
//                         return Center(child: CircularProgressIndicator());
//                       }

//                       if (snapshot.hasError) {
//                         return Text("Error: ${snapshot.error}");
//                       }

//                       if (snapshot.hasData && snapshot.data!.exists) {
//                         var storeName = snapshot.data?.get('storeName') ??
//                             'Unknown Store Name';
//                         // Use storeName safely...
//                         return Text(storeName);
//                       } else {
//                         return Text("Document does not exist");
//                       }
//                     },
//                   ),
//                   SizedBox(
//                     width: w * 0.02,
//                   ),
//                 ],
//               ),
//               SizedBox(
//                 height: h * 0.04,
//               ),
//               Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   FutureBuilder<DocumentSnapshot>(
//                     future: getStoreName(),
//                     builder: (BuildContext context,
//                         AsyncSnapshot<DocumentSnapshot> snapshot) {
//                       if (snapshot.connectionState == ConnectionState.waiting) {
//                         return Center(
//                           child: Lottie.asset(
//                             'assets/loading.json', // Replace with your Lottie animation file path
//                             width: w * 0.15,
//                           ),
//                         );
//                       }

//                       if (snapshot.hasError) {
//                         return Text("Error: ${snapshot.error}");
//                       }

//                       var storeName = snapshot.data![
//                           'storeName']; // Replace 'storeName' with your field name
//                       print(storeName);
//                       return Text(
//                         storeName,
//                         style: TextStyle(
//                             color: AppColors.secondarytextColor,
//                             fontSize: w * 0.045,
//                             fontWeight: FontWeight.w500),
//                       );
//                     },
//                   ),
//                 ],
//               ),
//               Spacer(),
//               Spacer(),
//               Spacer(),
//               SizedBox(
//                 height: h * 0.0363,
//               ),
//               Align(
//                 alignment: Alignment.topCenter,
//                 child: Container(
//                   width: w * 0.85,
//                   height: h * 0.07,
//                   decoration: BoxDecoration(
//                     borderRadius: BorderRadius.circular(10),
//                   ),
//                   child: ElevatedButton(
//                     onPressed: _isLoading
//                         ? null
//                         : () {
//                             _checkLocationPermissionAndSignIn();
//                           },
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: _isLoading
//                           ? Colors.black54
//                           : Colors.black, // Change color when loading
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(10),
//                       ),
//                     ),
//                     child: _isLoading
//                         ? Container(
//                             width: w * 0.045,
//                             height: h * 0.02,
//                             child: CircularProgressIndicator(
//                               color: Colors
//                                   .red, // Set the color of the progress indicator
//                               strokeWidth:
//                                   3.0, // Set the width of the progress indicator
//                               backgroundColor: AppColors
//                                   .secondaryColor, // Set the background color of the progress indicator
//                               valueColor: AlwaysStoppedAnimation<Color>(
//                                 AppColors.primaryColor,
//                               ), // Set the color of the progress indicator's value
//                             ),
//                           )
//                         : Row(
//                             mainAxisAlignment: MainAxisAlignment.center,
//                             children: [
//                               Text(
//                                 ' Sign In with Google',
//                                 style: GoogleFonts.inter(
//                                   color: AppColors.primaryColor,
//                                   fontSize: w * 0.04,
//                                   fontWeight: FontWeight.w300,
//                                 ),
//                               ),
//                               SizedBox(width: w * 0.04),
//                             ],
//                           ),
//                   ),
//                 ),
//               ),
//               Spacer(),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
