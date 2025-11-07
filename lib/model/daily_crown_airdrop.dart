// class DailyCrownAirdrop {
//   final int hour;
//   final bool isPeriodic;
//
//   DailyCrownAirdrop({required this.hour, required this.isPeriodic});
//
//   factory DailyCrownAirdrop.none() {
//     return DailyCrownAirdrop(hour: 0, isPeriodic: false);
//   }
//
//   factory DailyCrownAirdrop.fromJson(Map<String, dynamic> json) {
//     return DailyCrownAirdrop(hour: json['hour'], isPeriodic: json['isPeriodically']);
//   }
//
//   DailyCrownAirdrop copyWith({int? hour, bool? isPeriodic}) {
//     return DailyCrownAirdrop(
//       hour: hour ?? this.hour,
//       isPeriodic: isPeriodic ?? this.isPeriodic,
//     );
//   }
//
//   DailyCrownAirdrop update(DailyCrownAirdrop dailyCrownAirdrop) {
//     return copyWith(hour: dailyCrownAirdrop.hour, isPeriodic: dailyCrownAirdrop.isPeriodic);
//   }
// }
