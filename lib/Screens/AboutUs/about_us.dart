import 'package:flutter/material.dart';

import '../../Themes/appImages.dart';
import '../../Themes/app_colors.dart';

class AboutUsPage extends StatelessWidget {
  const AboutUsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('About Us'),
        backgroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Top Banner Section
            Image.asset(
             logo, // collage of client banners
              height: 100,
              fit: BoxFit.cover,
            ),

            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 50),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "ABOUT US",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                  SizedBox(height: 16),
                  Text(
                    "In the world where everyone is trying to be the odd and different, Metallicz Media is a very even and unique 360° solution provider. Serving the clients across the nation, the brand deals in offering solutions ranging from in-store & external branding, commercial interiors and architectural requirements.\n\n"
                    "Metallicz Media is a progressive branding and architectural solution facilitator, offering the expertise of over 125 honed professionals to channelize and optimize media communication and consultation. Starting with an initial investment of ₹ 5,000, today the company has a worth of around ₹ 40 crores, reflecting the planning, hard work and dedication involved. Metallicz Media incorporates clever imagery and patterns to convey key messages in a manner that they are etched in the memory of the onlookers.\n\n"
                    "The company stands out in client offerings and services, as it is also engaged in providing architectural and interior designing for offices, retail stores and exhibitions, making it one of its kind. Metallicz Media is a 360° solution provider, where the experts design, conceptualise and execute to deliver finesse.\n\n"
                    "Focussed on delivering divergent, unique and cost effective solutions to the brands, Metallicz Media masters in branding & printing, creative artwork & design and outdoor advertising in the shortest turnaround time. Taking of efficiency, Metallicz Media is an authorised convertor of 3M India Ltd., ISO certified and CRISIL rated.\n\n"
                    "While retail branding in rural areas is a task in itself, Metallicz Media is well-known for executing all sorts of projects from the flashy metropolitans to the remotest of the areas. Talking about the Pan India presence, the company has executed and completed projects in almost every city in the country, from Leh in the north to Trivandrum in the south and Porbandar in the west to Agartala in the east.\n\n"
                    "From one corner of the country to the other, Metallicz Media is engaged in offering varied services through the offices located in Noida (Delhi NCR), Pune, Jaipur, Jamshedpur and counting.\n\n"
                    "Unique concepts, quick and precise solutions has enabled the company to rope in a number of Fortune 500 brands, including, Bose Speakers, Adidas, Daikin Air condition, Haier, Oppo, Vivo, OYO, Patanjali, Muthoot Finance, Gionee, JK Tyre, Liberty, Andhra Bank, Colorbar, Ampliifone, Luxor (Parker), Hettich, Good Year, 24*7 and numerous more.",
                    style: TextStyle(fontSize: 15, height: 1.5),
                    textAlign: TextAlign.justify,
                  ),
                  SizedBox(height: 40),
                  Center(
                    child: Text(
                      "Copyright © All Rights Reserved\nDesign by: Oxymora Technology Pvt Ltd",
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
