import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
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
      'color': AppTheme.primaryColor,
    },
    {
      'title': 'Técnica Pomodoro comprovada',
      'subtitle': '25 minutos de foco intenso + 5 minutos de pausa = máxima produtividade',
      'icon': Icons.timer_outlined,
      'color': AppTheme.secondaryColor,
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

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    }
  }

  void _goToPolicies() {
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const PolicyViewerScreen()),
      );
    }
  }

  void _skipToPolicies() {
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const PolicyViewerScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: _currentPage > 0 
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: _previousPage,
                color: Colors.grey[600],
              )
            : null,
        actions: [
          // Botão Pular - só mostra nas primeiras telas
          if (_currentPage < _onboardingData.length - 1)
            TextButton(
              onPressed: _skipToPolicies,
              child: Text(
                'Pular',
                style: TextStyle(
                  color: AppTheme.primaryColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          // Indicador de progresso (dots) - OCULTO na última tela
          if (_currentPage < _onboardingData.length - 1)
            Padding(
              padding: const EdgeInsets.only(top: 20, bottom: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  _onboardingData.length,
                  (index) => AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(horizontal: 6),
                    width: _currentPage == index ? 24 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      shape: _currentPage == index ? BoxShape.rectangle : BoxShape.circle,
                      borderRadius: _currentPage == index ? BorderRadius.circular(4) : null,
                      color: _currentPage == index
                          ? AppTheme.primaryColor
                          : Colors.grey[300],
                    ),
                  ),
                ),
              ),
            ),
          
          // Conteúdo das páginas
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
                      // Ícone ilustrativo
                      Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          color: data['color'].withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          data['icon'] as IconData,
                          size: 60,
                          color: data['color'],
                        ),
                      ),
                      const SizedBox(height: 40),
                      
                      // Título
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
                      
                      // Subtítulo
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
          
          // Botões de navegação
          Container(
            padding: const EdgeInsets.all(32),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Botão Voltar
                if (_currentPage > 0)
                  TextButton(
                    onPressed: _previousPage,
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                    child: Text(
                      'Voltar',
                      style: TextStyle(
                        fontSize: 16,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                  )
                else
                  const SizedBox(width: 80),
                
                // Botão Avançar/Concordar
                ElevatedButton(
                  onPressed: _nextPage,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    _currentPage == _onboardingData.length - 1 
                        ? 'Concordar e Continuar' 
                        : 'Avançar',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}