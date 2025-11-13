import 'package:flutter/material.dart';
import 'dart:async';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  int _studyBlocksCompleted = 0;
  bool _isStudying = false;
  int _timeLeft = 1500;
  Timer? _studyTimer;
  Timer? _goalUpdateTimer;
  late TabController _tabController;

  // Sistema de Metas em Tempo Real
  final List<StudyGoal> _goals = [];
  bool _isLoadingGoals = false;
  StudyGoal? _currentTrackingGoal;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadGoals();
    _startGoalUpdateTimer();
  }

  // ========== SISTEMA DE METAS EM TEMPO REAL ==========
  void _loadGoals() {
    setState(() {
      _isLoadingGoals = true;
    });

    Future.delayed(const Duration(milliseconds: 500), () {
      setState(() {
        _isLoadingGoals = false;
        // Metas de exemplo menores para teste
        _goals.addAll([
          StudyGoal(
            id: '1',
            title: 'Estudar Flutter',
            description: 'Completar curso básico',
            targetMinutes: 30,
            completedMinutes: 5,
            createdAt: DateTime.now().subtract(const Duration(days: 1)),
          ),
          StudyGoal(
            id: '2',
            title: 'Preparar para prova',
            description: 'Revisar capítulos 1-3',
            targetMinutes: 45,
            completedMinutes: 10,
            createdAt: DateTime.now().subtract(const Duration(hours: 12)),
          ),
        ]);
      });
    });
  }

  void _startGoalUpdateTimer() {
    _goalUpdateTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_currentTrackingGoal != null && _isStudying) {
        setState(() {
          _currentTrackingGoal!.addLiveSecond();
        });
      }
    });
  }

  void _startTrackingGoal(StudyGoal goal) {
    setState(() {
      _currentTrackingGoal?.stopTracking();
      _currentTrackingGoal = goal;
      goal.startTracking();
    });
  }

  void _stopTrackingGoal() {
    setState(() {
      _currentTrackingGoal?.stopTracking();
      _currentTrackingGoal = null;
    });
  }

  void _addGoal(StudyGoal goal) {
    setState(() {
      _goals.add(goal);
    });
  }

  void _showAddGoalDialog(BuildContext context) {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    final targetController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Criar Nova Meta'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                labelText: 'Título da meta',
                hintText: 'Ex: Estudar Matemática',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: descriptionController,
              decoration: const InputDecoration(
                labelText: 'Descrição (opcional)',
                hintText: 'Ex: Revisar capítulos 1-5',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: targetController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Minutos desejados',
                hintText: 'Ex: 60',
                suffixText: 'minutos',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              final title = titleController.text.trim();
              final description = descriptionController.text.trim();
              final targetText = targetController.text.trim();

              if (title.isEmpty) {
                _showError('Digite um título para a meta!');
                return;
              }

              if (targetText.isEmpty) {
                _showError('Digite a quantidade de minutos!');
                return;
              }

              final targetMinutes = int.tryParse(targetText);
              if (targetMinutes == null || targetMinutes <= 0) {
                _showError('Digite um número válido de minutos!');
                return;
              }

              final newGoal = StudyGoal(
                id: DateTime.now().millisecondsSinceEpoch.toString(),
                title: title,
                description: description.isNotEmpty ? description : 'Meta de estudo',
                targetMinutes: targetMinutes,
                createdAt: DateTime.now(),
              );

              _addGoal(newGoal);
              Navigator.pop(context);
              _showSuccess('Meta "$title" criada!');

              // Vai para a aba de metas
              _tabController.animateTo(1);
            },
            child: const Text('Criar Meta'),
          ),
        ],
      ),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _showGoalDetails(BuildContext context, StudyGoal goal) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(goal.title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              goal.description,
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            _buildDetailItem('Meta total:', '${goal.targetMinutes} minutos'),
            _buildDetailItem('Completado:', '${goal.liveCompletedMinutes} minutos'),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: goal.liveProgress,
              backgroundColor: Colors.grey[300],
              color: _getProgressColor(goal.liveProgress),
            ),
            const SizedBox(height: 8),
            Text(
              '${(goal.liveProgress * 100).toStringAsFixed(1)}% completo',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: _getProgressColor(goal.liveProgress),
              ),
            ),
            if (goal.isCompleted) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.check_circle, color: Colors.green, size: 16),
                    SizedBox(width: 4),
                    Text(
                      'Meta concluída! 🎉',
                      style: TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
            if (goal == _currentTrackingGoal) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.timer, color: Colors.blue[700], size: 16),
                    const SizedBox(width: 4),
                    const Text(
                      'Tempo rodando... ⏱️',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fechar'),
          ),
          if (goal != _currentTrackingGoal && !goal.isCompleted)
            ElevatedButton(
              onPressed: () {
                _startTrackingGoal(goal);
                Navigator.pop(context);
                _showSuccess('Rastreando tempo em "${goal.title}" ⏰');
                
                // Se não estiver estudando, inicia automaticamente
                if (!_isStudying) {
                  _startStudyBlock();
                }
              },
              child: const Text('Rastrear Tempo'),
            )
          else if (goal == _currentTrackingGoal)
            ElevatedButton(
              onPressed: () {
                _stopTrackingGoal();
                Navigator.pop(context);
                _showSuccess('Parou de rastrear tempo');
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
              child: const Text('Parar Rastreio'),
            ),
        ],
      ),
    );
  }

  Widget _buildDetailItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
          const SizedBox(width: 8),
          Text(value),
        ],
      ),
    );
  }

  Color _getProgressColor(double progress) {
    if (progress >= 1.0) return Colors.green;
    if (progress >= 0.7) return Colors.blue;
    if (progress >= 0.4) return Colors.orange;
    return Colors.red;
  }

  // ========== POMODORO TIMER ==========
  void _startStudyBlock() {
    setState(() {
      _isStudying = true;
      _timeLeft = 1500; // 25 minutos
    });
    
    _studyTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_timeLeft > 0) {
          _timeLeft--;
        } else {
          timer.cancel();
          _isStudying = false;
          _studyBlocksCompleted++;
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

  void _showBreakDialog() {
    // Adiciona tempo automaticamente à meta sendo rastreada
    if (_currentTrackingGoal != null) {
      _currentTrackingGoal!.addStudyTime(25);
      setState(() {});
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('🎉 Bloco Concluído!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Parabéns! Você completou 25 minutos de estudo concentrado.'),
            const SizedBox(height: 8),
            if (_currentTrackingGoal != null) ...[
              Text(
                '✅ +25min na meta "${_currentTrackingGoal!.title}"',
                style: const TextStyle(fontSize: 14, color: Colors.green, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                'Progresso: ${_currentTrackingGoal!.liveCompletedMinutes}/${_currentTrackingGoal!.targetMinutes}min (${(_currentTrackingGoal!.liveProgress * 100).toInt()}%)',
                style: const TextStyle(fontSize: 12),
              ),
            ] else ...[
              const Text(
                '💡 Dica: Selecione uma meta para rastrear seu tempo!',
                style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Continuar'),
          ),
        ],
      ),
    );
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
    _goalUpdateTimer?.cancel();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('StudyPace ⏰'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.timer), text: 'Pomodoro'),
            Tab(icon: Icon(Icons.flag), text: 'Metas'),
            Tab(icon: Icon(Icons.dashboard), text: 'Dashboard'),
          ],
        ),
        actions: [
          if (_currentTrackingGoal != null)
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: Chip(
                label: Text(
                  _currentTrackingGoal!.title,
                  style: const TextStyle(fontSize: 12, color: Colors.white),
                ),
                backgroundColor: Colors.green,
                avatar: const Icon(Icons.timer, size: 16, color: Colors.white),
              ),
            ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddGoalDialog(context),
            tooltip: 'Criar nova meta',
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildPomodoroTab(),
          _buildGoalsTab(),
          _buildDashboardTab(),
        ],
      ),
    );
  }

  Widget _buildPomodoroTab() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.timer, color: Colors.blue),
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
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: const Text(
                          '🎯 Iniciar Bloco de 25min',
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
                          side: const BorderSide(color: Colors.blue),
                        ),
                        child: const Text(
                          '⏸️ Pausar Estudo',
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
                          '🔄 Reiniciar',
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
          
          if (_isStudying)
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          width: 140,
                          height: 140,
                          child: CircularProgressIndicator(
                            value: _progressValue,
                            strokeWidth: 8,
                            color: Colors.blue,
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
                      '💡 Foco total no estudo!',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (_currentTrackingGoal != null) ...[
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.timer, color: Colors.green[700]),
                            const SizedBox(width: 8),
                            Text(
                              'Rastreando: ${_currentTrackingGoal!.title}',
                              style: TextStyle(
                                color: Colors.green[700],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '(${_currentTrackingGoal!.liveCompletedMinutes}min)',
                              style: const TextStyle(
                                color: Colors.green,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ] else ...[
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.orange.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.info, color: Colors.orange),
                            SizedBox(width: 8),
                            Text(
                              'Selecione uma meta para rastrear!',
                              style: TextStyle(
                                color: Colors.orange,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            )
          else ...[
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '📊 Seu Progresso',
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
                            color: Colors.blue.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.emoji_events, color: Colors.blue),
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
        ],
      ),
    );
  }

  Widget _buildGoalsTab() {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddGoalDialog(context),
        child: const Icon(Icons.add),
      ),
      body: _isLoadingGoals
          ? const Center(child: CircularProgressIndicator())
          : _goals.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.flag, size: 80, color: Colors.grey),
                      const SizedBox(height: 16),
                      const Text(
                        'Nenhuma meta criada',
                        style: TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Crie sua primeira meta de estudo!',
                        style: TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () => _showAddGoalDialog(context),
                        child: const Text('➕ Criar Primeira Meta'),
                      ),
                    ],
                  ),
                )
              : Column(
                  children: [
                    if (_currentTrackingGoal != null)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        margin: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.green),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.timer, color: Colors.green[700]),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '⏰ Rastreando: ${_currentTrackingGoal!.title}',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.green[700],
                                    ),
                                  ),
                                  Text(
                                    '${_currentTrackingGoal!.liveCompletedMinutes}min / ${_currentTrackingGoal!.targetMinutes}min (${(_currentTrackingGoal!.liveProgress * 100).toInt()}%)',
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.stop, color: Colors.red),
                              onPressed: _stopTrackingGoal,
                              tooltip: 'Parar rastreio',
                            ),
                          ],
                        ),
                      ),
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _goals.length,
                        itemBuilder: (context, index) {
                          final goal = _goals[index];
                          return _buildGoalCard(goal);
                        },
                      ),
                    ),
                  ],
                ),
    );
  }

  Widget _buildGoalCard(StudyGoal goal) {
    final isTracking = goal == _currentTrackingGoal;
    final isCompleted = goal.isCompleted;
    
    return Card(
      elevation: 3,
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Stack(
          children: [
            SizedBox(
              width: 50,
              height: 50,
              child: CircularProgressIndicator(
                value: goal.liveProgress,
                strokeWidth: 4,
                color: isCompleted ? Colors.green : _getProgressColor(goal.liveProgress),
                backgroundColor: Colors.grey[200],
              ),
            ),
            Positioned.fill(
              child: Center(
                child: Text(
                  '${(goal.liveProgress * 100).toInt()}%',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: isCompleted ? Colors.green : Colors.blue,
                  ),
                ),
              ),
            ),
          ],
        ),
        title: Text(
          goal.title,
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: isTracking ? Colors.green : isCompleted ? Colors.green : null,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              goal.description,
              style: const TextStyle(fontSize: 12),
            ),
            const SizedBox(height: 6),
            LinearProgressIndicator(
              value: goal.liveProgress,
              backgroundColor: Colors.grey[200],
              color: isCompleted ? Colors.green : _getProgressColor(goal.liveProgress),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Text(
                  '${goal.liveCompletedMinutes}min',
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                ),
                const Text(' / ', style: TextStyle(fontSize: 12)),
                Text(
                  '${goal.targetMinutes}min',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                const Spacer(),
                if (isTracking)
                  const Text(
                    '⏰ Rastreando',
                    style: TextStyle(fontSize: 10, color: Colors.green, fontWeight: FontWeight.bold),
                  )
                else if (isCompleted)
                  const Text(
                    '✅ Concluída',
                    style: TextStyle(fontSize: 10, color: Colors.green, fontWeight: FontWeight.bold),
                  ),
              ],
            ),
          ],
        ),
        trailing: isTracking
            ? const Icon(Icons.timer, color: Colors.green)
            : isCompleted
                ? const Icon(Icons.check_circle, color: Colors.green)
                : const Icon(Icons.flag, color: Colors.blue),
        onTap: () => _showGoalDetails(context, goal),
      ),
    );
  }

  Widget _buildDashboardTab() {
    final totalTargetMinutes = _goals.fold(0, (sum, goal) => sum + goal.targetMinutes);
    final totalCompletedMinutes = _goals.fold(0, (sum, goal) => sum + goal.completedMinutes);
    final completedGoals = _goals.where((goal) => goal.isCompleted).length;
    final totalStudyTime = totalCompletedMinutes + (_studyBlocksCompleted * 25);
    final overallProgress = totalTargetMinutes > 0 ? totalCompletedMinutes / totalTargetMinutes : 0.0;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // Gráfico de Progresso
          Card(
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const Row(
                    children: [
                      Icon(Icons.insights, color: Colors.blue),
                      SizedBox(width: 8),
                      Text(
                        '📊 Progresso Geral',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 120,
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Stack(
                                alignment: Alignment.center,
                                children: [
                                  SizedBox(
                                    width: 80,
                                    height: 80,
                                    child: CircularProgressIndicator(
                                      value: overallProgress,
                                      strokeWidth: 8,
                                      color: _getProgressColor(overallProgress),
                                      backgroundColor: Colors.grey[200],
                                    ),
                                  ),
                                  Text(
                                    '${(overallProgress * 100).toInt()}%',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildStatItem('🎯 Metas Ativas', '${_goals.length}', Icons.flag),
                              _buildStatItem('✅ Concluídas', '$completedGoals', Icons.check_circle),
                              _buildStatItem('📈 Em Progresso', '${_goals.length - completedGoals}', Icons.trending_up),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Estatísticas
          Card(
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.analytics, color: Colors.green),
                      SizedBox(width: 8),
                      Text(
                        '📈 Estatísticas',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildDashboardStat('⏱️ Tempo Total Estudado', '${totalStudyTime}min', Icons.timer),
                  _buildDashboardStat('🎯 Minutos Completados', '$totalCompletedMinutes min', Icons.done_all),
                  _buildDashboardStat('📅 Minutos Planejados', '$totalTargetMinutes min', Icons.schedule),
                  _buildDashboardStat('🍅 Blocos Pomodoro', '$_studyBlocksCompleted', Icons.all_inclusive),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Ações Rápidas
          Card(
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '🚀 Ações Rápidas',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildActionButton(
                        'Nova Meta',
                        Icons.add,
                        Colors.blue,
                        () => _showAddGoalDialog(context),
                      ),
                      _buildActionButton(
                        'Iniciar Estudo',
                        Icons.play_arrow,
                        Colors.green,
                        _startStudyBlock,
                      ),
                      _buildActionButton(
                        'Ver Metas',
                        Icons.list_alt,
                        Colors.orange,
                        () {
                          _tabController.animateTo(1);
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey[600]),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
          ),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildDashboardStat(String title, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.blue),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(fontSize: 14),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.blue,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
    String label,
    IconData icon,
    Color color,
    VoidCallback onPressed,
  ) {
    return Column(
      children: [
        CircleAvatar(
          backgroundColor: color.withOpacity(0.2),
          child: IconButton(
            icon: Icon(icon, color: color),
            onPressed: onPressed,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: color,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

// ========== MODELO DE META EM TEMPO REAL ==========
class StudyGoal {
  final String id;
  final String title;
  final String description;
  final int targetMinutes;
  int completedMinutes;
  final DateTime createdAt;
  final DateTime? completedAt;
  
  // Controle de tempo real
  bool _isTracking = false;
  int _liveSeconds = 0;

  StudyGoal({
    required this.id,
    required this.title,
    required this.description,
    required this.targetMinutes,
    this.completedMinutes = 0,
    required this.createdAt,
    this.completedAt,
  });

  // Iniciar tracking em tempo real
  void startTracking() {
    if (!_isTracking) {
      _isTracking = true;
      _liveSeconds = 0;
    }
  }

  // Parar tracking e salvar tempo acumulado
  void stopTracking() {
    if (_isTracking) {
      // Converter segundos acumulados para minutos
      final additionalMinutes = _liveSeconds ~/ 60;
      if (additionalMinutes > 0) {
        completedMinutes += additionalMinutes;
      }
      _isTracking = false;
      _liveSeconds = 0;
    }
  }

  // Adicionar 1 segundo em tempo real
  void addLiveSecond() {
    if (_isTracking) {
      _liveSeconds++;
    }
  }

  // Adicionar tempo manualmente (ex: quando completa Pomodoro)
  void addStudyTime(int minutes) {
    completedMinutes += minutes;
  }

  // GETTER para minutos completos em tempo real
  int get liveCompletedMinutes {
    int total = completedMinutes;
    if (_isTracking) {
      total += _liveSeconds ~/ 60;
    }
    return total;
  }

  // GETTER para progresso em tempo real
  double get liveProgress {
    if (targetMinutes == 0) return 0.0;
    double progress = liveCompletedMinutes / targetMinutes;
    return progress > 1.0 ? 1.0 : progress;
  }

  bool get isCompleted => completedMinutes >= targetMinutes;
}