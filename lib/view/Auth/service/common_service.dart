class AuthCommonService {
  static bool isEmail(String email) {
    return RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+").hasMatch(email);
  }
}

class CancelableFuture<T> {
  Function(Object) onErrorCallback;
  Function(T) onSuccessCallback;
  bool _wasCancelled = false;

  CancelableFuture(Future<T> future, {required this.onSuccessCallback, required this.onErrorCallback}) {
    future.then((value) {
      if (!_wasCancelled) {
        onSuccessCallback(value);
      }
    }, onError: (e) {
      if (!_wasCancelled && onErrorCallback != null) {
        onErrorCallback(e);
      }
    });
  }

  cancel() {
    _wasCancelled = true;
  }
}
