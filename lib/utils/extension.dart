import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:jiffy/jiffy.dart';

extension IterableExtension<T> on Iterable<T> {
  Iterable<T> distinctBy(Object Function(T e) getCompareValue) {
    var result = <T>[];
    forEach((element) {
      if (!result.any((x) => getCompareValue(x) == getCompareValue(element))) {
        result.add(element);
      }
    });

    return result;
  }


}


/// extension for checking if its Today

extension DateTimeExtension on DateTime {
  bool isToday() {
    DateTime now = DateTime.now();
    return now.year == year && now.month == month && now.day == day;
  }

  /// extension on datetime to convert it to Jiffy
  /// convert to Jiffy
  String toNow() => Jiffy(this).fromNow();

  /// returns datetime in [yMMMed - yMMMed] format
  String getTwoDifferentTimes({DateTime? second}) {
    String time = Jiffy(this).Hm;
    print('time is single: $time');
    if (second != null) {
      time = '$time - ${Jiffy(second).Hm}';
      print('time is double: $time');
    }

    return time;
  }

  String get toDate => Jiffy(this).yMMMEd;
}


/// specifically for followers, members, and admins count
extension SocialFriendlyFormatter on String {
  String toSocialFriendly() {
    int number = int.tryParse(this) ?? 0;

    // 1,000,000
    if (number >= 1000000) {
      double num = number / 1000000.0;
      return '${num.toStringAsFixed(num.truncateToDouble() == num ? 0 : 1)}M';
    }
    // 1,000
    else if (number >= 1000) {
      double num = number / 1000.0;
      return '${num.toStringAsFixed(num.truncateToDouble() == num ? 0 : 1)}K';
    }
    // 0-999
    else {
      return this;
    }
  }
}

extension ToUpperCamelCase on String {
  String toUpperCamelCase() {
    List<String> words = split(' ');

    for (int i = 0; i < words.length; i++) {
      String word = words[i];
      if (word.isNotEmpty) {
        words[i] = '${word[0].toUpperCase()}${word.substring(1)}';
      }
    }

    return words.join();
  }
}

extension ToReadableString on int {
  /// Returns a string representation of this integer as + if value is greater than 99.
  String get toCount99Plus {
    if (this > 99) {
      return '99+';
    } else {
      return toString();
    }
  }
}

extension AggregateCount on Query {
  Future<int> getCount() async {
    return (await count().get()).count;
  }
}