// ignore_for_file: non_constant_identifier_names

class TeacherInfo {
  String id;
  String user_id;
  String attachments;
  TeacherInfo({
    required this.id,
    required this.user_id,
    required this.attachments,
  });

  factory TeacherInfo.initTeacherInfo() {
    return TeacherInfo(
      id: '',
      user_id: '',
      attachments: '',
    );
  }

  static TeacherInfo fromJson(Map<String, dynamic> json) {
    return TeacherInfo(
      id: json['id'],
      user_id: json['user_id'],
      attachments: json['attachments'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': user_id,
      'attachments': attachments,
    };
  }

  Map<String, dynamic> toVal() {
    return {
      // 'id': id,
      'user_id': user_id,
      'attachments': attachments,
    };
  }
}
