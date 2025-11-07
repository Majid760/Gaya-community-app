import '../utils/assets_icons.dart';

class TopicsModel {
  String image;
  String title;
  bool isSeleted;
  String? url;

  TopicsModel({
    required this.title,
    required this.image,
    required this.isSeleted,
    this.url,
  });

  @override
  bool operator ==(other) {
    if (identical(this, other)) return true;
    return other is TopicsModel && title == other.title;
  }

  @override
  int get hashCode => title.hashCode;

  factory TopicsModel.fromMap(Map<String, dynamic> map) {
    return TopicsModel(
      title: map['title'],
      image: map['image'],
      isSeleted: false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'image': image,
    };
  }
}

List<TopicsModel> topicsList = [
  TopicsModel(image: '🎯', title: 'Self development', isSeleted: false, url: IconsAssetsPathUtils.selfDevelopmentTopic),
  TopicsModel(image: '😂', title: 'Funny', isSeleted: false, url: IconsAssetsPathUtils.funnyTopic),
  TopicsModel(image: '📚', title: 'School', isSeleted: false, url: IconsAssetsPathUtils.schoolTopic),
  TopicsModel(image: '👫', title: 'Friends', isSeleted: false, url: IconsAssetsPathUtils.friendsTopic),
  TopicsModel(image: '🎮', title: 'Gaming', isSeleted: false, url: IconsAssetsPathUtils.gamingTopic),
  TopicsModel(image: '💋', title: 'Relationships', isSeleted: false, url: IconsAssetsPathUtils.relationshipsTopic),
  TopicsModel(image: '🎨', title: 'Art', isSeleted: false, url: IconsAssetsPathUtils.artTopic),
  TopicsModel(image: '🌿', title: 'Health', isSeleted: false, url: IconsAssetsPathUtils.healthTopic),
  TopicsModel(image: '🍔', title: 'Food', isSeleted: false, url: IconsAssetsPathUtils.foodTopic),
  TopicsModel(image: '💅🏻', title: 'Beauty', isSeleted: false, url: IconsAssetsPathUtils.beautyTopic),
  TopicsModel(image: '💫', title: 'Life style', isSeleted: false, url: IconsAssetsPathUtils.lifestyleTopic),
  TopicsModel(image: '🏃🏽‍♀', title: 'Fitness', isSeleted: false, url: IconsAssetsPathUtils.fitnessTopic),
  TopicsModel(image: '💡', title: 'Inspiration', isSeleted: false, url: IconsAssetsPathUtils.inspirationTopic),
  TopicsModel(image: '🖌', title: 'DIY', isSeleted: false, url: IconsAssetsPathUtils.diyTopic),
  TopicsModel(image: '🙏🏻', title: 'Advice', isSeleted: false, url: IconsAssetsPathUtils.adviceTopic),
  TopicsModel(image: '📝', title: 'Writing', isSeleted: false, url: IconsAssetsPathUtils.writingTopic),
  TopicsModel(image: '❤️', title: 'Love', isSeleted: false, url: IconsAssetsPathUtils.loveTopic),
  TopicsModel(image: '🎥', title: 'Movies', isSeleted: false, url: IconsAssetsPathUtils.moviesTopic),
  TopicsModel(image: '🐶', title: 'Animals', isSeleted: false, url: IconsAssetsPathUtils.animalsTopic),
  TopicsModel(image: '👗', title: 'Fashion', isSeleted: false, url: IconsAssetsPathUtils.fashionTopic),
  TopicsModel(image: '⚽', title: 'Sports', isSeleted: false, url: IconsAssetsPathUtils.sportTopic),
  TopicsModel(image: '💁‍♀', title: 'Girls talk', isSeleted: false, url: IconsAssetsPathUtils.girlsTalkTopic),
  TopicsModel(image: '📺', title: 'TV', isSeleted: false, url: IconsAssetsPathUtils.tvTopic),
  TopicsModel(image: '✈️', title: 'Travel', isSeleted: false, url: IconsAssetsPathUtils.travelTopic),
  TopicsModel(image: '🤫', title: 'Confessions', isSeleted: false, url: IconsAssetsPathUtils.confessionTopic),
  TopicsModel(image: '💡', title: 'Entrepreneurship', isSeleted: false, url: IconsAssetsPathUtils.entrepreneurshipTopic),
  TopicsModel(image: '🎎', title: 'Anime', isSeleted: false, url: IconsAssetsPathUtils.animeTopic),
  TopicsModel(image: '🎵', title: 'Music', isSeleted: false, url: IconsAssetsPathUtils.musicTopic),
  TopicsModel(image: '👯‍♀️', title: 'Dance', isSeleted: false, url: IconsAssetsPathUtils.danceTopic),
  TopicsModel(image: '📖', title: 'Poems', isSeleted: false, url: IconsAssetsPathUtils.poemsTopic),
  TopicsModel(image: '📷', title: 'Photography', isSeleted: false, url: IconsAssetsPathUtils.photographyTopic),
  TopicsModel(image: '📚', title: 'Books', isSeleted: false, url: IconsAssetsPathUtils.booksTopic),
  TopicsModel(image: '🎉', title: 'Parties', isSeleted: false, url: IconsAssetsPathUtils.partiesTopic),
  TopicsModel(image: '🚗', title: 'Motorsport', isSeleted: false, url: IconsAssetsPathUtils.motorshipTopic),
  TopicsModel(image: '🤘', title: 'Metal', isSeleted: false, url: IconsAssetsPathUtils.metalTopic),
  TopicsModel(image: '🎼', title: 'K pop', isSeleted: false, url: IconsAssetsPathUtils.kPopTopic),
  TopicsModel(image: '🔐', title: 'Crypto', isSeleted: false, url: IconsAssetsPathUtils.cryptoTopic),
  TopicsModel(image: '👩‍🎨', title: 'Design', isSeleted: false, url: IconsAssetsPathUtils.designTopic),
  TopicsModel(image: '🤔', title: 'Content creation', isSeleted: false, url: IconsAssetsPathUtils.contentCreationTopic),
  TopicsModel(image: '🚘', title: 'Cars', isSeleted: false, url: IconsAssetsPathUtils.carsTopic),
  TopicsModel(image: '🤩', title: 'Marvel Nintendo DC', isSeleted: false, url: IconsAssetsPathUtils.marvelNintendoDCTopic),
  TopicsModel(image: '💻', title: 'Blog', isSeleted: false, url: IconsAssetsPathUtils.blogTopic),
  TopicsModel(image: '🐎', title: 'Horse racing', isSeleted: false, url: IconsAssetsPathUtils.horseRacingTopic),
  TopicsModel(image: '📈', title: 'Business', isSeleted: false, url: IconsAssetsPathUtils.businessTopic),
  TopicsModel(image: '💰', title: 'Money', isSeleted: false, url: IconsAssetsPathUtils.moneyTopic),
  TopicsModel(image: '🧬', title: 'Science', isSeleted: false, url: IconsAssetsPathUtils.scienceTopic),
  TopicsModel(image: '🧸', title: 'Hobbies', isSeleted: false, url: IconsAssetsPathUtils.hobbiesTopic),
  TopicsModel(image: '👩‍💻', title: 'Technology', isSeleted: false, url: IconsAssetsPathUtils.technologyTopic),
  TopicsModel(image: '📸', title: 'Celebrity', isSeleted: false, url: IconsAssetsPathUtils.celebrityTopic),
  TopicsModel(image: '🪐', title: 'Space', isSeleted: false, url: IconsAssetsPathUtils.spaceTopic),
  TopicsModel(image: '🔑', title: 'Leadership', isSeleted: false, url: IconsAssetsPathUtils.leadershipTopic),
  TopicsModel(image: '🎁', title: 'Board games', isSeleted: false, url: IconsAssetsPathUtils.boardGamesTopic),
  TopicsModel(image: '🥣', title: 'Cooking', isSeleted: false, url: IconsAssetsPathUtils.cookingTopic),
  TopicsModel(image: '🖥️', title: 'Programming', isSeleted: false, url: IconsAssetsPathUtils.programmingTopic),
  TopicsModel(image: '🏀', title: 'Basketball', isSeleted: false, url: IconsAssetsPathUtils.basketballTopic),
  TopicsModel(image: '⚽️', title: 'Football', isSeleted: false, url: IconsAssetsPathUtils.footballTopic),
  TopicsModel(image: '🎾', title: 'Tennis', isSeleted: false, url: IconsAssetsPathUtils.tennisTopic),
  TopicsModel(image: '🤖', title: 'Cyber', isSeleted: false, url: IconsAssetsPathUtils.cyberTopic),
  TopicsModel(image: '👀', title: 'Nonsense', isSeleted: false, url: IconsAssetsPathUtils.nonesenseTopic),
  TopicsModel(image: '👣', title: 'Criminology', isSeleted: false, url: IconsAssetsPathUtils.criminologyTopic),
  TopicsModel(image: '👩‍❤️‍👨', title: 'Dating', isSeleted: false, url: IconsAssetsPathUtils.datingTopic),
  TopicsModel(image: '🏳️‍🌈', title: 'LGBTQ+', isSeleted: false, url: IconsAssetsPathUtils.lgtbTopic),
  TopicsModel(image: '🧶', title: 'Knitting', isSeleted: false, url: IconsAssetsPathUtils.knittingTopic),
  TopicsModel(image: '📰', title: 'News', isSeleted: false, url: IconsAssetsPathUtils.newsTopic),
];

