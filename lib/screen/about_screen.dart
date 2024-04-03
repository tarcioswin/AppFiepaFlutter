import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutScreen extends StatefulWidget {
  const AboutScreen({Key? key}) : super(key: key);

  @override
  _AboutScreenState createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen> {
  Widget bulletPoint(String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("• ", style: TextStyle(color: Color.fromARGB(255, 3, 3, 3), fontSize: 18)),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(color: Color.fromARGB(255, 14, 13, 13), fontSize: 18),
          ),
        ),
      ],
    );
  }

  Future<void> _sendEmail() async {
    final Uri params = Uri(
      scheme: 'mailto',
      path: 'tarcisio.pinheiro@senaipa.org.br',
      query: 'subject=App Inquiry&body=Hello!',
    );
    String url = params.toString();
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      print('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text("Sobre o App", style: TextStyle(color: Colors.white)),
        backgroundColor: const Color.fromARGB(255, 1, 138, 24),
        centerTitle: true,
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          Opacity(
            opacity: 0,
            child: Image.asset('lib/images/FIEPAImage.jpg', fit: BoxFit.cover),
          ),
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Versão 1.0 - 2024",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color.fromARGB(255, 7, 7, 7), decoration: TextDecoration.underline),
                  ),
                  const SizedBox(height: 10),
                  bulletPoint("Criado por: Eng.Tarcisio Pinheiro"),
                  const SizedBox(height: 10),
                  bulletPoint("Instituto Senai de Inovação em Tecnologias Minerais"),
                  const SizedBox(height: 10),
                  bulletPoint("Belém, PA"),
                  const SizedBox(height: 20),
                  InkWell(
                    onTap: _sendEmail,
                    child: const Text(
                      "Contato: tarcisio.pinheiro@senaipa.org.br",
                      style: TextStyle(fontSize: 18, color: Colors.lightBlueAccent, decoration: TextDecoration.underline),
                    ),
                  ),
                  // Add more bullet points here as needed
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
