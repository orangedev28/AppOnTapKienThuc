class AppConfig {
  static const String baseUrl = "http://192.168.1.71:8080/localconnect/";
}

class ApiUrls {
  static const String loginUrl = "${AppConfig.baseUrl}login.php";
  static const String registerUrl = "${AppConfig.baseUrl}register.php";
  static const String forgotpasswordUrl =
      "${AppConfig.baseUrl}forgot_password.php";
  static const String changePasswordUrl =
      "${AppConfig.baseUrl}change_password.php";
  static const String subjectsUrl = "${AppConfig.baseUrl}subjects.php";
  static const String quizzesUrl = "${AppConfig.baseUrl}quizzes.php";
  static const String questionsUrl = "${AppConfig.baseUrl}questions.php";
  static const String checkScoreExistAndSaveUrl =
      "${AppConfig.baseUrl}checkscore_exist_and_save.php";
  static const String documentsUrl = "${AppConfig.baseUrl}documents.php";
  static const String videossUrl = "${AppConfig.baseUrl}videos.php";
  static const String infoUserUrl = "${AppConfig.baseUrl}user.php";
  static const String updateImageUrl = "${AppConfig.baseUrl}update_image.php";
  static const String autoquizUrl = "${AppConfig.baseUrl}auto_createquiz.php";
  static const String saveNoteUrl = "${AppConfig.baseUrl}add_note.php";
  static const String getNoteUrl = "${AppConfig.baseUrl}get_note.php";
  static const String getScoreUrl = "${AppConfig.baseUrl}get_score.php";
  static const String getStudyPlan = "${AppConfig.baseUrl}get_studyplan.php";
}
