import 'package:get/get.dart';
import 'package:helpers/helpers.dart';

import 'language/translation.dart';

const noInternet = "No internet connection";
const sureInternet = "Make sure your wifi connection or mobile data is turned on, then try again";

// Notifications

// posts
const flowerGivenNotification = "Your got a new flower!";
const postIsLikedNotification = "Your post was liked! Check it out";
const youMentionedNotification = "You are mentioned in comment! Check it out";

const postIsCommentedNotification = "Your post has new comments!";
const postIsApproved = "Your post was approved, check it out!";
const entryApplicationApproved = "Welcome to Vegetarians Vibes. The community manager has approved your entry request.";
const postIsRejected = "Your post in Vegetarians Vibes was rejected, you can always reach out to the community manager for questions.";
const entryApplicationRejected =
    "Your entry request to Vegetarians Vibes was rejected. Private communities membership is permitted by Community managers.";
const postIsRejected2 = " was rejected, you can always reach out to the community manager for questions.";
const entryApplicationApproved2 = "The community manager has approved your entry request.";
const entryApplicationRejected2 = "was rejected. Private communities membership is permitted by Community managers.";

// community managers
const newCommunityApplications = "New members applied to your community, Confirm or Reject the applications";
const newPostsApplications = "New Posts are waiting for your approval in your community";
const reportedPost = "A post in your community has been reported. Consider deleting it";

//errors
const somethingWrong = "Oops! Something went wrong.";

// user type
String anonymousUser = GayaStrings.anonymous_user.tr;
String anonymousBoy = GayaStrings.anonymous_boy.tr;
String anonymousGirl = GayaStrings.anonymous_girl.tr;
// Stores link
const playstoreLink = "https://play.google.com/store/apps/details?id=com.gaya.android";
const appStoreLink = "https://apps.apple.com/zw/app/gaya-communities/id1662332476";

class Gaya_Strings {
  /// invalid age popup
  static const String invalidAge = "Sorry, looks like you are not eligible for Gaya... but thanks for checking us out!";
  static const String pin_post = "Pin Post";
  static const String unpin_post = "Unpin Post";
  static const String pin_post_to_top = "Pin the post to the top of the page or the topic.";
  static const String remove_pin_post_to_top = "Remove the post from the top of the page or the topic";

  static const String save_post = "Save Post";
  static const String unsave_post = "Unsave Post";
  static const String add_this_to_save_post = "Add this to your saved posts.";
  static const String remove_this_from_saved_posts = "Remove this from your saved posts.";

  static const String copy_link = "Copy Link";
  // alert box strings here
  static const String we_need_access = "We need access";
  static const String access_desc = "Allow the permission to access photos, media and files on your devices.";
  // button texts
  static const String enable_permission = "Enable permission";
  static const String cancel = "Cancel";

  //community view
  static const String about = "About";
  static const String community_notification = "Community notification";
  static const String community_settings = "Community settings";
  static const String access_lock = "Access lock";
  static const String require_touch_id = "Require Touch ID or Passcode";
  static const String when_enabled_you_will_need_to_use_touchid = "When enabled, you’ll need to use Touch ID to view this community.";
  static const String report = "Report";

  static const String community_subscription = "Community subscription";
  static const String new_community_posts = "New community posts";
  static const String recieve_alerts_for_any_new_updates_community = "Receive alerts for any new updates in the community";

  static const String dm_setting = "Privacy Settings";
  static const String change_dm_status = "Allow direct messages";
  static const String allow_others_to_send_to_send_dm = "Allow people to send you personal messages.";

  static const String approval_settings = "Approval Settings";
  static const String post_approvals = "Post Approval";
  static const String post_approval_description = "Posts must be approved in the community.";
  static const String post_approval_des_while_create_community =
      "Posts in the community must be approved by a community manager or moderator. (Recommended)";

  // community pop
  static const String pin_community = "Pin community";
  static const String unpin_community = "Unpin community";
  static const String pin_community_to_top = "Pin the community to the top of the page or the topic.";
  static const String report_community = "Report community";
  static const String im_concerned_about_this_community = "I’m concerned about this community.";
  static const String turn_on_notification_community = "Turn on notifications for this community";
  static const String turn_off_notification_community = "Turn off notifications for this community";
  static const String subscribe_this_community = "Subscribe this community.";
  static const String leave_vegetarians_vibes = "Leave Vegetarians Vibes";
  static const String you_can_request_to_join_again_later = "You can request to join again later.";
  static const String hide_this_community = "Hide this community";
  static const String unhide_this_community = "Unhide this community";
  static const String community_has_been_hidden = "Community has been hidden";
  static const String community_has_been_unhide = "Successfully unhidden the community";
  static const String i_dont_want_to_see_this_community = "I dont want to see this community.";
  static const String i_want_to_see_this_community = "I want to see this community.";
  static const String leave_community = "Leave community";
  static String leave_communityByName({required String communityName}) => "${communityName.toCapitalize()} left successfully";

  //notification
  static const String notification = "Notification";
  static const String new_posts = "New posts";
  static const String new_posts_desc = "Receive alerts for any new posts in the community";
  static const String Mark_all_as_read = "Mark all as read";
  static const String no_notifications = "No notifications";
  static const String no_notifications_desc = "You have no notifications yet";

  /// check for update
}
