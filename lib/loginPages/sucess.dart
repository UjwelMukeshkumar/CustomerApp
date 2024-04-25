import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:lottie/lottie.dart';
import 'package:quickfillcustomer/color.dart';

class sucessPage extends StatefulWidget {
  const sucessPage({super.key});

  @override
  State<sucessPage> createState() => _sucessPageState();
}

class _sucessPageState extends State<sucessPage> {
  @override
  void initState() {
    super.initState();

    // Delay the navigation by 4 seconds
    Future.delayed(const Duration(seconds: 3), () {
      Navigator.pushNamedAndRemoveUntil(
          context, 'productPage', (route) => false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final h = MediaQuery.of(context).size.height;
    final w = MediaQuery.of(context).size.width;
    return MediaQuery(
      data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
      child: Scaffold(
        backgroundColor: AppColors.primaryColor,
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Spacer(),
            Spacer(),
            Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // Image.asset(
                //   'assets/logo.png', // Replace with the path to your image asset
                //   width: w * 0.63, // Set the desired width of the image
                // ),
              ],
            ),
            Center(
              child: SizedBox(
                width: w * 0.7, // Set the desired width of the container
                // Set the desired height of the container
                // Container background color
                child: Lottie.asset(
                  'assets/thankyou.json', // Replace with the path to your Lottie animation
                ),
              ),
            ),
            Center(
              child: Padding(
                padding: const EdgeInsets.only(top: 1),
                child: Text(
                  "Your account have been created ",
                  style: GoogleFonts.poppins(
                    textStyle: TextStyle(
                      color: AppColors.thirdtextColor,
                      fontSize: w * 0.039,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(
              height: h * 0.01,
            ),
            Spacer(),
            Spacer(),
          ],
        ),
      ),
    );
  }
}
