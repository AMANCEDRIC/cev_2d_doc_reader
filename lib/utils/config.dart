class AppConfig {
  // Utilisez l'adresse IP pour les tests sur appareil réel/émulateur Android
  // localhost (127.0.0.1) ne fonctionne pas sur les émulateurs Android pour pointer vers la machine hôte
  static const String baseUrl = 'http://192.168.100.35:8081/api/v1';
  
  static const String verifyEndpoint = '$baseUrl/verification';
  
  // Timeout pour les requêtes API
  static const Duration apiTimeout = Duration(seconds: 10);
}
