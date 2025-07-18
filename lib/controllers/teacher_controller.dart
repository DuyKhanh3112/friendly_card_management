// ignore_for_file: invalid_use_of_protected_member

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:friendly_card_management/models/users.dart';
import 'package:get/get.dart';

class TeacherController extends GetxController {
  RxBool loading = false.obs;
  CollectionReference usersCollection = FirebaseFirestore.instance.collection(
    'users',
  );
  RxList<Users> listTeachers = <Users>[].obs;
  Rx<Users> teacher = Users.initTeacher().obs;

  Future<void> loadAllData() async {
    loading.value = true;
    listTeachers.value = [];
    final snapshoot = await usersCollection
        .where('role', isEqualTo: 'teacher')
        .get();

    for (var doc in snapshoot.docs) {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      data['id'] = doc.id;
      listTeachers.value.add(Users.fromJson(data));
    }

    loading.value = false;
  }

  Future<void> updateTeacher(Users teach) async {
    loading.value = true;
    teach.update_at = Timestamp.now();
    teach.role = 'teacher';
    await usersCollection.doc(teach.id).update(teach.toVal());
    await loadAllData();
    // teacher.value = Users.initTeacher();
    loading.value = false;
  }

  Future<void> createTeacher() async {
    loading.value = true;
    WriteBatch batch = FirebaseFirestore.instance.batch();
    String id = usersCollection.doc().id;
    DocumentReference refTeacher = usersCollection.doc(id);
    teacher.value.update_at = Timestamp.now();
    teacher.value.role = 'teacher';
    teacher.value.password = teacher.value.username;
    batch.set(refTeacher, teacher.value.toVal());
    await batch.commit();
    await loadAllData();
    teacher.value = Users.initTeacher();
    loading.value = false;
  }
}
