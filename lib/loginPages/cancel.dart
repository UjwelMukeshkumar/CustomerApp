import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:lottie/lottie.dart';
import 'package:quickfillcustomer/color.dart';

class cancel extends StatefulWidget {
  const cancel({super.key});

  @override
  State<cancel> createState() => _cancelState();
}

class _cancelState extends State<cancel> {
  @override
  void initState() {
    super.initState();

    // Delay the navigation by 4 seconds
    Future.delayed(const Duration(seconds: 5), () {
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
            Center(
              child: SizedBox(
                height: h * 0.8,
                width:
                    double.infinity, // Set the desired width of the container
                // Set the desired height of the container
                // Container background color
                child: Lottie.asset('assets/cancel.json',
                    repeat:
                        null // Replace with the path to your Lottie animation
                    ),
              ),
            ),
            Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  " Order ",
                  style: GoogleFonts.poppins(
                    textStyle: TextStyle(
                      color: AppColors.thirdtextColor,
                      fontSize: w * 0.055,
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                ),
                Text(
                  " Error",
                  style: GoogleFonts.poppins(
                    textStyle: TextStyle(
                      color: AppColors.shipColor,
                      fontSize: w * 0.055,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            Spacer(),
            Spacer(),
          ],
        ),
      ),
    );
  }
}
