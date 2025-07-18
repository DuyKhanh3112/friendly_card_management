// ignore_for_file: prefer_const_constructors, sort_child_properties_last, invalid_use_of_protected_member, sized_box_for_whitespace, deprecated_member_use, unrelated_type_equality_checks, avoid_unnecessary_containers, unused_import, avoid_print

import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:convert_vietnamese/convert_vietnamese.dart';
import 'package:flexible_grid_view/flexible_grid_view.dart';
import 'package:flutter/material.dart';
import 'package:friendly_card_management/components/custom_button.dart';
import 'package:friendly_card_management/components/custom_search_field.dart';
import 'package:friendly_card_management/components/custom_text_field.dart';
import 'package:friendly_card_management/controllers/main_controller.dart';
import 'package:friendly_card_management/controllers/question_controller.dart';
import 'package:friendly_card_management/controllers/teacher_controller.dart';
import 'package:friendly_card_management/controllers/topic_controller.dart';
import 'package:friendly_card_management/controllers/users_controller.dart';
import 'package:friendly_card_management/controllers/vocabulary_controller.dart';
import 'package:friendly_card_management/models/topic.dart';
import 'package:friendly_card_management/models/vocabulary.dart';
import 'package:friendly_card_management/utils/tool.dart';
import 'package:friendly_card_management/widget/empty_data.dart';
import 'package:friendly_card_management/widget/loading_page.dart';
import 'package:friendly_card_management/models/users.dart';
import 'package:friendly_card_management/utils/app_color.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
// import 'package:image_picker_web/image_picker_web.dart';
// import 'package:flutter/foundation.dart' show  kIsWeb;

