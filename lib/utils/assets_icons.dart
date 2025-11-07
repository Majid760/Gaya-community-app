import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gaya/utils/theme/app_colors.dart';

class IconsAssetsPathUtils {
  IconsAssetsPathUtils._();

  static const String filledPath = "Assets/icons/filled/";
  static const String outlinePath = "Assets/icons/outline/";
  static const String navbarPath = "Assets/icons/navbar_icons/";
  static const String notificationPath = "Assets/icons/notification_icon/";
  static const String appIconsPath = 'Assets/icons/';
  static const String assetImages = 'Assets/Images/';
  static const String appSplashImagesPath = 'Assets/splash/';
  static const String appSplashInterestPath = 'Assets/splash/interests/';
  static const String appSplashTopicsPath = 'Assets/splash/topics/';
  static const String appInfluenceBarIconsPath = 'Assets/icons/influence/';

  // Influence bar assets path getter
  static String get closeRed => '${appInfluenceBarIconsPath}close_red.svg';
  static String get emojiYellow => '${appInfluenceBarIconsPath}emoji_yellow.svg';
  static String get emojiBlue => '${appInfluenceBarIconsPath}emoji_blue.svg';
  static String get tickGreen => '${appInfluenceBarIconsPath}tick_green.svg';
  static String get tickBlue => '${appInfluenceBarIconsPath}tick_blue.svg';
  static String get heartPrimary => '${appInfluenceBarIconsPath}heart_primary.svg';

  static String get fireYellow => '${appInfluenceBarIconsPath}fire_yellow.svg';
  static String get fireRed => '${appInfluenceBarIconsPath}fire_red.svg';
  static String get firePrimary => '${appInfluenceBarIconsPath}fire_primary.svg';
  static String get fireGreen => '${appInfluenceBarIconsPath}fire_green.svg';

  // splash screen assets path getter
  static String get splashWelcome => '${appSplashImagesPath}Welcome123.svg';

  static String get splashWelcomePng => '${appSplashImagesPath}Welcome.png';

  static String get findEmoji => '${appSplashImagesPath}find_emoji.svg';

  static String get welcomeCirclesSvg => '${appSplashImagesPath}welcome_circleses.svg';

  static String get welcomeCirclesPng => '${appSplashImagesPath}welcome_circleses.png';

  static String get welcome2png => '${appSplashImagesPath}welcome2png.png';

  static String get welcomeCircleSvg => '${appSplashImagesPath}welcome_circleses.svg';

/*
  // interests
  static String get scienceInterest => '${appSplashInterestPath}science.png';
  static String get artDrawingInterest => '${appSplashInterestPath}art&drawing.png';
  static String get basketBallInterest => '${appSplashInterestPath}basketball.png';
  static String get businessInterest => '${appSplashInterestPath}business.png';
  static String get carMotorInterest => '${appSplashInterestPath}car&motor.png';
  static String get chessInterest => '${appSplashInterestPath}cheess.png';
  static String get campingInterest => '${appSplashInterestPath}camping.png';
  static String get fantasyInterest => '${appSplashInterestPath}fantasy.png';
  static String get fitnessInterest => '${appSplashInterestPath}fitnesss.png';
  static String get foodInterest => '${appSplashInterestPath}food.png';
  static String get gamesInterest => '${appSplashInterestPath}games.png';
  static String get historyInterest => '${appSplashInterestPath}history.png';
  static String get makeupInterest => '${appSplashInterestPath}makeup.png';
  static String get memeInterest => '${appSplashInterestPath}memes.png';
  static String get natureInterest => '${appSplashInterestPath}nature.png';
  static String get newInterest => '${appSplashInterestPath}new.png';
  static String get pizzaInterest => '${appSplashInterestPath}pizza.png';
  static String get recipeInterest => '${appSplashInterestPath}recipes1.png';
  static String get romanceInterest => '${appSplashInterestPath}romance.png';
  static String get selfImprovementInterest => '${appSplashInterestPath}selfimprovement.png';
  static String get spaceInterest => '${appSplashInterestPath}space.png';
  static String get technologyInterest => '${appSplashInterestPath}technology.png';
  static String get tennisInterest => '${appSplashInterestPath}tennis.png';
  static String get travelInterest => '${appSplashInterestPath}travel.png';
*/

