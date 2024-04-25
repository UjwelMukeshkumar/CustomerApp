import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:quickfillcustomer/color.dart';
import 'package:quickfillcustomer/pages/accountPage.dart';
import 'package:quickfillcustomer/pages/offers.dart';
import 'package:quickfillcustomer/pages/productView.dart';

class AdList extends StatefulWidget {
  const AdList({Key? key}) : super(key: key);

  @override
  State<AdList> createState() => _AdListState();
}

class _AdListState extends State<AdList> with TickerProviderStateMixin {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late String currentUserId;
  late TabController _tabController;
  List<String> categoryNames = [];
  List<String> categoryPhoto = [];
  Map<String, List<DocumentSnapshot>> productsByCategory = {};
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 0, vsync: this);
    initializeData();
  }

  Future<void> initializeData() async {
    getCurrentUser();
    await fetchCategories();
    if (categoryNames.isNotEmpty) {
      await getProductsUnderCategory(categoryNames[0]);
      if (mounted) {
        setState(() {
          _tabController?.dispose();
          _tabController =
              TabController(length: categoryNames.length, vsync: this);
          _tabController.addListener(_handleTabSelection);
        });
      }
    }
  }

  void getCurrentUser() async {
    final user = _auth.currentUser;
    if (user != null) {
      setState(() {
        currentUserId = user.uid;
      });
    }
  }

  Future<void> fetchCategories() async {
    try {
      QuerySnapshot categorySnapshot =
          await FirebaseFirestore.instance.collection('catagorie').get();
      List<String> fetchedCategories = [];
      for (var doc in categorySnapshot.docs) {
        fetchedCategories.add(doc.get('catagorieName') as String);
      }

      if (mounted) {
        setState(() {
          categoryPhoto = fetchedCategories;
          categoryNames = fetchedCategories;
          for (var category in categoryNames) {
            productsByCategory[category] = [];
          }
          //
          _tabController?.dispose();
          _tabController =
              TabController(length: categoryNames.length, vsync: this);
        });
      }
    } catch (e) {
      print("Error fetching categories: $e");
    }
  }

  Future<void> getProductsUnderCategory(String categoryName) async {
    List<DocumentSnapshot> productDetails = [];
    try {
      var categorySnapshot = await FirebaseFirestore.instance
          .collection('catagorie')
          .where('catagorieName', isEqualTo: categoryName)
          .where('uid', isEqualTo: currentUserId)
          .get();
      if (categorySnapshot.docs.isNotEmpty) {
        for (var categoryDoc in categorySnapshot.docs) {
          var categoryData = categoryDoc.data();
          var productIds = categoryData['productIds'] as List<dynamic>?;
          if (productIds != null) {
            for (var productId in productIds) {
              var productSnapshot = await FirebaseFirestore.instance
                  .collection('products')
                  .doc(productId)
                  .get();
              if (productSnapshot.exists) {
                productDetails.add(productSnapshot);
              }
            }
          }
        }
      } else {
        print(
            'No products found for category "$categoryName" with matching storeId');
      }
    } catch (e) {
      print("Error fetching products for category '$categoryName': $e");
    }

    if (mounted) {
      setState(() {
        productsByCategory[categoryName] = productDetails;
      });
    }
  }

  void _handleTabSelection() {
    if (_tabController.indexIsChanging) {
      getProductsUnderCategory(categoryNames[_tabController.index]);
    }
  }

  @override
  Widget build(BuildContext context) {
    final double w = MediaQuery.of(context).size.width;
    final double h = MediaQuery.of(context).size.height;

    return DefaultTabController(
      length: categoryNames.length,
      child: Scaffold(
        body: Column(
          children: [
            Padding(
              padding: EdgeInsets.only(
                top: w * 0.035,
              ),
              child: Container(
                height: h * 0.1,
                width: w,
                child: Padding(
                  padding: EdgeInsets.only(
                    left: w * 0.07,
                    right: w * 0.055,
                    top: w * 0.015,
                  ),
                  child: Row(
                    children: [
                      // if (storeLogo != null)
                      //   ClipRRect(
                      //     borderRadius: BorderRadius.circular(5),
                      //     child: Container(
                      //       width: w * 0.10,
                      //       child: Image.network(storeLogo!, fit: BoxFit.cover),
                      //     ),
                      //   ),
                      // SizedBox(
                      //   width: w * 0.02,
                      // ),
                      // Column(
                      //   mainAxisAlignment: MainAxisAlignment.center,
                      //   crossAxisAlignment: CrossAxisAlignment.start,
                      //   children: [
                      //     if (storeName != null)
                      //       Text(
                      //         storeName!,
                      //         style: TextStyle(
                      //           color: AppColors.secondarytextColor,
                      //           fontSize: w * 0.045,
                      //           fontWeight: FontWeight.w500,
                      //         ),
                      //       ),
                      //     Text(
                      //       "Store",
                      //       style: TextStyle(
                      //           fontSize: w * 0.025,
                      //           color: AppColors.shipColor),
                      //     )
                      //   ],
                      // ),
                      Container(
                        height: h * 0.06,
                        width: w * 0.7,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16.0),
                          boxShadow: [
                            BoxShadow(
                              color:
                                  Colors.grey.withOpacity(0.35), // Shadow color
                              spreadRadius: 1, // Spread radius
                              blurRadius: 30, // Blur radius
                              offset:
                                  const Offset(0, 2), // Offset of the shadow
                            ),
                          ],
                        ),
                        child: TextFormField(
                          onChanged: (val) {
                            setState(() {
                              searchQuery =
                                  val.toLowerCase(); // Update search query
                            });
                          },
                          style: TextStyle(
                            fontSize: w * 0.045,
                            color: Colors.black54,
                            fontWeight: FontWeight.w600,
                          ),
                          decoration: InputDecoration(
                            hintMaxLines: 1,
                            prefixIcon: Icon(
                              Icons.search,
                              color: Colors.grey.shade200,
                            ),
                            // hintText: '  Search Products Here ...',
                            // hintStyle: TextStyle(
                            //     color: AppColors.secondarytextColor,
                            //     height: h * 0.0019,
                            //     fontSize: w * 0.04,
                            //     fontWeight: FontWeight.w300),
                            border: InputBorder.none,
                          ),
                        ),
                      ),

                      Spacer(),
                      Stack(
                        children: [
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => AccountPage(),
                                ),
                              );
                            },
                            child: Center(
                              child: Container(
                                  width: w * 0.13,
                                  child: Image.asset('assets/accountnew.png')),
                            ),
                          ),
                          // Positioned(
                          //     top: h * 0.06,
                          //     right: h * 0.002,
                          //     child: ClipRRect(
                          //       borderRadius: BorderRadius.circular(100),
                          //       child: Container(
                          //           height: h * 0.027,
                          //           width: w * 0.06,
                          //           color: AppColors.shipColor,
                          //           child: Center(
                          //             child: Text(
                          //               '$cartQuantity', // Display the actual cart quantity
                          //               textAlign: TextAlign.center,
                          //               style: TextStyle(
                          //                   color: Colors.white,
                          //                   fontSize: w * 0.03,
                          //                   fontWeight: FontWeight.w500),
                          //             ),
                          //           )),
                          //     ))
                        ],
                      ),
                      SizedBox(
                        width: w * 0.02,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => offers(),
                  ),
                );
              },
              child: Padding(
                padding: const EdgeInsets.only(
                    left: 20.0, right: 20, top: 10, bottom: 10),
                child: Image.asset('assets/banner.png'),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(
                  left: 35.0, right: 35, top: 10, bottom: 10),
              child: Image.asset('assets/dotted.png'),
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(0, 12.0, 8.0, 4.0),
                child: Container(
                  height: MediaQuery.of(context).size.height * 0.04,
                  child: TabBar(
                    controller: _tabController,
                    isScrollable: true,
                    indicatorColor: Colors.transparent,
                    indicatorSize: TabBarIndicatorSize.tab,
                    indicator: BoxDecoration(
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: AppColors.thirdColor, width: 1),
                      color: AppColors.fourthColor,
                    ),
                    dividerColor: Colors.transparent,
                    labelColor: AppColors.thirdColor,
                    labelStyle:
                        TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
                    unselectedLabelColor: Colors.black,
                    tabs: List<Widget>.generate(categoryNames.length,
                        (int index) {
                      return Tab(
                        child: Container(
                          decoration: BoxDecoration(
                            color: _tabController.index == index
                                ? null
                                : Colors.white,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          alignment: Alignment.center,
                          child: Padding(
                            padding: EdgeInsets.fromLTRB(
                                MediaQuery.of(context).size.width * 0.04,
                                MediaQuery.of(context).size.height * 0.005,
                                MediaQuery.of(context).size.width * 0.04,
                                MediaQuery.of(context).size.height * 0.005),
                            child: Text(categoryNames[index]),
                          ),
                        ),
                      );
                    }),
                  ),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: TabBarView(
                  controller: _tabController,
                  children: categoryNames.map((String category) {
                    // Filter products for the current category based on the search query
                    return buildProductList(productsByCategory[category]
                            ?.where((doc) => (doc.data()
                                    as Map<String, dynamic>)['productName']
                                .toLowerCase()
                                .contains(searchQuery))
                            .toList() ??
                        []);
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
        // ... Other Scaffold Widgets ...
      ),
    );
  }

  Widget buildProductList(List<DocumentSnapshot> products) {
    final double w = MediaQuery.of(context).size.width;
    final double h = MediaQuery.of(context).size.height;

    return GridView.count(
      crossAxisCount: 2, // Number of columns
      childAspectRatio: (w * 1 / h * 1.55), // Aspect ratio of each grid cell
      children: products.map((DocumentSnapshot document) {
        Map<String, dynamic> data = document.data() as Map<String, dynamic>;
        String productName = data['productName'] ?? 'No Name';
        String productId = document.id;
        // Build each grid tile with only product name
        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => prdtView(
                  data: data,
                  imageStrings: data['images'],
                  cus_id: currentUserId,
                  prdt_id: productId,
                ),
              ),
            );
          },
          child: GridTile(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(3.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.fourthtextColor.withOpacity(0.5),
                          spreadRadius: 3,
                          blurRadius: 3,
                          offset: Offset(0, 3), // changes position of shadow
                        ),
                      ],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      children: [
                        if (data['images'] != null)
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Container(
                              height: h * 0.17,
                              width: w * 0.43,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: AppColors.fifthColor, // Border color
                                  width: 1.0, // Border thickness
                                ),
                              ),
                              child: Material(
                                // Set the elevation here
                                borderRadius: BorderRadius.circular(12),
                                child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: data['images'].length,
                                  itemBuilder: (context, index) {
                                    return ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      child: Container(
                                        height: h * 0.20,
                                        width: w * 0.43,
                                        child: Image.network(
                                          data['images'][index],
                                          fit: BoxFit.cover,
                                          loadingBuilder: (BuildContext context,
                                              Widget child,
                                              ImageChunkEvent?
                                                  loadingProgress) {
                                            if (loadingProgress == null)
                                              return child;
                                            return Center(
                                              child: CircularProgressIndicator(
                                                color: AppColors
                                                    .secondarytextColor,
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
                                          errorBuilder: (BuildContext context,
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
                        if (data['images'] == null)
                          ClipRRect(
                            borderRadius: BorderRadius.circular(7),
                            child: SizedBox(
                              height: h * 0.08,
                              child: Image.asset('assets/default.png'),
                            ),
                          ),
                        SizedBox(
                          height: h * 0.005,
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: SizedBox(
                                width: w * 0.4,
                                child: Text(
                                  '${data['productName'] ?? 'No product name available'}',
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.secondarytextColor,
                                      fontSize: w * 0.055),
                                ),
                              ),
                            ),

                            Text(
                              '₹ ${data['salePrice'] ?? '0.00'}/-',
                              style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.cardColor,
                                  fontSize: w * 0.055),
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
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}
