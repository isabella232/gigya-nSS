import 'package:flutter/foundation.dart';
import 'package:gigya_native_screensets_engine/config.dart';

class ScreenService {
  final NssChannels channels;

  final _defaultTimeout = 30;

  ScreenService(this.channels);

  /// Trigger the native SDK to instantiate the adjacent screen action.
  /// The screen action native component is responsible for performing all native SDK logic.
  Future<Map<String, dynamic>> initiateAction(String actionId, String screenId) async {
    var map = await channels.screenChannel.invokeMethod<Map<dynamic, dynamic>>(
      'action',
      {
        'actionId': actionId,
        'screenId': screenId,
      },
    ).catchError((error) {
      return {};
    }).timeout(Duration(seconds: _defaultTimeout), onTimeout: () {
      return {};
    });
    return map.cast<String, dynamic>();
  }

  /// Trigger the native SDK to display an external link providing a formatted [link] URL.
  Future<void> linkToBrowser(String link) async {
    await channels.screenChannel.invokeMethod<Map<dynamic, dynamic>>(
      'link',
      {
        'url': link,
      },
    ).catchError((error) {
      debugPrint('Link error returned from native');
    });
  }
}