  //topics
  static String adviceTopic =
      'https://firebasestorage.googleapis.com/v0/b/gaya-5876c.appspot.com/o/interestImages%2Fadvice.png?alt=media&token=1a0f3b9f-3d08-4796-b027-5b0b87916e25';
  static String animalsTopic =
      'https://firebasestorage.googleapis.com/v0/b/gaya-5876c.appspot.com/o/interestImages%2Fanimals.png?alt=media&token=60419965-8024-4c70-ae37-7355fc2f7892';
  static String animeTopic =
      'https://firebasestorage.googleapis.com/v0/b/gaya-5876c.appspot.com/o/interestImages%2Fanime.png?alt=media&token=ad67b0dd-9d21-41b7-b694-e53a1a630548';
  static String artTopic =
      'https://firebasestorage.googleapis.com/v0/b/gaya-5876c.appspot.com/o/interestImages%2Fart.png?alt=media&token=fdfba386-93db-49bf-9e84-5c9a44a035fd';
  static String basketballTopic =
      'https://firebasestorage.googleapis.com/v0/b/gaya-5876c.appspot.com/o/interestImages%2Fbasketball.png?alt=media&token=ab73d6a6-8cac-4121-a03f-3d2a0764706d';
  static String beautyTopic =
      'https://firebasestorage.googleapis.com/v0/b/gaya-5876c.appspot.com/o/interestImages%2Fbeauty.png?alt=media&token=a6757a56-8db6-4816-aaf7-7872cf0748ee';
  static String astronomy =
      'https://firebasestorage.googleapis.com/v0/b/gaya-5876c.appspot.com/o/interestImages%2Fastronomy.png?alt=media&token=74e08865-9446-46d0-b77e-bd0e28f9201c';
  static String blogTopic =
      'https://firebasestorage.googleapis.com/v0/b/gaya-5876c.appspot.com/o/interestImages%2Fblog.png?alt=media&token=d757e8b6-f6b2-4b39-973f-a4a7fce2cf20';
  static String boardGamesTopic =
      'https://firebasestorage.googleapis.com/v0/b/gaya-5876c.appspot.com/o/interestImages%2Fboard_games.png?alt=media&token=3d93906b-2b41-4a7d-8861-00b6a90e5437';
  static String booksTopic =
      'https://firebasestorage.googleapis.com/v0/b/gaya-5876c.appspot.com/o/interestImages%2Fbooks.png?alt=media&token=594e4427-2d34-4d2c-b49f-97094586c41b';
  static String businessTopic =
      'https://firebasestorage.googleapis.com/v0/b/gaya-5876c.appspot.com/o/interestImages%2Fbusiness.png?alt=media&token=91dfa35d-eb1f-4a66-b712-2d1218c48ed5';
  static String carsTopic =
      'https://firebasestorage.googleapis.com/v0/b/gaya-5876c.appspot.com/o/interestImages%2Fcars.png?alt=media&token=77d0343e-0e22-41dc-a56c-88e224ce844d';
  static String celebrityTopic =
      'https://firebasestorage.googleapis.com/v0/b/gaya-5876c.appspot.com/o/interestImages%2Fcelebrity.png?alt=media&token=8d9cf48f-54ec-42e3-98a2-9ec621fc22e5';
  static String contentCreationTopic =
      'https://firebasestorage.googleapis.com/v0/b/gaya-5876c.appspot.com/o/interestImages%2Fcontent_creation.png?alt=media&token=9665fd8e-8883-4379-8d06-883af6746129';
  static String confessionTopic =
      'https://firebasestorage.googleapis.com/v0/b/gaya-5876c.appspot.com/o/interestImages%2Fconfession.png?alt=media&token=0301022b-87b7-401e-9b1c-995d44301f52';
  static String cookingTopic =
      'https://firebasestorage.googleapis.com/v0/b/gaya-5876c.appspot.com/o/interestImages%2Fcooking.png?alt=media&token=619d311f-5519-4163-9146-f8644ef74315';
  static String criminologyTopic =
      'https://firebasestorage.googleapis.com/v0/b/gaya-5876c.appspot.com/o/interestImages%2Fcriminology.png?alt=media&token=73a52173-9305-4099-996f-e4890be46114';
  static String cryptoTopic =
      'https://firebasestorage.googleapis.com/v0/b/gaya-5876c.appspot.com/o/interestImages%2Fcrypto.png?alt=media&token=71ff3076-d40c-4096-a59e-33aa64584fd5';
  static String cyberTopic =
      'https://firebasestorage.googleapis.com/v0/b/gaya-5876c.appspot.com/o/interestImages%2Fcyber.png?alt=media&token=46687465-1b31-4fc8-8850-bdf4fb17ee86';
  static String danceTopic =
      'https://firebasestorage.googleapis.com/v0/b/gaya-5876c.appspot.com/o/interestImages%2Fdance.png?alt=media&token=a5576899-0306-49b2-9ca0-d762dcfa5e76';
  static String datingTopic =
      'https://firebasestorage.googleapis.com/v0/b/gaya-5876c.appspot.com/o/interestImages%2Fdating.png?alt=media&token=4b23ac07-c076-40e0-a82d-abd57c572a02';
  static String designTopic =
      'https://firebasestorage.googleapis.com/v0/b/gaya-5876c.appspot.com/o/interestImages%2Fdesign.png?alt=media&token=98b43f7f-9db9-40dc-af42-f17df53d4f5d';
  static String diyTopic =
      'https://firebasestorage.googleapis.com/v0/b/gaya-5876c.appspot.com/o/interestImages%2Fdiy.png?alt=media&token=56ccaf92-7acb-49c9-bcb1-b4a1f5344a41';
  static String entrepreneurshipTopic =
      'https://firebasestorage.googleapis.com/v0/b/gaya-5876c.appspot.com/o/interestImages%2Fentrepreneurship.png?alt=media&token=360df645-018b-4c3d-b7de-25a71c094ef6';
  static String fashionTopic =
      'https://firebasestorage.googleapis.com/v0/b/gaya-5876c.appspot.com/o/interestImages%2Ffashion.png?alt=media&token=16870217-886f-4944-93b3-5eae98ec5607';
  static String fitnessTopic =
      'https://firebasestorage.googleapis.com/v0/b/gaya-5876c.appspot.com/o/interestImages%2Ffitness.png?alt=media&token=4e68d4b5-78cd-44c5-995e-a2a9fe1ec819';
  static String foodTopic =
      'https://firebasestorage.googleapis.com/v0/b/gaya-5876c.appspot.com/o/interestImages%2Ffood.png?alt=media&token=8dd88cb7-5c54-49c5-a7f0-a6fed122e0f5';
  static String footballTopic =
      'https://firebasestorage.googleapis.com/v0/b/gaya-5876c.appspot.com/o/interestImages%2Ffootball.png?alt=media&token=6b4f7441-296c-43d5-9a26-8eb10c55665f';
  static String friendsTopic =
      'https://firebasestorage.googleapis.com/v0/b/gaya-5876c.appspot.com/o/interestImages%2Ffriends.png?alt=media&token=9f513af0-00a6-410d-bb68-3e8018a0687d';
  static String funnyTopic =
      'https://firebasestorage.googleapis.com/v0/b/gaya-5876c.appspot.com/o/interestImages%2Ffunny.png?alt=media&token=b3f96002-ae3e-4bb9-b115-218a652d2c82';
  static String gamingTopic =
      'https://firebasestorage.googleapis.com/v0/b/gaya-5876c.appspot.com/o/interestImages%2Fgaming.png?alt=media&token=ad421599-a924-4c30-bfc4-d7303497847b';
  static String giftsTopic =
      'https://firebasestorage.googleapis.com/v0/b/gaya-5876c.appspot.com/o/interestImages%2Fgifts.png?alt=media&token=b214b69d-08cf-4c1e-b583-62e7faec1170';
  static String girlsTalkTopic =
      'https://firebasestorage.googleapis.com/v0/b/gaya-5876c.appspot.com/o/interestImages%2Fgirls_talk.png?alt=media&token=309f7a34-7b98-4daa-8928-ca2adc3ac7ab';
  static String healthTopic =
      'https://firebasestorage.googleapis.com/v0/b/gaya-5876c.appspot.com/o/interestImages%2Fhealth.png?alt=media&token=926f16b8-4a6d-496c-a7a4-c1770cc6f706';
  static String hobbiesTopic =
      'https://firebasestorage.googleapis.com/v0/b/gaya-5876c.appspot.com/o/interestImages%2Fhobbies.png?alt=media&token=d7fc5bcd-1bbd-48ec-8467-f5f7df10e420';
  static String horseRacingTopic =
      'https://firebasestorage.googleapis.com/v0/b/gaya-5876c.appspot.com/o/interestImages%2Fhorse_racing.png?alt=media&token=7a797da3-f490-41fc-bacb-62022eb8107e';
  static String inspirationTopic =
      'https://firebasestorage.googleapis.com/v0/b/gaya-5876c.appspot.com/o/interestImages%2Finspiration.png?alt=media&token=d26c75ca-1bcf-43b3-a182-19577326f1b0';
  static String kPopTopic =
      'https://firebasestorage.googleapis.com/v0/b/gaya-5876c.appspot.com/o/interestImages%2Fk_pop.png?alt=media&token=a76e769b-047b-469e-847e-cfbf2895111a';
  static String leadershipTopic =
      'https://firebasestorage.googleapis.com/v0/b/gaya-5876c.appspot.com/o/interestImages%2Fleadership.png?alt=media&token=b920ffe6-c91b-4706-972e-2cbbe41f7b99';
  static String lgtbTopic =
      'https://firebasestorage.googleapis.com/v0/b/gaya-5876c.appspot.com/o/interestImages%2Flgbtq.png?alt=media&token=0828f6a9-2bb8-45c2-ab75-4e6afb7e2977';
  static String lifestyleTopic =
      'https://firebasestorage.googleapis.com/v0/b/gaya-5876c.appspot.com/o/interestImages%2Flifestyle.png?alt=media&token=a10d7fe9-3780-42e3-b2f5-0998f8ed20f0';
  static String loveTopic =
      'https://firebasestorage.googleapis.com/v0/b/gaya-5876c.appspot.com/o/interestImages%2Flove.png?alt=media&token=0877accc-eec2-4393-be0f-94625afb6c2b';
  static String marvelNintendoDCTopic =
      'https://firebasestorage.googleapis.com/v0/b/gaya-5876c.appspot.com/o/interestImages%2Fmarvel_nintendo_dc.png?alt=media&token=3191412f-1c33-49ae-b0cd-625f442df491';
  static String metalTopic =
      'https://firebasestorage.googleapis.com/v0/b/gaya-5876c.appspot.com/o/interestImages%2Fmetal.png?alt=media&token=182d7f72-f8dd-4bdb-9982-23f8065c9921';
  static String moneyTopic =
      'https://firebasestorage.googleapis.com/v0/b/gaya-5876c.appspot.com/o/interestImages%2Fmoney.png?alt=media&token=3351325b-ea82-4fbd-861e-9018a0c4d0e4';
  static String motorshipTopic =
      'https://firebasestorage.googleapis.com/v0/b/gaya-5876c.appspot.com/o/interestImages%2Fmotorsport.png?alt=media&token=d5b0485f-b65c-4a11-aa74-f0dddc4cf34d';
  static String moviesTopic =
      'https://firebasestorage.googleapis.com/v0/b/gaya-5876c.appspot.com/o/interestImages%2Fmovies.png?alt=media&token=dcbb5e05-5025-4592-8890-8d865d5e0dc7';
  static String musicTopic =
      'https://firebasestorage.googleapis.com/v0/b/gaya-5876c.appspot.com/o/interestImages%2Fmusic.png?alt=media&token=3ccb9b2a-0f4e-429e-b2ba-bf8aa9618807';
  static String nonesenseTopic =
      'https://firebasestorage.googleapis.com/v0/b/gaya-5876c.appspot.com/o/interestImages%2Fnonsense.png?alt=media&token=fc8d1697-021f-412e-95e2-20777469896c';
  static String partiesTopic =
      'https://firebasestorage.googleapis.com/v0/b/gaya-5876c.appspot.com/o/interestImages%2Fparties.png?alt=media&token=d30c095a-716c-480d-943c-377856120b41';
  static String photographyTopic =
      'https://firebasestorage.googleapis.com/v0/b/gaya-5876c.appspot.com/o/interestImages%2Fphotography.png?alt=media&token=01e8bf3e-c02c-4ab6-bcb6-dec83170a684';
  static String poemsTopic =
      'https://firebasestorage.googleapis.com/v0/b/gaya-5876c.appspot.com/o/interestImages%2Fpoems.png?alt=media&token=0d2d8df4-706d-4726-b987-4bce4946b4d3';
  static String programmingTopic =
      'https://firebasestorage.googleapis.com/v0/b/gaya-5876c.appspot.com/o/interestImages%2Fprogramming.png?alt=media&token=3e85370a-af7c-4cc4-a1b2-ab4f8e02fe3e';
  static String relationshipsTopic =
      'https://firebasestorage.googleapis.com/v0/b/gaya-5876c.appspot.com/o/interestImages%2Frealtionship.png?alt=media&token=ef0a6cf8-fc06-40e2-a0c9-e337fa1952b3';
  static String schoolTopic =
      'https://firebasestorage.googleapis.com/v0/b/gaya-5876c.appspot.com/o/interestImages%2Fschool.png?alt=media&token=77441071-c2e1-44ed-81e1-a9a86ae64472';
  static String scienceTopic =
      'https://firebasestorage.googleapis.com/v0/b/gaya-5876c.appspot.com/o/interestImages%2Fscience.png?alt=media&token=7d92c4b8-95b9-4c08-8ead-945ab8c3f2b4';
  static String selfDevelopmentTopic =
      'https://firebasestorage.googleapis.com/v0/b/gaya-5876c.appspot.com/o/interestImages%2Fself_development.png?alt=media&token=ad0b6cfc-ee6e-4c7f-98e1-3d9314bc6140';
  static String spaceTopic =
      'https://firebasestorage.googleapis.com/v0/b/gaya-5876c.appspot.com/o/interestImages%2Fspace.png?alt=media&token=1535fbeb-bcb8-4061-8386-8e4a08447d94';
  static String sportTopic =
      'https://firebasestorage.googleapis.com/v0/b/gaya-5876c.appspot.com/o/interestImages%2Fsports.png?alt=media&token=ac6bc8b2-fe67-49e6-bc8b-14c01dc569e3';
  static String technologyTopic =
      'https://firebasestorage.googleapis.com/v0/b/gaya-5876c.appspot.com/o/interestImages%2Ftechnology.png?alt=media&token=e1a57b14-0b08-4f33-9c9a-f4bd7f0f93ed';
  static String tennisTopic =
      'https://firebasestorage.googleapis.com/v0/b/gaya-5876c.appspot.com/o/interestImages%2Ftennis.png?alt=media&token=5a896459-66b2-411b-b98b-bae61e86da40';
  static String travelTopic =
      'https://firebasestorage.googleapis.com/v0/b/gaya-5876c.appspot.com/o/interestImages%2Ftravel.png?alt=media&token=8b76b4b0-e1ab-4f42-a8dc-288d235747fb';
  static String tvTopic =
      'https://firebasestorage.googleapis.com/v0/b/gaya-5876c.appspot.com/o/interestImages%2Ftv.png?alt=media&token=4e620db4-aec2-4134-aeee-2504ecd75088';
  static String writingTopic =
      'https://firebasestorage.googleapis.com/v0/b/gaya-5876c.appspot.com/o/interestImages%2Fwriting.png?alt=media&token=a37dfc38-f1e2-4cd6-aaf5-b4df9b379806';
  static String knittingTopic =
      'https://firebasestorage.googleapis.com/v0/b/gaya-5876c.appspot.com/o/interestImages%2Fknitting.png?alt=media&token=bfe4afc1-1ab9-44b4-b46b-3dd0d8f2eae1';
  static String newsTopic =
      'https://firebasestorage.googleapis.com/v0/b/gaya-5876c.appspot.com/o/interestImages%2Fnews.png?alt=media&token=091419bf-6351-43cb-af7d-31a111942bb3';

