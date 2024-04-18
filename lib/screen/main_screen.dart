import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:timeline_tile/timeline_tile.dart';
import 'login_screen.dart';
import 'update_screen.dart';
import 'about_screen.dart';
import 'events_data.dart';
import 'map_screen.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});



 Widget build(BuildContext context) {
    return const Scaffold(
      body: MapScreen(), // Use the MapScreen widget
    );
  }


  @override
  // ignore: library_private_types_in_public_api
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  final List<Widget> _children = [const MapScreen(), const AgendaScreen()];
  bool _isSearching = false;
  final TextEditingController _searchQueryController = TextEditingController();

  void onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  void _startSearch() {
    ModalRoute.of(context)?.addLocalHistoryEntry(
      LocalHistoryEntry(onRemove: _stopSearching),
    );
    setState(() {
      _isSearching = true;
    });
  }

  void _stopSearching() {
    setState(() {
      _isSearching = false;
      _searchQueryController.clear();
    });
    if (Navigator.canPop(context)) {
      Navigator.of(context).pop(); // Ensure the local history entry is popped.
    }
  }

  void _clearSearchQuery() {
    setState(() {
      _searchQueryController.clear();
    });
  }

  Widget _buildSearchField() {
    return TextField(
      controller: _searchQueryController,
      autofocus: true,
      decoration: InputDecoration(
        hintText: 'Procurar...',
        border: InputBorder.none,
        hintStyle: const TextStyle(color: Colors.white70),
        suffixIcon: IconButton(
          icon: const Icon(Icons.clear, color: Colors.white),
          onPressed: () {
            _clearSearchQuery();
            _stopSearching(); // Stop searching when 'X' is pressed
          },
        ),
      ),
      style: const TextStyle(color: Colors.white, fontSize: 16.0),
      onChanged: (query) => updateSearchQuery(query),
    );
  }

  void updateSearchQuery(String newQuery) {
    // Handle the search query update
    if (kDebugMode) {
      print("Searching for: $newQuery");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          backgroundColor: const Color.fromARGB(255, 1, 138, 24),
        title: _isSearching ? _buildSearchField() : const Text("Feira da Indústria do Pará",
         style: TextStyle(color: Colors.white, fontSize: 20)),
        actions: _buildActions(),
        centerTitle: true,
      ),
      body: _children[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        onTap: onTabTapped,
        currentIndex: _currentIndex,
        backgroundColor: const Color.fromARGB(255, 255, 243, 243),
        selectedItemColor: const Color.fromARGB(255, 1, 138, 24),
        unselectedItemColor: const Color.fromARGB(255, 179, 176, 176),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.map),
            label: 'Mapa',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'Agenda',
          ),
        ],
      ),
    );
  }

  List<Widget> _buildActions() {
    if (_isSearching) {
      return [
        IconButton(
          icon: const Icon(Icons.search, color: Colors.white),
          onPressed: _startSearch,
        ),
      ];
    } else {
      return [
        IconButton(
          icon: const Icon(Icons.search, color: Colors.white),
          onPressed: _startSearch,
        ),
        PopupMenuButton<String>(
          icon: const Icon(Icons.menu, color: Colors.white),
          onSelected: handleMenuAction,
          itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
            const PopupMenuItem<String>(
              value: 'Sair',
              child: ListTile(
                leading: Icon(Icons.exit_to_app), // Icon for "Sair"
                title: Text('Sair'),
              ),
            ),
            const PopupMenuItem<String>(
              value: 'Sobre',
              child: ListTile(
                leading: Icon(Icons.info_outline), // Icon for "Sobre"
                title: Text('Sobre'),
              ),
            ),
            const PopupMenuItem<String>(
              value: 'Atualizar cadastro',
              child: ListTile(
                leading: Icon(Icons.update), // Icon for "Atualizar Cadastro"
                title: Text('Atualizar Cadastro'),
              ),
            ),
          ],
        ),
      ];
    }
  }

  Future<void> handleMenuAction(String value) async {
    switch (value) {
      case 'Sair':
// Handle logout action
        try {
          await FirebaseAuth.instance.signOut(); // Firebase logout
          await GoogleSignIn().signOut(); // Google logout
          // Navigate back to the LoginScreen
          // ignore: use_build_context_synchronously
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const LoginScreen()),
            (Route<dynamic> route) => false,
          );
        } catch (error) {
          if (kDebugMode) {
            print('Logout error: $error');
          }
          // Optionally, show an error message if something goes wrong
        }
        break;
      case 'Sobre':
        // Handle about action
        try {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => const AboutScreen()));
        } catch (error) {
          if (kDebugMode) {
            print('Logout error: $error');
          }
          // Optionally, show an error message if something goes wrong
        }
        break;
      case 'Atualizar cadastro':
           // Handle about action
        try {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => const UpdateScreen()));
        } catch (error) {
          if (kDebugMode) {
            print('Logout error: $error');
          }
          // Optionally, show an error message if something goes wrong
        }
        break;
    }
  }
}






class AgendaScreen extends StatelessWidget {
  const AgendaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView.builder(
        itemCount: eventsData.length,
        itemBuilder: (context, index) {
          final eventDay = eventsData[index];
          List<Widget> detailWidgets =
              eventDay['details'].map<Widget>((detail) {
            return TimelineTile(
              alignment: TimelineAlign.manual,
              lineXY: 0.1,
              isFirst: eventDay['details'].indexOf(detail) == 0,
              isLast: eventDay['details'].indexOf(detail) ==
                  eventDay['details'].length - 1,
              indicatorStyle: const IndicatorStyle(
                width: 20,
                color: Colors.green, // Set your desired color here
                padding: EdgeInsets.all(6),
              ),
              beforeLineStyle: const LineStyle(
                color: Color.fromARGB(255, 230, 9, 9),
                thickness: 1.5,
              ),
              endChild: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.event,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .secondary), // Example icon for event
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  detail['title'],
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(Icons.access_time,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .secondary), // Icon for time
                              const SizedBox(width: 8),
                              Text(detail['time']),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(Icons.place,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .secondary), // Icon for location
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(detail['location']),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList();

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  eventDay['date'],
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              ...detailWidgets,
            ],
          );
        },
      ),
    );
  }
}
