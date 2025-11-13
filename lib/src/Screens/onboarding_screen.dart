import 'package:flutter/material.dart';
import 'policy_viewer_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, dynamic>> _onboardingData = [
    {
      'title': 'Estude no seu ritmo ideal',
      'subtitle': 'Blocos de tempo que se adaptam à sua concentração e produtividade',
      'icon': Icons.school_outlined,
      'color': Colors.blue,
    },
    {
      'title': 'Técnica Pomodoro comprovada',
      'subtitle': '25 minutos de foco intenso + 5 minutos de pausa = máxima produtividade',
      'icon': Icons.timer_outlined,
      'color': Colors.orange,
    },
    {
      'title': 'Privacidade garantida',
      'subtitle': 'Seus dados de estudo são protegidos e armazenados localmente no seu dispositivo',
      'icon': Icons.security_outlined,
      'color': Colors.green,
    },
  ];

  void _nextPage() {
    if (_currentPage < _onboardingData.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {
      _goToPolicies();
    }
  }

  void _goToPolicies() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const PolicyViewerScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          TextButton(
            onPressed: _goToPolicies,
            child: const Text(
              'Pular',
              style: TextStyle(color: Colors.blue),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 20, bottom: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _onboardingData.length,
                (index) => Container(
                  margin: const EdgeInsets.symmetric(horizontal: 6),
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _currentPage == index ? Colors.blue : Colors.grey[300],
                  ),
                ),
              ),
            ),
          ),
          
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              itemCount: _onboardingData.length,
              onPageChanged: (index) {
                setState(() {
                  _currentPage = index;
                });
              },
              itemBuilder: (context, index) {
                final data = _onboardingData[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        data['icon'] as IconData,
                        size: 80,
                        color: data['color'],
                      ),
                      const SizedBox(height: 40),
                      Text(
                        data['title'] as String,
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          height: 1.3,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20),
                      Text(
                        data['subtitle'] as String,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                          height: 1.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          
          Container(
            padding: const EdgeInsets.all(32),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _nextPage,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: Text(
                  _currentPage == _onboardingData.length - 1 
                      ? 'Concordar e Continuar' 
                      : 'Avançar',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}