  // notification icons getters
  static String get annonymous => '${notificationPath}annonymous.svg';

  static String get comment => '${notificationPath}comment.svg';

  static String get community => '${notificationPath}community.svg';

  static String get flower => '${notificationPath}flower.svg';

  static String get friend => '${notificationPath}friend.svg';

  static String get like => '${notificationPath}like.svg';

// post like reaction svgs
  static String get love => '${notificationPath}in-love.svg';
  static String get sad => '${notificationPath}sad.svg';
  static String get funny => '${notificationPath}funny.svg';
  static String get angry => '${notificationPath}angry.svg';
  static String get surprised => '${notificationPath}surprized.svg';

  static String get getCrown => '${appIconsPath}got_crown_icon.svg';

  // filled icons getters
  static String get annotationFilled => '${filledPath}annotation-dots_fill.svg';

  static String get bellFilled => '${filledPath}bell_fill.svg';

  static String get bookmarkFilled => '${filledPath}bookmark_fill.svg';

  static String get calendarDateFilled => '${filledPath}calendar-date_fill.svg';

  static String get cameraFilled => '${filledPath}camera_fill.svg';

  static String get checkVerifiedFilled => '${filledPath}check-verified_fill.svg';

  static String get clockFilled => '${filledPath}clock_fill.svg';

