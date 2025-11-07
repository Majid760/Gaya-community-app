class AiUserMatchedModel {
  List<String> goals;
  List<String> genders;
  CreatedBy createdBy;
  CreatedBy? matchedUserProfile;
  DateTime createdAt;
  DateTime? updatedAt;

  AiUserMatchedModel({
    required this.goals,
    required this.genders,
    required this.createdBy,
    this.matchedUserProfile,
    required this.createdAt,
    this.updatedAt,
  });

  factory AiUserMatchedModel.fromJson(Map<String, dynamic> json) => AiUserMatchedModel(
        goals: List<String>.from(json["goals"].map((x) => x)),
        genders: List<String>.from(json["genders"].map((x) => x)),
        createdBy: CreatedBy.fromJson(json["createdBy"]),
        matchedUserProfile: (json["matchedUserProfile"] != null) ? CreatedBy.fromJson(json["matchedUserProfile"]) : null,
        createdAt: DateTime.fromMillisecondsSinceEpoch(json["createdAt"]).toUtc(),
        updatedAt: (json["updatedAt"] != null) ? json["updatedAt"].toDate() : null,
      );

  Map<String, dynamic> toJson() => {
        "goals": List<String>.from(goals.map((x) => x)),
        "genders": List<String>.from(genders.map((x) => x)),
        "createdBy": createdBy.toJson(),
        // ignore: prefer_null_aware_operators
        "matchedUserProfile": matchedUserProfile == null ? null : matchedUserProfile?.toJson(),
        "createdAt": createdAt.millisecondsSinceEpoch,
        "updatedAt": updatedAt,
      };
}

class CreatedBy {
  String id;
  String name;
  DateTime age;
  List<String> joinedCommunities;
  List<String> interests;
  String gender;
  String imageUrl;

  CreatedBy({
    required this.id,
    required this.name,
    required this.age,
    required this.joinedCommunities,
    required this.interests,
    required this.gender,
    required this.imageUrl,
  });

  factory CreatedBy.fromJson(Map<String, dynamic> json) => CreatedBy(
        id: json["id"],
        name: json["name"],
        age: json["age"].toDate(),
        joinedCommunities: List<String>.from(json["joinedCommunities"].map((x) => x)),
        interests: List<String>.from(json["interests"].map((x) => x)),
        gender: json["gender"],
        imageUrl: json["imageUrl"] ?? "",
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "age": age,
        "joinedCommunities": List<String>.from(joinedCommunities.map((x) => x)),
        "interests": List<String>.from(interests.map((x) => x)),
        "gender": gender,
        "imageUrl": imageUrl,
      };
}

// class MatchedUserProfile {
//   String id;
//   String name;
//   List<String> interests;
//   List<MutualCommunity> mutualCommunities;
//   String age;

//   MatchedUserProfile({
//     required this.id,
//     required this.name,
//     required this.interests,
//     required this.mutualCommunities,
//     required this.age,
//   });

//   factory MatchedUserProfile.fromJson(Map<String, dynamic> json) => MatchedUserProfile(
//         id: json["id"],
//         name: json["name"],
//         interests: List<String>.from(json["interests"].map((x) => x)),
//         mutualCommunities: List<MutualCommunity>.from(json["mutualCommunities"].map((x) => MutualCommunity.fromJson(x))),
//         age: json["age"],
//       );

//   Map<String, dynamic> toJson() => {
//         "id": id,
//         "name": name,
//         "interests": List<String>.from(interests.map((x) => x)),
//         "mutualCommunities": List<dynamic>.from(mutualCommunities.map((x) => x.toJson())),
//         "age": age,
//       };
// }

// class MutualCommunity {
//   String communityId;
//   String communityName;

//   MutualCommunity({
//     required this.communityId,
//     required this.communityName,
//   });

//   factory MutualCommunity.fromJson(Map<String, dynamic> json) => MutualCommunity(
//         communityId: json["communityId"],
//         communityName: json["communityName"],
//       );

//   Map<String, dynamic> toJson() => {
//         "communityId": communityId,
//         "communityName": communityName,
//       };
// }
