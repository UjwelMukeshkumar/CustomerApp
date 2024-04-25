import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:firebase_auth/firebase_auth.dart';

import 'package:flutter/material.dart';

import 'package:lottie/lottie.dart';

import 'package:quickfillcustomer/color.dart';
import 'package:quickfillcustomer/loginPages/loginpage.dart';
import 'package:quickfillcustomer/pages/products.dart';
import 'package:quickfillcustomer/pages/trial.dart';
import 'package:quickfillcustomer/storeInfo.dart';

class splash extends StatefulWidget {
  const splash({super.key});

  @override
  State<splash> createState() => _splashState();
}

class _splashState extends State<splash> {
  FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  //final FirebaseAuth _auth = FirebaseAuth.instance;
  String? storeId; // To store the fetched storeId
  String? currentUserId; // Initialize with a default value
  Future<String>? storeNameFuture; // Future for fetching the store name

  @override
  void initState() {
    super.initState();
    _navigateToHome();
    //  storeNameFuture = getCurrentUser(); // Assigning Future to the variable
  }

  void _navigateToHome() async {
    await Future.delayed(Duration(seconds: 3)); // 3 seconds delay

    //   print("Constants.storeId is: ${Constants.storeId}"); // Debug print

    // Check the condition for Constants.storeId first
    //  if (Constants.storeId == 'test') {
    print("Navigating to TrialPage"); // Debug print
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => TrialPage()));
    return; // Return to prevent further execution
  }

  // Handle user authentication status
  // FirebaseAuth.instance.authStateChanges().first.then((user) async {
  //   if (user == null) {
  //     print("User is null, navigating to loginPage"); // Debug print
  //     Navigator.pushReplacement(context,
  //         MaterialPageRoute(builder: (context) => const loginPage()));
  //   } else {
  //     try {
  //       // Fetch user document from Firestore
  //       DocumentSnapshot userDoc = await FirebaseFirestore.instance
  //           .collection('customers')
  //           .doc(user.uid)
  //           .get();
  //       Map<String, dynamic>? data = userDoc.data() as Map<String, dynamic>?;
  //       bool? loginCompleted = data?['loginCompleted'];

  //       print("loginCompleted is: $loginCompleted"); // Debug print

  //       if (loginCompleted == true) {
  //         print("Navigating to productPage"); // Debug print
  //         Navigator.pushReplacement(context,
  //             MaterialPageRoute(builder: (context) => productPage()));
  //       } else {
  //         print(
  //             "Navigating to loginPage due to loginCompleted flag"); // Debug print
  //         Navigator.pushReplacement(
  //             context, MaterialPageRoute(builder: (context) => loginPage()));
  //       }
  //     } catch (e) {
  //       print("Error: $e"); // Debug print
  //     }
  //   }
  // });

  // Future<String> getCurrentUser() async {
  //   final user = firebaseAuth.currentUser;
  //   if (user == null) {
  //     print("User is not logged in.");
  //     return 'User not logged in';
  //   }

  //   try {
  //     DocumentSnapshot userDoc = await FirebaseFirestore.instance
  //         .collection('customers')
  //         .doc(user.uid)
  //         .get();

  //     if (!userDoc.exists || userDoc.data() == null) {
  //       print("User document does not exist or is empty.");
  //       return 'User document not found or empty';
  //     }

  //     var userData = userDoc.data() as Map<String, dynamic>;
  //     if (userData.containsKey('store_id')) {
  //       setState(() {
  //         currentUserId = user.uid;
  //         storeId = userData['store_id'] as String?;
  //         print("Current User ID: $currentUserId");
  //         print("Store ID: $storeId");
  //       });
  //       return getStoreName();
  //     } else {
  //       print("store_id field is missing in user document.");
  //       return 'store_id not found';
  //     }
  //   } catch (e) {
  //     print("Error fetching user data: $e");
  //     return 'Error fetching user data';
  //   }
  // }

  // Future<String> getStoreName() async {
  //   if (storeId == null) {
  //     print("Store ID is null");
  //     return 'No Store ID';
  //   }

  //   try {
  //     print("Fetching store name for storeId: $storeId");
  //     DocumentSnapshot storeDoc = await FirebaseFirestore.instance
  //         .collection('users')
  //         .doc(storeId)
  //         .get();

  //     if (!storeDoc.exists) {
  //       print("Document does not exist for storeId: $storeId");
  //       return 'No Store Name';
  //     }

  //     return storeDoc.get('storeName') as String? ?? 'No Store Name';
  //   } catch (e) {
  //     print("Error fetching store name: $e");
  //     return 'Error: $e';
  //   }
  // }

  // Future<Map<String, dynamic>?> getStoreName() async {
  //   if (storeId != null) {
  //     var docSnapshot = await FirebaseFirestore.instance
  //         .collection('users')
  //         .doc(storeId)
  //         .get();

  //     if (docSnapshot.exists) {
  //       return docSnapshot.data();
  //     }
  //   }
  //   return null;
  // }

  @override
  Widget build(BuildContext context) {
    final h = MediaQuery.of(context).size.height;
    final w = MediaQuery.of(context).size.width;
    return MediaQuery(
      data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
      child: Scaffold(
        backgroundColor: AppColors.primaryColor,
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // FutureBuilder<String>(
                //   future: getStoreName(),
                //   builder:
                //       (BuildContext context, AsyncSnapshot<String> snapshot) {
                //     if (snapshot.connectionState == ConnectionState.waiting) {
                //       return Center(
                //         child: Lottie.asset(
                //           'assets/loading.json', // Replace with your Lottie animation file path
                //           width: w * 0.15,
                //         ),
                //       );
                //     }

                //     if (snapshot.hasError) {
                //       return Text("Error: ${snapshot.error}");
                //     }

                //     // Directly use the string data from the snapshot
                //     String storeName = snapshot.data ?? 'No Store Name';

                //     return Text(
                //       storeName,
                //       style: TextStyle(
                //           color: AppColors.secondarytextColor,
                //           fontSize: w * 0.045,
                //           fontWeight: FontWeight.w500),
                //     );
                //   },
                // ),
              ],
            ),

            SizedBox(height: h * 0.5),

            Center(
              child: Image.asset(
                'assets/splashimage.png', // Lottie animation file path
                width: 200,
              ),
            ),
            Spacer(flex: 1),
            // Column(
            //   mainAxisAlignment: MainAxisAlignment.center,
            //   crossAxisAlignment: CrossAxisAlignment.start,
            //   children: [
            //     FutureBuilder<DocumentSnapshot>(
            //       future: getStoreName(),
            //       builder: (BuildContext context,
            //           AsyncSnapshot<DocumentSnapshot> snapshot) {
            //         if (snapshot.connectionState == ConnectionState.waiting) {
            //           return Center(
            //             child: Lottie.asset(
            //               'assets/loading.json', // Replace with your Lottie animation file path
            //               width: w * 0.15,
            //             ),
            //           );
            //         }

            //         if (snapshot.hasError) {
            //           return Text("Error: ${snapshot.error}");
            //         }

            //         var storeName = snapshot.data![
            //             'storeName']; // Replace 'storeName' with your field name

            //         return Text(
            //           storeName,
            //           style: TextStyle(
            //               color: AppColors.secondarytextColor,
            //               fontSize: w * 0.045,
            //               fontWeight: FontWeight.w500),
            //         );
            //       },
            //     ),
            //   ],
            // ),
          ],
        ),
      ),
    );
  }
}
