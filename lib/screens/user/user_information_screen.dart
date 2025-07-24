// ignore_for_file: sized_box_for_whitespace

import 'package:flutter/material.dart';
import 'package:friendly_card_management/components/custom_button.dart';
import 'package:friendly_card_management/components/custom_text_field.dart';
import 'package:friendly_card_management/config.dart';
import 'package:friendly_card_management/controllers/users_controller.dart';
import 'package:friendly_card_management/widget/loading_page.dart';
import 'package:friendly_card_management/utils/app_color.dart';
import 'package:get/get.dart';

class UserInformationScreen extends StatelessWidget {
  const UserInformationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    UsersController usersController = Get.find<UsersController>();
    Map<String, String> role =
        Config.listRole.firstWhereOrNull(
          (r) => r['value'] == usersController.user.value.role,
        ) ??
        {'value': '', 'label': ''};
    final formKey = GlobalKey<FormState>();
    TextEditingController fullnameController = TextEditingController(
      text: usersController.user.value.fullname,
    );
    TextEditingController phoneController = TextEditingController(
      text: usersController.user.value.phone,
    );
    TextEditingController emailController = TextEditingController(
      text: usersController.user.value.email,
    );

    return Obx(() {
      return usersController.loading.value
          ? const LoadingPage()
          : Center(
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: Get.width * 0.05,
                  vertical: Get.height * 0.05,
                ),
                width: Get.width * 0.65,
                height: Get.height * 0.8,
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(25)),
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                alignment: Alignment.center,
                child: Form(
                  key: formKey,
                  child: ListView(
                    children: [
                      Container(
                        width: Get.width * 0.4,
                        padding: EdgeInsets.symmetric(
                          horizontal: Get.width * 0.05,
                        ),
                        child: CustomTextField(
                          label: 'Tên tài khoản',
                          readOnly: true,
                          controller: TextEditingController(
                            text: usersController.user.value.username,
                          ),
                        ),
                      ),
                      Container(
                        width: Get.width * 0.4,
                        padding: EdgeInsets.symmetric(
                          horizontal: Get.width * 0.05,
                        ),
                        child: CustomTextField(
                          label: 'Họ tên',
                          readOnly: false,
                          controller: fullnameController,
                        ),
                      ),
                      Container(
                        width: Get.width * 0.4,
                        padding: EdgeInsets.symmetric(
                          horizontal: Get.width * 0.05,
                        ),
                        child: CustomTextField(
                          label: 'Số điện thoại',
                          readOnly: false,
                          controller: phoneController,
                        ),
                      ),
                      Container(
                        width: Get.width * 0.4,
                        padding: EdgeInsets.symmetric(
                          horizontal: Get.width * 0.05,
                        ),
                        child: CustomTextField(
                          label: 'Email',
                          readOnly: false,
                          type: ContactType.mail,
                          controller: emailController,
                        ),
                      ),
                      Container(
                        width: Get.width * 0.4,
                        padding: EdgeInsets.symmetric(
                          horizontal: Get.width * 0.05,
                        ),
                        child: CustomTextField(
                          label: 'Quyền',
                          readOnly: true,
                          controller: TextEditingController(
                            text: role['label'],
                          ),
                        ),
                      ),
                      Container(
                        width: Get.width * 0.4,
                        padding: EdgeInsets.symmetric(
                          horizontal: Get.width * 0.05,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              width: Get.width * 0.15,
                              child: CustomButton(
                                title: 'Lưu thông tin',
                                onClicked: () async {
                                  if (formKey.currentState!.validate()) {
                                    usersController.user.value.fullname =
                                        fullnameController.text;
                                    usersController.user.value.phone =
                                        phoneController.text;
                                    usersController.user.value.email =
                                        emailController.text;
                                    await usersController
                                        .updateInformationUser();
                                  }
                                },
                                bgColor: AppColor.blue,
                              ),
                            ),
                            Container(
                              width: Get.width * 0.15,
                              child: CustomButton(
                                title: 'Đổi mật khẩu',
                                bgColor: AppColor.blue,
                                onClicked: () async {},
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
    });
  }
}
