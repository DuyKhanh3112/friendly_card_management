// ignore_for_file: use_build_context_synchronously, prefer_const_constructors, sized_box_for_whitespace, avoid_unnecessary_containers

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:friendly_card_management/components/custom_button.dart';
import 'package:friendly_card_management/components/custom_dialog.dart';
import 'package:friendly_card_management/components/custom_text_field.dart';
import 'package:friendly_card_management/controllers/users_controller.dart';
import 'package:friendly_card_management/widget/loading_page.dart';
import 'package:friendly_card_management/utils/app_color.dart';
import 'package:get/get.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    UsersController usersController = Get.find<UsersController>();

    final formKey = GlobalKey<FormState>();
    Rx<TextEditingController> usernameController = TextEditingController().obs;
    Rx<TextEditingController> passwordController = TextEditingController().obs;

    return Obx(() {
      return usersController.loading.value
          ? const LoadingPage()
          : SafeArea(
              child: Scaffold(
                backgroundColor: AppColor.lightBlue,
                body: Center(
                  child: Container(
                    constraints: BoxConstraints(
                      maxHeight: Get.height * 0.75,
                      minHeight: Get.height * 0.3,
                    ),
                    width: Get.width * 0.4,
                    alignment: Alignment.center,
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
                    child: Container(
                      width: Get.width * 0.3,
                      alignment: Alignment.center,
                      child: Form(
                        key: formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset(
                              'images/logo.png',
                              height: Get.height * 0.15,
                            ),
                            Container(
                              padding: EdgeInsets.symmetric(
                                vertical: Get.height * 0.02,
                              ),
                              child: Text(
                                'Chào mừng bạn đến với FriendlyCard.\n Vui lòng đăng nhập để truy cập hệ thống.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: AppColor.blue,
                                ),
                              ),
                            ),
                            CustomTextField(
                              label: 'Tài khoản',
                              onChanged: (value) {
                                usernameController.value.text = value;
                              },
                              required: true,
                            ),
                            CustomTextField(
                              label: 'Mật khẩu',
                              onChanged: (value) {
                                passwordController.value.text = value;
                              },
                              required: true,
                              isPassword: true,
                            ),
                            InkWell(
                              onTap: () async {
                                TextEditingController emailController =
                                    TextEditingController();
                                TextEditingController unameController =
                                    TextEditingController();

                                final keyForgotPassword =
                                    GlobalKey<FormState>();
                                await Get.dialog(
                                  AlertDialog(
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
                                    title: Container(
                                      // padding: EdgeInsets.symmetric(
                                      //   horizontal: Get.width * 0.01,
                                      // ),
                                      // width: Get.width * 0.5,
                                      // height: Get.height * 0.5,
                                      child: Column(
                                        children: [
                                          Text(
                                            'Quên mật khẩu',
                                            style: TextStyle(
                                              color: AppColor.blue,
                                            ),
                                          ),
                                          const Divider(),
                                        ],
                                      ),
                                    ),
                                    content: Container(
                                      width: Get.width * 0.2,
                                      height: Get.height * 0.25,
                                      child: Form(
                                        key: keyForgotPassword,
                                        child: ListView(
                                          children: [
                                            CustomTextField(
                                              label: 'Tài khoản',
                                              controller: unameController,
                                              hint: 'Nhập tên tài khoản',
                                              required: true,
                                              widthPrefix: Get.width * 0.075,
                                            ),
                                            CustomTextField(
                                              label: 'Email',
                                              required: true,
                                              controller: emailController,
                                              hint: 'Nhập email',
                                              type: ContactType.mail,
                                              widthPrefix: Get.width * 0.075,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    actions: [
                                      ElevatedButton(
                                        style: ButtonStyle(
                                          backgroundColor:
                                              WidgetStatePropertyAll(
                                                Colors.red,
                                              ),
                                          foregroundColor:
                                              WidgetStatePropertyAll(
                                                Colors.white,
                                              ),
                                        ),
                                        onPressed: () {
                                          Get.back();
                                        },
                                        child: Text('Đóng'),
                                      ),
                                      ElevatedButton(
                                        style: ButtonStyle(
                                          backgroundColor:
                                              WidgetStatePropertyAll(
                                                AppColor.blue,
                                              ),
                                          foregroundColor:
                                              WidgetStatePropertyAll(
                                                Colors.white,
                                              ),
                                        ),
                                        onPressed: () async {
                                          if (keyForgotPassword.currentState!
                                              .validate()) {}
                                        },
                                        child: Text('Xác nhận'),
                                      ),
                                    ],
                                  ),
                                );
                              },
                              child: Container(
                                alignment: Alignment.centerRight,
                                padding: EdgeInsets.only(
                                  right: Get.width * 0.01,
                                ),
                                child: Text(
                                  'Quên mật khẩu ?',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: AppColor.blue,
                                    fontStyle: FontStyle.italic,
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                              ),
                            ),
                            CustomButton(
                              title: 'Đăng nhập',
                              bgColor: AppColor.blue,
                              textColor: Colors.white,
                              onClicked: () async {
                                if (formKey.currentState!.validate()) {
                                  bool res = await usersController.login(
                                    usernameController.value.text,
                                    passwordController.value.text,
                                  );
                                  if (!res) {
                                    if (usersController.user.value.id == '') {
                                      await showAlertDialog(
                                        context,
                                        DialogType.error,
                                        'Đăng nhập không thành công!',
                                        'Tài khoản hoặc mật khẩu không đúng.',
                                      );
                                      return;
                                    }
                                    if (!usersController.user.value.active) {
                                      await showAlertDialog(
                                        context,
                                        DialogType.error,
                                        'Đăng nhập không thành công!',
                                        'Tài khoản đã bị khóa.\nLý do bị khóa: ${usersController.user.value.reason_lock ?? ''}.\nVui lòng liên hệ quản trị viên để kích hoạt lại tài khoản.',
                                      );
                                      return;
                                    }
                                  }
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
    });
  }
}
