import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:quickfillcustomer/color.dart';

class orderPage extends StatefulWidget {
  @override
  _orderPageState createState() => _orderPageState();
}

class _orderPageState extends State<orderPage> {
  final Stream<QuerySnapshot> products =
      FirebaseFirestore.instance.collection('orders').snapshots();

  final FirebaseAuth _auth = FirebaseAuth.instance;

  late String currentUserId; // Variable to hold current user ID

  @override
  void initState() {
    super.initState();
    getCurrentUser();
  }

  void getCurrentUser() async {
    final user = _auth.currentUser;
    if (user != null) {
      setState(() {
        currentUserId = user.uid; // Assign the current user's UID
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final double w = MediaQuery.of(context).size.width;
    final double h = MediaQuery.of(context).size.height;
    return MediaQuery(
      data: MediaQuery.of(context)
          .copyWith(textScaler: const TextScaler.linear(1.0)),
      child: Scaffold(
        backgroundColor: AppColors.primaryColor,
        appBar: AppBar(
          backgroundColor: AppColors.primaryColor, // Adjust as needed
          leading: IconButton(
            icon: Icon(Icons.arrow_back,
                color: AppColors.thirdtextColor), // Change icon color as needed
            onPressed: () {
              Navigator.pop(context); // Go back to previous screen
            },
          ),
          title: Text("Orders List",
              style: TextStyle(
                  color:
                      AppColors.thirdtextColor)), // Change text style as needed
        ),
        body: SafeArea(
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('orders')
                .where('user_id',
                    isEqualTo: currentUserId) // Modify here for your field name
                .orderBy('orderNo', descending: true) // Modify this line
                .snapshots(),
            builder:
                (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              }

              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                  child: Center(
                    child: Lottie.asset(
                      'assets/loading.json', // Replace with your Lottie animation file path
                      width: 200,
                    ),
                  ),
                );
              }

              return ListView(
                children: snapshot.data!.docs.isEmpty
                    ? [
                        Column(
                          children: [
                            SizedBox(
                              height: h * 0.2,
                            ),
                            Center(
                              child: Lottie.asset(
                                'assets/product.json',
                                width: w * 0.8,
                              ),
                            ),
                            Text(
                              "No Orders Available",
                              style: TextStyle(
                                  fontSize: w * 0.05,
                                  color: AppColors.primaryColor),
                            )
                          ],
                        ),
                      ]
                    : snapshot.data!.docs.map((DocumentSnapshot document) {
                        Map<String, dynamic> data =
                            document.data() as Map<String, dynamic>;
                        return ListTile(
                          title: InkWell(
                            onTap: () {
                              String status = data['status'];
                              if (status == 'CANCELLED') {
                                Navigator.pushNamed(
                                  context,
                                  'orderCancel',
                                  arguments: {
                                    'data': data,
                                    'docId': document.id,
                                    'products': data['products'],
                                  },
                                );
                              } else if (status == 'CONFIRMED') {
                                Navigator.pushNamed(
                                  context,
                                  'orderView',
                                  arguments: {
                                    'data': data,
                                    'docId': document.id,
                                    'products': data['products'],
                                  },
                                );
                              } else if (status == 'DELIVERED') {
                                Navigator.pushNamed(
                                  context,
                                  'orderDeliver',
                                  arguments: {
                                    'data': data,
                                    'docId': document.id,
                                    'products': data['products'],
                                  },
                                );
                              } else if (status == 'SHIPPED') {
                                Navigator.pushNamed(
                                  context,
                                  'orderShip',
                                  arguments: {
                                    'data': data,
                                    'docId': document.id,
                                    'products': data['products'],
                                  },
                                );
                              }
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(9),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black12,

                                    // changes position of shadow
                                  ),
                                ],
                                border: Border.all(
                                  color: Colors.white.withOpacity(
                                      0.08), // replace with your desired border color
                                  width:
                                      0.5, // replace with your desired border width
                                ),
                              ),
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Padding(
                                        padding: EdgeInsets.only(
                                            left: w * 0.05,
                                            top: h * 0.02,
                                            bottom: h * 0.005),
                                        child: Text(
                                          'Order #0${data['orderNo'] ?? 'No orders Available'}',
                                          style: GoogleFonts.inter(
                                            fontSize: w * 0.045,
                                            fontWeight: FontWeight.w300,
                                            color: AppColors.thirdtextColor,
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: EdgeInsets.only(
                                            right: w * 0.055,
                                            top: h * 0.02,
                                            bottom: h * 0.005),
                                        child: Text(
                                          '${data['date'] ?? 'No date Available'}',
                                          overflow: TextOverflow.ellipsis,
                                          style: GoogleFonts.inter(
                                            fontWeight: FontWeight.w300,
                                            color: AppColors.thirdtextColor,
                                            fontSize: w * 0.035,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  Center(
                                    child: Container(
                                        width: w * 0.75,
                                        child: Image.asset('assets/line.png')),
                                  ),
                                  Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Padding(
                                          padding: EdgeInsets.only(
                                            left: w * 0.05,
                                            bottom: h * 0.02,
                                            top: h * 0.005,
                                          ),
                                          child: Container(
                                            decoration: BoxDecoration(
                                              color: Colors
                                                  .black, // Replace with your desired color
                                              borderRadius: BorderRadius.circular(
                                                  100), // Replace with your desired border radius
                                            ),
                                            width: w * 0.25,
                                            height: h * 0.03,
                                            child: Center(
                                              child: Text(
                                                '${data['status'] ?? 'No status Available'}',
                                                style: TextStyle(
                                                  fontSize: w * 0.027,
                                                  color: data['status'] ==
                                                          'DELIVERED'
                                                      ? AppColors.deliverColor
                                                      : data['status'] ==
                                                              'SHIPPED'
                                                          ? AppColors.shipColor
                                                          : data['status'] ==
                                                                  'CONFIRMED'
                                                              ? AppColors
                                                                  .primaryColor
                                                              : data['status'] ==
                                                                      'CANCELLED'
                                                                  ? AppColors
                                                                      .secondaryColor
                                                                  : Colors
                                                                      .black,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        Padding(
                                          padding: EdgeInsets.only(
                                              right: w * 0.06,
                                              bottom: h * 0.025,
                                              top: h * 0.009),
                                          child: RichText(
                                            text: TextSpan(
                                              text:
                                                  '${data['totalItems'] ?? 'No items Available'}',
                                              style: GoogleFonts.inter(
                                                fontSize: w * 0.05,
                                                fontWeight: FontWeight.w700,
                                                color: AppColors.thirdtextColor,
                                              ),
                                              children: [
                                                TextSpan(
                                                  text: ' items',
                                                  style: GoogleFonts.inter(
                                                    fontSize: w * 0.03,
                                                    fontWeight: FontWeight.w300,
                                                    color: AppColors
                                                        .thirdtextColor,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ])
                                ],
                              ),
                            ),
                          ),
                          // subtitle: Text('ID: ${document.id}'),
                        );
                      }).toList(),
              );
            },
          ),
        ),
      ),
    );
  }
}
