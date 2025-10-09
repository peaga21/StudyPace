import 'package:shared_preferences/shared_preferences.dart';

class PrefsService {
  static final PrefsService _instance = PrefsService._internal();
  factory PrefsService() => _instance;
  PrefsService._internal();

  // Chaves para armazenamento
  static const String _privacyReadKey = 'privacy_read_v1';
  static const String _termsReadKey = 'terms_read_v1';
  static const String _policiesVersionKey = 'policies_version_accepted';
  static const String _acceptedAtKey = 'accepted_at';
  static const String _onboardingCompletedKey = 'onboarding_completed';
  static const String _studyBlocksCompletedKey = 'study_blocks_completed';

  // Métodos para Privacy
  Future<void> setPrivacyRead(bool read) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_privacyReadKey, read);
  }

  Future<bool> isPrivacyRead() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_privacyReadKey) ?? false;
  }

  // Métodos para Terms
  Future<void> setTermsRead(bool read) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_termsReadKey, read);
  }

  Future<bool> isTermsRead() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_termsReadKey) ?? false;
  }

  // Verificar se ambos foram lidos
  Future<bool> isFullyAccepted() async {
    final privacyRead = await isPrivacyRead();
    final termsRead = await isTermsRead();
    return privacyRead && termsRead;
  }

  // Aceitar políticas
  Future<void> setPoliciesAccepted(String version) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_policiesVersionKey, version);
    await prefs.setString(_acceptedAtKey, DateTime.now().toIso8601String());
  }

  // Obter versão aceita
  Future<String?> getAcceptedVersion() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_policiesVersionKey);
  }

  // Onboarding
  Future<void> setOnboardingCompleted(bool completed) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_onboardingCompletedKey, completed);
  }

  Future<bool> isOnboardingCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_onboardingCompletedKey) ?? false;
  }

  // Progresso de estudo
  Future<void> setStudyBlocksCompleted(int count) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_studyBlocksCompletedKey, count);
  }

  Future<int> getStudyBlocksCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_studyBlocksCompletedKey) ?? 0;
  }

  // Limpar tudo (para revogação)
  Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}