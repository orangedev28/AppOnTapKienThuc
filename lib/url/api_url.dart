class ApiUrls {
  static const String quizzesUrl =
      "http://172.20.149.58:8080/localconnect/quizzes.php";
  static const String questionsUrl =
      "http://172.20.149.58:8080/localconnect/questions.php";
  static const String checkScoreExistAndSaveUrl =
      "http://172.20.149.58:8080/localconnect/checkscore_exist_and_save.php";
  static const String documentsUrl =
      "http://172.20.149.58:8080/localconnect/documents.php";
  static const String videossUrl =
      "http://172.20.149.58:8080/localconnect/videos.php";
  static const String subjectsUrl =
      "http://172.20.149.58:8080/localconnect/subjects.php";
  static const String loginUrl =
      "http://172.20.149.58:8080/localconnect/loginApp.php";
  static const String registerUrl =
      "http://172.20.149.58:8080/localconnect/register.php";
  static const String forgotpasswordUrl =
      "http://172.20.149.58:8080/localconnect/forgot_password.php";
  static const String changePasswordUrl =
      "http://172.20.149.58:8080/localconnect/change_password.php";
  static const String infoUserUrl =
      "http://172.20.149.58:8080/localconnect/user.php";
  static const String updateImageUrl =
      "http://172.20.149.58:8080/localconnect/update_image.php";
  static const String autoquizUrl =
      "http://172.20.149.58:8080/localconnect/auto_createquiz.php";
  static String getSavedQuizzesUrl(int userId) {
    return "http://172.20.149.58:8080/localconnect/check_quiz_saved.php?user_id=$userId";
  }
}
