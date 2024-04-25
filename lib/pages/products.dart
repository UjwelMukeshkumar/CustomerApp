import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_floating_bottom_bar/flutter_floating_bottom_bar.dart';
import 'package:quickfillcustomer/color.dart';
import 'package:quickfillcustomer/pages/accountPage.dart';
import 'package:quickfillcustomer/pages/addlist.dart';
import 'package:quickfillcustomer/pages/cart.dart';
import 'package:quickfillcustomer/pages/fav.dart';

class productPage extends StatefulWidget {
  const productPage({super.key});
  @override
  _productPageState createState() => _productPageState();
}

class _productPageState extends State<productPage>
    with SingleTickerProviderStateMixin {
  late int currentPage;
  late TabController tabController;
  final List<Color> colors = [
    AppColors.shipColor,
    AppColors.shipColor,
    AppColors.shipColor
  ];

  @override
  void initState() {
    super.initState();
    currentPage = 0;
    tabController = TabController(length: 3, vsync: this);
    // Listen to tab changes to hide/show the BottomBar
    tabController.addListener(() {
      final int tabIndex = tabController.index;
      // Check if the current tab is the cart tab (index 2)
      if (tabIndex == 2) {
        // Hide the BottomBar
        if (isBottomBarVisible) {
          setState(() {
            isBottomBarVisible = false;
          });
        }
      } else {
        // Show the BottomBar for any other tab
        if (!isBottomBarVisible) {
          setState(() {
            isBottomBarVisible = true;
          });
        }
      }
      // Update currentPage to the new index
      if (currentPage != tabIndex) {
        setState(() {
          currentPage = tabIndex;
        });
      }
    });
  }

  void changePage(int newPage) {
    setState(() {
      currentPage = newPage;
    });
  }

  bool isBottomBarVisible = true;

  @override
  void dispose() {
    tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Color unselectedColor = colors[currentPage].computeLuminance() < 0.5
        ? AppColors.fifthColor
        : Colors.white;
    return SafeArea(
        child: Scaffold(
      body: isBottomBarVisible
          ? // Existing BottomBar widget
          BottomBar(
              child: TabBar(
                dividerColor: Colors.transparent,

                controller: tabController,
                indicatorWeight:
                    0.0, // Set the indicatorWeight to 0.0 to remove the line

                indicator: BoxDecoration(
                  // Use BoxDecoration with transparent color
                  border: Border(
                      bottom: BorderSide(color: Colors.transparent, width: 0)),
                ),

                tabs: [
                  SizedBox(
                    height: 55,
                    width: 40,
                    child: Center(
                      child: Container(
                        width: 60,
                        height: 40,
                        decoration: BoxDecoration(
                          color: currentPage == 0
                              ? Colors.white
                              : Colors
                                  .transparent, // Apply conditional background color
                          borderRadius: BorderRadius.circular(
                              5), // Optional: add borderRadius for rounded corners
                        ),
                        child: Icon(
                          Icons.favorite_border,
                          color: currentPage == 0
                              ? AppColors.mainColor
                              : unselectedColor, // Conditional icon color
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 55,
                    width: 40,
                    child: Center(
                      child: Container(
                        width: 60,
                        height: 40,
                        decoration: BoxDecoration(
                          color: currentPage == 1
                              ? Colors.white
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          Icons.favorite_border,
                          color: currentPage == 1
                              ? AppColors.mainColor
                              : unselectedColor,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 55,
                    width: 40,
                    child: Center(
                      child: Container(
                        width: 60,
                        height: 40,
                        decoration: BoxDecoration(
                          color: currentPage == 2
                              ? Colors.white
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          Icons.shopping_cart_outlined,
                          color: currentPage == 2
                              ? AppColors.mainColor
                              : unselectedColor,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              fit: StackFit.expand,
              icon: (width, height) => Center(
                child: IconButton(
                  padding: EdgeInsets.zero,
                  onPressed: null,
                  icon: Icon(
                    Icons.arrow_upward_rounded,
                    color: unselectedColor,
                    size: width,
                  ),
                ),
              ),
              borderRadius: BorderRadius.circular(10),
              duration: Duration(seconds: 1),
              curve: Curves.decelerate,
              showIcon: true,
              width: MediaQuery.of(context).size.width * 0.7,
              barColor: colors[currentPage].computeLuminance() > 0.5
                  ? Colors.red
                  : AppColors.mainColor,
              start: 2,
              end: 0,
              offset: 10,
              barAlignment: Alignment.bottomCenter,
              iconHeight: 35,
              iconWidth: 35,
              reverse: false,
              hideOnScroll: true,
              scrollOpposite: false,
              onBottomBarHidden: () {},
              onBottomBarShown: () {},
              body: (context, controller) => TabBarView(
                  controller: tabController,
                  dragStartBehavior: DragStartBehavior.down,
                  physics: const BouncingScrollPhysics(),
                  children: [
                    Container(
                      child: AdList(),
                    ),
                    Container(
                      child: fav(),
                    ),
                    Container(
                        child: cart(

                            // Pass the images list to the next page
                            )),
                  ]
                  // .map((e) => InfiniteListPage(controller: controller, color: e))
                  // .toList(),
                  ),
            )
          : // If you want to hide the BottomBar, you might still want to keep the content visible
          TabBarView(
              controller: tabController,
              dragStartBehavior: DragStartBehavior.down,
              physics: const BouncingScrollPhysics(),
              children: [
                Container(
                  child: AdList(),
                ),
                Container(child: fav()),
                Container(child: cart()),
              ],
            ),
    ));
  }
}
