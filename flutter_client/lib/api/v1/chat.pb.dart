///
//  Generated code. Do not modify.
//  source: chat.proto
///
// ignore_for_file: non_constant_identifier_names,library_prefixes,unused_import

// ignore: UNUSED_SHOWN_NAME
import 'dart:core' show int, bool, double, String, List, Map, override;

import 'package:protobuf/protobuf.dart' as $pb;

class Notification extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = new $pb.BuilderInfo('Notification', package: const $pb.PackageName('v1'))
    ..aOS(1, 'message')
    ..hasRequiredFields = false
  ;

  Notification() : super();
  Notification.fromBuffer(List<int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) : super.fromBuffer(i, r);
  Notification.fromJson(String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) : super.fromJson(i, r);
  Notification clone() => new Notification()..mergeFromMessage(this);
  Notification copyWith(void Function(Notification) updates) => super.copyWith((message) => updates(message as Notification));
  $pb.BuilderInfo get info_ => _i;
  static Notification create() => new Notification();
  static $pb.PbList<Notification> createRepeated() => new $pb.PbList<Notification>();
  static Notification getDefault() => _defaultInstance ??= create()..freeze();
  static Notification _defaultInstance;
  static void $checkItem(Notification v) {
    if (v is! Notification) $pb.checkItemFailed(v, _i.qualifiedMessageName);
  }

  String get message => $_getS(0, '');
  set message(String v) { $_setString(0, v); }
  bool hasMessage() => $_has(0);
  void clearMessage() => clearField(1);
}

