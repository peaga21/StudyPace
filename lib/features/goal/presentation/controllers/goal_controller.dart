import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/goal_provider.dart';
import '../../data/models/study_goal.dart';

/// Controller para gerenciar dialogs e UI logic do módulo Goal
/// Separa a lógica de UI do GoalProvider (que gerencia estado)
class GoalController {
  final BuildContext context;
  
  GoalController(this.context);
  
  /// Retorna o GoalProvider do contexto
  GoalProvider get _goalProvider => Provider.of<GoalProvider>(context, listen: false);
  
  /// Mostra dialog para criar nova meta
  Future<void> showCreateGoalDialog() async {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    final targetController = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Criar Nova Meta'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(
                    labelText: 'Título*',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Descrição',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: targetController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Minutos alvo*',
                    border: OutlineInputBorder(),
                    suffixText: 'min',
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () => _createGoal(
                titleController.text,
                descriptionController.text,
                targetController.text,
                context,
              ),
              child: const Text('Salvar'),
            ),
          ],
        );
      },
    );
  }
  
  /// Cria uma nova meta
  Future<void> _createGoal(
    String title, 
    String description, 
    String targetText,
    BuildContext dialogContext,
  ) async {
    // Validação
    if (title.isEmpty) {
      _showSnackBar('Título é obrigatório', Colors.red);
      return;
    }
    
    if (targetText.isEmpty) {
      _showSnackBar('Minutos alvo é obrigatório', Colors.red);
      return;
    }
    
    final targetMinutes = int.tryParse(targetText);
    if (targetMinutes == null || targetMinutes <= 0) {
      _showSnackBar('Digite um número válido de minutos', Colors.red);
      return;
    }
    
    try {
      final newGoal = StudyGoal(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: title.trim(),
        description: description.trim().isNotEmpty 
            ? description.trim() 
            : 'Meta de estudo',
        targetMinutes: targetMinutes,
        createdAt: DateTime.now(),
      );
      
      await _goalProvider.addGoal(newGoal);
      Navigator.pop(dialogContext);
      _showSnackBar('Meta criada com sucesso!', Colors.green);
      
    } catch (e) {
      _showSnackBar('Erro ao criar meta: $e', Colors.red);
    }
  }
  
  /// Mostra detalhes de uma meta
  Future<void> showGoalDetails(StudyGoal goal) async {
    final isTracking = _goalProvider.currentTrackingGoal?.id == goal.id;
    final isCompleted = goal.isCompleted;
    
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(goal.title),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (goal.description.isNotEmpty) ...[
                  Text(
                    goal.description,
                    style: const TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                  const SizedBox(height: 16),
                ],
                
                // Informações da meta
                _buildDetailRow('Tempo alvo:', '${goal.targetMinutes} min'),
                _buildDetailRow('Tempo realizado:', '${goal.liveCompletedMinutes} min'),
                
                // Progresso
                const SizedBox(height: 12),
                LinearProgressIndicator(
                  value: goal.liveProgress,
                  backgroundColor: Colors.grey[200],
                  color: _getProgressColor(goal.liveProgress),
                ),
                const SizedBox(height: 8),
                Center(
                  child: Text(
                    '${(goal.liveProgress * 100).toStringAsFixed(1)}%',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: _getProgressColor(goal.liveProgress),
                    ),
                  ),
                ),
                
                // Status
                const SizedBox(height: 16),
                if (isCompleted)
                  _buildStatusChip('✅ Concluída', Colors.green)
                else if (isTracking)
                  _buildStatusChip('⏰ Em andamento', Colors.blue)
                else
                  _buildStatusChip('📝 Pendente', Colors.orange),
              ],
            ),
          ),
          actions: [
            // Botão deletar
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _showDeleteConfirmation(goal);
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Deletar'),
            ),
            
            const Spacer(),
            
            // Botão fechar
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Fechar'),
            ),
            
            // Botão ação (track/stop)
            if (!isCompleted)
              ElevatedButton(
                onPressed: () => _handleTrackingAction(goal, isTracking, context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isTracking ? Colors.orange : Colors.blue,
                ),
                child: Text(isTracking ? 'Parar' : 'Iniciar'),
              ),
          ],
        );
      },
    );
  }
  
  /// Gerencia ação de tracking
  Future<void> _handleTrackingAction(
    StudyGoal goal, 
    bool isTracking, 
    BuildContext dialogContext,
  ) async {
    try {
      if (isTracking) {
        await _goalProvider.stopTrackingGoal();
        _showSnackBar('Tracking parado', Colors.orange);
      } else {
        await _goalProvider.startTrackingGoal(goal);
        _showSnackBar('Tracking iniciado', Colors.green);
      }
      Navigator.pop(dialogContext);
    } catch (e) {
      _showSnackBar('Erro: $e', Colors.red);
    }
  }
  
  /// Confirmação para deletar
  Future<void> _showDeleteConfirmation(StudyGoal goal) async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar exclusão'),
        content: Text('Deletar "${goal.title}"? Esta ação não pode ser desfeita.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                await _goalProvider.deleteGoal(goal.id);
                Navigator.pop(context);
                _showSnackBar('Meta deletada', Colors.green);
              } catch (e) {
                Navigator.pop(context);
                _showSnackBar('Erro ao deletar: $e', Colors.red);
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Deletar'),
          ),
        ],
      ),
    );
  }
  
  // ========== MÉTODOS AUXILIARES ==========
  
  Widget _buildDetailRow(String label, String value) {
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
  
  Widget _buildStatusChip(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            text,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w500,
            ),
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
  
  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        duration: const Duration(seconds: 2),
      ),
    );
  }
}