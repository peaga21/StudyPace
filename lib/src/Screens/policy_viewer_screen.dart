import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'home_screen.dart';

class PolicyViewerScreen extends StatefulWidget {
  const PolicyViewerScreen({super.key});

  @override
  State<PolicyViewerScreen> createState() => _PolicyViewerScreenState();
}

class _PolicyViewerScreenState extends State<PolicyViewerScreen> {
  final List<ScrollController> _scrollControllers = [
    ScrollController(),
    ScrollController(),
  ];
  
  final List<double> _scrollProgress = [0.0, 0.0];
  final List<bool> _isRead = [false, false];
  int _currentTab = 0;

  @override
  void initState() {
    super.initState();
    _initializeScrollListeners();
  }

  void _initializeScrollListeners() {
    for (int i = 0; i < _scrollControllers.length; i++) {
      _scrollControllers[i].addListener(() {
        _updateScrollProgress(i);
      });
    }
  }

  void _updateScrollProgress(int index) {
    final controller = _scrollControllers[index];
    final maxScroll = controller.position.maxScrollExtent;
    final currentScroll = controller.position.pixels;
    final progress = maxScroll > 0 ? currentScroll / maxScroll : 1.0;
    
    setState(() {
      _scrollProgress[index] = progress;
      if (progress >= 0.95 && !_isRead[index]) {
        _isRead[index] = true;
      }
    });
  }

  void _markAsRead(int index) {
    setState(() {
      _isRead[index] = true;
    });
  }

  bool get _allRead => _isRead.every((read) => read);

  void _completeOnboarding() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const HomeScreen()),
    );
  }

  void _onTabChanged(int index) {
    setState(() {
      _currentTab = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Termos e Políticas'),
        elevation: 0,
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            color: Colors.blue.withOpacity(0.1),
            child: const Column(
              children: [
                Icon(Icons.privacy_tip, size: 40, color: Colors.blue),
                SizedBox(height: 12),
                Text(
                  'Leia atentamente nossos termos',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          
          Container(
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.grey[300]!)),
            ),
            child: Row(
              children: [
                _buildTab(0, 'Privacidade'),
                _buildTab(1, 'Termos de Uso'),
              ],
            ),
          ),
          
          LinearProgressIndicator(
            value: _scrollProgress[_currentTab],
            backgroundColor: Colors.grey[200],
            color: Colors.blue,
            minHeight: 3,
          ),
          
          Expanded(
            child: SingleChildScrollView(
              controller: _scrollControllers[_currentTab],
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: MarkdownBody(
                  data: _getPolicyContent(_currentTab),
                ),
              ),
            ),
          ),
          
          if (!_isRead[_currentTab])
            Container(
              padding: const EdgeInsets.all(16),
              child: ElevatedButton(
                onPressed: _scrollProgress[_currentTab] >= 0.95 
                    ? () => _markAsRead(_currentTab)
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: const Text('Marcar como Lido'),
              ),
            ),
        ],
      ),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  Widget _buildTab(int index, String title) {
    final isSelected = _currentTab == index;
    final isRead = _isRead[index];
    
    return Expanded(
      child: GestureDetector(
        onTap: () => _onTabChanged(index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: isSelected ? Colors.blue : Colors.transparent,
                width: 2,
              ),
            ),
          ),
          child: Column(
            children: [
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: isSelected ? Colors.blue : Colors.grey[600],
                ),
              ),
              const SizedBox(height: 4),
              if (isRead)
                const Icon(Icons.check_circle, size: 16, color: Colors.green),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            offset: const Offset(0, -2),
            blurRadius: 8,
            color: Colors.black.withOpacity(0.1),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              _buildReadStatus(0, 'Privacidade'),
              const Spacer(),
              _buildReadStatus(1, 'Termos'),
            ],
          ),
          
          const SizedBox(height: 16),
          
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _allRead ? _completeOnboarding : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: _allRead ? Colors.blue : Colors.grey,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: Text(
                _allRead ? 'Continuar para o App 🚀' : 'Leia Ambos os Documentos',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReadStatus(int index, String title) {
    final isRead = _isRead[index];
    
    return Row(
      children: [
        Icon(
          isRead ? Icons.check_circle : Icons.radio_button_unchecked,
          color: isRead ? Colors.green : Colors.grey,
          size: 20,
        ),
        const SizedBox(width: 6),
        Text(
          title,
          style: TextStyle(
            color: isRead ? Colors.green : Colors.grey,
            fontWeight: isRead ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  String _getPolicyContent(int index) {
    if (index == 0) {
      return """
# Política de Privacidade - StudyPace

## Como Coletamos Dados
O **StudyPace** foi desenvolvido com foco total na sua privacidade.

## Armazenamento e Segurança
**Todos os dados ficam no seu dispositivo!** 
- Não usamos servidores externos
- Não compartilhamos informações
- Tudo fica armazenado localmente

## Seus Direitos
Você tem controle total sobre seus dados.""";
    } else {
      return """
# Termos de Serviço - StudyPace

## Aceitação dos Termos
Ao usar o **StudyPace**, você concorda com estes termos.

## Uso Adequado
Você concorda em usar o StudyPace apenas para:
- **Fins educacionais**
- **Uso individual**
- **Respeitar** os limites de uso

## O Que Não Fazer
É expressamente proibido tentar burlar o aplicativo.""";
    }
  }

  @override
  void dispose() {
    for (final controller in _scrollControllers) {
      controller.dispose();
    }
    super.dispose();
  }
}