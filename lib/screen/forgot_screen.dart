import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Import FirebaseAuth

class ForgotScreen extends StatefulWidget {
  const ForgotScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _ForgotScreenState createState() => _ForgotScreenState();
}

class _ForgotScreenState extends State<ForgotScreen> {
  final TextEditingController _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text("Recuperar Senha",
            style: TextStyle(color: Colors.white)),
        backgroundColor: const Color.fromARGB(255, 1, 138, 24),
        centerTitle: true,
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          Opacity(
            opacity: 0.7,
            child: Image.asset('lib/images/FIEPAImage.jpg', fit: BoxFit.cover),
          ),
          Padding(
            padding: const EdgeInsets.only(
                top: 60.0), // Adjust the top padding as needed
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  _buildTextField(_emailController, 'Email', Icons.email),
                  const SizedBox(height: 10),
                  const Text(
                    "Um link será enviado para o email cadastrado!",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white, // Text color
                      fontSize: 16, // Font size
                      fontWeight: FontWeight.bold, // Font weight
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildButton(context, 'Enviar', _recover),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(
      TextEditingController controller, String label, IconData icon) {
    return Container(
      width: 370,
      height: 50,
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 209, 207, 207),
        borderRadius: BorderRadius.circular(15.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 1,
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(
            fontWeight: FontWeight.bold, // Make label text bold
          ),
          filled: true,
          fillColor: Colors.transparent,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(25.0),
            borderSide: BorderSide.none,
          ),
          prefixIcon: Icon(icon),
        ),
        keyboardType: label == 'Email'
            ? TextInputType.emailAddress
            : TextInputType.text, // Conditional keyboardType for Email
      ),
    );
  }

  Widget _buildButton(
      BuildContext context, String label, VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor: const Color.fromARGB(255, 1, 138, 24),
        elevation: 5,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        padding: const EdgeInsets.symmetric(horizontal: 100, vertical: 15),
      ),
      child: Text(label, style: const TextStyle(fontSize: 18)),
    );
  }

  void _recover() async {
    final String email =
        _emailController.text.trim(); // Obtém o email do controlador
    if (email.isEmpty) {
      // Se o campo de email estiver vazio, mostra uma mensagem para o usuário.
      _showDialog('Erro', 'Por favor, insira o seu endereço de email.');
      return;
    }
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      // Se o email for enviado com sucesso, mostra uma mensagem de sucesso.
      _showDialog('Sucesso',
          'Um link de redefinição de senha foi enviado para $email.');
    } on FirebaseAuthException catch (e) {
      // Lida com erros, como usuário não encontrado ou problemas de rede.
      String errorMessage = 'Ocorreu um erro. Por favor, tente novamente.';
      if (e.code == 'user-not-found') {
        errorMessage = 'Nenhum usuário encontrado para esse email.';
      }
      _showDialog('Erro', errorMessage);
    } catch (e) {
      // Lida com quaisquer outros erros que possam ocorrer.
      _showDialog(
          'Erro', 'Ocorreu um erro inesperado. Por favor, tente novamente.');
    }
  }

  void _showDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
            ),
          ],
        );
      },
    );
  }
}
