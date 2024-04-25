import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:quickfillcustomer/firebase_auth_implementation/firebase_auth_services.dart';

import 'package:quickfillcustomer/pages/addlist.dart';
import 'package:quickfillcustomer/storeInfo.dart';
import 'package:quickfillcustomer/toast.dart';

import '../../color.dart';

class loginPage extends StatefulWidget {
  const loginPage({super.key});

  @override
  State<loginPage> createState() => _loginPageState();
}

class _loginPageState extends State<loginPage> {
  bool _isSigning = false;
  bool isLoading = false;
  final AuthServices _auth = AuthServices();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
  }

  TextEditingController businessNameController = TextEditingController();
  TextEditingController businessAddressController = TextEditingController();
  TextEditingController phoneNumberController = TextEditingController();
  TextEditingController storeNameController = TextEditingController();

  String address = ''; // Define a variable to store the address
  String name = '';
  String phone = '';
  String storeName = '';

  String? _name;

  // @override
  // void initState() {
  //   super.initState();
  //   fetchAddress(); // Fetch the address when the widget initializes
  // }

  // Future<void> fetchAddress() async {
  //   try {
  //     String currentUserId = FirebaseAuth.instance.currentUser!.uid;

  //     DocumentSnapshot userDoc = await FirebaseFirestore.instance
  //         .collection('customers')
  //         .doc(currentUserId)
  //         .get();

  //     setState(() {
  //       phone = userDoc['phone'] ?? '';
  //     });

  //     // Populate text field controllers with fetched values

  //     phoneNumberController.text = phone;

  //     // Assuming 'phoneNumber' is the field name in the Firestore document
  //     phoneNumberController.text = userDoc['phoneNumber'] ?? '';
  //   } catch (e) {
  //     print('Error fetching address: $e');
  //     setState(() {
  //       address = 'Address not found';
  //       name = 'name not found';
  //     });
  //   }
  // }

  Future<DocumentSnapshot> getStoreName() {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(Constants.liveid)
        .get();
  }

  @override
  Widget build(BuildContext context) {
    final double w = MediaQuery.of(context).size.width;
    final double h = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Container(
          width: w,
          height: h,
          padding: EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              SizedBox(
                height: h * 0.08,
              ),
              Stack(
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
                    padding: EdgeInsets.only(top: 20, left: 30),
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
                    padding: EdgeInsets.only(left: 35, top: 5),
                    child: Transform.rotate(
                      angle: -0.4, //
                      child: Container(
                        width: w * 0.6,
                        height: h * 0.27,
                        child: Image.asset('assets/a1.png'),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: h * 0.08,
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
                    fontSize: 12,
                    color: Color(0xFF6A6A6A),
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox(
                height: h * 0.03,
              ),
              Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 27),
                    child: Container(
                      child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "Email id",
                            style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: AppColors.primarytextColor),
                          )),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 25, right: 25),
                    child: Container(
                      //color: AppColors.secondarytextColor,
                      decoration: BoxDecoration(
                        color: AppColors
                            .box, // Set the background color of the container to grey
                        borderRadius:
                            BorderRadius.circular(10), // Set border radius
                      ), // Se
                      child: TextField(
                        style: TextStyle(
                            color: AppColors
                                .secondarytextColor // Set text color to white
                            ),
                        controller: emailController,
                        decoration: InputDecoration(
                          labelText: " ",
                          hintText: "",
                          labelStyle: TextStyle(
                            color: AppColors
                                .secondarytextColor, // Set label text color to white
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(
                                color: AppColors
                                    .secondarytextColor), // White border
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(
                                color: AppColors
                                    .secondarytextColor), // White border when focused
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide:
                                BorderSide(color: AppColors.primaryColor),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: h * 0.02,
              ),
              Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 25),
                    child: Container(
                      child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "Password",
                            style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: AppColors.primarytextColor),
                          )),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 25, right: 25),
                    child: Container(
                      //color: AppColors.secondarytextColor,
                      decoration: BoxDecoration(
                        color: AppColors
                            .box, // Set the background color of the container to grey
                        borderRadius:
                            BorderRadius.circular(10), // Set border radius
                      ), // Se
                      child: TextField(
                        style: TextStyle(
                            color: AppColors
                                .secondarytextColor // Set text color to white
                            ),
                        controller: passwordController,
                        obscureText: true,
                        decoration: InputDecoration(
                          labelText: "",
                          hintText: "",
                          labelStyle: TextStyle(
                            color: AppColors
                                .secondarytextColor, // Set label text color to white
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(
                                color: AppColors
                                    .secondarytextColor), // White border
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(
                                color: AppColors
                                    .primaryColor), // White border when focused
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide:
                                BorderSide(color: AppColors.secondarytextColor),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: h * 0.02,
              ),
              Padding(
                padding: EdgeInsets.all(15),
                child: GestureDetector(
                  onTap: () {
                    _signin();
                  },
                  child: Container(
                    width: double.infinity,
                    height: 57,
                    decoration: BoxDecoration(
                      color: isLoading
                          ? AppColors.FirstColor
                          : AppColors.FirstColor,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Center(
                      child: isLoading
                          ? CircularProgressIndicator(
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            )
                          : Text(
                              "Login Now",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 20,
                              ),
                            ),
                    ),
                  ),
                  // InkWell(
                  //   onTap: () {
                  //     Navigator.pushNamed(context, '/Signpage');
                  //   },
                  //   child: Container(
                  //     height: h * 0.03,
                  //     decoration: BoxDecoration(),
                  //     child: Text("SignUp"),
                  //   ),
                  // )
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  void _signin() async {
    setState(() {
      isLoading = true;
      _isSigning = true;
    });
    await Future.delayed(Duration(seconds: 2));
    // Set isLoading to false to hide the circular progress indicator
    setState(() {
      isLoading = false;
    });
    String email = emailController.text;
    String password = passwordController.text;
    // String address = addressController.text;

    User? user =
        await _auth.signinWithEmailAndPassword(email, password, context);
    setState(() {
      _isSigning = false;
    });
    if (user != null) {
      showToast(message: "User is Sucessfuly Logged in");
      Navigator.pushNamedAndRemoveUntil(
          context, 'sucessPage', (route) => false);
    } else {
      //  showToast(message: "An error OCCUred");
    }
  }
}

class LeftCurvedClipper extends CustomClipper<RRect> {
  @override
  RRect getClip(Size size) {
    return RRect.fromLTRBAndCorners(
      10, // left
      20, // top
      size.width, // right
      size.height, // bottom
      topLeft: Radius.circular(10), // Adjust the radius as needed
      bottomLeft: Radius.circular(10), // Adjust the radius as needed
    );
  }

  @override
  bool shouldReclip(CustomClipper<RRect> oldClipper) => false;
}
