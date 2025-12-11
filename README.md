# StudyPace - Entities,DTO e mappers
Pedro Henrique Dias

## Estrutura Implementada:

### Core/
- `injection/` - Injeção de dependência (GetIt)
- `storage/` - Serviços de armazenamento (PrefsService)
- `theme/` - Tema global

### Features/goal/
- `domain/` - Entities, Repositories, UseCases
- `data/` - Datasources, Models, Adapters  
- `presentation/` - Providers, Screens, Widgets

### Funcionalidades:
- ✅ CRUD completo de metas
- ✅ Tracking em tempo real
- ✅ Pomodoro timer integrado
- ✅ Dashboard com estatísticas
- ✅ Persistência com SharedPreferences

## Como expandir:
1. Criar nova feature: `features/nova_feature/`
2. Seguir mesma estrutura: domain/data/presentation
3. Registrar no injector.dart
