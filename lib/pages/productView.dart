import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:quickfillcustomer/color.dart';
import 'package:quickfillcustomer/pages/cart.dart';

class prdtView extends StatefulWidget {
  final Map<String, dynamic> data;
  final List<dynamic>?
      imageStrings; // Change the type to List<dynamic> initially
  final String cus_id;
  final String prdt_id;
  // Change the type to List<dynamic> initially

  const prdtView({
    Key? key,
    required this.data,
    required this.imageStrings,
    required this.cus_id,
    required this.prdt_id,
// Initialize imageStrings here
  }) : super(key: key);

  @override
  State<prdtView> createState() => _prdtViewState();
}

class _prdtViewState extends State<prdtView> {
  late String cus_id;
  late List<dynamic> products = widget.data['products'];
  late String productName = widget.data['productName'];
  late int salePrice = widget.data['salePrice'];
  late int mrp = widget.data['mrp'];
  late int qty = widget.data['qty'];
  late String description = widget.data['description'];
  late String percent = (((salePrice) / (mrp)) * 100).toStringAsFixed(0);
  late List<String> imageStrings;

  Color _iconColor = Colors.grey.shade200; // Initialize with primary color
  Color getShipColor() {
    return widget.data.containsKey('fav') &&
            widget.data['fav'].contains(widget.cus_id)
        ? AppColors.secoundColor // Set favorite color
        : Colors.grey.shade200; // Set primary color
  }

  bool isInCart = false; // Track if the product is in the cart initially

// Declare docId as a class-level variable
  @override
  void initState() {
    super.initState();
    imageStrings = (widget.imageStrings ?? []).cast<String>();
    cus_id = widget.cus_id; // Set its value in initState
    _iconColor = getShipColor(); // Set initial color based on conditions
    checkIfInCart(); // Check if the product is in the cart on initialization
  }

  Future<void> updateProduct() async {
    try {
      DocumentReference productRef =
          FirebaseFirestore.instance.collection('products').doc(widget.prdt_id);

      DocumentSnapshot productSnapshot = await productRef.get();

      if (productSnapshot.exists) {
        List<dynamic> customerIds = productSnapshot.get('fav') ?? [];

        if (customerIds.contains(widget.cus_id)) {
          productRef.update({
            'fav': FieldValue.arrayRemove([widget.cus_id])
          });

          // Update widget.data
          widget.data['fav'] = List.from(customerIds)..remove(widget.cus_id);
        } else {
          productRef.update({
            'fav': FieldValue.arrayUnion([widget.cus_id])
          });

          // Update widget.data
          widget.data['fav'] = List.from(customerIds)..add(widget.cus_id);
        }

        // Update local state and trigger a UI refresh
        setState(() {
          _iconColor =
              getShipColor(); // Update color state after the product is updated
        });
      } else {
        print('Product does not exist');
      }
    } catch (e) {
      print('Error updating product: $e');
    }
  }

  Future<void> compareProduct() async {
    try {
      DocumentReference productRef =
          FirebaseFirestore.instance.collection('products').doc(widget.prdt_id);

      DocumentSnapshot productSnapshot = await productRef.get();

      if (productSnapshot.exists) {
        List<dynamic> customerIds = productSnapshot.get('compare') ?? [];

        if (customerIds.contains(widget.cus_id)) {
          productRef.update({
            'compare': FieldValue.arrayRemove([widget.cus_id])
          });

          // Update widget.data
          widget.data['compare'] = List.from(customerIds)
            ..remove(widget.cus_id);
        } else {
          productRef.update({
            'compare': FieldValue.arrayUnion([widget.cus_id])
          });

          // Update widget.data
          widget.data['compare'] = List.from(customerIds)..add(widget.cus_id);
        }

        // Update local state and trigger a UI refresh
        setState(() {
          _iconColor =
              getShipColor(); // Update color state after the product is updated
        });
      } else {
        print('Product does not exist');
      }
    } catch (e) {
      print('Error updating product: $e');
    }
  }

  Future<void> checkIfInCart() async {
    try {
      DocumentSnapshot productSnapshot = await FirebaseFirestore.instance
          .collection('products')
          .doc(widget.prdt_id)
          .get();

      if (productSnapshot.exists) {
        List<dynamic> customerIds = productSnapshot.get('cart') ?? [];
        setState(() {
          isInCart = customerIds.contains(widget.cus_id);
        });
      }
    } catch (e) {
      print('Error checking cart: $e');
    }
  }

