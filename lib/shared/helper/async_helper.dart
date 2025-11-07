

//this class is used to manage the async calls (e.g cancelling the async call(used In mentioned users using algolia search))
class CancelableFuture<T> {
  Function(Object) onErrorCallback;
  Function(T) onSuccessCallback;
  bool _wasCancelled = false;

  CancelableFuture(Future<T> future,
      {required this.onSuccessCallback,required this.onErrorCallback}) {
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