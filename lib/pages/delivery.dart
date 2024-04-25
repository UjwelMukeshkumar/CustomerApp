import 'package:flutter/material.dart';
import 'package:quickfillcustomer/color.dart';

class DeliveryDetails extends StatelessWidget {
  final String name;
  final String phone;
  final String address;
  final String payMethod;
  final String delTime;
  final double subtotal;
  final double extraCharge;

  DeliveryDetails({
    required this.name,
    required this.phone,
    required this.address,
    required this.payMethod,
    required this.delTime,
    required this.subtotal,
    required this.extraCharge,
  });

  @override
  Widget build(BuildContext context) {
    final double w = MediaQuery.of(context).size.width;
    final double h = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.mainColor,
        title: Text('Delivery Details'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: h * 0.008),
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: 'Name : ',
                          style: TextStyle(
                              fontWeight: FontWeight.w400,
                              color: AppColors.cardColor),
                        ),
                        TextSpan(
                          text: ' $name',
                          style: TextStyle(
                              fontWeight: FontWeight.w400,
                              color: AppColors.secondarytextColor),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: h * 0.005),
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: 'No : ',
                          style: TextStyle(
                              fontWeight: FontWeight.w400,
                              color: AppColors.cardColor),
                        ),
                        TextSpan(
                          text: ' $phone',
                          style: TextStyle(
                              fontWeight: FontWeight.w400,
                              color: AppColors.secondarytextColor),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: h * 0.005),
                  Text(
                    'Address :',
                    style: TextStyle(
                        fontWeight: FontWeight.w400,
                        color: AppColors.cardColor),
                  ),
                  Text(
                    '$address',
                    style: TextStyle(
                        fontWeight: FontWeight.w400,
                        color: AppColors.secondarytextColor),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(5.0),
              child: Center(
                child: Container(
                    width: w * 0.85,
                    child: Image.asset('assets/yellow_line.png')),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Payment : ',
                  style: TextStyle(
                      fontWeight: FontWeight.w500, color: AppColors.cardColor),
                ),
                Text(
                  '$payMethod ',
                  style: TextStyle(
                      fontWeight: FontWeight.w600, color: AppColors.shipColor),
                ),
                Text(
                  '| Dispatch in: $delTime',
                  style: TextStyle(
                      fontWeight: FontWeight.w500, color: AppColors.cardColor),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(5.0),
              child: Center(
                child: Container(
                    width: w * 0.85,
                    child: Image.asset('assets/yellow_line.png')),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Center(
                child: Container(
                    width: w * 0.85, child: Image.asset('assets/adline.png')),
              ),
            ),
            Center(
              child: Text(
                'Total Amount: ₹${subtotal + extraCharge}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Center(
                child: Container(
                    width: w * 0.85, child: Image.asset('assets/adline.png')),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
