import 'package:gaya/model/user.model.dart';

class ContactUs {
  late String name;
  late String email;
  late String message;

  ContactUs({required this.name, required this.email, required this.message});

  ContactUs.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    email = json['email'];
    message = json['message'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['name'] = name;
    data['email'] = email;
    data['message'] = message;
    return data;
  }

  factory ContactUs.problem({required String message}) {
    final user = UserModel.to;
    return ContactUs(name: user.userName, email: user.email ?? user.phoneNumber ?? user.uId ?? "", message: message);
  }
}
