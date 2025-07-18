import 'package:friendly_card_management/controllers/main_controller.dart';
import 'package:friendly_card_management/controllers/question_controller.dart';
import 'package:friendly_card_management/controllers/teacher_controller.dart';
import 'package:friendly_card_management/controllers/topic_controller.dart';
import 'package:friendly_card_management/controllers/users_controller.dart';
import 'package:friendly_card_management/controllers/vocabulary_controller.dart';
import 'package:get/get.dart';

class InitalBinding extends Bindings {
  @override
  void dependencies() async {
    Get.put(MainController());
    Get.put(UsersController());
    Get.put(TeacherController());
    Get.put(TopicController());
    Get.put(VocabularyController());
    Get.put(QuestionController());

    await Get.find<QuestionController>().loadQuestionType();
    // Get.find<UsersController>().checkLogin();
  }
}

// class AdminBinding extends Bindings {
//   @override
//   void dependencies() {
//     Get.find<UsersController>().checkLogin();
//   }
// }