  static String get crownFilledd => '${filledPath}crown_fill.svg';

  static String get editFilled => '${filledPath}edit_fill.svg';

  static String get eyeOffFilled => '${filledPath}eye-off_fill.svg';

  static String get eyeFilled => '${filledPath}eye_fill.svg';

  static String get faceSmileFilled => '${filledPath}face-smile_fill.svg';

  static String get fileFilled => '${filledPath}file_fill.svg';

  static String get heartFilled => '${filledPath}heart_fill.svg';

  static String get homeLineFilled => '${filledPath}home-line_fill.svg';

  static String get infoCircleFilled => '${filledPath}info-circle_fill.svg';

  static String get lockUnlockedFilled => '${filledPath}lock-unlocked_fill.svg';

  static String get lockFilled => '${filledPath}lock_fill.svg';

  static String get logoutFilled => '${filledPath}log-out_fill.svg';

  static String get messageTextSquare1Filled => '${filledPath}message-text-square-1_fill.svg';

  static String get messageTextSquareFilled => '${filledPath}message-text-square_fill.svg';

  static String get microphoneFilled => '${filledPath}microphone_fill.svg';

  static String get minusCircleFilled => '${filledPath}minus-circle_fill.svg';

  static String get musicNoteFilled => '${filledPath}music-note_fill.svg';

  static String get paletteFilled => '${filledPath}palette_fill.svg';

  static String get pinFilled => '${filledPath}pin_fill.svg';

  static String get playFilled => '${filledPath}play_fill.svg';

  static String get plusCircleFilled => '${filledPath}plus-circle_fill.svg';

  static String get send1Filled => '${filledPath}send-01_fill.svg';

  static String get settingsFilled => '${filledPath}settings_fill.svg';

  static String get shareFilled => '${filledPath}share_fill.svg';

  static String get trashFilled => '${filledPath}trash_fill.svg';

  static String get userCheckFilled => '${filledPath}user-check_fill.svg';

  static String get userCircleFilled => '${filledPath}user-circle_fill.svg';

  static String get userMinusFilled => '${filledPath}user-minus_fill.svg';

  static String get userPlusFilled => '${filledPath}user-plus_fill.svg';

  static String get userRightFilled => '${filledPath}user-right_fill.svg';

  static String get userFilled => '${filledPath}user_fill.svg';

  static String get usersCheckFilled => '${filledPath}users-check_fill.svg';

  static String get usersMinusFilled => '${filledPath}users-minus_fill.svg';

  static String get usersFilled => '${filledPath}users_fill.svg';

  // end of filled icons getters

  // outlined icons getters
  static String get bellOutline => '${outlinePath}bell_outline.svg';

  static String get bookmarkOutline => '${outlinePath}bookmark_outline.svg';

  static String get calendarDateOutline => '${outlinePath}calendar-date_outline.svg';

  static String get cameraOutline => '${outlinePath}camera_outline.svg';

  static String get checkVerifiedOutline => '${outlinePath}check-verified_outline.svg';

  static String get checkOutline => '${outlinePath}check_outline.svg';

  static String get chevronDownOutline => '${outlinePath}chevron-down_outline.svg';

  static String get chevronLeftOutline => '${outlinePath}chevron-left_outline.svg';

  static String get clockOutline => '${outlinePath}clock_outline.svg';

  static String get commentOutline => '${outlinePath}comment_outline.svg';

  static String get cropOutline => '${outlinePath}crop_outline.svg';

  static String get crownOutline => '${outlinePath}crown_outline.svg';

  static String get dotsHorizontalOutline => '${outlinePath}dots-horizontal_outline.svg';

  static String get editOutline => '${outlinePath}edit_outline.svg';

  static String get eyeOffOutline => '${outlinePath}eye-off_outline.svg';

  static String get eyeOutline => '${outlinePath}eye_outline.svg';

  static String get faceSmileOutline => '${outlinePath}face-smile_outline.svg';

  static String get fileOutline => '${outlinePath}file_outline.svg';

  static String get heartOutline => '${outlinePath}heart_outline.svg';

  static String get greyHeartOutline => '${outlinePath}grey_heart_outline.svg';

  static String get homeLineOutline => '${outlinePath}home-line_outline.svg';

  static String get imageOutline => '${outlinePath}image_outline.svg';

  static String get infoCircleOutline => '${outlinePath}info-circle_outline.svg';

  static String get linkOutline => '${outlinePath}link_outline.svg';

  static String get loadingOutline => '${outlinePath}loading_outline.svg';

  static String get lockUnlockedOutline => '${outlinePath}lock-unlocked_outline.svg';

  static String get lockOutline => '${outlinePath}lock_outline.svg';

  static String get logoutOutline => '${outlinePath}log-out_outline.svg';

  static String get menuOutline => '${outlinePath}menu_outline.svg';

  static String get messageTextSquareOutline => '${outlinePath}message-text-square_outline.svg';

  static String get messagesOutline => '${outlinePath}messages_outline.svg';

  static String get microphoneOutline => '${outlinePath}microphone_outline.svg';

  static String get minusCircleOutline => '${outlinePath}minus-circle_outline.svg';

  static String get musicNoteOutline => '${outlinePath}music-note_outline.svg';

  static String get paletteOutline => '${outlinePath}palette_outline.svg';

  static String get pinOutlinee => '${outlinePath}pin_outline.svg';

  static String get playCircleOutline => '${outlinePath}play-circle_outline.svg';

  static String get playOutline => '${outlinePath}play_outline.svg';

  static String get plusCircleOutline => '${outlinePath}plus-circle_outline.svg';

  static String get plusOutline => '${outlinePath}plus_outline.svg';

  static String get searchLgOutline => '${outlinePath}search-lg_outline.svg';
  static String get notification => '${navbarPath}selected_notification.svg';

  static String get sendOutline => '${outlinePath}send_outline.svg';

  static String get settingsOutline => '${outlinePath}settings_outline.svg';

  static String get shareOutline => '${outlinePath}share_outline.svg';

