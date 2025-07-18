// ignore_for_file: invalid_use_of_protected_member

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:friendly_card_management/controllers/cloudinary_controller.dart';
import 'package:friendly_card_management/controllers/users_controller.dart';
import 'package:friendly_card_management/models/topic.dart';
import 'package:get/get.dart';

class TopicController extends GetxController {
  RxBool loading = false.obs;

  CollectionReference topicCollection = FirebaseFirestore.instance.collection(
    'topic',
  );

  RxList<Topic> listTopics = <Topic>[].obs;
  Rx<Topic> topic = Topic.initTopic().obs;
  UsersController usersController = Get.find<UsersController>();

  Future<void> loadTopicTeacher() async {
    listTopics.value = [];
    loading.value = true;

    var snapshoot = await topicCollection
        .where('user_id', isEqualTo: usersController.user.value.id)
        .get();
    for (var item in snapshoot.docs) {
      Map<String, dynamic> data = item.data() as Map<String, dynamic>;
      data['id'] = item.id;
      listTopics.value.add(Topic.fromJson(data));
    }
    loading.value = false;
  }

  Future<void> loadAllTopic() async {
    listTopics.value = [];
    loading.value = true;

    var snapshoot = await topicCollection.get();
    for (var item in snapshoot.docs) {
      Map<String, dynamic> data = item.data() as Map<String, dynamic>;
      data['id'] = item.id;
      listTopics.value.add(Topic.fromJson(data));
    }
    loading.value = false;
  }

  Future<void> createTopic(String imgBase64) async {
    loading.value = true;
    WriteBatch batch = FirebaseFirestore.instance.batch();
    String id = topicCollection.doc().id;
    String imgUrl = await CloudinaryController().uploadImage(
      imgBase64,
      id,
      'topic/$id',
    );
    topic.value.image = imgUrl;
    DocumentReference refTopic = topicCollection.doc(id);
    topic.value.update_at = Timestamp.now();
    batch.set(refTopic, topic.value.toVal());
    await batch.commit();
    await loadTopicTeacher();
    topic.value = Topic.initTopic();
    loading.value = false;
  }

  Future<void> updateTopic(String imgBase64) async {
    loading.value = true;
    topic.value.update_at = Timestamp.now();
    if (imgBase64 != '') {
      String imgUrl = await CloudinaryController().uploadImage(
        imgBase64,
        topic.value.id,
        'topic',
      );
      topic.value.image = imgUrl;
    }
    await topicCollection.doc(topic.value.id).update(topic.value.toVal());
    loading.value = false;
  }

  Future<void> updateTopicStatus(Topic item, String status) async {
    loading.value = true;
    item.update_at = Timestamp.now();
    item.status = status;
    await topicCollection.doc(item.id).update(item.toVal());
    await loadAllTopic();
    loading.value = false;
  }
}
