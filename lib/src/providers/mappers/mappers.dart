/// Este arquivo contém classes de modelo e mappers.
/// Mappers são responsáveis por converter dados de um formato para outro,
/// como, por exemplo, converter um JSON de uma API para um objeto Dart.

/// Representa o modelo de dados para uma dica de estudo.
class StudyTip {
  final int id;
  final String title;
  final String content;

  StudyTip({required this.id, required this.title, required this.content});

  /// Um "mapper" que converte um `Map<String, dynamic>` (formato JSON)
  /// em uma instância de [StudyTip].
  factory StudyTip.fromJson(Map<String, dynamic> json) {
    return StudyTip(
      id: json['id'] as int,
      title: json['title'] as String,
      content: json['content'] as String,
    );
  }
}