  static String get trash1Outline => '${outlinePath}trash-1_outline.svg';

  static String get trashOutline => '${outlinePath}trash_outline.svg';

  static String get userCheckOutline => '${outlinePath}user-check_outline.svg';
  static String get communityOutline => '${outlinePath}community_outline.svg';
  static String get interestOutline => '${outlinePath}interest_outline.svg';
  static String get friendOutline => '${outlinePath}friend_outline.svg';
  static String get sendMessageOutline => '${outlinePath}send_message_outline.svg';
  static String get shuffleOutline => '${outlinePath}shuffle.svg';

  static String get userCircleOutline => '${outlinePath}user-circle_outline.svg';

  static String get userMinusOutline => '${outlinePath}user-minus_outline.svg';

  static String get userPlusOutline => '${outlinePath}user-plus_outline.svg';

  static String get userRightOutline => '${outlinePath}user-right_outline.svg';

  static String get userShieldTickOutline => '${outlinePath}user-shield-tick_outline.svg';

  static String get userOutline => '${outlinePath}user_outline.svg';

  static String get usersCheckOutline => '${outlinePath}users-check_outline.svg';

  static String get usersMinusOutline => '${outlinePath}users-minus_outline.svg';

  static String get usersPlusOutline => '${outlinePath}users-plus_outline.svg';

  static String get usersRightOutline => '${outlinePath}users-right_outline.svg';

  static String get usersOutline => '${outlinePath}users_outline.svg';

  static String get xCloseOutline => '${outlinePath}x-close_outline.svg';
  static String get calendarOutline => '${outlinePath}calendar_outline.svg';
  static String get whiteInstaLogo => '${appIconsPath}white_insta_logo.svg';
  // done by ubaid for signup module UI changes
  static String get maleImg => '${assetImages}maleImg.png';
  static String get femaleImg => '${assetImages}femaleImg.png';
  static String get nonBinaryImg => '${assetImages}nonBinaryImg.png';

  /* ------------------------------ SEARCH MODULE ----------------------------- */
  static String get addFriend => '${appIconsPath}add_friend.svg';
  static String get friendAdded => '${appIconsPath}friend_added.svg';
  static String get requestSent => '${appIconsPath}request_sent.svg';
  static String get unFriendRequest => '${appIconsPath}Union_del.svg';
  static String get lock => '${appIconsPath}lock.svg';
  static String get unLock => '${appIconsPath}unlock.svg';
  static String get delete => '${appIconsPath}delete.svg';

  /* ------------------------ EMPTY COMMUNITY / NO POST ----------------------- */
  static String get inviteFriend => '${appIconsPath}Union.svg';
  static String get rightArrow => '${appIconsPath}right_arrow.svg';
}

class SvgIconWidget {
  // new splash screen
  static Widget findEmojiIcon({double? height, double? width, Color? color}) =>
      GayaSvgAsset(IconsAssetsPathUtils.findEmoji, height: height, width: width, color: color);
  static Widget newWelcomeCircle({double? height, double? width, Color? color}) =>
      GayaSvgAsset(IconsAssetsPathUtils.welcomeCircleSvg, height: height, width: width, color: color);

  //
  static Widget leftArrowIcon({required bool isLight}) =>
      SvgPicture.asset('${IconsAssetsPathUtils.appIconsPath}left_arrow.svg', color: isLight ? AppColors.white : AppColors.black);

  // (notification icons widgets)
  static Widget annonymous({double? height, double? width, Color? color}) =>
      GayaSvgAsset(IconsAssetsPathUtils.annonymous, height: height, width: width, color: color);

  static Widget comment({double? height, double? width, Color? color}) =>
      GayaSvgAsset(IconsAssetsPathUtils.comment, height: height, width: width, color: color);

  static Widget community({double? height, double? width, Color? color}) =>
      GayaSvgAsset(IconsAssetsPathUtils.community, height: height, width: width, color: color);

  static Widget flower({double? height, double? width, Color? color}) =>
      GayaSvgAsset(IconsAssetsPathUtils.flower, height: height, width: width, color: color);

  static Widget friend({double? height, double? width, Color? color}) =>
      GayaSvgAsset(IconsAssetsPathUtils.friend, height: height, width: width, color: color);

  static Widget like({double? height, double? width, Color? color}) =>
      GayaSvgAsset(IconsAssetsPathUtils.like, height: height, width: width, color: color);

  static Widget love({double? height, double? width, Color? color}) =>
      GayaSvgAsset(IconsAssetsPathUtils.love, height: height, width: width, color: color);
  static Widget sad({double? height, double? width, Color? color}) =>
      GayaSvgAsset(IconsAssetsPathUtils.sad, height: height, width: width, color: color);
  static Widget funny({double? height, double? width, Color? color}) =>
      GayaSvgAsset(IconsAssetsPathUtils.funny, height: height, width: width, color: color);
  static Widget angry({double? height, double? width, Color? color}) =>
      GayaSvgAsset(IconsAssetsPathUtils.angry, height: height, width: width, color: color);
  static Widget surprised({double? height, double? width, Color? color}) =>
      GayaSvgAsset(IconsAssetsPathUtils.surprised, height: height, width: width, color: color);

  // (filled icons widgets)
  static Widget annotationFilled({double? height, double? width, Color? color}) =>
      GayaSvgAsset(IconsAssetsPathUtils.annotationFilled, height: height, width: width, color: color);

  static Widget bellFilled({double? height, double? width, Color? color}) =>
      GayaSvgAsset(IconsAssetsPathUtils.bellFilled, height: height, width: width, color: color);

  static Widget bookmarkFilled({double? height, double? width, Color? color}) =>
      GayaSvgAsset(IconsAssetsPathUtils.bookmarkFilled, height: height, width: width, color: color);

  static Widget calendarDateFilled({double? height, double? width, Color? color}) =>
      GayaSvgAsset(IconsAssetsPathUtils.calendarDateFilled, height: height, width: width, color: color);

  static Widget cameraFilled({double? height, double? width, Color? color}) =>
      GayaSvgAsset(IconsAssetsPathUtils.cameraFilled, height: height, width: width, color: color);

  static Widget checkVerifiedFilled({double? height, double? width, Color? color}) =>
      GayaSvgAsset(IconsAssetsPathUtils.checkVerifiedFilled, height: height, width: width, color: color);

  static Widget clockFilled({double? height, double? width, Color? color}) =>
      GayaSvgAsset(IconsAssetsPathUtils.clockFilled, height: height, width: width, color: color);

  static Widget crownFilledd({double? height, double? width, Color? color}) =>
      GayaSvgAsset(IconsAssetsPathUtils.crownFilledd, height: height, width: width, color: color);

  static Widget editFilled({double? height, double? width, Color? color}) =>
      GayaSvgAsset(IconsAssetsPathUtils.editFilled, height: height, width: width, color: color);

  static Widget eyeOffFilled({double? height, double? width, Color? color}) =>
      GayaSvgAsset(IconsAssetsPathUtils.eyeOffFilled, height: height, width: width, color: color);

