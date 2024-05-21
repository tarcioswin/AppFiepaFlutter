import 'package:flutter/material.dart';
import 'about_screen.dart';
import 'map_screen.dart';
import 'company_data.dart';
import 'agenda_screen.dart'; 

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
          return const Iterable<String>.empty(); // When text is empty, show no options.
        }
        return companyNames.where((String option) {
          return option.toLowerCase().contains(textEditingValue.text.toLowerCase());
        });
      },
      onSelected: (String selection) {
        updateSearchQuery(selection);
        // Dismiss the keyboard after a selection
        FocusScope.of(context).requestFocus(FocusNode());
      },
      fieldViewBuilder: (context, textEditingController, focusNode, onFieldSubmitted) {
        textEditingController.text = _searchQueryController.text; // Sync with the main controller
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
                textEditingController.clear(); // Only clear the text, do not stop searching
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
                    leading: const Icon(Icons.place, color: Color.fromARGB(255, 240, 9, 9)), // Icon added here
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
    if (_currentIndex == 0) {
      // Check if the current index is 0 (Map tab)
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
              value: 'Sobre',
              child: ListTile(
                leading: Icon(Icons.info_outline),
                title: Text('Sobre'),
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
              value: 'Sobre',
              child: ListTile(
                leading: Icon(Icons.info_outline),
                title: Text('Sobre'),
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
          backgroundColor: const Color.fromARGB(255, 5, 73, 16),
          title: _isSearching
              ? _buildSearchField()
              : const Text("Feira da Indústria do Pará",
                  style: TextStyle(color: Colors.white, fontSize: 18)),
          actions: _buildActions(),
          centerTitle: true,
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        body: Container(
          color: const Color.fromARGB(255, 19, 44, 2), // Set the background color to black
          child: _children[_currentIndex],
        ),
        bottomNavigationBar: BottomNavigationBar(
          onTap: onTabTapped,
          currentIndex: _currentIndex,
          backgroundColor: const Color.fromARGB(255, 255, 243, 243),
          selectedItemColor: const Color.fromARGB(255, 1, 138, 24),
          unselectedItemColor: const Color.fromARGB(255, 179, 176, 176),
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.map), label: 'Mapa'),
            BottomNavigationBarItem(icon: Icon(Icons.calendar_today), label: 'Agenda'),
          ],
        ),
      ),
    );
  }

  Future<void> handleMenuAction(String value) async {
    switch (value) {
      case 'Sobre':
        Navigator.push(context, MaterialPageRoute(builder: (context) => const AboutScreen()));
        break;
    }
  }
}
