import 'dart:convert';
import '../../domain/entities/goal_entity.dart';

class GoalDTO {
  final String id;
  final String title;
  final bool isCompleted;

  GoalDTO({
    required this.id,
    required this.title,
    required this.isCompleted,
  });

  // ---------------------------------------------------------------------------
  // CONVERSÃO 1: JSON <-> DTO (Para Supabase e SharedPreferences)
  // ---------------------------------------------------------------------------

  // Transforma um MAP (vindo do Supabase/JSON) em um objeto DTO
  factory GoalDTO.fromJson(Map<String, dynamic> json) {
    return GoalDTO(
      // O '??' garante que se vier nulo, o app não quebra (tenta converter para String)
      id: json['id']?.toString() ?? '', 
      title: json['title'] ?? '',
      // Supabase costuma usar snake_case (is_completed), Dart usa camelCase
      isCompleted: json['is_completed'] ?? false, 
    );
  }

  // Transforma o DTO em MAP (Para enviar ao Supabase ou salvar no SharedPrefs)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'is_completed': isCompleted, // Envia no formato que o banco espera
    };
  }

  // ---------------------------------------------------------------------------
  // CONVERSÃO 2: DTO <-> ENTIDADE (Para a camada de Domínio/UI)
  // ---------------------------------------------------------------------------

  // Pega uma Entidade pura (Goal) e transforma em DTO (para poder salvar)
  factory GoalDTO.fromDomain(GoalEntity goal) {
    return GoalDTO(
      id: goal.id,
      title: goal.title,
      isCompleted: goal.isCompleted,
    );
  }

  // Transforma este DTO em uma Entidade pura (para a UI usar)
  GoalEntity toDomain() {
    return GoalEntity(
      id: id,
      title: title,
      targetMinutes: 0, // Adicione um valor padrão ou obtenha-o se estiver disponível
      completedMinutes: 0,
      description: '',
      deadline: DateTime.now(), // Adicione um valor padrão ou obtenha-o se estiver disponível
      progress: 0.0,
      createdAt: DateTime.now(), // Adicione um valor padrão ou obtenha-o se estiver disponível
      isCompleted: isCompleted,
    );
  }

  // ---------------------------------------------------------------------------
  // EXTRAS: Helpers para SharedPreferences (Lista <-> String)
  // ---------------------------------------------------------------------------
  
  // Converte uma Lista de DTOs para uma única String JSON (para salvar no cache)
  static String encode(List<GoalDTO> goals) => json.encode(
        goals.map<Map<String, dynamic>>((goal) => goal.toJson()).toList(),
      );

  // Converte uma String JSON (do cache) de volta para uma Lista de DTOs
  static List<GoalDTO> decode(String goalsStr) =>
      (json.decode(goalsStr) as List<dynamic>)
          .map<GoalDTO>((item) => GoalDTO.fromJson(item))
          .toList();
}