  static Widget eyeFilled({double? height, double? width, Color? color}) =>
      GayaSvgAsset(IconsAssetsPathUtils.eyeFilled, height: height, width: width, color: color);

  static Widget faceSmileFilled({double? height, double? width, Color? color}) =>
      GayaSvgAsset(IconsAssetsPathUtils.faceSmileFilled, height: height, width: width, color: color);

  static Widget fileFilled({double? height, double? width, Color? color}) =>
      GayaSvgAsset(IconsAssetsPathUtils.fileFilled, height: height, width: width, color: color);

  static Widget heartFilled({double? height, double? width, Color? color}) =>
      GayaSvgAsset(IconsAssetsPathUtils.heartFilled, height: height, width: width, color: color);

  static Widget homeLineFilled({double? height, double? width, Color? color}) =>
      GayaSvgAsset(IconsAssetsPathUtils.homeLineFilled, height: height, width: width, color: color);

  static Widget infoCircleFilled({double? height, double? width, Color? color}) =>
      GayaSvgAsset(IconsAssetsPathUtils.infoCircleFilled, height: height, width: width, color: color);

  static Widget lockUnlockedFilled({double? height, double? width, Color? color}) =>
      GayaSvgAsset(IconsAssetsPathUtils.lockUnlockedFilled, height: height, width: width, color: color);

  static Widget lockFilled({double? height, double? width, Color? color}) =>
      GayaSvgAsset(IconsAssetsPathUtils.lockFilled, height: height, width: width, color: color);

  static Widget logoutFilled({double? height, double? width, Color? color}) =>
      GayaSvgAsset(IconsAssetsPathUtils.logoutFilled, height: height, width: width, color: color);

  static Widget messageTextSquare1Filled({double? height, double? width, Color? color}) =>
      GayaSvgAsset(IconsAssetsPathUtils.messageTextSquare1Filled, height: height, width: width, color: color);

  static Widget messageTextSquareFilled({double? height, double? width, Color? color}) =>
      GayaSvgAsset(IconsAssetsPathUtils.messageTextSquareFilled, height: height, width: width, color: color);

  static Widget microphoneFilled({double? height, double? width, Color? color}) =>
      GayaSvgAsset(IconsAssetsPathUtils.microphoneFilled, height: height, width: width, color: color);

  static Widget minusCircleFilled({double? height, double? width, Color? color}) =>
      GayaSvgAsset(IconsAssetsPathUtils.minusCircleFilled, height: height, width: width, color: color);

  static Widget musicNoteFilled({double? height, double? width, Color? color}) =>
      GayaSvgAsset(IconsAssetsPathUtils.musicNoteFilled, height: height, width: width, color: color);

  static Widget paletteFilled({double? height, double? width, Color? color}) =>
      GayaSvgAsset(IconsAssetsPathUtils.paletteFilled, height: height, width: width, color: color);

  static Widget pinFilled({double? height, double? width, Color? color}) =>
      GayaSvgAsset(IconsAssetsPathUtils.pinFilled, height: height, width: width, color: color);

  static Widget playFilled({double? height, double? width, Color? color}) =>
      GayaSvgAsset(IconsAssetsPathUtils.playFilled, height: height, width: width, color: color);

  static Widget plusCircleFilled({double? height, double? width, Color? color}) =>
      GayaSvgAsset(IconsAssetsPathUtils.plusCircleFilled, height: height, width: width, color: color);

  static Widget send1Filled({double? height, double? width, Color? color}) =>
      GayaSvgAsset(IconsAssetsPathUtils.send1Filled, height: height, width: width, color: color);

  static Widget settingsFilled({double? height, double? width, Color? color}) =>
      GayaSvgAsset(IconsAssetsPathUtils.settingsFilled, height: height, width: width, color: color);

  static Widget shareFilled({double? height, double? width, Color? color}) =>
      GayaSvgAsset(IconsAssetsPathUtils.shareFilled, height: height, width: width, color: color);

  static Widget trashFilled({double? height, double? width, Color? color}) =>
      GayaSvgAsset(IconsAssetsPathUtils.trashFilled, height: height, width: width, color: color);

  static Widget userCheckFilled({double? height, double? width, Color? color}) =>
      GayaSvgAsset(IconsAssetsPathUtils.userCheckFilled, height: height, width: width, color: color);

  static Widget userCircleFilled({double? height, double? width, Color? color}) =>
      GayaSvgAsset(IconsAssetsPathUtils.userCircleFilled, height: height, width: width, color: color);

  static Widget userMinusFilled({double? height, double? width, Color? color}) =>
      GayaSvgAsset(IconsAssetsPathUtils.userMinusFilled, height: height, width: width, color: color);

  static Widget userPlusFilled({double? height, double? width, Color? color}) =>
      GayaSvgAsset(IconsAssetsPathUtils.userPlusFilled, height: height, width: width, color: color);

  static Widget userRightFilled({double? height, double? width, Color? color}) =>
      GayaSvgAsset(IconsAssetsPathUtils.userRightFilled, height: height, width: width, color: color);

  static Widget userFilled({double? height, double? width, Color? color}) =>
      GayaSvgAsset(IconsAssetsPathUtils.userFilled, height: height, width: width, color: color);

  static Widget usersCheckFilled({double? height, double? width, Color? color}) =>
      GayaSvgAsset(IconsAssetsPathUtils.usersCheckFilled, height: height, width: width, color: color);

  static Widget usersMinusFilled({double? height, double? width, Color? color}) =>
      GayaSvgAsset(IconsAssetsPathUtils.usersMinusFilled, height: height, width: width, color: color);

  static Widget usersFilled({double? height, double? width, Color? color}) =>
      GayaSvgAsset(IconsAssetsPathUtils.usersFilled, height: height, width: width, color: color);

  //  outline icons widgets
  static Widget bellOutline1({double? height, double? width, Color? color}) =>
      GayaSvgAsset(IconsAssetsPathUtils.bellOutline, height: height, width: width, color: color);

  static Widget bookmarkOutline({double? height, double? width, Color? color}) =>
      GayaSvgAsset(IconsAssetsPathUtils.bookmarkOutline, height: height, width: width, color: color);

  static Widget calendarDateOutline({double? height, double? width, Color? color}) =>
      GayaSvgAsset(IconsAssetsPathUtils.calendarDateOutline, height: height, width: width, color: color);

  static Widget cameraOutline({double? height, double? width, Color? color}) =>
      GayaSvgAsset(IconsAssetsPathUtils.cameraOutline, height: height, width: width, color: color);

  static Widget checkVerifiedOutline({double? height, double? width, Color? color}) =>
      GayaSvgAsset(IconsAssetsPathUtils.checkVerifiedOutline, height: height, width: width, color: color);

  static Widget checkOutline({double? height, double? width, Color? color}) =>
      GayaSvgAsset(IconsAssetsPathUtils.checkOutline, height: height, width: width, color: color);

