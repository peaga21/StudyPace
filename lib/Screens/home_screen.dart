import 'package:flutter/material.dart';
import 'dart:async';
import '../services/prefs_service.dart';
import '../theme/app_theme.dart';
import 'onboarding_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _studyBlocksCompleted = 0;
  bool _isStudying = false;
  int _timeLeft = 1500; // 25 minutos em segundos
  Timer? _studyTimer;

  @override
  void initState() {
    super.initState();
    _loadProgress();
  }

  void _loadProgress() async {
    final prefs = PrefsService();
    _studyBlocksCompleted = await prefs.getStudyBlocksCompleted();
    setState(() {});
  }

  void _startStudyBlock() {
    setState(() {
      _isStudying = true;
      _timeLeft = 1500;
    });
    
    _studyTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_timeLeft > 0) {
          _timeLeft--;
        } else {
          timer.cancel();
          _isStudying = false;
          _studyBlocksCompleted++;
          _saveProgress();
          _showBreakDialog();
        }
      });
    });
  }

  void _pauseStudyBlock() {
    _studyTimer?.cancel();
    setState(() {
      _isStudying = false;
    });
  }

  void _resetStudyBlock() {
    _studyTimer?.cancel();
    setState(() {
      _isStudying = false;
      _timeLeft = 1500;
    });
  }

  void _saveProgress() async {
    final prefs = PrefsService();
    await prefs.setStudyBlocksCompleted(_studyBlocksCompleted);
  }

  void _showBreakDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('🎉 Bloco Concluído!'),
        content: const Text('Parabéns! Você completou 25 minutos de estudo concentrado. Hora de uma pausa de 5 minutos.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _revokeConsent() async {
    final shouldRevoke = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Revogar Consentimento'),
        content: const Text('Isso irá resetar todas as suas configurações e você precisará aceitar as políticas novamente.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Revogar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (shouldRevoke == true && mounted) {
      final prefs = PrefsService();
      await prefs.clearAll();
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Consentimento revogado'),
          duration: Duration(seconds: 3),
        ),
      );

      // Navegar de volta para o onboarding - SEM CONST
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => OnboardingScreen()), // REMOVIDO CONST
      );
    }
  }

  String _formatTime(int seconds) {
    final minutes = (seconds / 60).floor();
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  double get _progressValue => _timeLeft / 1500;

  @override
  void dispose() {
    _studyTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('StudyPace'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onSelected: (value) {
              if (value == 'revoke') {
                _revokeConsent();
              } else if (value == 'stats') {
                _showStatsDialog();
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem<String>(
                value: 'stats',
                child: ListTile(
                  leading: Icon(Icons.insights),
                  title: Text('Estatísticas'),
                ),
              ),
              const PopupMenuItem<String>(
                value: 'revoke',
                child: ListTile(
                  leading: Icon(Icons.privacy_tip, color: Colors.red),
                  title: Text('Revogar Consentimento', style: TextStyle(color: Colors.red)),
                ),
              ),
            ],
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Card principal de estudo
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.timer, color: AppTheme.primaryColor),
                        const SizedBox(width: 8),
                        const Text(
                          'Técnica Pomodoro',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '25 minutos de estudo focado + 5 minutos de pausa',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 20),
                    
                    if (!_isStudying) ...[
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _startStudyBlock,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryColor,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'Iniciar Bloco de 25min',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                    ] else ...[
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          onPressed: _pauseStudyBlock,
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            side: BorderSide(color: AppTheme.primaryColor),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'Pausar Estudo',
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        width: double.infinity,
                        child: TextButton(
                          onPressed: _resetStudyBlock,
                          child: const Text(
                            'Reiniciar',
                            style: TextStyle(fontSize: 14),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Timer visual (aparece apenas durante estudo)
            if (_isStudying)
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      // Timer circular
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          SizedBox(
                            width: 140,
                            height: 140,
                            child: CircularProgressIndicator(
                              value: _progressValue,
                              strokeWidth: 8,
                              color: AppTheme.primaryColor,
                              backgroundColor: Colors.grey[200],
                            ),
                          ),
                          Column(
                            children: [
                              Text(
                                _formatTime(_timeLeft),
                                style: const TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                '${(_progressValue * 100).toInt()}%',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        '💡 Foco no estudo!',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _timeLeft > 60 
                            ? '${(_timeLeft / 60).floor()} minutos restantes'
                            : 'Menos de 1 minuto',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else ...[
              // Seção de progresso (quando não está estudando)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Seu Progresso',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Card(
                    elevation: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryColor.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(Icons.emoji_events, color: AppTheme.primaryColor),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Blocos Concluídos',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                Text(
                                  '$_studyBlocksCompleted',
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
            
            const Spacer(),
            
            // Dica do dia
            if (!_isStudying)
              Card(
                elevation: 2,
                color: AppTheme.secondaryColor.withOpacity(0.1),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Icon(Icons.lightbulb_outline, color: AppTheme.secondaryColor),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          'Dica: Estude em blocos de 25min com pausas de 5min para melhor rendimento.',
                          style: TextStyle(
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _showStatsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('📊 Estatísticas'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Blocos completados: $_studyBlocksCompleted'),
            Text('Tempo total: ${_studyBlocksCompleted * 25} minutos'),
            const SizedBox(height: 16),
            const Text('Continue assim! 🎉'),
          ],
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
}