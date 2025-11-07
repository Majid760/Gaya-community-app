class CommonUtils {
  // returns dynamic field.
 static  getFirebaseField({required String fieldName, Object? data}) {
    if (data == null) return null;
    try {
      final Map<String, dynamic>? newData = data as Map<String, dynamic>?;
      if (newData != null && newData.containsKey('isPinned')) {
        final field = newData['isPinned'];
        return field;
      }
    } catch (_) {}
    return null;
  }

}

