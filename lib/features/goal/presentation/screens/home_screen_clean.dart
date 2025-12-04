import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:studypace/features/goal/data/models/study_goal.dart';
import 'dart:async';
import '../providers/goal_provider.dart';
class HomeScreenClean extends StatefulWidget {
  const HomeScreenClean({super.key});

  @override
  State<HomeScreenClean> createState() => _HomeScreenCleanState();
}

class _HomeScreenCleanState extends State<HomeScreenClean> 
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  Timer? _goalUpdateTimer;
  
  int _studyBlocksCompleted = 0;
  bool _isStudying = false;
  int _timeLeft = 1500;
  Timer? _studyTimer;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadGoals();
      _startGoalUpdateTimer();
    });
  }

  void _loadGoals() {
    final goalProvider = Provider.of<GoalProvider>(context, listen: false);
    goalProvider.loadGoals();
  }

  void _startGoalUpdateTimer() {
    _goalUpdateTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final goalProvider = Provider.of<GoalProvider>(context, listen: false);
      goalProvider.updateLiveProgress();
      if (_isStudying) setState(() {});
    });
  }

  @override
  void dispose() {
    _goalUpdateTimer?.cancel();
    _studyTimer?.cancel();
    _tabController.dispose();
    super.dispose();
  }

  // ========== POMODORO ==========
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
          _showBreakDialog(context);
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

  void _showBreakDialog(BuildContext context) {
    final goalProvider = Provider.of<GoalProvider>(context, listen: false);
    if (goalProvider.currentTrackingGoal != null) {
      goalProvider.addStudyTime(25);
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('🎉 Bloco Concluído!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Parabéns! 25 minutos de estudo concentrado.'),
            const SizedBox(height: 8),
            if (goalProvider.currentTrackingGoal != null) ...[
              Text(
                '✅ +25min na meta "${goalProvider.currentTrackingGoal!.title}"',
                style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
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

  // ========== MÉTODOS DE META ==========
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
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: descriptionController,
              decoration: const InputDecoration(
                labelText: 'Descrição (opcional)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: targetController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Minutos desejados',
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
                _showSnackBar('Digite um título!', Colors.red);
                return;
              }

              final targetMinutes = int.tryParse(targetText);
              if (targetMinutes == null || targetMinutes <= 0) {
                _showSnackBar('Digite minutos válidos!', Colors.red);
                return;
              }

              final newGoal = StudyGoal(
                id: DateTime.now().millisecondsSinceEpoch.toString(),
                title: title,
                description: description.isNotEmpty ? description : 'Meta de estudo',
                targetMinutes: targetMinutes,
                createdAt: DateTime.now(),
              );

              final goalProvider = Provider.of<GoalProvider>(context, listen: false);
              goalProvider.addGoal(newGoal);
              
              Navigator.pop(context);
              _showSnackBar('Meta criada!', Colors.green);
              _tabController.animateTo(1);
            },
            child: const Text('Criar'),
          ),
        ],
      ),
    );
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
      ),
    );
  }

  void _showGoalDetails(BuildContext context, StudyGoal goal) {
    final goalProvider = Provider.of<GoalProvider>(context, listen: false);
    final isTracking = goalProvider.currentTrackingGoal?.id == goal.id;
    final isCompleted = goal.isCompleted;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(goal.title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(goal.description),
            const SizedBox(height: 16),
            Text('Meta: ${goal.targetMinutes}min'),
            Text('Completado: ${goal.liveCompletedMinutes}min'),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: goal.liveProgress,
              backgroundColor: Colors.grey[300],
              color: _getProgressColor(goal.liveProgress),
            ),
            const SizedBox(height: 8),
            Text(
              '${(goal.liveProgress * 100).toStringAsFixed(1)}%',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: _getProgressColor(goal.liveProgress),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fechar'),
          ),
          if (!isTracking && !isCompleted)
            ElevatedButton(
              onPressed: () {
                goalProvider.startTrackingGoal(goal);
                Navigator.pop(context);
                _showSnackBar('Rastreando "${goal.title}"', Colors.green);
                if (!_isStudying) _startStudyBlock();
              },
              child: const Text('Rastrear'),
            )
          else if (isTracking)
            ElevatedButton(
              onPressed: () {
                goalProvider.stopTrackingGoal();
                Navigator.pop(context);
                _showSnackBar('Parou de rastrear', Colors.orange);
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
              child: const Text('Parar'),
            ),
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

  // ========== UI ==========
  @override
  Widget build(BuildContext context) {
    final goalProvider = Provider.of<GoalProvider>(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('StudyPace'),
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
          if (goalProvider.currentTrackingGoal != null)
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: Chip(
                label: Text(goalProvider.currentTrackingGoal!.title),
                backgroundColor: Colors.green,
                avatar: const Icon(Icons.timer, size: 16),
              ),
            ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddGoalDialog(context),
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildPomodoroTab(context, goalProvider),
          _buildGoalsTab(context, goalProvider),
          _buildDashboardTab(context, goalProvider),
        ],
      ),
    );
  }

  Widget _buildPomodoroTab(BuildContext context, GoalProvider goalProvider) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const Row(
                    children: [
                      Icon(Icons.timer, color: Colors.blue),
                      SizedBox(width: 8),
                      Text('Técnica Pomodoro', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text('25 minutos de estudo focado + 5 minutos de pausa'),
                  const SizedBox(height: 20),
                  
                  if (!_isStudying)
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _startStudyBlock,
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                        child: const Text('🎯 Iniciar Bloco de 25min', style: TextStyle(color: Colors.white)),
                      ),
                    )
                  else
                    Column(
                      children: [
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton(
                            onPressed: _pauseStudyBlock,
                            child: const Text('⏸️ Pausar'),
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextButton(
                          onPressed: _resetStudyBlock,
                          child: const Text('🔄 Reiniciar'),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 32),
          
          if (_isStudying)
            Card(
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
                          ),
                        ),
                        Column(
                          children: [
                            Text(_formatTime(_timeLeft), style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                            Text('${(_progressValue * 100).toInt()}%'),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    const Text('💡 Foco total no estudo!'),
                    if (goalProvider.currentTrackingGoal != null) ...[
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
                            const Icon(Icons.timer, color: Colors.green),
                            const SizedBox(width: 8),
                            Text('Rastreando: ${goalProvider.currentTrackingGoal!.title}'),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            )
          else
            Column(
              children: [
                const Text('📊 Seu Progresso', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                Card(
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
                              const Text('Blocos Concluídos', style: TextStyle(color: Colors.grey)),
                              Text('$_studyBlocksCompleted', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
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
      ),
    );
  }

  Widget _buildGoalsTab(BuildContext context, GoalProvider goalProvider) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddGoalDialog(context),
        child: const Icon(Icons.add),
      ),
      body: goalProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : goalProvider.goals.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.flag, size: 80, color: Colors.grey),
                      const SizedBox(height: 16),
                      const Text('Nenhuma meta criada', style: TextStyle(fontSize: 18, color: Colors.grey)),
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
                    if (goalProvider.currentTrackingGoal != null)
                      Container(
                        padding: const EdgeInsets.all(16),
                        margin: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.timer, color: Colors.green),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('⏰ Rastreando: ${goalProvider.currentTrackingGoal!.title}', style: const TextStyle(fontWeight: FontWeight.bold)),
                                  Text('${goalProvider.currentTrackingGoal!.liveCompletedMinutes}min / ${goalProvider.currentTrackingGoal!.targetMinutes}min'),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.stop, color: Colors.red),
                              onPressed: () => goalProvider.stopTrackingGoal(),
                            ),
                          ],
                        ),
                      ),
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: goalProvider.goals.length,
                        itemBuilder: (context, index) {
                          final goal = goalProvider.goals[index];
                          return _buildGoalCard(context, goal, goalProvider);
                        },
                      ),
                    ),
                  ],
                ),
    );
  }

  Widget _buildGoalCard(BuildContext context, StudyGoal goal, GoalProvider goalProvider) {
    final isTracking = goalProvider.currentTrackingGoal?.id == goal.id;
    final isCompleted = goal.isCompleted;
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Stack(
          children: [
            SizedBox(
              width: 50,
              height: 50,
              child: CircularProgressIndicator(
                value: goal.liveProgress,
                color: isCompleted ? Colors.green : _getProgressColor(goal.liveProgress),
              ),
            ),
            Positioned.fill(
              child: Center(
                child: Text('${(goal.liveProgress * 100).toInt()}%', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
        title: Text(goal.title, style: TextStyle(color: isTracking ? Colors.green : null)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(goal.description),
            const SizedBox(height: 6),
            LinearProgressIndicator(value: goal.liveProgress),
            const SizedBox(height: 4),
            Row(
              children: [
                Text('${goal.liveCompletedMinutes}min'),
                const Text(' / '),
                Text('${goal.targetMinutes}min'),
                const Spacer(),
                if (isTracking) const Text('⏰ Rastreando', style: TextStyle(fontSize: 10, color: Colors.green))
                else if (isCompleted) const Text('✅ Concluída', style: TextStyle(fontSize: 10, color: Colors.green)),
              ],
            ),
          ],
        ),
        trailing: isTracking ? const Icon(Icons.timer, color: Colors.green) : isCompleted ? const Icon(Icons.check_circle, color: Colors.green) : const Icon(Icons.flag),
        onTap: () => _showGoalDetails(context, goal),
      ),
    );
  }

  Widget _buildDashboardTab(BuildContext context, GoalProvider goalProvider) {
    final stats = goalProvider.statistics;
    final totalTargetMinutes = stats['totalTargetTime'] ?? 0;
    final totalCompletedMinutes = stats['totalCompletedTime'] ?? 0;
    final completedGoals = stats['completedGoals'] ?? 0;
    final totalGoals = stats['totalGoals'] ?? 0;
    final totalStudyTime = totalCompletedMinutes + (_studyBlocksCompleted * 25);
    final overallProgress = totalTargetMinutes > 0 ? totalCompletedMinutes / totalTargetMinutes : 0.0;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const Row(
                    children: [
                      Icon(Icons.insights, color: Colors.blue),
                      SizedBox(width: 8),
                      Text('📊 Progresso Geral', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          children: [
                            Stack(
                              alignment: Alignment.center,
                              children: [
                                SizedBox(
                                  width: 80,
                                  height: 80,
                                  child: CircularProgressIndicator(
                                    value: overallProgress,
                                    color: _getProgressColor(overallProgress),
                                  ),
                                ),
                                Text('${(overallProgress * 100).toInt()}%', style: const TextStyle(fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Column(
                          children: [
                            _buildStatItem('🎯 Metas Ativas', '$totalGoals'),
                            _buildStatItem('✅ Concluídas', '$completedGoals'),
                            _buildStatItem('📈 Em Progresso', '${totalGoals - completedGoals}'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.analytics, color: Colors.green),
                      SizedBox(width: 8),
                      Text('📈 Estatísticas', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildDashboardStat('⏱️ Tempo Total Estudado', '${totalStudyTime}min'),
                  _buildDashboardStat('🎯 Minutos Completados', '$totalCompletedMinutes min'),
                  _buildDashboardStat('📅 Minutos Planejados', '$totalTargetMinutes min'),
                  _buildDashboardStat('🍅 Blocos Pomodoro', '$_studyBlocksCompleted'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(label, style: const TextStyle(fontSize: 12)),
          const Spacer(),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildDashboardStat(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(child: Text(title)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)),
        ],
      ),
    );
  }
}