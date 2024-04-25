import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:quickfillcustomer/color.dart';

class orderView extends StatefulWidget {
  final Map<String, dynamic> data;

  final String docId;
  const orderView({
    Key? key,
    required this.data,
    required this.docId,
  }) : super(key: key);

  @override
  State<orderView> createState() => _orderViewState();
}

class _orderViewState extends State<orderView> {
  late String docId;

  /// Prints the document ID.

  late List<dynamic> products = widget.data['products'];

  late int orderNo = widget.data['orderNo'];
  late String userPhone = widget.data['userPhone'];
  late String userName = widget.data['userName'];
  late String status = widget.data['status'];
  late int totalItems = widget.data['totalItems'];
  late String date = widget.data['date'];
  late String userAddress = widget.data['userAddress'];
  // late int totalPrice = widget.data['totalPrice'];
  late int totalPrice = (widget.data['totalPrice'] is double)
      ? (widget.data['totalPrice'] as double).toInt()
      : widget.data['totalPrice'];
  late int grandTotal = (widget.data['grandTotal'] is double)
      ? (widget.data['grandTotal'] as double).toInt()
      : widget.data['grandTotal'];
  late int shippingCharge = (widget.data['shippingCharge'] is double)
      ? (widget.data['shippingCharge'] as double).toInt()
      : widget.data['shippingCharge'];
  TextEditingController shipName = TextEditingController();
  TextEditingController shipLink = TextEditingController();
  TextEditingController shipId = TextEditingController();
// Declare docId as a class-level variable

  @override
  void initState() {
    super.initState();
    docId = widget.docId; // Assign widget's docId to the state's docId
  }

  Future<void> updateStatusToCancelled(String docId) async {
    try {
      await FirebaseFirestore.instance
          .collection('orders')
          .doc(docId)
          .update({'status': 'CANCELLED'});
    } catch (e) {
      print('Failed to update order status: $e');
      // Handle the error as appropriate for your application
    }
  }

  Future<void> addShipping(
      String docId, String name, String link, String trackingId) async {
    try {
      await FirebaseFirestore.instance.collection('orders').doc(docId).update({
        'shipName': name,
        'shipLink': link,
        'shipId': trackingId,
        'status': 'SHIPPED', // Assuming you want to update the status here
        'shipped_at': FieldValue.serverTimestamp(), // Timestamp for shipping
      });
    } catch (e) {
      print('Failed to update shipping details: $e');
      // Handle the error as appropriate for your application
    }
  }

  bool showCancel = false;

