class GlobalConstants {
  static const String API_BASE_URL = 'https://api.jieyu.org';
  static const String APP_NAME = 'Jieyu App';
  static const int TIMEOUT_DURATION_SECONDS = 10;
}

class HttpConstants {
  static const String SELECT_SALT = '/auth/selectSalt';
  static const String LOGIN = '/auth/login';
  static const String REGISTRATION = '/auth/registration';
  static const String RESEND_OTP = '/auth/resendOtp';
  static const String VERIFY_OTP = '/auth/verifyOtp';
  static const String VERIFY_TOKEN = '/auth/verifyToken';
  static const String GET_USER_INFO = '/auth/getUserInfo';
  static const String UPDATE_USER_INFO = '/auth/updateUserInfo';
  static const String CHANGE_PASSWORD = '/auth/changePassword';
  static const String LOGOUT = '/auth/logout';

  static const String GET_TASK = '/task/getTask';
  static const String ADD_TASK = '/task/addTask';
  static const String UPDATE_TASK = '/task/updateTask';
  static const String DELETE_TASK = '/task/deleteTask';
}

class RegexConstant {
  static const String USERNAME = r"^[a-zA-Z][a-zA-Z0-9_]{4,20}$";
  static const String PASSWORD = r"^[a-zA-Z0-9!@?_]{8,}$";
  static const String EMAIL = r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+";
  static const String PHONE = r"^09\d{8}$'";
}

class SecurityStorageServiceConstant {
  static const String TOKEN = "token";
  static const String ID = "id";
  static const String USERNAME = "username";
  static const String EMAIL = "email";
  static const String PHONE = "phone";
  static const String GENDER = "gender";
  static const String BIRTHDAY = "birthday";
  static const String ADDRESS = "address";
  static const String PASSWORD = "password";
}

class SharedPreferenceConstant {
  static const String REMEMBER_ME = "rememberMe";
  static const String APP_THEME_COLOR = "appThemeColor";
}