import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:timeline_tile/timeline_tile.dart';
import 'login_screen.dart';
import 'update_screen.dart';
import 'about_screen.dart';
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
        leading: _isSearching
            ? BackButton(
                color: Colors.white,
                onPressed: () {
                  if (_isSearching) {
                    _stopSearching();
                  } else {
                    Navigator.of(context).pop();
                  }
                },
              )
            : IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.of(context).pop(),
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
        child: Image.asset('lib/images/Mapa2.jpg'), // Your image asset path
      ),
    );
  }
}

final List<Map<String, dynamic>> eventsData = [
  {
    'date': '19 OUT | Quarta-feira',
    'details': [
      {
        'time': '17h',
        'title': 'Grand Prix SENAI de Inovação - 1º dia',
        'location': 'Espaço SENAI de Inovação',
      },
      {
        'time': '18h',
        'title': 'Abertura daFeira da Indústria do Pará',
        'location': 'FIEPA',
      },
    ],
  },
  {
    'date': '20 OUT | Quinta-feira',
    'details': [
      {
        'time': '14h',
        'title': 'Supply Tank - Rodada REDES FIEPA',
        'location': 'Auditório Marajó',
      },
      {
        'time': '15h',
        'title': 'Exportação: Tecnologia e Estratégia REDES/CIN/CNI',
        'location': 'Auditório 12',
      },
      {
        'time': '15h',
        'title': 'Soluções em Filtração AMAZON TECNOLOGIA',
        'location': 'Auditório 09',
      },
      {
        'time': '16h',
        'title':
            'Certificação de Empresas - Estratégias de fora para dentro IEL',
        'location': 'Auditório 04',
      },
      {
        'time': '17h',
        'title': 'Rodada Internacional de Negócios CIN',
        'location': 'Auditório Pará',
      },
      {
        'time': '17h',
        'title':
            'Workshop Inovação: Reposicionamento da Marca, com a Libra Design IEL',
        'location': 'Multifunctional Room 04',
      },
      {
        'time': '17h',
        'title': 'Grand Prix SENAI de Inovação - 2º dia SENAI',
        'location': 'Espaço SENAI de Inovação',
      },
      {
        'time': '18h',
        'title': 'Produtos Cerâmicos e a Norma de Desempenho SINDOLPA',
        'location': 'Auditório 10',
      },
      {
        'time': '18h',
        'title': 'Painel Mercado de Trabalho na Indústria Paraense SENAI',
        'location': 'Auditório 11',
      },
      {
        'time': '18h',
        'title': 'Saúde Mental como pilar e estratégia do seu negócio SESI',
        'location': 'Auditório 09',
      },
      {
        'time': '18h30',
        'title': 'Painel Educação e o Futuro do Trabalho SENAI',
        'location': 'Auditório Marajó',
      },
      {
        'time': '19h',
        'title':
            'A Saúde Auditiva como Qualidade de Vida no Trabalho e no Ambiente Familiar SESI',
        'location': 'Auditório 09',
      },
      {
        'time': '19h',
        'title': 'Inovar é para todos SENAI - ISI',
        'location': 'Auditório 12',
      },
      {
        'time': '19h',
        'title':
            'Perspectivas Econômicas para o Brasil e o Mundo XP INVESTIMENTOS',
        'location': 'Auditório 11',
      },
      {
        'time': '20h',
        'title': 'Palestra Inova Moda Digital SENAI',
        'location': 'Auditório 10',
      },
      {
        'time': '20h',
        'title': 'Evento: A Saúde e Segurança como Boas Práticas SESI',
        'location': 'Auditório Marajó',
      },
    ],
  },
  {
    'date': '21 OUT | Sexta-feira',
    'details': [
      {
        'time': '14h',
        'title': 'Workshop Moda e Sustentabilidade SENAI DR PA/CETIQT',
        'location': 'Auditório 12',
      },
      {
        'time': '14h',
        'title': 'Grand Prix SENAI de Inovação - 3º dia SENAI',
        'location': 'Espaço SENAI de Inovação',
      },
      {
        'time': '15h',
        'title': 'Lançamento da Campanha Estágio Legal IEL',
        'location': 'Auditório 04',
      },
      {
        'time': '15h',
        'title': 'Hidráulica Conectada HYTEC',
        'location': 'Auditório 09',
      },
      {
        'time': '16h',
        'title': 'Fórum ESG nos Negócios REDES FIEPA',
        'location': 'Auditório Marajó',
      },
      {
        'time': '16h30',
        'title': 'Impulsionando a Transformação Digital - Soluções Pneumáticas',
        'location': 'Auditório 09',
      },
      {
        'time': '17h',
        'title':
            'Promovendo o melhor do Brasil no mundo - Apresentação da Gerência de Indústria e Serviço da ApexBrasil CNI/APEX BRASIL',
        'location': 'Multifunctional Room 04',
      },
      {
        'time': '17h',
        'title': 'Inovação na indústria do Pará HYDRO',
        'location': 'Auditório 10',
      },
      {
        'time': '19h',
        'title': 'Inteligência em Gestão da Saúde e Segurança do Trabalho SESI',
        'location': 'Auditório 09',
      },
      {
        'time': '19h',
        'title':
            'Mercado Livre de energia - Autoprodução de energia ELETRON ENERGY',
        'location': 'Auditório 04',
      },
      {
        'time': '19h',
        'title': 'Desenvolvimento territorial no contexto amazônico HYDRO',
        'location': 'Multifunctional Room 10',
      },
      {
        'time': '19h',
        'title': 'Florida Connection Road Show CIN/SINDUSCON',
        'location': 'Auditório 11',
      },
      {
        'time': '21h',
        'title':
            'Atração de talentos e diversidade & inclusão na indústria do alumínio HYDRO',
        'location': 'Multifunctional Room 10',
      },
      {
        'time': '21h',
        'title': 'Sorteio de Motos FIEPA',
        'location': 'Estande de Motos',
      },
    ],
  },
  {
    'date': '22 OUT | Sábado',
    'details': [
      {
        'time': '14h',
        'title': 'Grand Prix SENAI de Inovação - Encerramento SENAI',
        'location': 'Espaço SENAI de Inovação',
      },
      {
        'time': '21h30',
        'title': 'Sorteio de Motos FIEPA',
        'location': 'Estande de Motos',
      },
    ],
  },
];

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
