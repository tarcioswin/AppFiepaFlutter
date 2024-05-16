import 'package:flutter/material.dart';
import 'package:flutter_sticky_header/flutter_sticky_header.dart';
import 'package:share/share.dart';
import 'package:timeline_tile/timeline_tile.dart';
import 'package:url_launcher/url_launcher.dart';
import 'events_data.dart'; // Assuming this has necessary data structures

class AgendaScreen extends StatelessWidget {
  const AgendaScreen({super.key});

  String formatEventTitle(int index) {
    int dayNumber = index + 1;
    return "Programação do $dayNumber${dayNumber == 1 ? "º" : "º"} dia do Evento";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          for (int index = 0; index < eventsData.length; index++)
            SliverStickyHeader(
              header: Container(
                height: 60,
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 227, 229, 231),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 1,
                      blurRadius: 3,
                      offset: const Offset(0, 1), // changes position of shadow
                    ),
                  ],
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                alignment: Alignment.centerLeft,
                child: Row(
                  children: [
                    const Icon(Icons.event,
                        color: Colors.green), // Example icon
                    const SizedBox(width: 10), // Space between icon and text
                    Text(
                      eventsData[index]['date'],
                      style: const TextStyle(
                          color: Color.fromARGB(255, 2, 2, 2),
                          fontWeight: FontWeight.bold,
                          fontSize: 18),
                    ),
                  ],
                ),
              ),
              sliver: SliverToBoxAdapter(
                child: ExpansionTile(
                  title: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      formatEventTitle(index),
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
               children: _buildDetailWidgets(context, eventsData[index]['date'], eventsData[index]['details']),
                ),
              ),
            ),
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 16),
              child: FractionallySizedBox(
                widthFactor:
                    0.8, // Adjusts the button's width to 80% of its container width
                child: ElevatedButton(
                  onPressed: _launchUrl,
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: const Color.fromARGB(255, 1, 138, 24),
                    elevation: 10,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 30, vertical: 10),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    minimumSize: const Size(double.infinity,
                        50), // Minimum width and specified height
                  ),
                  child: const Text(
                    'Inscrições Aqui!',
                    style: TextStyle(fontSize: 20),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}



Future<void> _launchUrl() async {
  final Uri url = Uri.parse(
      'https://www.sympla.com.br/evento/xvi-feira-da-industria-do-para-fipa-2024/2390753');
  if (!await launchUrl(url)) {
    throw 'Could not launch $url';
  }
}


List<Widget> _buildDetailWidgets(BuildContext context, String date, List<Map<String, dynamic>> details) {
  return details.asMap().entries.map<Widget>((entry) {
    int idx = entry.key;
    var detail = entry.value;

    List<String> speakerImages =
        List<String>.from(detail['speakerImages'] ?? []);
    List<String> speakerNames = List<String>.from(detail['speakerNames'] ?? []);
    List<String> speakerCompanies =
        List<String>.from(detail['speakerCompanies'] ?? []);
    String title = detail['title'] ?? 'No Title Provided';
    String eventType = detail['type'] ?? 'Unknown';
    String time = detail['time'] ??
        'Time Not Available'; // Ensure this key exists in your detail maps
    String location = detail['location'] ??
        'Location Not Provided'; // Ensure this key exists in your detail maps
    IconData eventTypeIcon =
        eventType == "Painel" ? Icons.group : Icons.speaker_notes;

    Color bgColor = idx % 2 == 0
        ? const Color.fromARGB(255, 245, 245, 245)
        : Colors.lightGreen.shade100;

    return TimelineTile(
      alignment: TimelineAlign.manual,
      lineXY: 0.1,
      isFirst: idx == 0,
      isLast: idx == details.length - 1,
      indicatorStyle: const IndicatorStyle(
        width: 20,
        color: Colors.green,
        padding: EdgeInsets.all(6),
      ),
      beforeLineStyle: const LineStyle(
        color: Color.fromARGB(255, 230, 9, 9),
        thickness: 1.5,
      ),
      endChild: Container(
        color: bgColor,
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
                    title,
                    textAlign: TextAlign.left,
                    style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.black),
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
                    child: Text(detail['location'] ?? 'No Location Provided')),
              ],
            ),
            const SizedBox(height: 4),
            GestureDetector(
             onTap: () => shareEvent(title, date, time, location, speakerNames, speakerCompanies, eventType),
              child: const Row(
                children: [
                  Icon(Icons.share, color: Color.fromARGB(255, 54, 244, 111)),
                  SizedBox(width: 8),
                  Expanded(child: Text('Compartilhar evento')),
                ],
              ),
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
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: List.generate(speakerImages.length, (index) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: GestureDetector(
                      onTap: () => _showImageDialog(
                          context,
                          speakerImages[index],
                          speakerNames[index],
                          speakerCompanies[index]),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircleAvatar(
                              backgroundImage: AssetImage(speakerImages[index]),
                              radius: 24),
                          const SizedBox(height: 4),
                          ...speakerNames[index].split(" ").map(
                                (namePart) => Text(
                                  namePart,
                                  style: const TextStyle(
                                      fontSize: 12, color: Colors.black),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                          const SizedBox(height: 2),
                          ...speakerCompanies[index].split(" ").map(
                                (companyPart) => Text(
                                  companyPart,
                                  style: const TextStyle(
                                      fontSize: 12, color: Colors.grey),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                        ],
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
}

void shareEvent(String title, String date, String time, String location, List<String> speakerNames, List<String> speakerCompanies, String eventType) {
  String speakersText = speakerNames.asMap().entries.map((entry) {
    int index = entry.key;
    String name = entry.value;
    String company = speakerCompanies.length > index ? speakerCompanies[index] : "Não informado";
    return "• $name, $company";
  }).join("\n");

  String text = "FEIRA DA INDÚSTRIA 2024\n\n"
                "• Local: Hangar Convenções & Feiras da Amazônia\n"
                "• Endereço: Avenida Doutor Freitas, s/n Marco, Belém, PA\n\n"
                "DETALHES DO EVENTO:\n"
                "• Título: $title\n"
                "• Data: $date às $time\n"
                "• $eventType\n"
                "• Localização: $location\n\n"
                "PARTICIPANTES:\n$speakersText\n\n"
                "Junte-se a nós para este evento emocionante!";
  Share.share(text);
}





void _showImageDialog(BuildContext context, String imagePath,
    String speakerName, String speakerCompany) {
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
                onTap: () => Navigator.of(context).pop(),
                child: const CircleAvatar(
                    backgroundColor: Colors.red,
                    child: Icon(Icons.close, color: Colors.white)),
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
                  Text(speakerCompany,
                      style: const TextStyle(
                          fontSize: 14)), // Displaying the company name
                ],
              ),
            ),
          ],
        ),
      );
    },
  );
}
