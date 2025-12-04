import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:studypace/features/goal/data/repositories/study_goal_repository.dart';
import 'package:studypace/features/goal/data/repositories/study_goal_repository_impl.dart';

// ========== CORE SERVICES ==========
// ========== CLEAN ARCHITECTURE - GOAL MODULE ==========
// Data Layer
import '../features/goal/data/datasources/goal_local_datasource.dart';
import '../features/goal/data/datasources/goal_local_datasource_impl.dart';
import '../features/goal/data/repositories/study_goal_repository_adapter.dart';

// Domain Layer
import '../features/goal/domain/repositories/goal_repository.dart';
import '../features/goal/domain/usecases/get_goals_usecase.dart';
import '../features/goal/domain/usecases/create_goal_usecase.dart';
import '../features/goal/domain/usecases/update_goal_usecase.dart';
import '../features/goal/domain/usecases/delete_goal_usecase.dart';

// Presentation Layer
import '../features/goal/presentation/providers/goal_provider.dart';
import '../core/storage/prefs_service.dart';

// ========== INSTÂNCIA GLOBAL ==========
final GetIt getIt = GetIt.instance;

/// Configura todos os serviços do app
Future<void> setupInjector() async {
  print('🛠️  Configurando Injector...');
  
  // ========== SERVIÇOS CORE ==========
  
  // 1. SharedPreferences (base para storage)
  final sharedPreferences = await SharedPreferences.getInstance();
  getIt.registerSingleton<SharedPreferences>(sharedPreferences);
  print('✅ SharedPreferences registrado');
  
  // 2. PrefsService (serviço personalizado)
  getIt.registerSingletonAsync<PrefsService>(() async {
    final service = PrefsService();
    // PrefsService does not have an init method, it initializes internally.
    print('✅ PrefsService inicializado');
    return service;
  });
  
  // ========== REPOSITÓRIO LEGADO ==========
  
  // 3. StudyGoalRepository (implementação legada)
  getIt.registerLazySingleton<StudyGoalRepository>(
    () => StudyGoalRepositoryImpl(prefs: getIt()),
  );
  print('✅ StudyGoalRepository (legado) registrado');
  
  // ========== CLEAN ARCHITECTURE - DATA LAYER ==========
  
  // 4. GoalLocalDataSource (novo datasource)
  getIt.registerLazySingleton<GoalLocalDataSource>(
    () => GoalLocalDataSourceImpl(prefs: getIt()),
  );
  print('✅ GoalLocalDataSource registrado');
  
  // 5. ADAPTER: Conecta repositorio legado com Clean Architecture
  getIt.registerLazySingleton<GoalRepository>(
    () => StudyGoalRepositoryAdapter(getIt()),
  );
  print('✅ GoalRepository (adapter) registrado');
  
  // ========== CLEAN ARCHITECTURE - DOMAIN LAYER ==========
  
  // 6. UseCases
  getIt.registerLazySingleton(() => GetGoalsUseCase(getIt()));
  getIt.registerLazySingleton(() => CreateGoalUseCase(getIt()));
  getIt.registerLazySingleton(() => UpdateGoalUseCase(getIt()));
  getIt.registerLazySingleton(() => DeleteGoalUseCase(getIt()));
  print('✅ UseCases registrados');
  
  // ========== CLEAN ARCHITECTURE - PRESENTATION LAYER ==========
  
  // 7. GoalProvider (gerencia estado das metas)
  getIt.registerFactory(() => GoalProvider(
    getIt<GetGoalsUseCase>(),
    getIt<CreateGoalUseCase>(),
    getIt<UpdateGoalUseCase>(),
    getIt<DeleteGoalUseCase>(),
  ));
  print('✅ GoalProvider registrado');
  
  // ========== FINALIZAÇÃO ==========
  
  // Aguarda inicialização de todos os serviços async
  await getIt.allReady();
  
  print('🎯 Injector configurado com sucesso!');
  print('📦 Serviços registrados:');
  print('   - SharedPreferences');
  print('   - PrefsService');
  print('   - StudyGoalRepository (legado)');
  print('   - GoalLocalDataSource');
  print('   - GoalRepository (via adapter)');
  print('   - GetGoalsUseCase');
  print('   - CreateGoalUseCase');
  print('   - UpdateGoalUseCase');
  print('   - DeleteGoalUseCase');
  print('   - GoalProvider');
}

/// Função auxiliar para testes
bool isServiceRegistered<T extends Object>() {
  return getIt.isRegistered<T>();
}

/// Reseta o injector (útil para testes)
void resetInjector() {
  getIt.reset();
}