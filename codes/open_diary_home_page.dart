import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:flutter/material.dart';
import 'package:open_diary_app/entry_list_page.dart';
import 'package:open_diary_app/profile_page.dart';

class OpenDiaryAppHomePage extends StatefulWidget {
  const OpenDiaryAppHomePage({super.key});

  @override
  State<OpenDiaryAppHomePage> createState() => _OpenDiaryAppHomePageState();
}

class _OpenDiaryAppHomePageState extends State<OpenDiaryAppHomePage> {
  int _selectedIndex = 0;
  static const List<Widget> _widgetOptions = <Widget>[
    EntryListPage(),
    ProfilePage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Open Diary'),
        actions: [
          IconButton(
            onPressed: Amplify.Auth.signOut,
            icon: const Icon(
              Icons.exit_to_app,
            ),
          )
        ],
      ),
      body: _widgetOptions[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.edit_note),
            label: 'Entries',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.amber[800],
        onTap: _onItemTapped,
      ),
    );
  }
}
