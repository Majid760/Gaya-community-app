import 'package:gaya/utils/language/translation.dart';
import 'package:gaya/view/ai_daily_user_matches/model/goal_Interest_model.dart';
import 'package:gaya/view/ai_daily_user_matches/utils/ai_assets_path.dart';
import 'package:gaya/view/ai_daily_user_matches/utils/strings.dart';

class GoalInterestUtil{
  List<GoalInterestModel> goals = [
    GoalInterestModel(title:GayaStrings.friends, image:AiAssetsPath.friendSvg,),
    GoalInterestModel(title:GayaStrings.relationship, image:AiAssetsPath.inLoveSvg),
    GoalInterestModel(title:GayaStrings.just_talk,image: AiAssetsPath.justTalkSvg),
  ];
  List<GoalInterestModel> genders=[
    GoalInterestModel(title:GayaStrings.everyone,image: AiAssetsPath.boySvg,image2:AiAssetsPath.girlSvg,),
    GoalInterestModel(title:GayaStrings.only_boys, image:AiAssetsPath.boySvg),
    GoalInterestModel(title:GayaStrings.only_girls, image:AiAssetsPath.girlSvg),
  ];
}