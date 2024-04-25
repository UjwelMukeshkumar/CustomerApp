// import 'package:cloud_firestore/cloud_firestore.dart';

// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';

// import 'package:lottie/lottie.dart';
// import 'package:quickfillcustomer/color.dart';
// import 'package:quickfillcustomer/loginPages/loginpage.dart';
// import 'package:quickfillcustomer/pages/products.dart';

// class splashtest extends StatefulWidget {
//   const splashtest({super.key});

//   @override
//   State<splashtest> createState() => _splashtestState();
// }

// class _splashtestState extends State<splashtest> {
//   @override
//   void initState() {
//     super.initState();
//     _navigateToHome();
//     getCurrentUser();

//     // Delay the navigation by 4 seconds
//   }

//   void _navigateToHome() async {
//     await Future.delayed(Duration(seconds: 3), () {}); // 3 seconds delay
//     // ignore: use_build_context_synchronously
//     Navigator.pushReplacement(
//       context,
//       MaterialPageRoute(
//         builder: (context) => StreamBuilder<User?>(
//           stream: FirebaseAuth.instance.authStateChanges(),
//           builder: (BuildContext context, AsyncSnapshot<User?> snapshot) {
//             if (snapshot.hasError) {
//               return Text(snapshot.error.toString());
//             }
//             if (snapshot.connectionState == ConnectionState.active) {
//               if (snapshot.data == null) {
//                 return const loginPage();
//               } else {
//                 final user = snapshot.data;
//                 return FutureBuilder<DocumentSnapshot>(
//                   future: FirebaseFirestore.instance
//                       .collection('customers')
//                       .doc(user!.uid)
//                       .get(),
//                   builder: (BuildContext context,
//                       AsyncSnapshot<DocumentSnapshot> snapshot) {
//                     if (snapshot.hasError) {
//                       return Text(snapshot.error.toString());
//                     }
//                     if (snapshot.connectionState == ConnectionState.done) {
//                       Map<String, dynamic>? data =
//                           snapshot.data?.data() as Map<String, dynamic>?;
//                       bool? loginCompleted;

//                       if (data != null && data.containsKey('loginCompleted')) {
//                         loginCompleted = data['loginCompleted'];
//                       }

//                       if (loginCompleted == true) {
//                         return productPage();
//                       } else if (loginCompleted == false) {
//                         return loginPage();
//                       } else {
//                         return const loginPage();
//                       }
//                     }
//                     return Center(
//                         child: Container(
//                       child: CircularProgressIndicator(
//                         color: Colors
//                             .red, // Set the color of the progress indicator
//                         strokeWidth:
//                             3.0, // Set the width of the progress indicator
//                         backgroundColor: AppColors
//                             .secondaryColor, // Set the background color of the progress indicator
//                         valueColor: AlwaysStoppedAnimation<Color>(
//                           AppColors.primaryColor,
//                         ), // Set the color of the progress indicator's value
//                       ),
//                     ));
//                   },
//                 );
//               }
//             }
//             return Center(
//               child: Lottie.asset(
//                 'assets/loading.json', // Replace with your Lottie animation file path
//                 width: 200,
//               ),
//             );
//           },
//         ),
//       ),
//     );
//   }

//   String? storeId; // To store the fetched storeId
//   String currentUserId = "";
//   final FirebaseAuth _auth = FirebaseAuth.instance;
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
//           storeId = userDoc.get('store_id') as String?;
//         });
//         // Call updateCartQuantity here to ensure it's done after currentUserId and storeId are set
//         if (storeId != null) {}
//       }
//     }
//   }

//   Future<DocumentSnapshot> getStoreName() {
//     return FirebaseFirestore.instance.collection('users').doc(storeId).get();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final h = MediaQuery.of(context).size.height;
//     final w = MediaQuery.of(context).size.width;
//     return MediaQuery(
//       data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
//       child: Scaffold(
//         backgroundColor: Colors.black,
//         body: Column(
//           crossAxisAlignment: CrossAxisAlignment.center,
//           children: [
//             Spacer(),
//             Spacer(),
//             Spacer(),
//             Spacer(),
//             Spacer(),
//             Spacer(),
//             Spacer(),
//             Spacer(),
//             Spacer(),
//             Spacer(),
//             Spacer(),
//             Spacer(),
//             Spacer(),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 FutureBuilder<DocumentSnapshot>(
//                   future: getStoreName(),
//                   builder: (BuildContext context,
//                       AsyncSnapshot<DocumentSnapshot> snapshot) {
//                     if (snapshot.connectionState == ConnectionState.waiting) {
//                       return Center(
//                         child: Lottie.asset(
//                           'assets/loading.json', // Replace with your Lottie animation file path
//                           width: w * 0.15,
//                         ),
//                       );
//                     }

//                     if (snapshot.hasError) {
//                       return Text("Error: ${snapshot.error}");
//                     }

//                     var storeLogo = snapshot.data![
//                         'storeLogo']; // Replace 'storeName' with your field name

//                     return Container(
//                         width: w * 0.22,
//                         child: Image.network(storeLogo, fit: BoxFit.cover));
//                   },
//                 ),
//                 SizedBox(
//                   width: w * 0.02,
//                 ),
//               ],
//             ),
//             SizedBox(
//               height: h * 0.02,
//             ),
//             Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 FutureBuilder<DocumentSnapshot>(
//                   future: getStoreName(),
//                   builder: (BuildContext context,
//                       AsyncSnapshot<DocumentSnapshot> snapshot) {
//                     if (snapshot.connectionState == ConnectionState.waiting) {
//                       return Center(
//                         child: Lottie.asset(
//                           'assets/loading.json', // Replace with your Lottie animation file path
//                           width: w * 0.15,
//                         ),
//                       );
//                     }

//                     if (snapshot.hasError) {
//                       return Text("Error: ${snapshot.error}");
//                     }

//                     var storeName = snapshot.data![
//                         'storeName']; // Replace 'storeName' with your field name

//                     return Text(
//                       storeName,
//                       style: TextStyle(
//                           color: AppColors.secondarytextColor,
//                           fontSize: w * 0.045,
//                           fontWeight: FontWeight.w500),
//                     );
//                   },
//                 ),
//               ],
//             ),
//             Spacer(),
//             Spacer(),
//             Center(
//               child: Lottie.asset(
//                 'assets/loading.json', // Replace with your Lottie animation file path
//                 width: 150,
//               ),
//             ),
//             Spacer(),
//           ],
//         ),
//       ),
//     );
//   }
// }