  void onPressedAction() {
    setState(() {
      showCancel = !showCancel;
    });
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
        body: SafeArea(
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color:
                            const Color.fromARGB(255, 0, 0, 0).withOpacity(0.1),
                        spreadRadius: 2,
                        blurRadius: 1,
                        offset: Offset(0, 3), // changes position of shadow
                      ),
                    ],
                    border: Border.all(
                      color: Colors.white.withOpacity(
                          0.08), // replace with your desired border color
                      width: 0.5, // replace with your desired border width
                    ),
                  ),
                  child: Column(
                    children: [
                      Padding(
                        padding: EdgeInsets.only(
                            left: w * 0.06,
                            top: h * 0.03,
                            bottom: h * 0.015,
                            right: w * 0.06),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Order #0$orderNo',
                              style: GoogleFonts.inter(
                                fontSize: w * 0.05,
                                fontWeight: FontWeight.w300,
                                color: AppColors.primaryColor,
                              ),
                            ),
                            Container(
                              decoration: BoxDecoration(
                                color: Colors
                                    .black, // Replace with your desired color
                                borderRadius: BorderRadius.circular(100),
                                border: Border.all(
                                  color: Colors.white, // Border color
                                  width: w * 0.0005, // Border width
                                ),
                              ),
                              width: w * 0.25,
                              height: h * 0.03,
                              child: Center(
                                child: Text(
                                  status,
                                  style: TextStyle(
                                    fontSize: w * 0.027,
                                    color: status == 'DELIVERED'
                                        ? AppColors.deliverColor
                                        : status == 'SHIPPED'
                                            ? AppColors.shipColor
                                            : status == 'CONFIRMED'
                                                ? AppColors.primaryColor
                                                : status == 'CANCELLED'
                                                    ? AppColors.secondaryColor
                                                    : Colors.black,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Center(
                        child: Container(
                            width: w * 0.75,
                            child: Image.asset('assets/line.png')),
                      ),
                      Padding(
                        padding: EdgeInsets.only(
                            top: h * 0.01, right: w * 0.08, left: w * 0.06),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            RichText(
                              text: TextSpan(
                                text: totalItems.toString(),
                                style: GoogleFonts.inter(
                                  fontSize: w * 0.045,
                                  fontWeight: FontWeight.w300,
                                  color: AppColors.secondaryColor,
                                ),
                                children: [
                                  TextSpan(
                                    text: ' items',
                                    style: GoogleFonts.inter(
                                      fontSize: w * 0.035,
                                      fontWeight: FontWeight.w300,
                                      color: AppColors.primaryColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            RichText(
                              text: TextSpan(
                                text: ' | ',
                                style: GoogleFonts.inter(
                                  fontSize: w * 0.035,
                                  fontWeight: FontWeight.w300,
                                  color: AppColors.primaryColor,
                                ),
                                children: [
                                  TextSpan(
                                    text: date,
                                    style: GoogleFonts.inter(
                                      fontSize: w * 0.03,
                                      fontWeight: FontWeight.w300,
                                      color: AppColors.secondaryColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(
                            left: w * 0.06,
                            top: h * 0.003,
                            bottom: h * 0.01,
                            right: w * 0.07),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "Address",
                            style: GoogleFonts.inter(
                              fontSize: w * 0.045,
                              fontWeight: FontWeight.w500,
                              color: AppColors.primaryColor,
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(
                            left: w * 0.06, bottom: h * 0.005, right: w * 0.07),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            userAddress,
                            style: GoogleFonts.inter(
                              height: h * 0.0022,
                              fontSize: w * 0.035,
                              fontWeight: FontWeight.w300,
                              color: AppColors.secondarytextColor,
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(
                            bottom: h * 0.005, right: w * 0.07, left: w * 0.06),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "Contact Name : " + userName,
                            style: GoogleFonts.inter(
                              fontSize: w * 0.035,
                              fontWeight: FontWeight.w300,
                              color: AppColors.primaryColor,
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(
                            bottom: h * 0.02, right: w * 0.07, left: w * 0.06),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "Contact Number : +91 " + userPhone,
                            style: GoogleFonts.inter(
                              fontSize: w * 0.035,
                              fontWeight: FontWeight.w300,
                              color: AppColors.primaryColor,
                            ),
                          ),
                        ),
                      ),
                      Center(
                        child: Container(
                            width: w * 0.8,
                            child: Image.asset('assets/line.png')),
                      ),
                      Expanded(
                        child: SingleChildScrollView(
                          child: Column(children: [
                            Padding(
                              padding: EdgeInsets.only(
                                  left: w * 0.06,
                                  bottom: h * 0.006,
                                  top: h * 0.015,
                                  right: w * 0.07),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "item Total",
                                    style: GoogleFonts.inter(
                                      fontSize: w * 0.035,
                                      fontWeight: FontWeight.w300,
                                      color: AppColors.secondarytextColor,
                                    ),
                                  ),
                                  Text(
                                    "₹ " + totalPrice.toString(),
                                    style: GoogleFonts.inter(
                                      fontSize: w * 0.035,
                                      fontWeight: FontWeight.w300,
                                      color: AppColors.secondarytextColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.only(
                                  left: w * 0.06,
                                  bottom: h * 0.015,
                                  right: w * 0.07),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "Delivery",
                                    style: GoogleFonts.inter(
                                      fontSize: w * 0.035,
                                      fontWeight: FontWeight.w300,
                                      color: AppColors.secondarytextColor,
                                    ),
                                  ),
                                  Text(
                                    "₹ " + shippingCharge.toString(),
                                    style: GoogleFonts.inter(
                                      fontSize: w * 0.035,
                                      fontWeight: FontWeight.w300,
                                      color: AppColors.secondarytextColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Center(
                              child: Container(
                                  width: w * 0.8,
                                  child: Image.asset('assets/redline.png')),
                            ),
                            Padding(
                              padding: EdgeInsets.only(
                                  top: h * 0.015,
                                  left: w * 0.06,
                                  bottom: h * 0.015,
                                  right: w * 0.07),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "Grand Total",
                                    style: GoogleFonts.inter(
                                      fontSize: w * 0.035,
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.primaryColor,
                                    ),
                                  ),
                                  Text(
                                    "₹ " + grandTotal.toString(),
                                    style: GoogleFonts.inter(
                                      fontSize: w * 0.035,
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.primaryColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Center(
                              child: Container(
                                width: w * 0.8,
                                child: Image.asset('assets/redline.png'),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.only(
                                top: h * 0.005,
                                left: w * 0.035,
                              ),
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: Container(
                                  width: w * 0.99,
                                  height: h * 0.4,
                                  child: ListView.builder(
                                    itemCount: products.length,
                                    itemBuilder: (context, index) {
                                      var product = products[index];
                                      return ListTile(
                                        title: Row(
                                          children: [
                                            Container(
                                              width: w * 0.13,
                                              height: h * 0.055,
                                              child: ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(4),
                                                child: Image.network(
                                                  product['images'][0],
                                                  fit: BoxFit.cover,
                                                ),
                                              ),
                                            ),
                                            SizedBox(
                                              width: w * 0.035,
                                            ),
                                            Container(
                                              width: w * 0.4,
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    '${product['productName']}',
                                                    style: GoogleFonts.inter(
                                                      fontSize: w * 0.035,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      color: AppColors
                                                          .primaryColor,
                                                    ),
                                                  ),
                                                  RichText(
                                                    text: TextSpan(
                                                      text: '${product['qty']}',
                                                      style: GoogleFonts.inter(
                                                        fontSize: w * 0.035,
                                                        fontWeight:
                                                            FontWeight.w300,
                                                        color: AppColors
                                                            .secondarytextColor,
                                                      ),
                                                      children: [
                                                        TextSpan(
                                                          text:
                                                              ' x ₹ ${product['salePrice']}',
                                                          style:
                                                              GoogleFonts.inter(
                                                            fontSize: w * 0.035,
                                                            fontWeight:
                                                                FontWeight.w300,
                                                            color: AppColors
                                                                .secondarytextColor,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Spacer(),
                                            Text(' ₹ ${product['salePrice']}',
                                                style: GoogleFonts.inter(
                                                  fontSize: w * 0.035,
                                                  fontWeight: FontWeight.w600,
                                                  color: AppColors.primaryColor,
                                                )),
                                          ],
                                        ),

                                        // Add more details as needed
                                      );
                                    },
                                  ),
                                ),
                              ),
                            )
                          ]),
                        ),
                      )
                    ],
                  ),
                ),
              ),
              Positioned(
                  top: h * 0.84,
                  left: w * 0.07,
                  child: Row(
                    children: [
                      ElevatedButton(
                        onPressed: () async {
                          await updateStatusToCancelled(docId);
                          print(docId);
                          // Navigate to the 'productPage'

                          Navigator.pop(
                              context); // Navigate back to the previous screen
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors
                              .thirdtextColor, // Change color as needed
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          minimumSize: Size(w * 0.63, h * 0.09),
                          side: BorderSide(
                            color: AppColors.primaryColor, // border color
                            width: 0.5, // thickness
                          ),
                        ),
                        child: Text(
                          'Cancel Order',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: w * 0.05,
                            fontWeight: FontWeight.w300,
                          ),
                        ),
                      ),
                      SizedBox(
                        width: w * 0.03,
                      ),
                      ElevatedButton(
                        onPressed: () async {
                          // Call the method to add product details
                          // await addProduct();
                          Navigator.pop(
                              context); // Navigate back to the previous screen
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryColor,
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(10), // small curve
                          ),
                          minimumSize: Size(w * 0.2,
                              h * 0.09), // set the width and height of the button
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            // replace with your asset path
                            SizedBox(
                                width: w * 0.07,
                                child: Image.asset('assets/icon10.png')),
                          ],
                        ),
                      ),
                    ],
                  )),
            ],
          ),
        ),
      ),
    );
  }

  // This is a placeholder function. Replace it with your actual implementation.
}