class TopicsUtils {
  static List<TopicsModel> getTopicsList() => topicsList;

  /// get related topics for each topic to recommend to user
  /// for example: if user selected 'Fitness' topic, we will recommend 'Health' topic to him
  /// if no topics selected, return all topics
  static List<String> getRecommendedTopics(List<String> selectedTopics) {
    /// if no topics selected, return all topics
    if (selectedTopics.isEmpty) return allTopics;
    Map<String, String> recommendedTopics = <String, String>{};

    // get related topics
    for (String topic in selectedTopics) {
      relatedTopics[topic]?.forEach((element) {
        recommendedTopics[element] = element;
      });
    }

    return recommendedTopics.keys.toList();
  }

  static List<String> get allTopics => topicsList.map((e) => e.title).toList();
  static Map<String, List<String>> relatedTopics = {
    'Self development': ['Inspiration', 'Advice', 'Entrepreneurship', 'Money'],
    'Funny': ['Movies', 'TV', 'Celebrity'],
    'School': ['Books', 'Writing', 'Poems'],
    'Friends': ['Relationships', 'Girls talk', 'Travel', 'Parties', 'Confessions'],
    'Gaming': ['Motorsport', 'Technology', 'Dance', 'Sports'],
    'Relationships': ['Love', 'Confessions', 'Girls talk', 'Travel'],
    'Art': ['Design', 'Photography', 'Fashion', 'DIY'],
    'Health': ['Fitness', 'Food', 'Beauty', 'Life style'],
    'Food': ['Travel', 'Cooking', 'Hobbies'],
    'Beauty': ['Fashion', 'Design', 'Photography', 'Art'],
    'Life style': ['Fashion', 'Travel', 'Hobbies', 'Parties', 'Knitting'],
    'Fitness': ['Health', 'Dance', 'Motorsport', 'Sports'],
    'Inspiration': ['Self development', 'Entrepreneurship', 'Leadership', 'Advice'],
    'DIY': ['Design', 'Photography', 'Art', 'Fashion', 'Hobbies'],
    'Advice': ['Self development', 'Entrepreneurship', 'Leadership', 'Inspiration'],
    'Writing': ['Books', 'School', 'Poems'],
    'Love': ['Relationships', 'Confessions', 'Girls talk', 'Travel'],
    'Movies': ['Funny', 'TV', 'Celebrity', 'Marvel Nintendo DC', 'Anime', 'Music'],
    'Animals': ['Travel'],
    'Fashion': ['Beauty', 'Life style', 'Design', 'Photography', 'Art'],
    'Sports': ['Motorsport', 'Horse racing'],
    'Girls talk': ['Relationships', 'Love', 'Confessions', 'Friends', 'Travel', 'Parties', 'Life style'],
    'TV': ['Funny', 'Movies', 'Celebrity', 'Marvel Nintendo DC', 'Anime', 'Music', 'Dance'],
    'Travel': ['Friends', 'Life style', 'Animals'],
    'Confessions': ['Love', 'Relationships', 'Girls talk'],
    'Entrepreneurship': ['Self development', 'Inspiration', 'Advice', 'Business'],
    'Anime': ['Design', 'Art'],
    'Music': ['K pop', 'Metal', 'Dance'],
    'Dance': ['Fitness', 'Motorsport', 'Gaming', 'K pop'],
    'Poems': ['Writing', 'School', 'Books'],
    'Photography': ['Design', 'Art'],
    'Books': ['Writing', 'School', 'Poems'],
    'Parties': ['Friends', 'Life style', 'Travel'],
    'Motorsport': ['Gaming', 'Sports', 'Fitness', 'Cars', 'Horse racing'],
    'Metal': ['Music', 'K pop'],
    'K pop': ['Music', 'Dance', 'Metal'],
    'Crypto': ['Money', 'Technology', 'Business', 'Leadership'],
    'Design': ['Art', 'DIY', 'Content creation', 'Cars', 'Beauty'],
    'Content creation': ['Design', 'Technology', 'Business', 'Hobbies'],
    'Cars': ['Motorsport', 'Design'],
    'Marvel Nintendo DC': ['Movies', 'Gaming'],
    'Blog': [
      'Writing',
      'Technology',
      'Celebrity',
      'Fashion',
      'Life style',
      'Travel',
      'Animals',
      'Food',
      'Health',
      'Fitness',
      'Hobbies',
      'Cyber',
      'News'
    ],
    'Horse racing': ['Sports', 'Motorsport', 'Travel', 'Animals', 'Life style'],
    'Business': ['Entrepreneurship', 'Money', 'Leadership'],
    'Money': ['Self development', 'Entrepreneurship', 'Crypto', 'Business', 'Leadership'],
    'Science': ['Technology', 'Space', 'Astronomy'],
    'Hobbies': ['Life style', 'Technology', 'Content creation', 'Programming', 'News', 'Knitting'],
    'Technology': ['Gaming', 'Crypto', 'Design', 'Content creation', 'Science', 'Hobbies', 'Programming', 'Cyber'],
    'Celebrity': ['Funny', 'TV', 'Blog'],
    'Space': ['Science', 'Technology', 'Astronomy'],
    'Leadership': ['Self development', 'Entrepreneurship', 'Inspiration', 'Business'],
    'Gifts': ['Life style'],
    'Programming': ['Cyber', 'Technology', 'Content creation', 'Business'],
    'Astronomy': ['Science', 'Space', 'Photography', 'Technology'],
    'Basketball': ['Sports', 'Fitness', 'Health', 'Motorsport'],
    'Football': ['Sports', 'Fitness', 'Health', 'Motorsport'],
    'Tennis': ['Sports', 'Fitness', 'Health', 'Motorsport'],
    'Cyber': ['Programming', 'Technology'],
    'Nonsense': ['Funny', 'TV', 'Celebrity'],
    'Criminology': ['Science', 'Technology', 'Leadership', 'Business', 'Money', 'Entrepreneurship', 'Self development'],
    'LGBTQ+': ['Love', 'Relationships'],
    'News': ['Hobbies', 'Blog'],
    'Knitting': ['Hobbies', 'Life style'],
  };

// TODO GENDER WISE
}
