class AuthService {
  String? _currentUser;
  String? _authToken;

  bool get isAuthenticated => _authToken != null;
  String? get currentUser => _currentUser;

  Future<bool> login(String username, String password) async {
    _currentUser = username;
    _authToken = 'token_$username';
    return true;
  }

  void logout() {
    _currentUser = null;
    _authToken = null;
  }
}
