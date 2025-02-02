import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firestore
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:judica/common_pages/profile.dart';
import 'package:judica/user/chat_bot_user.dart';
import 'package:judica/user/chatapp.dart';
import 'package:judica/user/filing_case.dart';
import 'package:judica/user/govscheme.dart';
import 'package:judica/user/voice.dart';

class UserHome extends StatefulWidget {
  const UserHome({super.key});

  @override
  State<UserHome> createState() => _UserHomeState();
}

class _UserHomeState extends State<UserHome> {
  int _selectedIndex = 0; // Tracks the selected tab
  bool _isUserDataChecked = false; // Flag to track if user data has been checked

  // Define the pages for navigation
  static final List<Widget> _pages = <Widget>[
    const ChatScreenUser(),
     ComplaintForm(),// ChatBot Page
    const ProfilePage(),
    SpeechDemo()
  ];

  // Function to handle tab selection
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  // Check user data in Firestore
  Future<void> _checkUserDetails() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user != null && !_isUserDataChecked) {
      final userDoc =
      FirebaseFirestore.instance.collection('users').doc(user.email);
      final docSnapshot = await userDoc.get();

      // If document exists and all required data is present, set to Home page
      if (docSnapshot.exists &&
          docSnapshot.data()?['Mobile Number'] != null &&
          docSnapshot.data()?['email'] != null &&
          docSnapshot.data()?['username'] != null &&
          docSnapshot.data()?['role'] != null) {
        // User has complete data, stay on Home page
        setState(() {
          _selectedIndex = 0; // Set to Home tab if data is valid
          _isUserDataChecked = true;
        });
      } else {
        // If any data is missing, set to Profile page
        setState(() {
          _selectedIndex = 1; // Navigate to Profile Page if data is incomplete
          _isUserDataChecked = true;
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _checkUserDetails(); // Check user details only once during initialization
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Judica"),
        backgroundColor: const Color.fromRGBO(255, 165, 89, 1), // Lighter orange
        automaticallyImplyLeading: false,
        actions: [
          IconButton(onPressed: (){
            showDialog(context: context, builder: (context)=>GovernmentInfo(),);
          }, icon: Icon(Icons.notifications))
        ],// Removes the back button
      ),
      body: _pages[_selectedIndex], // Display the selected page
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.chat),
            label: 'ChatBot',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.file_copy_outlined),
            label: 'Filing',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.file_copy_outlined),
            label: 'Chat',
          ),
        ],
        currentIndex: _selectedIndex, // Highlight the selected tab
        selectedItemColor: Colors.white, // Selected icon color
        unselectedItemColor: Colors.black54, // Unselected icon color
        backgroundColor: const Color.fromRGBO(255, 165, 89, 1), // Lighter orange
        onTap: _onItemTapped, // Handle tab selection
      ),
    );
  }
}
