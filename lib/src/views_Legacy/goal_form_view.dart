import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:studypace/features/goal/presentation/controllers/goal_controller.dart';
import 'package:studypace/features/goal/presentation/providers/goal_provider.dart';

class GoalFormView extends StatefulWidget {
  const GoalFormView({super.key});

  @override
  State<GoalFormView> createState() => _GoalFormViewState();
}

class _GoalFormViewState extends State<GoalFormView> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _targetMinutesController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _targetMinutesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Nova Meta de Estudo'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Título',
                hintText: 'Ex: Estudar Flutter',
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Título é obrigatório';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Descrição',
                hintText: 'Ex: Estudar widgets básicos do Flutter',
              ),
              maxLines: 3,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Descrição é obrigatória';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _targetMinutesController,
              decoration: const InputDecoration(
                labelText: 'Minutos Alvo',
                hintText: 'Ex: 120',
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Minutos alvo é obrigatório';
                }
                final minutes = int.tryParse(value);
                if (minutes == null || minutes <= 0) {
                  return 'Digite um número válido maior que zero';
                }
                return null;
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        Consumer<GoalProvider>(
          builder: (context, goalProvider, child) {
            return ElevatedButton(onPressed: goalProvider.isLoading ? null : () => _createGoal(context),
              child: goalProvider.isLoading
                  ? const SizedBox(
                      width: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Criar Meta'),
            );
          },
        ),
      ],
    );
  }

  Future<void> _createGoal(BuildContext context) async {
    if (_formKey.currentState!.validate()) {
      final goalController = GoalController(context);
      await goalController.showCreateGoalDialog(); // Call the public method
      // The actual creation logic is now handled within showCreateGoalDialog
      // and it will pop the dialog itself.
      // We just need to ensure this dialog is popped if it's still open.
      if (context.mounted) {
        Navigator.pop(context); // Pop the GoalFormView dialog
      }
    }
  }
}