import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:quickfillcustomer/color.dart';
import 'package:quickfillcustomer/pages/productView.dart';

class fav extends StatefulWidget {
  const fav({super.key});

  @override
  State<fav> createState() => _favState();
}

class _favState extends State<fav> {
  Future<DocumentSnapshot> getStoreName() {
    return FirebaseFirestore.instance.collection('users').doc(storeId).get();
  }

  final FirebaseAuth _auth = FirebaseAuth.instance;
  String? storeId; // To store the fetched storeId
  String currentUserId = ""; // Initialize with a default value

  @override
  void initState() {
    super.initState();
    getCurrentUser();
  }

  Future<void> getCurrentUser() async {
    final user = _auth.currentUser;
    if (user != null) {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('customers')
          .doc(user.uid)
          .get();

      if (userDoc.exists) {
        setState(() {
          currentUserId = user.uid;
          storeId = userDoc.get('store_id') as String?;
        });
        // Call updateCartQuantity here to ensure it's done after currentUserId and storeId are set
        // if (storeId != null) {
        //   updateCartQuantity();
        //   fetchStoreDetails(); // Fetch store details
        // }
      }
    }
  }

  String searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final double w = MediaQuery.of(context).size.width;
    final double h = MediaQuery.of(context).size.height;
    return MediaQuery(
      data: MediaQuery.of(context)
          .copyWith(textScaler: const TextScaler.linear(1.0)),
      child: Scaffold(
        body: SafeArea(
            child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SizedBox(
              height: h * 0.02,
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                height: h * 0.067,
                width: w * 0.9,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(100.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.35), // Shadow color
                      spreadRadius: 1, // Spread radius
                      blurRadius: 30, // Blur radius
                      offset: const Offset(0, 2), // Offset of the shadow
                    ),
                  ],
                ),
                child: TextFormField(
                  onChanged: (val) {
                    setState(() {
                      searchQuery = val;
                    });
                  },
                  style: TextStyle(
                    fontSize: w * 0.045,
                    color: Colors.black54,
                    fontWeight: FontWeight.w600,
                  ),
                  decoration: InputDecoration(
                    prefixIcon: Icon(
                      Icons.search,
                      color: Colors.grey.shade200,
                    ),

                    hintText: 'Search Favourite here ...',
                    hintStyle: TextStyle(
                        color: AppColors.secondarytextColor,
                        height: h * 0.0019,
                        fontSize: w * 0.04,
                        fontWeight: FontWeight.w300),
                    border: InputBorder.none,
                    // focusedBorder: OutlineInputBorder(
                    //   borderSide: BorderSide(color: AppColors.cardColor),
                    //   borderRadius: BorderRadius.circular(100.0),
                    // ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: (currentUserId != null)
                  ? StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('products')
                          .where('user_id', isEqualTo: storeId)
                          .where('fav', arrayContains: currentUserId)
                          .snapshots(),
                      builder: (BuildContext context,
                          AsyncSnapshot<QuerySnapshot> snapshot) {
                        if (snapshot.hasError) {
                          return Text('Error: ${snapshot.error}');
                        }

                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Center(
                            child: Lottie.asset(
                              'assets/loading.json', // Replace with your Lottie animation file path
                              width: 200,
                            ),
                          );
                        }

                        List<DocumentSnapshot> searchResults = [];
                        for (DocumentSnapshot doc in snapshot.data!.docs) {
                          if (doc['productName']
                              .toLowerCase()
                              .contains(searchQuery.toLowerCase())) {
                            searchResults.add(doc);
                          }
                        }
                        // List<DocumentSnapshot> searchResults = [];
                        // for (DocumentSnapshot doc in snapshot.data!.docs) {
                        //   var data = doc.data() as Map<String, dynamic>;
                        //   if (data['productName']
                        //           .toLowerCase()
                        //           .contains(searchQuery.toLowerCase()) &&
                        //       data['qty'] > 0) {
                        //     searchResults.add(doc);
                        //   }
                        // }

                        return Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: searchResults.isEmpty
                              ? Center(
                                  // Center the content when the list is empty
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment
                                        .center, // Center vertically
                                    crossAxisAlignment: CrossAxisAlignment
                                        .center, // Center horizontally
                                    children: [
                                      Lottie.asset(
                                        'assets/product.json',
                                        width: w *
                                            0.6, // Adjust the width as needed
                                      ),
                                      SizedBox(
                                          height: h *
                                              0.02), // Space between animation and text
                                      Text(
                                        "No Favorites Available",
                                        style: TextStyle(
                                            fontSize: w * 0.03,
                                            color:
                                                AppColors.secondarytextColor),
                                      )
                                    ],
                                  ),
                                )
                              : GridView.count(
                                  crossAxisCount: 2,
                                  childAspectRatio: (w *
                                      1 /
                                      w *
                                      0.67), // Number of grids side by side
                                  children: searchResults
                                      .map((DocumentSnapshot document) {
                                    Map<String, dynamic> data =
                                        document.data() as Map<String, dynamic>;
                                    return GestureDetector(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => prdtView(
                                              data: data,
                                              imageStrings: data['images'],
                                              cus_id: currentUserId,
                                              prdt_id: document.id,

                                              // Pass the images list to the next page
                                            ),
                                          ),
                                        );
                                      },
                                      child: GridTile(
                                        child: Column(
                                          children: [
                                            Column(
                                              children: [
                                                if (data['images'] != null)
                                                  Container(
                                                    height: h * 0.23,
                                                    width: w * 0.43,
                                                    decoration: BoxDecoration(
                                                      boxShadow: [
                                                        BoxShadow(
                                                          color: AppColors
                                                              .fourthtextColor
                                                              .withOpacity(0.5),
                                                          spreadRadius: 2,
                                                          blurRadius: 2,
                                                          offset: Offset(0,
                                                              2), // changes position of shadow
                                                        ),
                                                      ],
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              12),
                                                    ),
                                                    child: Material(
                                                      // Set the elevation here
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              12),
                                                      child: ListView.builder(
                                                        scrollDirection:
                                                            Axis.horizontal,
                                                        itemCount:
                                                            data['images']
                                                                .length,
                                                        itemBuilder:
                                                            (context, index) {
                                                          return ClipRRect(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        12),
                                                            child: Container(
                                                              height: h * 0.23,
                                                              width: w * 0.43,
                                                              child:
                                                                  Image.network(
                                                                data['images']
                                                                    [index],
                                                                fit: BoxFit
                                                                    .cover,
                                                                loadingBuilder: (BuildContext
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
                                                        BorderRadius.circular(
                                                            7),
                                                    child: SizedBox(
                                                      height: h * 0.13,
                                                      child: Image.asset(
                                                          'assets/default.png'),
                                                    ),
                                                  ),
                                              ],
                                            ),
                                            SizedBox(
                                              height: h * 0.01,
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
                                                    width: w * 0.4,
                                                    child: Text(
                                                      '${data['productName'] ?? 'No product name available'}',
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.w400,
                                                          color: AppColors
                                                              .secondarytextColor,
                                                          fontSize: w * 0.035),
                                                    ),
                                                  ),
                                                ),

                                                SizedBox(
                                                  height: h * 0.002,
                                                ),
                                                Text(
                                                  'Rs ${data['salePrice'] ?? '0.00'}/-',
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      color:
                                                          AppColors.cardColor),
                                                ),
                                                SizedBox(
                                                  height: h * 0.01,
                                                ),
                                                // Text('${data['qty'] ?? '-'}'),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                ),
                        );
                      },
                    )
                  : Container(), // Show an empty container or some other widget when currentUserId is null
            ),
          ],
        )),
      ),
    );
  }
}
