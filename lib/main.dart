import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:quickfillcustomer/firebase_options.dart';
import 'package:quickfillcustomer/loginPages/loginpage.dart';
import 'package:quickfillcustomer/loginPages/sucess.dart';
import 'package:quickfillcustomer/pages/addlist.dart';
import 'package:quickfillcustomer/pages/orderCancelled.dart';
import 'package:quickfillcustomer/pages/orderDelivered.dart';
import 'package:quickfillcustomer/pages/orderPage.dart';
import 'package:quickfillcustomer/pages/orderShipped.dart';
import 'package:quickfillcustomer/pages/products.dart';
import 'package:quickfillcustomer/pages/splash.dart';
import 'package:quickfillcustomer/pages/trial.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    // String initialRoute = (Constants.storeId == 'test') ? 'trial' : 'splash';

    return MaterialApp(
        routes: {
          'adlist': (context) => const AdList(),
          'trial': (context) => const TrialPage(),
          'splash': (context) => const splash(),
          'loginPage': (context) => const loginPage(),
          'productPage': (context) => productPage(),
          'sucessPage': (context) => sucessPage(),
          'orderView': (context) {
            final Map<String, dynamic> arguments = ModalRoute.of(context)!
                .settings
                .arguments as Map<String, dynamic>;

            return orderView(
              data: arguments['data'],
              docId: arguments['docId'],
            );
          },
          'orderShip': (context) {
            final Map<String, dynamic> arguments = ModalRoute.of(context)!
                .settings
                .arguments as Map<String, dynamic>;

            return orderShip(
              data: arguments['data'],
              docId: arguments['docId'],
            );
          },
          'orderCancel': (context) {
            final Map<String, dynamic> arguments = ModalRoute.of(context)!
                .settings
                .arguments as Map<String, dynamic>;

            return orderCancel(
              data: arguments['data'],
              docId: arguments['docId'],
            );
          },
          'orderDeliver': (context) {
            final Map<String, dynamic> arguments = ModalRoute.of(context)!
                .settings
                .arguments as Map<String, dynamic>;

            return orderDeliver(
              data: arguments['data'],
              docId: arguments['docId'],
            );
          },
        },
        debugShowCheckedModeBanner: false,
        title: 'Cloi',
        home: splash() // Use the determined initial route
        );
  }
}
