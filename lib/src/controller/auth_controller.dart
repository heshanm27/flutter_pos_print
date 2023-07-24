


class AuthController {
  static const String _key = "O7sdHPml6zBaGgvjQQ/lNfD22ZvbJ6hP92PZ98P9dPlKk352xrHpYQvYzZ970qw0";


  static Future<bool> checkAuth(String key) async {
    if(key == _key){
      return true;
    }else{
      return false;
    }
  }

}