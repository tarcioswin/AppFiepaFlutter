import 'package:flutter/material.dart';
import 'package:timeline_tile/timeline_tile.dart';
import 'about_screen.dart';
import 'events_data.dart';
import 'map_screen.dart';
import 'company_data.dart';

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
        key: ValueKey(
            newQuery), // This ensures the widget rebuilds with new data
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
                    leading: const Icon(Icons.place,
                        color:
                            Color.fromARGB(255, 240, 9, 9)), // Icon added here
                    title: Text(option,
                        style: const TextStyle(color: Colors.black)),
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
      case 'Sobre':
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => const AboutScreen()));
        break;
    }
  }
}

Map<String, List<Map<String, String>>> groupEventsByLocation(
    List<Map<String, dynamic>> eventData) {
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
          final List<Widget> detailWidgets =
              eventDay['details'].map<Widget>((detail) {
            List<String> speakerImages =
                List<String>.from(detail['speakerImages'] ?? []);
            List<String> speakerNames =
                List<String>.from(detail['speakerNames'] ?? []);
            String title = detail['title'] ?? 'No Title Provided';
            List<TextSpan> titleTextSpans = _formatTitle(title);
            String eventType = detail['type'] ?? 'Unknown';
            IconData eventTypeIcon =
                eventType == "Painel" ? Icons.group : Icons.speaker_notes;

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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.event,
                            color: Color.fromARGB(255, 54, 73, 244)),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            title, // Use your title variable or the method that retrieves the title
                            textAlign: TextAlign.left,
                            style: const TextStyle(
                              fontSize: 14, // Set your desired font size
                              color: Colors.black, // Set your desired color
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.access_time,
                            color: Color.fromARGB(255, 7, 131, 17)),
                        const SizedBox(width: 8),
                        Text(detail['time'] ?? 'No Time Provided'),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.place, color: Colors.red),
                        const SizedBox(width: 8),
                        Expanded(
                            child: Text(
                                detail['location'] ?? 'No Location Provided')),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(eventTypeIcon),
                        const SizedBox(width: 4),
                        Text(eventType),
                      ],
                    ),
                    const SizedBox(height: 10),
                    // Horizontal list for speaker images
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: List.generate(speakerImages.length, (index) {
                          return Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: GestureDetector(
                              onTap: () => _showImageDialog(context,
                                  speakerImages[index], speakerNames[index]),
                              child: CircleAvatar(
                                backgroundImage:
                                    AssetImage(speakerImages[index]),
                                radius: 24,
                              ),
                            ),
                          );
                        }),
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
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            children: detailWidgets,
          );
        },
      ),
    );
  }

  List<TextSpan> _formatTitle(String title) {
    // Check for multiple prefixes and apply bold formatting
    const List<String> boldPrefixes = ["Palestra:", "Painel:"];
    for (String prefix in boldPrefixes) {
      if (title.startsWith(prefix)) {
        return [
          TextSpan(
              text: prefix,
              style: const TextStyle(fontWeight: FontWeight.bold)),
          TextSpan(text: title.substring(prefix.length)),
        ];
      }
    }
    return [TextSpan(text: title)];
  }

  void _showImageDialog(
      BuildContext context, String imagePath, String speakerName) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.topCenter,
            children: <Widget>[
              Positioned(
                right: -40.0,
                top: -40.0,
                child: InkResponse(
                  onTap: () {
                    Navigator.of(context).pop();
                  },
                  child: const CircleAvatar(
                    backgroundColor: Colors.red,
                    child: Icon(Icons.close, color: Colors.white),
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(20),
                margin: const EdgeInsets.only(top: 20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset(imagePath),
                    Padding(
                      padding: const EdgeInsets.only(top: 16),
                      child: Text(speakerName,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16)),
                    ),
                    // Optionally add more content here
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