  static Widget commentOutline({double? height, double? width, Color? color}) =>
      GayaSvgAsset(IconsAssetsPathUtils.commentOutline, height: height, width: width, color: color);

  static Widget cropOutline({double? height, double? width, Color? color}) =>
      GayaSvgAsset(IconsAssetsPathUtils.cropOutline, height: height, width: width, color: color);

  static Widget crownOutline({double? height, double? width, Color? color}) =>
      GayaSvgAsset(IconsAssetsPathUtils.crownOutline, height: height, width: width, color: color);

  static Widget dotsHorizontalOutline({double? height, double? width, Color? color}) =>
      GayaSvgAsset(IconsAssetsPathUtils.dotsHorizontalOutline, height: height, width: width, color: color);

  static Widget editOutline({double? height, double? width, Color? color}) =>
      GayaSvgAsset(IconsAssetsPathUtils.editOutline, height: height, width: width, color: color);

  static Widget eyeOffOutline({double? height, double? width, Color? color}) =>
      GayaSvgAsset(IconsAssetsPathUtils.eyeOffOutline, height: height, width: width, color: color);

  static Widget faceSmileOutline({double? height, double? width, Color? color}) =>
      GayaSvgAsset(IconsAssetsPathUtils.faceSmileOutline, height: height, width: width, color: color);

  static Widget fileOutline({double? height, double? width, Color? color}) =>
      GayaSvgAsset(IconsAssetsPathUtils.fileOutline, height: height, width: width, color: color);

  static Widget heartOutline({double? height, double? width, Color? color}) =>
      GayaSvgAsset(IconsAssetsPathUtils.heartOutline, height: height, width: width, color: color);

  static Widget homeLineOutline({double? height, double? width, Color? color}) =>
      GayaSvgAsset(IconsAssetsPathUtils.homeLineOutline, height: height, width: width, color: color);

  static Widget imageOutline({double? height, double? width, Color? color}) =>
      GayaSvgAsset(IconsAssetsPathUtils.imageOutline, height: height, width: width, color: color);

  static Widget infoCircleOutline({double? height, double? width, Color? color}) =>
      GayaSvgAsset(IconsAssetsPathUtils.infoCircleOutline, height: height, width: width, color: color);

  static Widget linkOutline1({double? height, double? width, Color? color}) =>
      GayaSvgAsset(IconsAssetsPathUtils.linkOutline, height: height, width: width, color: color);

  static Widget loadingOutline({double? height, double? width, Color? color}) =>
      GayaSvgAsset(IconsAssetsPathUtils.loadingOutline, height: height, width: width, color: color);

  static Widget clockOutline({double? height, double? width, Color? color}) =>
      GayaSvgAsset(IconsAssetsPathUtils.clockOutline, height: height, width: width, color: color);

  static Widget lockUnlockedOutline({double? height, double? width, Color? color}) =>
      GayaSvgAsset(IconsAssetsPathUtils.lockUnlockedOutline, height: height, width: width, color: color);

  static Widget lockOutline1({double? height, double? width, Color? color}) =>
      GayaSvgAsset(IconsAssetsPathUtils.lockOutline, height: height, width: width, color: color);

  static Widget logoutOutline({double? height, double? width, Color? color}) =>
      GayaSvgAsset(IconsAssetsPathUtils.logoutOutline, height: height, width: width, color: color);

  static Widget menuOutline({double? height, double? width, Color? color}) =>
      GayaSvgAsset(IconsAssetsPathUtils.menuOutline, height: height, width: width, color: color);

  static Widget messageTextSquareOutline({double? height, double? width, Color? color}) =>
      GayaSvgAsset(IconsAssetsPathUtils.messageTextSquareOutline, height: height, width: width, color: color);

  static Widget messagesOutline({double? height, double? width, Color? color}) =>
      GayaSvgAsset(IconsAssetsPathUtils.messagesOutline, height: height, width: width, color: color);

  static Widget microphoneOutline({double? height, double? width, Color? color}) =>
      GayaSvgAsset(IconsAssetsPathUtils.microphoneOutline, height: height, width: width, color: color);

  static Widget minusCircleOutline({double? height, double? width, Color? color}) =>
      GayaSvgAsset(IconsAssetsPathUtils.minusCircleOutline, height: height, width: width, color: color);

  static Widget musicNoteOutline({double? height, double? width, Color? color}) =>
      GayaSvgAsset(IconsAssetsPathUtils.musicNoteOutline, height: height, width: width, color: color);

  static Widget paletteOutline({double? height, double? width, Color? color}) =>
      GayaSvgAsset(IconsAssetsPathUtils.paletteOutline, height: height, width: width, color: color);

  static Widget pinOutlinee({double? height, double? width, Color? color}) =>
      GayaSvgAsset(IconsAssetsPathUtils.pinOutlinee, height: height, width: width, color: color);

  static Widget playCircleOutline({double? height, double? width, Color? color}) =>
      GayaSvgAsset(IconsAssetsPathUtils.playCircleOutline, height: height, width: width, color: color);

  static Widget playOutline({double? height, double? width, Color? color}) =>
      GayaSvgAsset(IconsAssetsPathUtils.playOutline, height: height, width: width, color: color);

  static Widget plusCircleOutline({double? height, double? width, Color? color}) =>
      GayaSvgAsset(IconsAssetsPathUtils.plusCircleOutline, height: height, width: width, color: color);

  static Widget plusOutline({double? height, double? width, Color? color}) =>
      GayaSvgAsset(IconsAssetsPathUtils.plusOutline, height: height, width: width, color: color);

  static Widget searchLgOutline({double? height, double? width, Color? color}) =>
      GayaSvgAsset(IconsAssetsPathUtils.searchLgOutline, height: height, width: width, color: color);
  static Widget selectedNotification({double? height, double? width, Color? color}) =>
      GayaSvgAsset(IconsAssetsPathUtils.notification, height: height, width: width, color: color);

  static Widget sendOutline({double? height, double? width, Color? color}) =>
      GayaSvgAsset(IconsAssetsPathUtils.sendOutline, height: height, width: width, color: color);

  static Widget settingsOutline({double? height, double? width, Color? color}) =>
      GayaSvgAsset(IconsAssetsPathUtils.settingsOutline, height: height, width: width, color: color);

  static Widget shareOutline({double? height, double? width, Color? color}) =>
      GayaSvgAsset(IconsAssetsPathUtils.shareOutline, height: height, width: width, color: color);

  static Widget trash1Outline({double? height, double? width, Color? color}) =>
      GayaSvgAsset(IconsAssetsPathUtils.trash1Outline, height: height, width: width, color: color);

  static Widget trashOutline({double? height, double? width, Color? color}) =>
      GayaSvgAsset(IconsAssetsPathUtils.trashOutline, height: height, width: width, color: color);

  static Widget userCheckOutline({double? height, double? width, Color? color}) =>
      GayaSvgAsset(IconsAssetsPathUtils.userCheckOutline, height: height, width: width, color: color);

