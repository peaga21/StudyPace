import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../services/prefs_service.dart';
import 'home_screen.dart';
import '../theme/app_theme.dart';

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
    _checkInitialState();
  }

  void _initializeScrollListeners() {
    for (int i = 0; i < _scrollControllers.length; i++) {
      _scrollControllers[i].addListener(() {
        _updateScrollProgress(i);
      });
    }
  }

  void _checkInitialState() async {
    final prefs = PrefsService();
    _isRead[0] = await prefs.isPrivacyRead();
    _isRead[1] = await prefs.isTermsRead();
    setState(() {});
  }

  void _updateScrollProgress(int index) {
    final controller = _scrollControllers[index];
    final maxScroll = controller.position.maxScrollExtent;
    final currentScroll = controller.position.pixels;
    final progress = maxScroll > 0 ? currentScroll / maxScroll : 1.0;
    
    setState(() {
      _scrollProgress[index] = progress;
      if (progress >= 0.95 && !_isRead[index]) { // 95% para ser mais fácil
        _isRead[index] = true;
      }
    });
  }

  void _markAsRead(int index) async {
    final prefs = PrefsService();
    
    if (index == 0) {
      await prefs.setPrivacyRead(true);
    } else {
      await prefs.setTermsRead(true);
    }
    
    setState(() {
      _isRead[index] = true;
    });
  }

  bool get _allRead => _isRead.every((read) => read);

  void _completeOnboarding() async {
    final prefs = PrefsService();
    await prefs.setPoliciesAccepted('v1');
    await prefs.setOnboardingCompleted(true);
    
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    }
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
          // Cabeçalho informativo
          Container(
            padding: const EdgeInsets.all(20),
            color: AppTheme.primaryColor.withOpacity(0.1),
            child: const Column(
              children: [
                Icon(Icons.privacy_tip, size: 40, color: AppTheme.primaryColor),
                SizedBox(height: 12),
                Text(
                  'Leia atentamente nossos termos',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'É necessário ler ambos os documentos para continuar',
                  style: TextStyle(fontSize: 14),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          
          // Abas
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
          
          // Barra de progresso
          LinearProgressIndicator(
            value: _scrollProgress[_currentTab],
            backgroundColor: Colors.grey[200],
            color: AppTheme.primaryColor,
            minHeight: 3,
          ),
          
          // Conteúdo da política
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
          
          // Botão "Marcar como lido"
          if (!_isRead[_currentTab])
            Container(
              padding: const EdgeInsets.all(16),
              child: ElevatedButton(
                onPressed: _scrollProgress[_currentTab] >= 0.95 
                    ? () => _markAsRead(_currentTab)
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
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
                color: isSelected ? AppTheme.primaryColor : Colors.transparent,
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
                  color: isSelected ? AppTheme.primaryColor : Colors.grey[600],
                ),
              ),
              const SizedBox(height: 4),
              if (isRead)
                Icon(Icons.check_circle, size: 16, color: Colors.green),
            ],
          ),
        ),
      ),
    );
  }

  String _getPolicyContent(int index) {
    if (index == 0) {
      return """
# 📄 Política de Privacidade - StudyPace

*Última atualização: ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}*

## 🤔 Como Coletamos Dados

O **StudyPace** foi desenvolvido com foco total na sua privacidade. Coletamos apenas informações essenciais para o funcionamento do aplicativo:

- **Preferências de estudo** que você configura
- **Progresso** nos seus blocos de tempo  
- **Metas** e objetivos definidos por você
- **Configurações** personalizadas do timer

## 💾 Armazenamento e Segurança

**Todos os dados ficam no seu dispositivo!** 
- Não usamos servidores externos
- Não compartilhamos informações com terceiros
- Não vendemos dados (nem teríamos o que vender)
- Tudo fica armazenado localmente no seu celular

## 🛡️ Seus Direitos

Você tem controle total sobre seus dados:
- **Revogar consentimento** a qualquer momento nas configurações
- **Exportar seus dados** (em desenvolvimento)
- **Excluir tudo** com um único botão

## 📞 Contato e Suporte

Em caso de dúvidas sobre privacidade:
**pedro@estudante.com**

---

*🔍 Role até o final e clique em "Marcar como Lido"*
""";
    } else {
      return """
# 📝 Termos de Serviço - StudyPace

*Última atualização: ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}*

## ✅ Aceitação dos Termos

Ao usar o **StudyPace**, você automaticamente concorda com estes termos de serviço. Se não concordar, não use o aplicativo.

## 🎯 Uso Adequado do Aplicativo

Você concorda em usar o StudyPace apenas para:

- **Fins educacionais** e aumento de produtividade pessoal
- **Uso individual** e não-comercial
- **Respeitar** os limites de uso razoável

## ❌ O Que Não Fazer

É expressamente proibido:

- Tentar burlar ou modificar o aplicativo
- Usar para atividades ilegais
- Distribuir versões modificadas

## ⚠️ Limitações e Isenções

**O aplicativo é fornecido "como está"**, o que significa:

- Não garantimos disponibilidade 100% do tempo
- Podemos fazer atualizações sem aviso prévio
- Não nos responsabilizamos por danos indiretos

## 🔄 Modificações nos Termos

Podemos atualizar estes termos periodicamente. A versão sempre estará disponível no aplicativo.

---

*🔍 Role até o final e clique em "Marcar como Lido"*
""";
    }
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
          // Status de leitura
          Row(
            children: [
              _buildReadStatus(0, 'Privacidade'),
              const Spacer(),
              _buildReadStatus(1, 'Termos'),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Botão continuar
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _allRead ? _completeOnboarding : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: _allRead ? AppTheme.primaryColor : Colors.grey,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
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

  @override
  void dispose() {
    for (final controller in _scrollControllers) {
      controller.dispose();
    }
    super.dispose();
  }
}