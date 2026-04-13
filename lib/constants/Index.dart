class GlobalConstants {
  static const String API_BASE_URL = 'https://api.jieyu.org';
  static const String APP_NAME = 'Jieyu App';
  static const int TIMEOUT_DURATION_SECONDS = 10;
}

class HttpConstants {
  static const String SELECT_SALT_ENDPOINT = '/auth/selectSalt';
  static const String LOGIN_ENDPOINT = '/auth/login';
  static const String REGISTRATION_ENDPOINT = '/auth/registration';
  static const String RESEND_OTP_ENDPOINT = '/auth/resendOtp';
  static const String VERIFY_OTP_ENDPOINT = '/auth/verifyOtp';
  static const String GET_TASK_ENDPOINT = '/task/getTask';
  static const String ADD_TASK_ENDPOINT = '/task/addTask';
  static const String UPDATE_TASK_ENDPOINT = '/task/updateTask';
  static const String DELETE_TASK_ENDPOINT = '/task/deleteTask';
}