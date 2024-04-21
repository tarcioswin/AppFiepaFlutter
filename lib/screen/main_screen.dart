import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timeline_tile/timeline_tile.dart';
import 'login_screen.dart';
import 'update_screen.dart';
import 'about_screen.dart';
import 'events_data.dart';
import 'map_screen.dart';
import 'company_data.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  final List<Widget> _children;
  bool _isSearching = false;
  final TextEditingController _searchQueryController = TextEditingController();

  _MainScreenState() : _children = [const MapScreen(), const AgendaScreen()];

  void _startSearch() {
    ModalRoute.of(context)?.addLocalHistoryEntry(
      LocalHistoryEntry(onRemove: _stopSearching),
    );
    setState(() => _isSearching = true);
  }

  void _stopSearching() {
    setState(() {
      _isSearching = false;
      _searchQueryController.clear();
    });
    if (Navigator.canPop(context)) {
      Navigator.of(context).pop();
    }
  }

void updateSearchQuery(String newQuery) {
  setState(() {
    _searchQueryController.text = newQuery;
    Offset? newMarkerPosition = companyPositions[newQuery];
    _children[0] = MapScreen(
      key: ValueKey(newQuery), // This ensures the widget rebuilds with new data
      markerPosition: newMarkerPosition,
    );
  });
}





  Widget _buildSearchField() {
    return Autocomplete<String>(
      optionsBuilder: (TextEditingValue textEditingValue) {
        if (textEditingValue.text.isEmpty) {
          return const Iterable<
              String>.empty(); // When text is empty, show no options.
        }
        return companyNames.where((String option) {
          return option
              .toLowerCase()
              .contains(textEditingValue.text.toLowerCase());
        });
      },
      onSelected: (String selection) {
        updateSearchQuery(selection);
        // Dismiss the keyboard after a selection
        FocusScope.of(context).requestFocus(FocusNode());
      },
      fieldViewBuilder:
          (context, textEditingController, focusNode, onFieldSubmitted) {
        textEditingController.text =
            _searchQueryController.text; // Sync with the main controller
        return TextField(
          controller: textEditingController,
          focusNode: focusNode,
          autofocus: true,
          style: const TextStyle(color: Colors.white, fontSize: 16.0),
          decoration: InputDecoration(
            hintText: 'Procurar Stands...',
            border: InputBorder.none,
            hintStyle: const TextStyle(color: Colors.white70),
            suffixIcon: IconButton(
              icon: const Icon(Icons.clear, color: Colors.white),
              onPressed: () {
                textEditingController
                    .clear(); // Only clear the text, do not stop searching
                // Optionally update state related to search
                updateSearchQuery("");
              },
            ),
          ),
          onChanged: (query) {
            updateSearchQuery(query); // Update search query on text change
          },
        );
      },
      optionsViewBuilder: (context, onSelected, options) {
        return Align(
          alignment: Alignment.topLeft,
          child: Material(
            elevation: 5.0,
            borderRadius: BorderRadius.circular(10),
            child: SizedBox(
              width: 255,
              height: 300,
              child: ListView.builder(
                padding: EdgeInsets.zero,
                itemCount: options.length,
                itemBuilder: (context, index) {
                  final option = options.elementAt(index);
                 return ListTile(
                    leading: const Icon(Icons.place, color: Color.fromARGB(255, 240, 9, 9)),  // Icon added here
                    title: Text(option, style: const TextStyle(color: Colors.black)),
                    onTap: () {
                      onSelected(option);
                    },
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }



List<Widget> _buildActions() {
    if (_currentIndex == 0) {  // Check if the current index is 0 (Map tab)
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
                    leading: Icon(Icons.exit_to_app),
                    title: Text('Sair'),
                  ),
                ),
                const PopupMenuItem<String>(
                  value: 'Sobre',
                  child: ListTile(
                    leading: Icon(Icons.info_outline),
                    title: Text('Sobre'),
                  ),
                ),
                const PopupMenuItem<String>(
                  value: 'Atualizar cadastro',
                  child: ListTile(
                    leading: Icon(Icons.update),
                    title: Text('Atualizar Cadastro'),
                  ),
                ),
              ],
            ),
        ];
    } else {
        return [
            PopupMenuButton<String>(
              icon: const Icon(Icons.menu, color: Colors.white),
              onSelected: handleMenuAction,
              itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                const PopupMenuItem<String>(
                  value: 'Sair',
                  child: ListTile(
                    leading: Icon(Icons.exit_to_app),
                    title: Text('Sair'),
                  ),
                ),
                const PopupMenuItem<String>(
                  value: 'Sobre',
                  child: ListTile(
                    leading: Icon(Icons.info_outline),
                    title: Text('Sobre'),
                  ),
                ),
                const PopupMenuItem<String>(
                  value: 'Atualizar cadastro',
                  child: ListTile(
                    leading: Icon(Icons.update),
                    title: Text('Atualizar Cadastro'),
                  ),
                ),
              ],
            ),
        ];
    }
}


void onTabTapped(int index) {
  if (index != 0 && _isSearching) {
    // If moving away from the map tab and search is active, stop searching
    _stopSearching();
  }
  setState(() {
    _currentIndex = index;
  });
}

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // If search is active and the keyboard is not focused
        if (_isSearching && FocusScope.of(context).hasPrimaryFocus) {
          _stopSearching();
        }
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          backgroundColor: const Color.fromARGB(255, 1, 138, 24),
          title: _isSearching
              ? _buildSearchField()
              : const Text("Feira da Indústria do Pará",
                  style: TextStyle(color: Colors.white, fontSize: 18)),
          actions: _buildActions(),
          centerTitle: true,
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        body: _children[_currentIndex],
        bottomNavigationBar: BottomNavigationBar(
          onTap: onTabTapped,
          currentIndex: _currentIndex,
          backgroundColor: const Color.fromARGB(255, 255, 243, 243),
          selectedItemColor: const Color.fromARGB(255, 1, 138, 24),
          unselectedItemColor: const Color.fromARGB(255, 179, 176, 176),
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.map), label: 'Mapa'),
            BottomNavigationBarItem(
                icon: Icon(Icons.calendar_today), label: 'Agenda'),
          ],
        ),
      ),
    );
  }

  Future<void> handleMenuAction(String value) async {
    switch (value) {
      case 'Sair':
        await FirebaseAuth.instance.signOut();
        await GoogleSignIn().signOut();
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('stayLoggedIn', false);
        // ignore: use_build_context_synchronously
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const LoginScreen()),
          (Route<dynamic> route) => false,
        );
        break;
      case 'Sobre':
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => const AboutScreen()));
        break;
      case 'Atualizar cadastro':
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => const UpdateScreen()));
        break;
    }
  }
}


