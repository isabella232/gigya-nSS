import 'package:flutter/foundation.dart';
import 'package:gigya_native_screensets_engine/nss_configuration.dart';

class ScreenService {
  final NssChannels channels;

  final _defaultTimeout = 30;

  ScreenService({
    @required this.channels,
  });

  Future<Map<String, dynamic>> initiateAction(String flowId) async {
    var map = await channels.screenChannel.invokeMethod<Map<dynamic, dynamic>>(
      'action',
      {'actionId': flowId},
    ).catchError((error) {
      return {};
    }).timeout(Duration(seconds: _defaultTimeout), onTimeout: () {
      return {};
    });
    return map.cast<String, dynamic>();
  }
}
