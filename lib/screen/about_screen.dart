import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutScreen extends StatefulWidget {
  const AboutScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _AboutScreenState createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen> {
  Future<void> _sendEmail(String email) async {
    final Uri emailLaunchUri = Uri(
      scheme: 'mailto',
      path: email,
      query: 'subject=App Inquiry&body=Hello!',
    );

    if (!await launchUrl(emailLaunchUri)) {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not launch email client')),
      );
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
        backgroundColor:  const Color.fromARGB(255, 1, 138, 24),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                "Versão 1.0 - 2024",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(255, 7, 7, 7),
                  decoration: TextDecoration.underline,
                ),
              ),
              const SizedBox(height: 40),
              const Text("Criado por:",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color.fromARGB(255, 7, 7, 7),
                  )),

              const BulletPoint(text: "Eng.Tarcisio Pinheiro"),
              const BulletPoint(text: "Instituto SENAI de Inovação em Tecnologias Minerais"),
              const SizedBox(height: 10),
              const Text(
                "Contato:",
                style: TextStyle(
                  fontSize: 18,
                  color: Colors
                      .black, // Make this non-clickable and visually distinct
                ),
              ),
              InkWell(
                onTap: () => _sendEmail("tarcisio.pinheiro@outlook.com"),
                child: const Text(
                  "tarcisio.pinheiro@outlook.com",
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.lightBlueAccent,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
              // Add more bullet points here as needed
            ],
          ),
        ),
      ),
    );
  }
}



class BulletPoint extends StatelessWidget {
  final String text;
  const BulletPoint({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("• ",
            style:
                TextStyle(color: Color.fromARGB(255, 3, 3, 3), fontSize: 18)),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
                color: Color.fromARGB(255, 14, 13, 13), fontSize: 18),
          ),
        ),
      ],
    );
  }
}
