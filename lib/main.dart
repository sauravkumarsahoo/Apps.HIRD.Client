import 'dart:async';
import 'dart:developer';

import 'package:animated_theme_switcher/animated_theme_switcher.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:hird/common.dart';
import 'package:hird/constants.dart';
import 'package:hird/helpers/device_helper.dart';
import 'package:hird/models/server_info.dart';
import 'package:hird/pages/data_visualizer_page.dart';
import 'package:hird/pages/no_connectivity_page.dart';
import 'package:hird/pages/select_server_page.dart';
import 'package:hird/services/server_scanner_service.dart';
import 'package:hird/settings.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

// MOBILE APPS
// For smartphone apps, please add a link to https://icons8.com in the about section or settings.
//
// Also, please credit our work in your App Store or Google Play description (something like "Icons by Icons8" is fine).

const minPrintLevel = PrintLevel.info;

void main() => runApp(const MyApp());

void setup() {
  GetIt.I.registerSingleton<DeviceHelper>(DeviceHelper());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final Settings _settings = Settings();

  ConnectivityResult _connectionStatus = ConnectivityResult.none;
  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<ConnectivityResult> _connectivitySubscription;

  @override
  void initState() {
    super.initState();
    initConnectivity();
    setup();
    _connectivitySubscription =
        _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
  }

  Future<void> initConnectivity() async {
    late ConnectivityResult result;

    try {
      result = await _connectivity.checkConnectivity();
    } on PlatformException catch (e) {
      log('Couldn\'t check connectivity status', error: e);
      return;
    }

    if (!mounted) {
      return Future.value(null);
    }

    return _updateConnectionStatus(result);
  }

  Future<void> _updateConnectionStatus(ConnectivityResult result) async {
    setState(() {
      _connectionStatus = result;
    });
  }

  @override
  Widget build(BuildContext context) {
    final initTheme =
        _settings.theme == Brightness.dark ? darkTheme : lightTheme;

    return ThemeProvider(
      initTheme: initTheme,
      builder: (_, _theme) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: Constants.appName,
          theme: _theme,
          home: _connectionStatus == ConnectivityResult.ethernet ||
                  _connectionStatus == ConnectivityResult.wifi
              //? buildVisualizerDirectly('192.168.0.242')
              ? const SelectServerPage()
              : const NoConnectivityPage(),
        );
      },
    );
  }

  FutureBuilder<ServerInfo> buildVisualizerDirectly(String ip) {
    WakelockPlus.enable();
    return FutureBuilder<ServerInfo>(
      future: ServerScannerService().getServerInfo(ip),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const CircularProgressIndicator();
        }
        ServerScannerService().pause('Direct Visualizer');
        return DataVisualizerPage(
          serverInfo: snapshot.data!,
        );
      },
    );
  }
}
