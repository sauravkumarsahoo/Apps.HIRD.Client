import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';

class DeviceHelper {
  late String deviceName;

  DeviceHelper() {
    var deviceInfoPlugin = DeviceInfoPlugin();
    deviceInfoPlugin.deviceInfo.then((value) => deviceName = Platform.isAndroid
        ? (value as AndroidDeviceInfo).device!
        : (value as IosDeviceInfo).name!);
  }
}
