import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:google_fonts/google_fonts.dart';

import 'package:quickfillcustomer/firebase_auth_implementation/firebase_auth_services.dart';

import '../../color.dart';

class TrialPage extends StatefulWidget {
  final String? storeId;

  const TrialPage({Key? key, this.storeId}) : super(key: key);

  @override
  _TrialPageState createState() => _TrialPageState();
}

class _TrialPageState extends State<TrialPage> {
  @override
  void initState() {
    super.initState();
  }

  TextEditingController newid = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  final AuthServices _auth = AuthServices();

  @override
  Widget build(BuildContext context) {
    final double w = MediaQuery.of(context).size.width;
    final double h = MediaQuery.of(context).size.height;

    // print('storeIdFromStoreInfoPage: $storeIdFromStoreInfoPage');

    return MediaQuery(
      data: MediaQuery.of(context)
          .copyWith(textScaler: const TextScaler.linear(1.0)),
      child: Scaffold(
          backgroundColor: Colors.white,
          body: SafeArea(
            child: Column(
              children: [
                SizedBox(
                  height: h * 0.2,
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 140),
                  child: Stack(
                    children: [
                      Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Transform.rotate(
                          angle: -0.4, // Adjust the angle as needed
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: Container(
                              width: w * 0.6,
                              height: h * 0.25,
                              color: AppColors
                                  .FirstColor, // Example color, you can change it
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: 20, left: 40),
                        child: Transform.rotate(
                          angle: -0.4, // Adjust the angle as needed
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: Container(
                                width: w * 0.6,
                                height: h * 0.25,
                                color: AppColors.secoundColor),
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(left: 30, top: 5),
                        child: Transform.rotate(
                          angle: -0.4, //
                          child: Container(
                            width: w * 0.6,
                            height: h * 0.28,
                            child: Image.asset('assets/a1.png'),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: h * 0.04,
                ),
                Container(
                  padding: EdgeInsets.all(10),
                  child: Text(
                    'Filling inventories in\n record time',
                    style: TextStyle(
                      color: AppColors.primarytextColor,
                      fontWeight: FontWeight.w500,
                      fontSize: 18,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(10),
                  child: Text(
                    'Record inventory restocking with technology',
                    style: TextStyle(
                        fontSize: 15, color: AppColors.thirdtextColor),
                    textAlign: TextAlign.center,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(30, 0, 30, 0),
                  // child: TextField(
                  //   controller: newid,
                  //   decoration: InputDecoration(
                  //     labelText: 'Secret Code',
                  //   ),
                  // ),
                ),
                // SizedBox(height: h * 0.18),
                Align(
                  alignment: Alignment.topCenter,
                  child: Container(
                    width: w * 0.85,
                    height: h * 0.07,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: ElevatedButton(
                      onPressed: _isLoading
                          ? null
                          : () async {
                              Navigator.pushNamed(context, 'loginPage');
                              // // Call signinWithEmailAndPassword method with email and password
                              // await firebaseAuth.signInWithEmailAndPassword(
                              //     email: emailController.text,
                              //     password: passwordController.text);
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.FirstColor,
                        // primary: _isLoading
                        //     ? Colors.black54
                        //     : AppColors.cardColor, // Change color when loading
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Container(
                        width: double.infinity,
                        height: 45,
                        decoration: BoxDecoration(
                            color: AppColors.FirstColor,
                            borderRadius: BorderRadius.circular(10)),
                        child: Center(
                          child: Text(
                            "Continue",
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w400,
                                fontSize: 23),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Spacer(),
              ],
            ),
          )),
    );
  }

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
        //   If the document does not exist, create it
        if (!userDoc.exists) {
          await FirebaseFirestore.instance
              .collection('customers')
              .doc(user.uid)
              .set({
            'name': user.displayName,
            'cus_id': user.uid,
            'email': user.email,
            'photoURL': photoURL,
            'phone': user.phoneNumber,
            'address': Address,
            'store_id': newid.text,
            'loginCompleted':
                false, // Update 'loginCompleted' to true upon successful login
            'paid': false,
            'trial': false,
          });
        }

        bool loginCompleted =
            userDoc.exists ? userDoc['loginCompleted'] : false;
        if (loginCompleted == false) {
          // ignore: use_build_context_synchronously
          showModalBottomSheet(
            isScrollControlled: true,
            context: context,
            builder: (context) {
              final h = MediaQuery.of(context).size.height;
              final w = MediaQuery.of(context).size.width;

              return Padding(
                padding: MediaQuery.of(context).viewInsets,
                child: Container(
                  color: Colors.transparent,
                  height: h * 0.33,
                  width: w * 0.95,
                  child: ClipRRect(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20.0),
                      topRight: Radius.circular(20.0),
                    ),
                    child: Container(
                      color: AppColors
                          .cardColor, // Set the desired background color
                      // Your bottom sheet UI goes here
                      child: Column(
                        children: [
                          SizedBox(
                            height: h * 0.05,
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 48.0),
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: RichText(
                                text: TextSpan(
                                  children: <TextSpan>[
                                    TextSpan(
                                      text: 'Your \n',
                                      style: TextStyle(
                                          fontWeight: FontWeight.w500,
                                          fontSize: w * 0.065,
                                          color: AppColors.primaryColor),
                                    ),
                                    TextSpan(
                                      text: 'Phoned number',
                                      style: TextStyle(
                                          fontWeight: FontWeight.w500,
                                          fontSize: w * 0.065,
                                          color: AppColors.secondaryColor),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          SizedBox(
                            height: h * 0.02,
                          ),
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(6),
                              color: AppColors.fourthtextColor,
                              border: Border.all(
                                color: AppColors.secondaryColor,
                              ),
                            ),
                            width: w * 0.7,
                            child: Padding(
                              padding: EdgeInsets.only(left: w * 0.03),
                              child: TextField(
                                keyboardType: TextInputType.number,
                                controller: addressController,
                                style: TextStyle(
                                  fontSize: w * 0.05,
                                  color: AppColors
                                      .thirdtextColor, // Set the text color to your primary color
                                ),
                                decoration: InputDecoration(
                                  border: InputBorder.none,
                                  hintText: '  phone no here',
                                  hintStyle: TextStyle(
                                      color: AppColors.secondarytextColor,
                                      fontSize: w * 0.04,
                                      fontWeight: FontWeight.w300),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(
                            height: h * 0.015,
                          ),
                          Padding(
                            padding: const EdgeInsets.all(5),
                            child: Container(
                              width: w * 0.7,
                              height: h * 0.07,
                              decoration: BoxDecoration(
                                borderRadius:
                                    BorderRadius.circular(10), // small curve
                              ),
                              child: ElevatedButton(
                                onPressed: () {
                                  String currentUserId =
                                      FirebaseAuth.instance.currentUser!.uid;

                                  // Save the data to Firestore under the current user's document
                                  FirebaseFirestore.instance
                                      .collection('customers')
                                      .doc(currentUserId)
                                      .set({
                                    'phone': addressController.text,
                                    'loginCompleted': true,
                                    // Add more fields as needed
                                    // For example, store the image URL if the image is uploaded to storage
                                  }, SetOptions(merge: true));

                                  Navigator.pushNamedAndRemoveUntil(
                                      context, 'productPage', (route) => false);
                                },
                                style: ElevatedButton.styleFrom(
                                  // primary: AppColors
                                  //     .secondaryColor, // background color
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                        100), // small curve
                                  ),
                                ),
                                child: Text(
                                  'Confirm',
                                  style: GoogleFonts.inter(
                                    color: AppColors.primaryColor,
                                    fontSize: w * 0.06,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        }
      } else {
        Navigator.pushNamedAndRemoveUntil(
            context, 'productPage', (route) => false);
      }
      //   }
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
  //     } else {
  //       Navigator.pushNamedAndRemoveUntil(
  //           context, 'productPage', (route) => false);
  //     }
  //   }

  //   // Continue with the user-credential processing...
  // } catch (e) {
  //   final snackBar = SnackBar(content: Text('Error: $e'));
  //   ScaffoldMessenger.of(context).showSnackBar(snackBar);
  // } finally {
  //   setState(() {
  //     _isLoading = false;
  //   });
  // }
}

// Future<bool> checkLocationServicesAndRequestPermission() async {
//   bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
//   if (!serviceEnabled) {
//     return false; // Location services are not enabled
//   }

//   LocationPermission permission = await Geolocator.checkPermission();
//   if (permission == LocationPermission.denied) {
//     permission = await Geolocator.requestPermission();
//     if (permission == LocationPermission.denied) {
//       return false; // Permissions are denied
//     }
//   }

//   if (permission == LocationPermission.deniedForever) {
//     return false; // Permissions are permanently denied
//   }

//   // Permissions are granted
//   return true;
// }

TextEditingController phoneNumberController = TextEditingController();
TextEditingController addressController = TextEditingController();
bool _isLoading = false;
