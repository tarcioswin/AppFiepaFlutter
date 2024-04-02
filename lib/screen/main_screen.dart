import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

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
    ModalRoute.of(context)!
        .addLocalHistoryEntry(LocalHistoryEntry(onRemove: _stopSearching));
    setState(() {
      _isSearching = true;
    });
  }

  void _stopSearching() {
    _clearSearchQuery();
    setState(() {
      _isSearching = false;
    });
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
        leading: _isSearching
            ? BackButton(
                color: Colors.white,
                onPressed: _stopSearching,
              )
            : IconButton(
                icon: const Icon(Icons.clear, color: Colors.white),
                onPressed: () {
                  _clearSearchQuery();
                  _stopSearching(); // Add this line to stop searching when 'X' is pressed
                },
              ),
        backgroundColor: const Color.fromARGB(255, 1, 138, 24),
        title: _isSearching ? _buildSearchField() : const Text(""),
        actions: _buildActions(),
        centerTitle: true,
      ),
      body: _children[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        onTap: onTabTapped,
        currentIndex: _currentIndex,
        backgroundColor: Colors.white,
        selectedItemColor: const Color.fromARGB(255, 1, 138, 24),
        unselectedItemColor: Colors.grey,
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

  void handleMenuAction(String value) {
    switch (value) {
      case 'Logout':
        // Handle logout action
        if (kDebugMode) {
          print('Logout pressed');
        }
        break;
      case 'About':
        // Handle about action
        if (kDebugMode) {
          print('About pressed');
        }
        break;
      case 'Cadastro':
        // Handle cadastro action
        if (kDebugMode) {
          print('Cadastro pressed');
        }
        break;
    }
  }
}

class MapScreen extends StatelessWidget {
  const MapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return InteractiveViewer(
      panEnabled: true, // Set it to false to prevent panning.
      boundaryMargin: const EdgeInsets.all(80), // Respect margins
      minScale: 0.5, // The minimum zoom level
      maxScale: 4, // The maximum zoom level
      child: Center(
        child: Image.asset('lib/images/Mapa.jpg'), // Your image asset path
      ),
    );
  }
}

class AgendaScreen extends StatelessWidget {
  const AgendaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text("Agenda Screen Placeholder"));
  }
}
