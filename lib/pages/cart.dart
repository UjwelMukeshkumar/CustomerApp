import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:page_transition/page_transition.dart';
import 'package:quickfillcustomer/color.dart';
import 'package:quickfillcustomer/loginPages/cancel.dart';
import 'package:quickfillcustomer/pages/confirm.dart';
import 'package:quickfillcustomer/pages/delivery.dart';
import 'package:quickfillcustomer/pages/productView.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:swipeable_button_view/swipeable_button_view.dart';

int selectedProductCount = 0;

class cart extends StatefulWidget {
  const cart({super.key});

  @override
  State<cart> createState() => _cartState();
}

class _cartState extends State<cart> {
  Future<DocumentSnapshot> getStoreName() async {
    var currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      return FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid) // Use current user's UID
          .get();
    } else {
      // Handle the case where there is no current user
      print("No current user found.");
      // Return a dummy snapshot or handle this case as needed
      return FirebaseFirestore.instance
          .collection('users')
          .doc('dummyId')
          .get();
    }
  }

  final FirebaseAuth _auth = FirebaseAuth.instance;
  late double subtotal = 0.0; // Declare totalAmount here
  late int extraCharge = 0; // Initialize extra charge here
  late String delTime = ''; // Initialize with default value
  late String payMethod = ''; // Initialize with default value
  late String payKey = ''; // Initialize with default value
  late String storeName = ''; // Initialize with default value
  late String name; // Initialize extra charge here

  String? address; // Initialize extra charge here
  String? phone; // Initialize extra charge here
  String? currentUserId;
  bool isFinished = false;
  bool isLoading = false;
  Razorpay? _razorpay;

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    Fluttertoast.showToast(
        msg: "SUCCESS: " + response.paymentId!,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: AppColors.primaryColor,
        textColor: Colors.white,
        fontSize: 16.0);

    createOrder(); // Call createOrder here after successful payment
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    // Navigate to the cancel() page
    Navigator.pushReplacement(
      context,
      PageTransition(
        type: PageTransitionType.fade,
        child: cancel(), // Replace with your Cancel page widget
      ),
    );
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    // Do something when an external wallet is selected
    Fluttertoast.showToast(
        msg: "EXTERNAL_WALLET: " + response.walletName!,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: AppColors.primaryColor,
        textColor: Colors.white,
        fontSize: 16.0);
  }

  @override
  void initState() {
    super.initState();
    getCurrentUser();

    getmoreCustInfo();
    _razorpay = Razorpay();
    _razorpay!.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay!.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay!.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  void makePayment() async {
    var options = {
      'key': payKey,
      'amount': (subtotal + extraCharge) * 100, // amount in paisa
      'name': storeName,
      'description': '-',
      'prefill': {'contact': '8888888888', 'email': 'nil@gmail.com'},
    };
    try {
      _razorpay!.open(options);
    } catch (e) {
      debugPrint(e.toString());
      // Navigate to the cancel() page if there's an error with the payment API
      Navigator.pushReplacement(
        context,
        PageTransition(
          type: PageTransitionType.fade,
          child: cancel(), // Replace with your Cancel page widget
        ),
      );
    }
  }

  String? storeId; // To store the fetched storeId

  Future<void> getCurrentUser() async {
    final user = _auth.currentUser;
    if (user != null) {
      try {
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('customers')
            .doc(user.uid)
            .get();

        if (userDoc.exists) {
          setState(() {
            currentUserId = user.uid;
            storeId = userDoc.get('store_id') as String?;
          });
          if (storeId != null) {
            await getExtraCharge();
            calculateTotal();
          }
        }
      } catch (e) {
        print("Error fetching user data: $e");
      }
    }
  }

  Future<void> getExtraCharge() async {
    if (storeId != null) {
      print("Fetching extra charge for storeId: $storeId"); // Debug statement
      DocumentSnapshot storeDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(storeId)
          .get();
      print("Store Doc: ${storeDoc.data()}"); // Check the fetched document

      String fetchedpayMethod = storeDoc['paymentMethod'] ?? '0';
      int fetchedExtraCharge = storeDoc['extraCharge'] ?? 0;
      String fetchedDelTime = storeDoc['shippingDetails'] ?? '0';
      String fetchedPayKey = storeDoc['paymentkey'] ?? '0';
      String fetchedStoreName = storeDoc['storeName'] ?? '0';
      print(
          "Fetched Extra Charge: $fetchedExtraCharge"); // Check the fetched value

      setState(() {
        delTime = fetchedDelTime;
        payMethod = fetchedpayMethod;
        extraCharge = fetchedExtraCharge;
        storeName = fetchedStoreName;
        payKey = fetchedPayKey;
        // Other state updates
      });
    } else {
      print("storeId is null"); // Error handling
    }
  }

  void calculateTotal() async {
    if (storeId != null) {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('products')
          .where('user_id', isEqualTo: storeId)
          .where('cart', arrayContains: currentUserId)
          .get();
      setState(() {
        subtotal = calculateTotalAmount(snapshot);
      });
    }
  }

  // void calculateTotal() async {
  //   // Perform your calculation logic here
  //   // For instance, if it's dependent on some data or API call
  //   // Fetch the data and calculate the total amount
  //   QuerySnapshot snapshot = await FirebaseFirestore.instance
  //       .collection('products')
  //       .where('user_id', isEqualTo: Constants.storeId)
  //       .where('cart', arrayContains: currentUserId)
  //       .get();

  //   setState(() {
  //     subtotal = calculateTotalAmount(snapshot);
  //   });
  // }

  void getmoreCustInfo() async {
    final user = _auth.currentUser;
    if (user != null) {
      try {
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('customers')
            .doc(user.uid)
            .get();

        if (userDoc.exists) {
          setState(() {
            // Safely access 'name' and 'phone' fields
            name = userDoc.get('name') as String? ?? '';

            phone = userDoc.get('phone') as String? ?? '';

            address = userDoc.get('address') as String? ?? '';
            // Add similar lines for other fields like 'address' if needed
          });
        } else {
          print("User document does not exist in Firestore");
        }
      } catch (e) {
        print("Error fetching user data: $e");
      }
    }
  }

  double calculateTotalAmount(QuerySnapshot snapshot) {
    double amount = snapshot.docs.fold(0.0, (sum, doc) {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      double salePrice = double.tryParse(data['salePrice'].toString()) ?? 0.0;
      int quantity = quantities[doc.id] ?? 1; // Get the quantity for each item
      return sum + (salePrice * quantity); // Multiply sale price by quantity
    });
    return amount;
  }

  void incrementQuantity(String productId) {
    if ((quantities[productId] ?? 0) < (avlQty[productId] ?? 0)) {
      setState(() {
        quantities[productId] = (quantities[productId] ?? 0) + 1;
        calculateTotal();
      });
    } else {
      Fluttertoast.showToast(
          msg: "Maximum available quantity reached",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.grey,
          textColor: Colors.white,
          fontSize: 16.0);
    }
  }

  void decrementQuantity(String productId) {
    if (quantities.containsKey(productId) && quantities[productId]! > 1) {
      setState(() {
        quantities[productId] = quantities[productId]! - 1;
        calculateTotal();
      });
    }
  }

  // Function to create a new order in Firestore
  Future<void> createOrder() async {
    try {
      // Create a unique order ID, for example using a timestamp
      DateTime now = DateTime.now();
      String formattedDate = DateFormat('dMMMyyyy').format(now); // Format date

      String orderId = DateTime.now().millisecondsSinceEpoch.toString();
      String status = "CONFIRMED"; // Initial order status
      String shipId = ""; // Replace with actual shipId
      String shipLink = ""; // Replace with actual shipLink
      String shipName = ""; // Replace with actual shipName
      String shipped_at = ""; // Replace with actual shipName
      // Create a list of products with their details
      List<Map<String, dynamic>> products =
          []; // Replace with actual product data
      String currentUserId = _auth.currentUser?.uid ?? '';

      // Reference to the store's order counter document
      DocumentReference storeCounterRef =
          FirebaseFirestore.instance.collection('storeOrderCount').doc(storeId);

      // Transaction to increment the store's order count
      int storeOrderNumber = await FirebaseFirestore.instance
          .runTransaction<int>((transaction) async {
        DocumentSnapshot storeSnapshot = await transaction.get(storeCounterRef);

        int newStoreOrderNumber = 1; // Start from 1 if not exists
        if (storeSnapshot.exists) {
          newStoreOrderNumber = storeSnapshot.get('count') + 1;
        }
        transaction.set(storeCounterRef, {'count': newStoreOrderNumber});
        return newStoreOrderNumber;
      });

      // Reference to the user's order counter document
      DocumentReference counterRef = FirebaseFirestore.instance
          .collection('customerOrderCount')
          .doc(currentUserId);

      // Transaction to increment the user's order counter
      int orderNumber = await FirebaseFirestore.instance
          .runTransaction<int>((transaction) async {
        DocumentSnapshot snapshot = await transaction.get(counterRef);

        int newOrderNumber = 1; // Start from 1 if not exists
        if (snapshot.exists) {
          newOrderNumber = snapshot.get('count') + 1;
        }
        transaction.set(counterRef, {'count': newOrderNumber});
        return newOrderNumber;
      });
      // Loop through the products in the cart and add them to the products list
      // You will need to adjust this according to how you are storing cart data
      for (var productId in quantities.keys) {
        DocumentSnapshot productDoc = await FirebaseFirestore.instance
            .collection('products')
            .doc(productId)
            .get();
        if (productDoc.exists) {
          Map<String, dynamic> productData =
              productDoc.data() as Map<String, dynamic>;
          productData['qty'] = quantities[productId];
          // Add any other necessary product details here
          products.add(productData);
        }
      }

      // Create order data
      Map<String, dynamic> orderData = {
        'date': formattedDate, // Use the formatted date
        'grandTotal': subtotal + extraCharge,
        'orderNo': orderNumber,
        'products': products,
        'shipId': shipId,
        'shipLink': shipLink,
        'shipName': shipName,
        'shipped_at': shipped_at,
        'shippingCharge': extraCharge,
        'status': status,
        'totalItems': products.length,
        'totalPrice': subtotal,
        'userAddress': address,
        'userName': name,
        'userPhone': phone,
        'user_id': currentUserId,
        'store_id': storeId, // Use the Constants.storeId here
        'storeOrderNo':
            storeOrderNumber, // Add store's order number to order data

        // Add any other necessary order details here
      };

      // Save the order to Firestore
      await FirebaseFirestore.instance
          .collection('orders')
          .doc(orderId)
          .set(orderData);
      print("Order created successfully.");

// Subtract ordered quantities from product quantities
      for (var productId in quantities.keys) {
        await FirebaseFirestore.instance
            .collection('products')
            .doc(productId)
            .get()
            .then((productDoc) {
          if (productDoc.exists) {
            int currentQty = productDoc.data()?['qty'] ?? 0;
            int orderedQty = quantities[productId] ?? 0;
            int newQty = (currentQty - orderedQty)
                .clamp(0, currentQty); // Ensure qty does not go below zero

            FirebaseFirestore.instance
                .collection('products')
                .doc(productId)
                .update({'qty': newQty});
          }
        });
      }
      // Remove user ID from 'cart' field of each product
      for (var productId in quantities.keys) {
        await FirebaseFirestore.instance
            .collection('products')
            .doc(productId)
            .update({
          'cart': FieldValue.arrayRemove([currentUserId])
        }).catchError((error) {
          print("Error updating cart for product $productId: $error");
        });
      }

      // Clear local cart data if necessary
      quantities.clear();

      // Clear the cart or perform any other necessary actions after order creation
      // ...
    } catch (e) {
      print("Error creating order: $e");
    }
  }

  String searchQuery = '';

  Map<String, int> quantities = {};
  Map<String, int> avlQty = {};

  @override
  Widget build(BuildContext context) {
    final double w = MediaQuery.of(context).size.width;
    final double h = MediaQuery.of(context).size.height;

    return MediaQuery(
      data: MediaQuery.of(context)
          .copyWith(textScaler: const TextScaler.linear(1.0)),
      child: Scaffold(
          body: SafeArea(
        child: Column(children: [
          Padding(
            padding: EdgeInsets.only(
              top: h * 0.03,
              left: w * 0.07,
              right: w * 0.055,
            ),
            child: Row(
              children: [
                InkWell(
                  onTap: () {
                    Navigator.pushNamedAndRemoveUntil(
                        context, 'productPage', (route) => false);
                  },
                  child: Center(
                    child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(100.0),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.fourthtextColor.withOpacity(1),
                              spreadRadius: 3,
                              blurRadius: 3,
                              offset:
                                  Offset(0, 3), // changes position of shadow
                            ),
                          ],
                        ),
                        width: w * 0.12,
                        child: Image.asset('assets/back.png')),
                  ),
                ),
                SizedBox(
                  width: w * 0.05,
                ),
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: 'Buy',
                        style: TextStyle(
                          color: AppColors.mainColor,
                          fontSize: w * 0.055,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      TextSpan(
                        text: ' Now page',
                        style: TextStyle(
                          color: AppColors.fourthColor,
                          fontSize: w * 0.055,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('products')
                  .where('user_id', isEqualTo: storeId)
                  .where('cart', arrayContains: currentUserId)
                  .snapshots(),
              builder: (BuildContext context,
                  AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: Lottie.asset(
                      'assets/loading.json', // Replace with your Lottie animation file path
                      width: 200,
                    ),
                  );
                }
                selectedProductCount = snapshot.data!.docs.length;
                // Inside your StreamBuilder where you fetch cart data
                if (snapshot.hasData) {
                  subtotal = calculateTotalAmount(snapshot.data!);
                  snapshot.data!.docs.forEach((document) {
                    if (!quantities.containsKey(document.id)) {
                      quantities[document.id] =
                          1; // Initialize with default value 1
                    }
                  });
                }

                return Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: ListView(
                      children: snapshot.data!.docs.isEmpty
                          ? [
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    height: h * 0.05,
                                  ),
                                  Center(
                                    child: Lottie.asset(
                                      'assets/product.json',
                                      width: w * 0.9,
                                    ),
                                  ),
                                  Text(
                                    "Empty Cart",
                                    style: TextStyle(
                                        fontSize: w * 0.05,
                                        color: AppColors.secondarytextColor),
                                  )
                                ],
                              ),
                            ]
                          : snapshot.data!.docs
                              .map((DocumentSnapshot document) {
                              Map<String, dynamic> data =
                                  document.data() as Map<String, dynamic>;
                              avlQty[document.id] = data['qty'] ?? 1;

                              return GridTile(
                                child: Column(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(16.0),
                                      child: Center(
                                        child: Container(
                                            width: w * 0.65,
                                            child: Image.asset(
                                                'assets/adline.png')),
                                      ),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.only(
                                        left: w * 0.05,
                                      ),
                                      child: Row(
                                        children: [
                                          InkWell(
                                            onTap: () {
                                              try {
                                                if (data != null &&
                                                    currentUserId != null) {
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) =>
                                                          prdtView(
                                                        data: data,
                                                        imageStrings:
                                                            data['images'],
                                                        cus_id: currentUserId!,
                                                        prdt_id: document.id,
                                                      ),
                                                    ),
                                                  );
                                                } else {
                                                  print(
                                                      "Data or Current User ID is null");
                                                }
                                              } catch (e) {
                                                print("Navigation Error: $e");
                                              }
                                            },
                                            child: Row(children: [
                                              if (data['images'] != null)
                                                Container(
                                                  height: h * 0.07,
                                                  width: w * 0.15,
                                                  decoration: BoxDecoration(
                                                    boxShadow: [
                                                      BoxShadow(
                                                        color: AppColors
                                                            .fourthtextColor
                                                            .withOpacity(1),
                                                        spreadRadius: 3,
                                                        blurRadius: 3,
                                                        offset: Offset(0,
                                                            3), // changes position of shadow
                                                      ),
                                                    ],
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            7),
                                                  ),
                                                  child: Material(
                                                    // Set the elevation here
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            7),
                                                    child: ListView.builder(
                                                      scrollDirection:
                                                          Axis.horizontal,
                                                      itemCount:
                                                          data['images'].length,
                                                      itemBuilder:
                                                          (context, index) {
                                                        return ClipRRect(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(7),
                                                          child: Container(
                                                            height: h * 0.07,
                                                            width: w * 0.15,
                                                            child:
                                                                Image.network(
                                                              data['images']
                                                                  [index],
                                                              fit: BoxFit.cover,
                                                              loadingBuilder:
                                                                  (BuildContext
                                                                          context,
                                                                      Widget
                                                                          child,
                                                                      ImageChunkEvent?
                                                                          loadingProgress) {
                                                                if (loadingProgress ==
                                                                    null)
                                                                  return child;
                                                                return Center(
                                                                  child:
                                                                      CircularProgressIndicator(
                                                                    color: AppColors
                                                                        .primaryColor,
                                                                    value: loadingProgress.expectedTotalBytes !=
                                                                            null
                                                                        ? loadingProgress.cumulativeBytesLoaded /
                                                                            loadingProgress.expectedTotalBytes!
                                                                        : null,
                                                                  ),
                                                                );
                                                              },
                                                              errorBuilder: (BuildContext
                                                                      context,
                                                                  Object
                                                                      exception,
                                                                  StackTrace?
                                                                      stackTrace) {
                                                                return Image.asset(
                                                                    'assets/default.png',
                                                                    fit: BoxFit
                                                                        .cover);
                                                              },
                                                            ),
                                                          ),
                                                        );
                                                      },
                                                    ),
                                                  ),
                                                ),
                                              if (data['images'] == null)
                                                ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(7),
                                                  child: SizedBox(
                                                    height: h * 0.13,
                                                    child: Image.asset(
                                                        'assets/default.png'),
                                                  ),
                                                ),
                                              SizedBox(
                                                width: w * 0.04,
                                              ),
                                            ]),
                                          ),
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              SingleChildScrollView(
                                                scrollDirection:
                                                    Axis.horizontal,
                                                child: SizedBox(
                                                  width: w * 0.2,
                                                  child: Text(
                                                    '${data['productName'] ?? 'No product name available'}',
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.w400,
                                                        color: AppColors
                                                            .secondarytextColor,
                                                        fontSize: w * 0.05),
                                                  ),
                                                ),
                                              ),

                                              SizedBox(
                                                height: h * 0.002,
                                              ),

                                              Text(
                                                '₹ ${data['salePrice'] ?? '0.00'}/-',
                                                style: TextStyle(
                                                    fontSize: w * 0.045,
                                                    fontWeight: FontWeight.w500,
                                                    color: AppColors.cardColor),
                                              ),
                                              Text(
                                                'MRP ₹ ${data['mrp'] ?? '0.00'}/-',
                                                style: TextStyle(
                                                  color: AppColors.mainColor,
                                                  fontSize: w * 0.025,
                                                  fontWeight: FontWeight.w500,
                                                  decoration: TextDecoration
                                                      .lineThrough,
                                                ),
                                              ),
                                              SizedBox(
                                                height: h * 0.01,
                                              ),
                                              // Text('${data['qty'] ?? '-'}'),
                                            ],
                                          ),
                                          Container(
                                            width: w * 0.33,
                                            child: Row(children: [
                                              Container(
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(20),
                                                  color: Colors
                                                      .white, // Set a white background color
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: AppColors
                                                          .fourthtextColor
                                                          .withOpacity(1),
                                                      spreadRadius: 3,
                                                      blurRadius: 3,
                                                      offset: Offset(0,
                                                          3), // changes position of shadow
                                                    ),
                                                  ],
                                                ),
                                                child: InkWell(
                                                  borderRadius:
                                                      BorderRadius.circular(20),
                                                  onTap: () {
                                                    decrementQuantity(document
                                                        .id); // Decrease quantity by 1 if it's greater than 1
                                                  },
                                                  child: Padding(
                                                    padding: EdgeInsets.all(8),
                                                    child: Icon(
                                                      Icons.remove,
                                                      color: Colors
                                                          .black, // Set icon color
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              Padding(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: Text(
                                                  '${quantities[document.id] ?? 1}', // This will display the quantity from the quantities map
                                                  style: TextStyle(
                                                    fontSize: w * 0.055,
                                                    fontWeight: FontWeight.w600,
                                                    color: AppColors.cardColor,
                                                  ),
                                                ),
                                              ),
                                              Container(
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(20),
                                                  color: Colors
                                                      .white, // Set a white background color
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: AppColors
                                                          .fourthtextColor
                                                          .withOpacity(1),
                                                      spreadRadius: 3,
                                                      blurRadius: 3,
                                                      offset: Offset(0,
                                                          3), // changes position of shadow
                                                    ),
                                                  ],
                                                ),
                                                child: InkWell(
                                                  borderRadius:
                                                      BorderRadius.circular(20),
                                                  onTap: () {
                                                    incrementQuantity(document
                                                        .id); // Decrease quantity by 1 if it's greater than 1
                                                  },
                                                  child: Padding(
                                                    padding: EdgeInsets.all(8),
                                                    child: Icon(
                                                      Icons.add,
                                                      color: Colors
                                                          .black, // Set icon color
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              SizedBox(
                                                width: w * 0.02,
                                              ),
                                            ]),
                                          ),
                                          IconButton(
                                            onPressed: () {
                                              FirebaseFirestore.instance
                                                  .collection('products')
                                                  .doc(document.id)
                                                  .update({
                                                'cart': FieldValue.arrayRemove(
                                                    [currentUserId])
                                              });
                                              // TODO: Implement close functionality
                                              calculateTotal();
                                            },
                                            icon: Icon(Icons.close),
                                          ),
                                        ],
                                      ),
                                    ),
                                    // Padding(
                                    //   padding: const EdgeInsets.all(8.0),
                                    //   child: Center(
                                    //     child: Container(
                                    //         width: w * 0.85,
                                    //         child: Image.asset(
                                    //             'assets/adline.png')),
                                    //   ),
                                    // ),
                                  ],
                                ),
                              );
                            }).toList()),
                );
              },
            ),
          ),
          if (subtotal > 0) // Show if there are items in the cart
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Center(
                    child: Container(
                        width: w * 0.65,
                        child: Image.asset('assets/adline.png')),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 58.0, top: 5, bottom: 5),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Sub Total: ₹$subtotal',
                      style: TextStyle(
                        fontWeight: FontWeight.w400,
                        color: AppColors.mainColor,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 58.0, top: 5, bottom: 5),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Shipping Amount: ₹$extraCharge',
                      style: TextStyle(
                          fontWeight: FontWeight.w500,
                          color: AppColors.cardColor),
                    ),
                  ),
                ),
                SizedBox(
                  height: h * 0.01,
                ),
                Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: Container(
                      width: w * 0.7,
                      child: Image.asset('assets/blueline.png')),
                ),
                Padding(
                  padding:
                      const EdgeInsets.only(left: 58.0, top: 10, bottom: 10),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Total Amount: ₹${subtotal + extraCharge}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: Container(
                      width: w * 0.7,
                      child: Image.asset('assets/blueline.png')),
                ),
                SizedBox(
                  height: h * 0.02,
                ),
                InkWell(
                  //       onTap: () {
                  //   Navigator.push(
                  //     context,
                  //     MaterialPageRoute(
                  //       builder: (context) => DeliveryDetails(
                  //         name: name,
                  //         phone: phone,
                  //         address: address,
                  //         payMethod: payMethod,
                  //         delTime: delTime,
                  //         subtotal: subtotal,
                  //         extraCharge: extraCharge,
                  //       ),
                  //     ),
                  //   );
                  // },
                  onTap: () {
                    // createOrder();
                    showModalBottomSheet(
                      backgroundColor: AppColors.primaryColor,
                      context: context,
                      isScrollControlled: true,
                      builder: (BuildContext context) {
                        return SingleChildScrollView(
                          physics: NeverScrollableScrollPhysics(),
                          child: Container(
                            padding: EdgeInsets.all(10),
                            height: MediaQuery.of(context).size.height *
                                0.9, // Adjust the height as needed
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Text(
                                    'Address Confirmation',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 27,
                                    ),
                                  ),
                                ),
                                Center(
                                  child: Container(
                                      width: w * 0.85,
                                      child: Image.asset('assets/adline.png')),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      SizedBox(
                                        height: h * 0.008,
                                      ),
                                      RichText(
                                        text: TextSpan(
                                          children: [
                                            TextSpan(
                                              text: 'Ujwel Mukeshkumar',
                                              // text: ' $name',
                                              style: TextStyle(
                                                  fontWeight: FontWeight.w700,
                                                  color:
                                                      AppColors.thirdtextColor),
                                            ),
                                          ],
                                        ),
                                      ),
                                      SizedBox(
                                        height: h * 0.005,
                                      ),
                                      RichText(
                                        text: TextSpan(
                                          children: [
                                            TextSpan(
                                              text: '9072897487',
                                              //   text: ' $phone',
                                              style: TextStyle(
                                                  fontWeight: FontWeight.w400,
                                                  color: Color(0xFF8F8B8B)),
                                            ),
                                          ],
                                        ),
                                      ),
                                      SizedBox(
                                        height: h * 0.005,
                                      ),
                                      Text(
                                        // '$address',
                                        'Nenmenath Parambil House\n chelakkra P,O\n Thrissur,Kerala',

                                        style: TextStyle(
                                            fontWeight: FontWeight.w400,
                                            color: Color(0xFF8F8B8B)),
                                      ),
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(5.0),
                                  child: Center(
                                    child: Container(
                                        width: w * 0.85,
                                        child:
                                            Image.asset('assets/adline.png')),
                                  ),
                                ),
                                SizedBox(
                                  height: h * 0.02,
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(left: 10),
                                  child: Row(
                                    children: [
                                      Align(
                                        alignment: Alignment.centerLeft,
                                        child: Container(
                                            width: w * 0.05,
                                            child:
                                                Image.asset("assets/car.png")),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: RichText(
                                          text: TextSpan(
                                            children: [
                                              TextSpan(
                                                text: '$selectedProductCount  ',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.w500,
                                                  color: AppColors.FirstColor,
                                                ),
                                              ),
                                              TextSpan(
                                                text: 'Products ',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.w600,
                                                  color: AppColors.FirstColor,
                                                ),
                                              ),
                                              TextSpan(
                                                text: 'Selected ',
                                                style: TextStyle(
                                                    fontWeight: FontWeight.w600,
                                                    color: AppColors
                                                        .thirdtextColor),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),

                                      // Text(
                                      //   '| Dispatch in: $delTime',
                                      //   style: TextStyle(
                                      //       fontWeight: FontWeight.w500,
                                      //       color: AppColors.cardColor),
                                      // ),
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(left: 6),
                                  child: Row(
                                    children: [
                                      Container(
                                          width: w * 0.05,
                                          child:
                                              Image.asset("assets/card.png")),
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: RichText(
                                          text: TextSpan(
                                            children: [
                                              TextSpan(
                                                text: 'COD ',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.w500,
                                                  color: AppColors.FirstColor,
                                                ),
                                              ),
                                              TextSpan(
                                                text: 'Payment ',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.w600,
                                                  color:
                                                      AppColors.thirdtextColor,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),

                                      // Text(
                                      //   '| Dispatch in: $delTime',
                                      //   style: TextStyle(
                                      //       fontWeight: FontWeight.w500,
                                      //       color: AppColors.cardColor),
                                      // ),
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(12.0),
                                  child: Center(
                                    child: Container(
                                        width: w * 0.85,
                                        child:
                                            Image.asset('assets/adline.png')),
                                  ),
                                ),
                                SizedBox(height: h * 0.01),
                                Padding(
                                  padding: const EdgeInsets.only(left: 15),
                                  child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      'Sub Total: ₹$subtotal',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w400,
                                        color: AppColors.thirdtextColor,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Center(
                                    child: Align(
                                      alignment: Alignment.centerLeft,
                                      child: Text(
                                        'Total Amount: ₹${subtotal + extraCharge}',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                Center(
                                  child: Container(
                                      width: w * 0.85,
                                      child: Image.asset('assets/adline.png')),
                                ),
                                SizedBox(height: h * 0.33),
                                Center(
                                    child: ElevatedButton(
                                  onPressed: () async {
                                    setState(() {
                                      isLoading =
                                          true; // Start showing the progress indicator
                                    });

                                    // Check if the payment method is Razorpay
                                    if (payMethod == "Razorpay") {
                                      makePayment();
                                    } else {
                                      await createOrder();
                                    }

                                    // Simulate a delay before navigating to the next page
                                    await Future.delayed(Duration(seconds: 3));

                                    setState(() {
                                      isLoading =
                                          false; // Stop showing the progress indicator
                                      isFinished = true;
                                    });

                                    // Navigate to the next page
                                    Navigator.pushReplacement(
                                      context,
                                      PageTransition(
                                        type: PageTransitionType.fade,
                                        child: confirm(),
                                      ),
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.FirstColor,
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  child: isLoading
                                      ? Padding(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 10),
                                          child: SizedBox(
                                            width: 24,
                                            height: 24,
                                            child: CircularProgressIndicator(
                                              valueColor:
                                                  AlwaysStoppedAnimation<Color>(
                                                      Colors.white),
                                            ),
                                          ),
                                        )
                                      : Padding(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 15, horizontal: 30),
                                          child: Text(
                                            'Confirm Purchase',
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                ))
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: AppColors.FirstColor,
                    ),
                    height: h * 0.07,
                    width: w * 0.84,
                    child: Center(
                      child: Text(
                        'Confirm Address',
                        style: TextStyle(
                            fontSize: w * 0.050,
                            color: AppColors.primaryColor,
                            fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: h * 0.02,
                ),
              ],
            ),
        ]),
      )),
    );
  }
}