  static Widget userCircleOutline({double? height, double? width, Color? color}) =>
      GayaSvgAsset(IconsAssetsPathUtils.userCircleOutline, height: height, width: width, color: color);

  static Widget userMinusOutline({double? height, double? width, Color? color}) =>
      GayaSvgAsset(IconsAssetsPathUtils.userMinusOutline, height: height, width: width, color: color);

  static Widget userPlusOutline({double? height, double? width, Color? color}) =>
      GayaSvgAsset(IconsAssetsPathUtils.userPlusOutline, height: height, width: width, color: color);

  static Widget userRightOutline({double? height, double? width, Color? color}) =>
      GayaSvgAsset(IconsAssetsPathUtils.userRightOutline, height: height, width: width, color: color);

  static Widget userShieldTickOutline({double? height, double? width, Color? color}) =>
      GayaSvgAsset(IconsAssetsPathUtils.userShieldTickOutline, height: height, width: width, color: color);

  static Widget userOutline({double? height, double? width, Color? color}) =>
      GayaSvgAsset(IconsAssetsPathUtils.userOutline, height: height, width: width, color: color);

  static Widget usersCheckOutline({double? height, double? width, Color? color}) =>
      GayaSvgAsset(IconsAssetsPathUtils.usersCheckOutline, height: height, width: width, color: color);

  static Widget usersMinusOutline({double? height, double? width, Color? color}) =>
      GayaSvgAsset(IconsAssetsPathUtils.usersMinusOutline, height: height, width: width, color: color);

  static Widget usersPlusOutline({double? height, double? width, Color? color}) =>
      GayaSvgAsset(IconsAssetsPathUtils.usersPlusOutline, height: height, width: width, color: color);

  static Widget usersRightOutline({double? height, double? width, Color? color}) =>
      GayaSvgAsset(IconsAssetsPathUtils.usersRightOutline, height: height, width: width, color: color);

  static Widget usersOutline({double? height, double? width, Color? color}) =>
      GayaSvgAsset(IconsAssetsPathUtils.usersOutline, height: height, width: width, color: color);

  static Widget xCloseOutline({double? height, double? width, Color? color}) =>
      GayaSvgAsset(IconsAssetsPathUtils.xCloseOutline, height: height, width: width, color: color);
  static Widget calendarOutline({double? height, double? width, Color? color}) =>
      GayaSvgAsset(IconsAssetsPathUtils.calendarOutline, height: height, width: width, color: color);
  static Widget communityOutline({double? height, double? width, Color? color}) =>
      GayaSvgAsset(IconsAssetsPathUtils.communityOutline, height: height, width: width, color: color);
  static Widget interestOutline({double? height, double? width, Color? color}) =>
      GayaSvgAsset(IconsAssetsPathUtils.interestOutline, height: height, width: width, color: color);
  static Widget friendOutline({double? height, double? width, Color? color}) =>
      GayaSvgAsset(IconsAssetsPathUtils.friendOutline, height: height, width: width, color: color);
  static Widget sendMessageOutline({double? height, double? width, Color? color}) =>
      GayaSvgAsset(IconsAssetsPathUtils.sendMessageOutline, height: height, width: width, color: color);
  static Widget shuffleOutline({double? height, double? width, Color? color}) =>
      GayaSvgAsset(IconsAssetsPathUtils.shuffleOutline, height: height, width: width, color: color);

  /* ------------------------------ SEARCH MODULE ----------------------------- */
  static Widget get addFriend => GayaSvgAsset(
        IconsAssetsPathUtils.addFriend,
        color: AppColors.white,
      );
  static Widget get friendAdded => GayaSvgAsset(
        IconsAssetsPathUtils.friendAdded,
        color: AppColors.black,
      );
  static Widget get requestSentBlack => GayaSvgAsset(
        IconsAssetsPathUtils.requestSent,
        color: AppColors.black,
      );
  static Widget get requestSentWhite => GayaSvgAsset(
        IconsAssetsPathUtils.requestSent,
        color: AppColors.white,
      );
  static Widget get unFriendRequest => GayaSvgAsset(
        IconsAssetsPathUtils.unFriendRequest,
        color: AppColors.black,
      );
  static Widget get lock => GayaSvgAsset(
        IconsAssetsPathUtils.lock,
        color: AppColors.black,
        width: 16.0,
        height: 16.0,
      );
  static Widget get unLock => GayaSvgAsset(
        IconsAssetsPathUtils.unLock,
        color: AppColors.black,
        width: 16.0,
        height: 16.0,
      );
  static Widget get delete => GayaSvgAsset(
        IconsAssetsPathUtils.delete,
        color: AppColors.black,
        width: 16.0,
        height: 16.0,
      );
  /* ------------------------------ INFLUENCE BAR MODULE ----------------------------- */
  static Widget closeRedSvg({double? height, double? width, Color? color}) =>
      GayaSvgAsset('Assets/icons/close_red.svg', height: 41.r, width: 41.r, color: Colors.blue);

  static Widget get closeRed => GayaSvgAsset(
        IconsAssetsPathUtils.closeRed,
        height: 41.r,
        width: 41.r,
      );
  static Widget get emojiYellow => GayaSvgAsset(
        IconsAssetsPathUtils.emojiYellow,
        height: 41.r,
        width: 41.r,
      );
  static Widget get emojiBlue => GayaSvgAsset(
        IconsAssetsPathUtils.emojiBlue,
        height: 41.r,
        width: 41.r,
      );
  static Widget get tickGreen => GayaSvgAsset(
        IconsAssetsPathUtils.tickGreen,
        height: 41.r,
        width: 41.r,
      );
  static Widget get tickBlue => GayaSvgAsset(
        IconsAssetsPathUtils.tickBlue,
        height: 41.r,
        width: 41.r,
      );
  static Widget get heartPrimary => GayaSvgAsset(
        IconsAssetsPathUtils.heartPrimary,
        height: 41.r,
        width: 41.r,
      );

  static Widget get fireYellow => GayaSvgAsset(
        IconsAssetsPathUtils.fireYellow,
        height: 41.r,
        width: 41.r,
      );
  static Widget get fireRed => GayaSvgAsset(
        IconsAssetsPathUtils.fireRed,
        height: 41.r,
        width: 41.r,
      );
  static Widget get firePrimary => GayaSvgAsset(
        IconsAssetsPathUtils.firePrimary,
        height: 41.r,
        width: 41.r,
      );
  static Widget get fireGreen => GayaSvgAsset(
        IconsAssetsPathUtils.fireGreen,
        height: 41.r,
        width: 41.r,
      );
}

class GayaSvgAsset extends StatelessWidget {
  final String assetPath;
  final double? height;
  final double? width;
  final Color? color;

  const GayaSvgAsset(
    this.assetPath, {
    Key? key,
    this.height = 16,
    this.width = 16,
    this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(assetPath,
        height: height, width: width, colorFilter: color != null ? ColorFilter.mode(color!, BlendMode.srcIn) : null);
  }
}
