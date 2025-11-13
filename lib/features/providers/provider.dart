import 'dart:async';
import 'package:flutter/material.dart';
import '../../services/prefs_service.dart';

/// Gerencia o estado relacionado ao timer, blocos de estudo e progresso.
///
/// Utiliza o padrão [ChangeNotifier] para notificar os widgets ouvintes
/// sobre as mudanças de estado, permitindo que a UI seja reconstruída.
class StudyProvider with ChangeNotifier {
  final PrefsService _prefsService = PrefsService();

  int _studyBlocksCompleted = 0;
  bool _isStudying = false;
  int _timeLeft = 1500; // 25 minutos em segundos
  Timer? _studyTimer;
  VoidCallback? onBlockCompleted;

  // Getters para a UI ouvir as mudanças
  int get studyBlocksCompleted => _studyBlocksCompleted;
  bool get isStudying => _isStudying;
  int get timeLeft => _timeLeft;
  String get formattedTime {
    final minutes = (_timeLeft / 60).floor();
    final remainingSeconds = _timeLeft % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }
  double get progressValue => _timeLeft / 1500.0;

  StudyProvider() {
    _loadProgress();
  }

  /// Carrega o progresso salvo no SharedPreferences.
  void _loadProgress() async {
    _studyBlocksCompleted = await _prefsService.getStudyBlocksCompleted();
    notifyListeners();
  }

  /// Salva o número de blocos de estudo concluídos.
  void _saveProgress() async {
    await _prefsService.setStudyBlocksCompleted(_studyBlocksCompleted);
  }

  /// Inicia um novo bloco de estudo de 25 minutos.
  void startStudyBlock() {
    if (_isStudying) return;

    _isStudying = true;
    _timeLeft = 1500;
    notifyListeners();

    _studyTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timeLeft > 0) {
        _timeLeft--;
        notifyListeners();
      } else {
        timer.cancel();
        _isStudying = false;
        _studyBlocksCompleted++;
        _saveProgress();
        onBlockCompleted?.call(); // Chama o callback para mostrar o diálogo na UI
        notifyListeners();
      }
    });
  }

  /// Pausa o bloco de estudo atual.
  void pauseStudyBlock() {
    _studyTimer?.cancel();
    _isStudying = false;
    notifyListeners();
  }

  @override
  void dispose() {
    _studyTimer?.cancel();
    super.dispose();
  }
}