import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/goal_controller.dart';
import '../widgets/progress_chart.dart';
import '../widgets/statistics_card.dart';
import 'goal_list_view.dart';

class DashboardView extends StatefulWidget {
  const DashboardView({super.key});

  @override
  State<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView> {
  @override
  void initState() {
    super.initState();
    // Carregar metas quando a tela iniciar
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<GoalController>().loadGoals();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard de Estudos'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.list),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const GoalListView()),
              );
            },
            tooltip: 'Ver Lista de Metas',
          ),
        ],
      ),
      body: Consumer<GoalController>(
        builder: (context, controller, child) {
          if (controller.isLoading && controller.goals.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (controller.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Erro: ${controller.error}'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: controller.loadGoals,
                    child: const Text('Tentar Novamente'),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => controller.loadGoals(),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Gráfico de Progresso
                  ProgressChart(goals: controller.goals),
                  const SizedBox(height: 20),
                  
                  // Estatísticas e Insights
                  StatisticsCard(goals: controller.goals),
                  const SizedBox(height: 20),

                  // Card de Lembretes (NOVO)
                  Card(
                    elevation: 2,
                    child: ListTile(
                      leading: const Icon(Icons.notifications, color: Colors.orange),
                      title: const Text('Lembretes Inteligentes'),
                      subtitle: const Text('Configure seus horários de estudo'),
                      trailing: const Icon(Icons.arrow_forward_ios),
                      onTap: () {
                        Navigator.pushNamed(context, '/reminders');
                      },
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Quick Actions
                  _buildQuickActions(context, controller),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context, GoalController controller) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Ações Rápidas',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildActionButton(
                  'Nova Meta',
                  Icons.add,
                  Colors.blue,
                  () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const GoalListView()),
                    );
                  },
                ),
                _buildActionButton(
                  'Ver Todas',
                  Icons.list_alt,
                  Colors.green,
                  () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const GoalListView()),
                    );
                  },
                ),
                _buildActionButton(
                  'Lembretes',
                  Icons.notifications,
                  Colors.orange,
                  () {
                    Navigator.pushNamed(context, '/reminders');
                  },
                ),
              ],
            ),
          ],
        ),
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
          style: const TextStyle(fontSize: 12),
        ),
      ],
    );
  }
}