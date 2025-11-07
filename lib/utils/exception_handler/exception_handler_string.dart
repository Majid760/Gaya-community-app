import 'package:gaya/utils/language/translation.dart';
import 'package:gaya/utils/logger.dart';
import 'package:get/get.dart';

class ExceptionHandler {
  // done by mak
  // get error message of firebase exception
  static String getMsgFirebaseException(dynamic errorCode) {
    switch (errorCode) {
      case "ABORTED":
      case "operation aborted due to concurrency issue!":
      case "ALREADY_EXISTS":
        return GayaStrings.document_already_exist.tr;
      case "CANCELLED":
        return GayaStrings.operation_cancelled_by_caller.tr;
      case "DATA_LOSS":
        return GayaStrings.unrecoverable_data_loss_or_corruption.tr;
      case "DEADLINE_EXCEEDED":
        return GayaStrings.deadline_expired_before_operation_could_complete.tr;
      case "FAILED_PRECONDITION":
        return GayaStrings.operation_was_rejected.tr;
      case "INTERNAL":
        return GayaStrings.internal_errors.tr;
      case "INVALID_ARGUMENT":
        return GayaStrings.invalid_field_name.tr;
      case "NOT_FOUND":
        return GayaStrings.some_requested_document_was_not_found.tr;
      case "OUT_OF_RANGE":
        return GayaStrings.Operation_was_attempted_past_the_valid_range.tr;
      case "PERMISSION_DENIED":
        return GayaStrings.the_caller_does_not_have_permission.tr;
      case "RESOURCE_EXHAUSTED":
        return GayaStrings.some_resource_has_been_exhausted.tr;
      case "UNAUTHENTICATED":
        return GayaStrings.un_authenticated.tr;
      case "UNAVAILABLE":
        return GayaStrings.un_available.tr;
      case "UNIMPLEMENTED":
        return GayaStrings.un_implemented.tr;
      case "UNKNOWN":
        return GayaStrings.unknown.tr;
      default:
        return GayaStrings.something_went_wrong_try_again.tr;
    }
  }

  // get error message of firebase auth exception
  static String getMsgAuthException(dynamic errorCode) {
    MyLoggerServices.to.print("error code: $errorCode");
    switch (errorCode) {
      case "ERROR_EMAIL_ALREADY_IN_USE":
      case "account-exists-with-different-credential":
      case "email-already-in-use":
        return GayaStrings.email_already_exist.tr;
      case "too-many-requests":
        return GayaStrings.too_many_requests.tr;
      case "ERROR_WRONG_PASSWORD":
      case "wrong-password":
        return GayaStrings.wrong_email_password_combination.tr;
      case "ERROR_USER_NOT_FOUND":
      case "user-not-found":
        return GayaStrings.no_user_found_with_this_email.tr;
      case "ERROR_USER_DISABLED":
      case "user-disabled":
        return GayaStrings.user_has_been_disabled.tr;
      case "provider-already-linked":
        return GayaStrings.provider_already_linked.tr;
      case "ERROR_TOO_MANY_REQUESTS":
      case "operation-not-allowed":
        return GayaStrings.too_many_request.tr;
      case "ERROR_OPERATION_NOT_ALLOWED":
      // case "operation-not-allowed":
      //   return "Server error, please try again later.";
      case "ERROR_INVALID_EMAIL":
      case "invalid-email":
        return GayaStrings.invalid_email.tr;
      case "canceled":
        return "";
      default:
        return GayaStrings.something_went_wrong_try_again.tr;
    }
  }
}