class TopicManagmentScreen extends StatelessWidget {
  const TopicManagmentScreen({super.key});
  void loadData(
    RxList<Topic> listTopic,
    Rx<TextEditingController> searchController,
  ) {
    TopicController topicController = Get.find<TopicController>();
    listTopic.value = topicController.listTopics.value
        .where(
          (item) => removeDiacritics(item.name.toUpperCase()).contains(
            removeDiacritics(searchController.value.text.toUpperCase()),
          ),
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    UsersController usersController = Get.find<UsersController>();
    TopicController topicController = Get.find<TopicController>();

    Rx<TextEditingController> searchController = TextEditingController().obs;

    RxList<Topic> listTopic = <Topic>[].obs;

    RxInt currentPage = 0.obs;
    if (usersController.user.value.role == 'teacher') {
      topicController.loadTopicTeacher();
    }

    return Obx(() {
      loadData(listTopic, searchController);
      return usersController.loading.value || topicController.loading.value
          ? const LoadingPage()
          : Scaffold(
              body: Column(
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: Get.width * 0.05),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          width: Get.width * 0.6,
                          child: CustomSearchFiled(
                            hint: 'Tìm kiếm chủ đề theo Tên chủ đề.',
                            onChanged: (String value) {
                              loadData(listTopic, searchController);
                            },
                            controller: searchController.value,
                          ),
                        ),
                        Container(
                          width: Get.width * 0.05,
                          child: IconButton(
                            onPressed: () async {
                              topicController.loading.value = true;
                              searchController.value.clear();
                              if (usersController.user.value.role == 'admin') {
                                await topicController.loadAllTopic();
                              } else {
                                await topicController.loadTopicTeacher();
                              }
                              loadData(listTopic, searchController);
                              topicController.loading.value = false;
                            },
                            icon: Icon(
                              Icons.refresh,
                              color: AppColor.lightBlue,
                            ),
                            style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all<Color>(
                                AppColor.blue,
                              ),
                            ),
                          ),
                        ),
                        usersController.user.value.role == 'teacher'
                            ? Container(
                                width: Get.width * 0.2,
                                decoration: BoxDecoration(),
                                child: CustomButton(
                                  title: 'Thêm chủ đề',
                                  bgColor: AppColor.blue,
                                  onClicked: () async {
                                    topicController.topic.value =
                                        Topic.initTopic();
                                    await formTopic();
                                  },
                                ),
                              )
                            : SizedBox(),
                      ],
                    ),
                  ),
                  Divider(),
                  listTopic.value
                          .where(
                            (item) =>
                                item.status ==
                                Tool.listStatus[currentPage.value]['value'],
                          )
                          .isEmpty
                      ? EmptyData()
                      : Expanded(
                          child: FlexibleGridView(
                            axisCount: GridLayoutEnum.threeElementsInRow,
                            crossAxisSpacing: 8,
                            mainAxisSpacing: 8,
                            children: listTopic.value
                                .where(
                                  (item) =>
                                      item.status ==
                                      Tool.listStatus[currentPage
                                          .value]['value'],
                                )
                                .map((item) => topicItem(context, item))
                                .toList(),
                          ),
                        ),
                ],
              ),
              backgroundColor: AppColor.lightBlue,
              bottomNavigationBar: BottomNavigationBar(
                elevation: 15,
                type: BottomNavigationBarType.fixed,
                selectedFontSize: 16,
                unselectedFontSize: 13,
                selectedIconTheme: const IconThemeData(size: 32),
                unselectedIconTheme: const IconThemeData(size: 24),
                showUnselectedLabels: true,
                backgroundColor: AppColor.blue,
                unselectedItemColor: AppColor.labelBlue,
                unselectedLabelStyle: TextStyle(color: AppColor.labelBlue),
                selectedLabelStyle: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
                selectedItemColor: Colors.white,
                items: Tool.listStatus
                    .map(
                      (status) => BottomNavigationBarItem(
                        icon: Icon(Icons.check_circle),
                        label:
                            '${status['label']} (${listTopic.value.where((item) => item.status == status['value']).length})',
                      ),
                    )
                    .toList(),
                // items: [
                // BottomNavigationBarItem(
                //   icon: Icon(Icons.check_circle),
                //   label:
                //       'Đã được duyệt (${listTopic.value.where((item) => item.status == 'active').length})',
                // ),
                // BottomNavigationBarItem(
                //   icon: Icon(Icons.cancel),
                //   label:
                //       'Chờ duyệt (${listTopic.value.where((item) => item.status == 'draft').length})',
                // ),
                // BottomNavigationBarItem(
                //   icon: Icon(Icons.cancel),
                //   label:
                //       'Không duyệt (${listTopic.value.where((item) => item.status == 'inactive').length})',
                // ),
                // ],
                currentIndex: currentPage.value,
                onTap: (value) {
                  currentPage.value = value;
                },
              ),
            );
    });
  }

  Container topicItem(BuildContext context, Topic item) {
    UsersController usersController = Get.find<UsersController>();
    TeacherController teacherController = Get.find<TeacherController>();
    TopicController topicController = Get.find<TopicController>();
    Users teacher = Users.initTeacher();
    if (usersController.user.value.role == 'teacher') {
      teacher = usersController.user.value;
    } else {
      teacher =
          teacherController.listTeachers.value.firstWhereOrNull(
            (t) => t.id == item.user_id,
          ) ??
          Users.initTeacher();
    }
    var itemColor =
        (Tool.listStatus.firstWhereOrNull((s) => s['value'] == item.status) ??
        Tool.listStatus[0])['color'];
    // var itemStatusLabel =
    //     (Tool.listStatus.firstWhereOrNull((s) => s['value'] == item.status) ??
    //         Tool.listStatus[0])['label'];
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: Get.width * 0.03,
        vertical: Get.height * 0.05,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(25)),
        color: Colors.white,
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: InkWell(
        onTap: () async {
          topicController.topic.value = item;
          await formTopic();
        },
        child: Column(
          children: [
            Stack(
              alignment: Alignment.topRight,
              children: [
                Container(
                  height: Get.height * 0.3,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: NetworkImage(
                        (item.image != '')
                            ? item.image
                            : 'https://res.cloudinary.com/drir6xyuq/image/upload/v1749203203/logo_icon.png',
                      ),
                      fit: BoxFit.fitHeight,
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.only(
                    top: Get.width * 0.01,
                    right: Get.width * 0.01,
                  ),
                  child: PopupMenuButton<String>(
                    child: Icon(Icons.circle, color: itemColor),
                    color: AppColor.lightBlue,
                    itemBuilder: (context) =>
                        usersController.user.value.role == 'teacher'
                        ? []
                        : Tool.listStatus
                              .where((stt) => stt['value'] != item.status)
                              .map(
                                (stt) => PopupMenuItem(
                                  value: stt['value'].toString(),
                                  child: ListTile(
                                    leading: Icon(
                                      Icons.circle,
                                      color: stt['color'],
                                    ),
                                    textColor: stt['color'],
                                    titleTextStyle: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                    title: Text(stt['label']),
                                  ),
                                ),
                              )
                              .toList(),
                    // : item.status == 'darft'
                    //     ? [
                    //         PopupMenuItem(
                    //           value: 'active',
                    //           child: ListTile(
                    //             leading: Icon(
                    //               Icons.circle,
                    //               color: Colors.grey,
                    //             ),
                    //             textColor: Colors.grey,
                    //             titleTextStyle: TextStyle(
                    //               fontWeight: FontWeight.bold,
                    //             ),
                    //             title: Text('Duyệt'),
                    //           ),
                    //         ),
                    //         PopupMenuItem(
                    //           value: 'inactive',
                    //           child: ListTile(
                    //             leading: Icon(
                    //               Icons.circle,
                    //               color: AppColor.blue,
                    //             ),
                    //             textColor: AppColor.blue,
                    //             titleTextStyle: TextStyle(
                    //               fontWeight: FontWeight.bold,
                    //             ),
                    //             title: Text('Không duyệt'),
                    //           ),
                    //         ),
                    //       ]
                    //     : [],
                    onSelected: (value) async {
                      await topicController.updateTopicStatus(item, value);
                    },
                  ),
                ),
              ],
            ),
            Divider(),
            Container(
              padding: EdgeInsets.all(Get.height * 0.01),
              child: Text(
                item.name.toUpperCase(),
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Container(
              padding: EdgeInsets.all(Get.height * 0.01),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.person),
                  Text(
                    ' ${teacher.fullname}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> formTopic() async {
    TopicController topicController = Get.find<TopicController>();
    UsersController usersController = Get.find<UsersController>();
    TextEditingController nameController = TextEditingController(
      text: topicController.topic.value.name,
    );
    final formKey = GlobalKey<FormState>();

    RxString imgBase64 = ''.obs;
    RxString imgUrl = topicController.topic.value.image.obs;

    await Get.dialog(
      Obx(
        () => AlertDialog(
          backgroundColor: AppColor.lightBlue,
          titlePadding: EdgeInsets.symmetric(
            horizontal: Get.width * 0.025,
            vertical: Get.width * 0.01,
          ),
          contentPadding: EdgeInsets.symmetric(
            horizontal: Get.width * 0.025,
            // vertical: Get.width * 0.01,
          ),
          buttonPadding: EdgeInsets.symmetric(
            horizontal: Get.width * 0.025,
            vertical: Get.width * 0.01,
          ),
          actionsPadding: EdgeInsets.symmetric(
            horizontal: Get.width * 0.025,
            vertical: Get.width * 0.01,
          ),
          title: Column(
            children: [
              Text(
                'Thông tin chủ đề',
                style: TextStyle(
                  fontSize: 28,
                  color: AppColor.blue,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Divider(color: AppColor.blue),
            ],
          ),
          content: Container(
            width: Get.width * 0.5,
            height: Get.height * 0.3,
            child: Form(
              key: formKey,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Container(
                      // padding: const EdgeInsets.all(8.0),
                      child: CustomTextField(
                        label: 'Tên chủ đề',
                        controller: nameController,
                        required: true,
                        readOnly: usersController.user.value.role != 'teacher',
                      ),
                    ),
                  ),
                  Column(
                    children: [
                      Expanded(
                        flex: 1,
                        child: InkWell(
                          onTap: usersController.user.value.role != 'teacher'
                              ? null
                              : () async {
                                  // if (kIsWeb) {
                                  //   var result =
                                  //       await ImagePickerWeb.getImageAsBytes();
                                  //   if (result != null) {
                                  //     imgBase64.value = base64Encode(result);
                                  //   }
                                  // } else {
                                  //   //saif image picker
                                  // }
                                },
                          child: Container(
                            height: Get.height * 0.25,
                            width: Get.height * 0.25,
                            padding: EdgeInsets.all(12),
                            margin: EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              // border: Border.all(),
                              borderRadius: BorderRadius.all(
                                Radius.circular(32),
                              ),
                              image: topicController.topic.value.id == ''
                                  ? imgBase64.value == ''
                                        ? null
                                        : DecorationImage(
                                            image: MemoryImage(
                                              base64Decode(imgBase64.value),
                                            ),
                                            fit: BoxFit.cover,
                                          )
                                  : imgBase64.value == ''
                                  ? imgUrl.value == ''
                                        ? null
                                        : DecorationImage(
                                            image: NetworkImage(imgUrl.value),
                                            fit: BoxFit.cover,
                                          )
                                  : DecorationImage(
                                      image: MemoryImage(
                                        base64Decode(imgBase64.value),
                                      ),
                                      fit: BoxFit.cover,
                                    ),
                              color: Colors.white,
                              boxShadow: const [
                                BoxShadow(
                                  color: Colors.black26,
                                  blurRadius: 10,
                                  offset: Offset(0, 4),
                                ),
                              ],
                            ),
                            alignment: Alignment.center,
                          ),
                        ),
                      ),
                      usersController.user.value.role == 'teacher'
                          ? Text(
                              'Nhấn vào đây để thay đổi ảnh chủ đề.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 14,
                                fontStyle: FontStyle.italic,
                                color: AppColor.labelBlue,
                              ),
                            )
                          : SizedBox(),
                    ],
                  ),
                ],
              ),
            ),
          ),
          actions: [
            Column(
              children: [
                Divider(color: AppColor.blue),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      style: ButtonStyle(
                        backgroundColor: WidgetStatePropertyAll(Colors.red),
                        foregroundColor: WidgetStatePropertyAll(Colors.white),
                      ),
                      onPressed: () {
                        Get.back();
                      },
                      child: Text('Đóng'),
                    ),
                    usersController.user.value.role == 'teacher'
                        ? Row(
                            children: [
                              SizedBox(width: 64),
                              ElevatedButton(
                                style: ButtonStyle(
                                  backgroundColor: WidgetStatePropertyAll(
                                    AppColor.blue,
                                  ),
                                  foregroundColor: WidgetStatePropertyAll(
                                    Colors.white,
                                  ),
                                ),
                                onPressed: () async {
                                  if (formKey.currentState!.validate()) {
                                    topicController.topic.value.name =
                                        nameController.text;
                                    topicController.topic.value.user_id =
                                        usersController.user.value.id;
                                    topicController.topic.value.update_at =
                                        Timestamp.now();
                                    Get.back();
                                    if (topicController.topic.value.id == '') {
                                      await topicController.createTopic(
                                        imgBase64.value,
                                      );
                                    } else {
                                      await topicController.updateTopic(
                                        imgBase64.value,
                                      );
                                    }
                                  }
                                },
                                child: Text('Xác nhận'),
                              ),
                            ],
                          )
                        : SizedBox(),
                    topicController.topic.value.id != ''
                        ? Row(
                            children: [
                              SizedBox(width: 64),
                              ElevatedButton(
                                style: ButtonStyle(
                                  backgroundColor: WidgetStatePropertyAll(
                                    AppColor.blue,
                                  ),
                                  foregroundColor: WidgetStatePropertyAll(
                                    Colors.white,
                                  ),
                                ),
                                onPressed: () async {
                                  Get.back();
                                  topicController.loading.value = true;
                                  await Get.find<VocabularyController>()
                                      .loadVocabularyTopic();
                                  topicController.loading.value = false;
                                  Get.toNamed('/vocabulary');
                                },
                                child: Text('Từ vựng'),
                              ),
                              SizedBox(width: 64),
                              ElevatedButton(
                                style: ButtonStyle(
                                  backgroundColor: WidgetStatePropertyAll(
                                    AppColor.blue,
                                  ),
                                  foregroundColor: WidgetStatePropertyAll(
                                    Colors.white,
                                  ),
                                ),
                                onPressed: () async {
                                  Get.back();
                                  topicController.loading.value = true;
                                  await Get.find<QuestionController>()
                                      .loadQuestionData();
                                  topicController.loading.value = false;
                                  Get.toNamed('/question');
                                },
                                child: Text('Câu hỏi'),
                              ),
                            ],
                          )
                        : SizedBox(),
                    usersController.user.value.role == 'admin'
                        ? Row(
                            children: Tool.listStatus
                                .where(
                                  (stt) =>
                                      stt['value'] !=
                                      topicController.topic.value.status,
                                )
                                .map(
                                  (stt) => Row(
                                    children: [
                                      SizedBox(width: 64),
                                      ElevatedButton(
                                        style: ButtonStyle(
                                          backgroundColor:
                                              WidgetStatePropertyAll(
                                                stt['color'],
                                              ),
                                          foregroundColor:
                                              WidgetStatePropertyAll(
                                                Colors.white,
                                              ),
                                        ),
                                        onPressed: () async {
                                          Get.back();
                                          await topicController
                                              .updateTopicStatus(
                                                topicController.topic.value,
                                                stt['value'],
                                              );
                                        },
                                        child: Text(stt['label']),
                                      ),
                                    ],
                                  ),
                                )
                                .toList(),
                          )
                        : SizedBox(),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
