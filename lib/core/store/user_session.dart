// No imports needed for this simple model

class UserIdentity {
  final String name;
  final String dni;
  final String pin;
  final String did;
  final List<String> seedPhrase;

  UserIdentity({
    required this.name,
    required this.dni,
    required this.pin,
    required this.did,
    required this.seedPhrase,
  });
}

class UserSession {
  static final UserSession _instance = UserSession._internal();
  factory UserSession() => _instance;
  UserSession._internal();

  UserIdentity? _currentIdentity;

  UserIdentity? get currentIdentity => _currentIdentity;

  void setIdentity(UserIdentity identity) {
    _currentIdentity = identity;
  }

  bool get hasIdentity => _currentIdentity != null;

  void logout() {
    _currentIdentity = null;
  }
}
