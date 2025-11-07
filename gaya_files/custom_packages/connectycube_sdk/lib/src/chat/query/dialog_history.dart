import '../../../connectycube_calls.dart';

class GetDialogHistory extends AutoManagedQuery<bool> {
  String dialogId;

  GetDialogHistory({required this.dialogId});

  @override
  void setMethod(RestRequest request) {
    request.setMethod(RequestMethod.DELETE);
  }

  @override
  setUrl(RestRequest request) {
    request.setUrl(buildQueryUrl([CHAT_ENDPOINT, DIALOG_ENDPOINT, CLEAR_HISTORY, dialogId]));
  }

  @override
  bool processResult(String response) {
    return response.isEmpty;
  }
}

class UnSubscribe extends AutoManagedQuery<bool> {
  String dialogId;

  UnSubscribe({required this.dialogId});

  @override
  void setMethod(RestRequest request) {
    request.setMethod(RequestMethod.DELETE);
  }

  @override
  setUrl(RestRequest request) {
    request.setUrl(buildQueryUrl([CHAT_ENDPOINT, DIALOG_ENDPOINT, SUBSCRIBE, dialogId]));
  }

  @override
  bool processResult(String response) {
    return response.isEmpty;
  }
}
