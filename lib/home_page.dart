import 'package:flutter/material.dart';
import 'file_complaint_page.dart';
import 'display_board_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF34495e), Color(0xFF2c3e50)], // Gradient colors
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const SizedBox(height: 40), // Add some space between top and logo

            // Logo Image at the top
            Image.asset(
              'assets/Sentinels_logo.svg.png', // Path to the image in your project
              width: 180, // Adjust the size as needed
              height: 180,
            ),
            const SizedBox(height: 10), // Space between logo and app name

            // App Name below the logo
            const Text(
              'Sentinel',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 2.0,
              ),
            ),
            const SizedBox(height: 50), // Space between app name and buttons

            // New Report Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30.0), // Add padding to the left and right of buttons
              child: SizedBox(
                width: double.infinity, // Make button take full width
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1abc9c), // Updated button background color
                    foregroundColor: Colors.white, // Text color
                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                    elevation: 5, // Add shadow for a floating effect
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => FileComplaintPage(),
                      ),
                    );
                  },
                  child: const Text(
                    'New Report',
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 30), // Increased space between buttons

            // Display Board Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30.0), // Add padding to the left and right of buttons
              child: SizedBox(
                width: double.infinity, // Make button take full width
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1abc9c), // Updated button background color
                    foregroundColor: Colors.white, // Text color
                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                    elevation: 5, // Add shadow for a floating effect
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DisplayBoardPage(),
                      ),
                    );
                  },
                  child: const Text(
                    'Display Board',
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 30), // Increased space between buttons

            // App Info Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30.0), // Add padding to the left and right of buttons
              child: SizedBox(
                width: double.infinity, // Make button take full width
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1abc9c), // Updated button background color
                    foregroundColor: Colors.white, // Text color
                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                    elevation: 3, // Subtle shadow effect
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    // Nothing happens for App Info
                  },
                  child: const Text(
                    'App Info',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 40), // Space between buttons and trademark

            // Spacer to push the trademark to the bottom
            const Spacer(),

            // Official Trademark Text at the bottom
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                '@Trademarked by Amrita',
                style: TextStyle(
                  color: Colors.white70, // Light gray color
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                  fontWeight: FontWeight.w300,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 20), // Space between text and bottom of screen
          ],
        ),
      ),
    );
  }
}
