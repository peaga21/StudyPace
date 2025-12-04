import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class PolicyViewerScreen extends StatefulWidget {
  const PolicyViewerScreen({super.key});

  @override
  State<PolicyViewerScreen> createState() => _PolicyViewerScreenState();
}

class _PolicyViewerScreenState extends State<PolicyViewerScreen> {
  bool _acceptedTerms = false;
  bool _acceptedPrivacy = false;
  bool _acceptedAge = false;
  
  bool get _allAccepted => _acceptedTerms && _acceptedPrivacy && _acceptedAge;

  Future<void> _acceptTerms() async {
    if (!_allAccepted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, aceite todos os termos para continuar.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('accepted_terms', true);
    Navigator.pushReplacementNamed(context, '/home');
  }

  Future<void> _cancelAndExit() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Recusar Termos'),
        content: const Text(
          'Para usar o StudyPace, você precisa aceitar os Termos de Serviço e Política de Privacidade.\n\n'
          'Deseja sair do aplicativo?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Voltar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _exitApp();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Sair do App'),
          ),
        ],
      ),
    );
  }

  void _exitApp() {
    // Para web, mostra mensagem
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    }
    
    // Para mobile, fecha o app
    // Nota: Em produção, você precisaria de permissões especiais
    // Esta é uma implementação simplificada
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Termos Recusados'),
        content: const Text(
          'Os termos de serviço são necessários para usar o aplicativo.\n\n'
          'Por favor, feche o aplicativo manualmente.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> _launchURL(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) { // Use the canLaunchUrl from url_launcher
      await launchUrl(uri);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Termos e Privacidade'),
        centerTitle: true,
        elevation: 0,
        actions: [
          // Botão de cancelar
          TextButton(
            onPressed: _cancelAndExit,
            child: const Text(
              'Recusar',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(20),
            color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
            child: const Column(
              children: [
                Icon(
                  Icons.security,
                  size: 50,
                  color: Colors.blue,
                ),
                SizedBox(height: 10),
                Text(
                  'Termos de Uso do StudyPace',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  'Leia e aceite para continuar usando o aplicativo',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),
          
          // Conteúdo com scroll
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Termos de Serviço
                  _buildSection(
                    title: '📄 Termos de Serviço',
                    content: '''
1. Uso do Aplicativo
O StudyPace é uma ferramenta de produtividade para organização de estudos pessoais.

2. Seus Dados
Seus dados de estudo são armazenados apenas localmente no seu dispositivo.

3. Responsabilidades
Você é responsável pelo uso adequado do aplicativo e por manter sua produtividade.
''',
                  ),
                  
                  const SizedBox(height: 30),
                  
                  // Política de Privacidade
                  _buildSection(
                    title: '🔒 Política de Privacidade',
                    content: '''
PRIVACIDADE EM PRIMEIRO LUGAR

• Nenhum dado pessoal é coletado
• Tudo fica armazenado no SEU dispositivo
• Não compartilhamos dados com ninguém
• Você pode excluir tudo quando quiser

O StudyPace respeita totalmente sua privacidade.
''',
                  ),
                  
                  const SizedBox(height: 30),
                  
                  // Checkboxes
                  _buildCheckbox(
                    title: 'Li e concordo com os Termos de Serviço',
                    value: _acceptedTerms,
                    onChanged: (value) => setState(() => _acceptedTerms = value!),
                    onTapLink: () => _launchURL('https://studypace.com/termos'),
                  ),
                  
                  const SizedBox(height: 15),
                  
                  _buildCheckbox(
                    title: 'Li e concordo com a Política de Privacidade',
                    value: _acceptedPrivacy,
                    onChanged: (value) => setState(() => _acceptedPrivacy = value!),
                    onTapLink: () => _launchURL('https://studypace.com/privacidade'),
                  ),
                  
                  const SizedBox(height: 15),
                  
                  _buildCheckbox(
                    title: 'Confirmo que tenho mais de 13 anos ou tenho consentimento dos pais',
                    value: _acceptedAge,
                    onChanged: (value) => setState(() => _acceptedAge = value!),
                  ),
                  
                  const SizedBox(height: 30),
                  
                  // Aviso importante
                  Container(
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.orange),
                    ),
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.warning, color: Colors.orange, size: 20),
                            SizedBox(width: 8),
                            Text(
                              'Importante:',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.orange,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Ao recusar os termos, você não poderá usar o aplicativo. '
                          'Se mudar de ideia, basta reabrir o app e aceitar os termos.',
                          style: TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Botões de ação
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: Colors.grey.shade200)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: [
                // Botão Cancelar
                Expanded(
                  child: OutlinedButton(
                    onPressed: _cancelAndExit,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: const BorderSide(color: Colors.red),
                    ),
                    child: const Text(
                      'Recusar e Sair',
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                ),
                
                const SizedBox(width: 16),
                
                // Botão Aceitar
                Expanded(
                  child: ElevatedButton(
                    onPressed: _acceptTerms,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _allAccepted ? Colors.blue : Colors.grey,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Aceitar e Continuar'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildSection({required String title, required String content}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.blue,
          ),
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Text(
            content,
            style: const TextStyle(fontSize: 14, height: 1.6),
          ),
        ),
      ],
    );
  }
  
  Widget _buildCheckbox({
    required String title,
    required bool value,
    required ValueChanged<bool?> onChanged,
    VoidCallback? onTapLink,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Checkbox(
          value: value,
          onChanged: onChanged,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(fontSize: 14),
              ),
              if (onTapLink != null) ...[
                const SizedBox(height: 4),
                GestureDetector(
                  onTap: onTapLink,
                  child: const Text(
                    '(ler versão completa)',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.blue,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
  
  Future<bool> canLaunchUrl(Uri uri) async {
    return false; // Placeholder, as the actual function is from url_launcher
  }
}

/*
  // These functions are already provided by the url_launcher package.
  // No need to redefine them here.
  Future<bool> canLaunchUrl(Uri uri) async { return false; }
  Future<void> launchUrl(Uri uri) async { }
*/