import '../../../../model/community.model.dart';

/// This class contains communities with topic name
/// A local model to store communities with topic name
class TopicCommunities {
  final String topicName;
  final List<Community> communities;

  TopicCommunities({required this.topicName, required this.communities});

  @override
  String toString() => 'TopicCommunities(topicName: $topicName, communities: $communities)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is TopicCommunities && other.topicName == topicName;
  }

  @override
  int get hashCode => topicName.hashCode;
}
