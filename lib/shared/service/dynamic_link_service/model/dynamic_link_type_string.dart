/// This class will be implemented by all of the model that have
/// a dynamic link feature and will be used to get the type of the
/// dynamic link.
///
/// [DynamicLinkType] is an enum that contains all the types of
/// dynamic links.
abstract class DynamicLinkTypeString {
  /// This method will return the type of the dynamic link [DynamicLinkType].
  String get type;
  String get queryParams;
}