  Future<void> updateCart() async {
    try {
      DocumentReference productRef =
          FirebaseFirestore.instance.collection('products').doc(widget.prdt_id);

      DocumentSnapshot productSnapshot = await productRef.get();

      if (productSnapshot.exists) {
        List<dynamic> customerIds = productSnapshot.get('cart') ?? [];

        if (customerIds.contains(widget.cus_id)) {
          productRef.update({
            'cart': FieldValue.arrayRemove([widget.cus_id])
          });
          setState(() {
            isInCart =
                false; // Update the local state to reflect removal from cart
          });
        } else {
          productRef.update({
            'cart': FieldValue.arrayUnion([widget.cus_id])
          });
          setState(() {
            isInCart =
                true; // Update the local state to reflect addition to cart
          });
        }
      } else {
        print('Product does not exist');
      }
    } catch (e) {
      print('Error updating cart: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final double w = MediaQuery.of(context).size.width;
    final double h = MediaQuery.of(context).size.height;
    bool isAvailable = widget.data['qty'] > 0; // Check if product is available

    return MediaQuery(
      data: MediaQuery.of(context)
          .copyWith(textScaler: const TextScaler.linear(1.0)),
      child: Scaffold(
        body: SafeArea(
          child: Stack(
            children: [
              Column(children: [
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(
                            height: 20,
                          ),
                          Row(
                            children: [
                              const SizedBox(
                                width: 10,
                              ),
                              InkWell(
                                onTap: () {
                                  Navigator.pushNamedAndRemoveUntil(
                                      context, 'productPage', (route) => false);
                                },
                                child: Center(
                                  child: Container(
                                      width: w * 0.12,
                                      child: Image.asset('assets/back.png')),
                                ),
                              ),
                              const SizedBox(
                                width: 10,
                              ),
                              Text(
                                productName,
                                style: TextStyle(
                                    fontSize: w * 0.05,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.grey.shade400),
                              ),
                              Spacer(),
                              Container(
                                  width: w * 0.12,
                                  child: Image.asset('assets/star.png')),
                              const SizedBox(
                                width: 30,
                              ),
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Stack(
                              children: [
                                if (imageStrings != null)
                                  Center(
                                    child: Container(
                                      height: h * 0.37,
                                      width: w * 0.9,
                                      decoration: BoxDecoration(
                                        boxShadow: [
                                          BoxShadow(
                                            color: AppColors.fourthtextColor
                                                .withOpacity(1),
                                            spreadRadius: 3,
                                            blurRadius: 3,
                                            offset: Offset(0,
                                                3), // changes position of shadow
                                          ),
                                        ],
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Material(
                                        // Set the elevation here
                                        borderRadius: BorderRadius.circular(12),
                                        child: ListView.builder(
                                          scrollDirection: Axis.horizontal,
                                          itemCount: imageStrings.length,
                                          itemBuilder: (context, index) {
                                            return ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              child: Container(
                                                height: h * 0.37,
                                                width: w * 0.9,
                                                child: Image.network(
                                                  imageStrings[index],
                                                  fit: BoxFit.cover,
                                                  loadingBuilder:
                                                      (BuildContext context,
                                                          Widget child,
                                                          ImageChunkEvent?
                                                              loadingProgress) {
                                                    if (loadingProgress == null)
                                                      return child;
                                                    return Center(
                                                      child:
                                                          CircularProgressIndicator(
                                                        color: AppColors
                                                            .primaryColor,
                                                        value: loadingProgress
                                                                    .expectedTotalBytes !=
                                                                null
                                                            ? loadingProgress
                                                                    .cumulativeBytesLoaded /
                                                                loadingProgress
                                                                    .expectedTotalBytes!
                                                            : null,
                                                      ),
                                                    );
                                                  },
                                                  errorBuilder: (BuildContext
                                                          context,
                                                      Object exception,
                                                      StackTrace? stackTrace) {
                                                    return Image.asset(
                                                        'assets/default.png',
                                                        fit: BoxFit.cover);
                                                  },
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                    ),
                                  ),
                                if (imageStrings == null)
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(7),
                                    child: SizedBox(
                                      height: h * 0.13,
                                      child: Image.asset('assets/default.png'),
                                    ),
                                  ),
                                Positioned(
                                    top: h * 0.025,
                                    right: w * 0.05,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          color: Colors.grey
                                              .shade200, // Color of the border
                                          width: 2.0, // Thickness of the border
                                        ),
                                        borderRadius: BorderRadius.circular(
                                            100), // Rounded corners
                                      ),
                                      child: IconButton(
                                        icon: Icon(Icons.compare_arrows),
                                        color: widget.data['compare'] != null &&
                                                widget.data['compare']
                                                    .contains(widget.cus_id)
                                            ? AppColors.mainColor
                                            // Product is in compare list
                                            : Colors
                                                .grey, // Product is not in compare list
                                        onPressed: () {
                                          compareProduct();
                                        },
                                      ),
                                    )),
                              ],
                            ),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Row(
                            children: [
                              Column(
                                children: [
                                  Padding(
                                    padding: EdgeInsets.only(
                                      left: w * 0.07,
                                      right: w * 0.055,
                                      top: w * 0.015,
                                    ),
                                    child: Text(
                                      'Rs ${salePrice}/-',
                                      style: TextStyle(
                                          fontSize: w * 0.07,
                                          fontWeight: FontWeight.w600),
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.only(
                                      left: w * 0.07,
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Text(
                                          'MRP : ${mrp}/- ',
                                          style: TextStyle(
                                              fontSize: w * 0.025,
                                              fontWeight: FontWeight.w400),
                                        ),
                                        Text(
                                          '| ${percent}% Discount',
                                          style: TextStyle(
                                              fontSize: w * 0.025,
                                              color: AppColors.mainColor,
                                              fontWeight: FontWeight.w500),
                                        ),
                                      ],
                                    ),
                                  )
                                ],
                              ),
                              Spacer(),
                              Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(100),
                                  color: Colors.white,
                                  border: Border.all(
                                    color: Colors.grey
                                        .shade200, // Set your desired border color here
                                    width: 2, // Set the width of the border
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    IconButton(
                                      onPressed: () async {
                                        await updateProduct();
                                        // Refresh the UI after the favorite status changes
                                      },
                                      icon: Icon(
                                        Icons.favorite,
                                        color:
                                            _iconColor, // Use the variable to set color
                                        size: w * 0.06,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(
                                width: 25,
                              )
                            ],
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: w * 0.07, vertical: w * 0.02),
                            child: isAvailable
                                ? const Row(
                                    children: [
                                      // Spacer(),

                                      Spacer(),
                                      Spacer(),

                                      Spacer(),
                                      Spacer(),
                                    ],
                                  )
                                : Center(
                                    child: Container(
                                      decoration: BoxDecoration(
                                        borderRadius:
                                            BorderRadius.circular(100),
                                        color: Colors
                                            .red, // Grey color for not available
                                      ),
                                      height: h * 0.06,
                                      width: w * 0.8,
                                      child: Center(
                                        child: Text(
                                          'OUT OF STOCK',
                                          style: TextStyle(
                                            fontSize: w * 0.04,
                                            color: Colors.white, // White text
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(
                              left: w * 0.1,
                              right: w * 0.1,
                              top: w * 0.005,
                              bottom: w * 0.005,
                            ),
                            child: Center(
                              child: Container(
                                  width: w * 0.9,
                                  child: Image.asset('assets/adline.png')),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(
                              left: w * 0.07,
                              right: w * 0.055,
                              top: w * 0.025,
                              bottom: w * 0.1,
                            ),
                            child: Text(
                              description,
                              style: TextStyle(
                                  fontSize: w * 0.037,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.grey.shade400),
                            ),
                          ),
                        ]),
                  ),
                ),
              ]),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: isAvailable
                    ? Padding(
                        padding: const EdgeInsets.all(16),
                        child: GestureDetector(
                          onTap: () async {
                            await updateCart();
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => cart(),
                              ),
                            );
                          },
                          child: Container(
                            width: double.infinity,
                            height: 60,
                            decoration: BoxDecoration(
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.mainColor.withOpacity(1),
                                  spreadRadius: 1,
                                  blurRadius: 1,
                                  offset: const Offset(
                                      0, 1), // changes position of shadow
                                ),
                              ],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Center(
                              child: Text(
                                isInCart
                                    ? 'REMOVE FROM CART'
                                    : 'Buy Now     |     Rs ${salePrice}/-',
                                style: TextStyle(
                                  fontSize: w * 0.05,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                        ),
                      )
                    : Container(
                        padding: EdgeInsets.all(16),
                        width: double.infinity,
                        color: Colors.red, // Grey color for not available
                        height: 60,
                        child: Center(
                          child: Text(
                            'OUT OF STOCK',
                            style: TextStyle(
                                fontSize: w * 0.04,
                                color: Colors.white), // White text
                          ),
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