Map<String, List<Map<String, String>>> groupEventsByLocation(List<Map<String, dynamic>> eventData) {
  Map<String, List<Map<String, String>>> eventsByLocation = {};

  for (var day in eventData) {
    for (var detail in day['details']) {
      String location = detail['location'];
      if (!eventsByLocation.containsKey(location)) {
        eventsByLocation[location] = [];
      }
      eventsByLocation[location]!.add({
        'date': day['date'],
        'time': detail['time'],
        'title': detail['title'],
      });
    }
  }

  return eventsByLocation;
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
          final List<Widget> detailWidgets = eventDay['details'].map<Widget>((detail) {
            return TimelineTile(
              alignment: TimelineAlign.manual,
              lineXY: 0.1,
              isFirst: eventDay['details'].indexOf(detail) == 0,
              isLast: eventDay['details'].indexOf(detail) ==
                  eventDay['details'].length - 1,
              indicatorStyle: const IndicatorStyle(
                width: 20,
                color: Colors.green,
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
                                  color: Theme.of(context).colorScheme.secondary),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(detail['title'],
                                    style: const TextStyle(fontWeight: FontWeight.bold)),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(Icons.access_time,
                                  color: Theme.of(context).colorScheme.secondary),
                              const SizedBox(width: 8),
                              Text(detail['time']),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(Icons.place,
                                  color: Theme.of(context).colorScheme.secondary),
                              const SizedBox(width: 8),
                              Expanded(child: Text(detail['location'])),
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

          return ExpansionTile(
            title: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                eventDay['date'],
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            children: detailWidgets,
          );
        },
      ),
    );
  }
}