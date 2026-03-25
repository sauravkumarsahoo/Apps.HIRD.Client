import 'package:animated_theme_switcher/animated_theme_switcher.dart';
import 'package:fading_edge_scrollview/fading_edge_scrollview.dart';
import 'package:flutter/material.dart';
import 'package:hird/common.dart';
import 'package:hird/generated/sensorcomms.pb.dart';
import 'package:hird/services/server_scanner_service.dart';
import 'package:hird/models/server_info.dart';
import 'package:hird/pages/data_visualizer_page.dart';
import 'package:hird/widgets_lib.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

class SelectServerPage extends StatefulWidget {
  const SelectServerPage({Key? key}) : super(key: key);

  @override
  State<SelectServerPage> createState() => _SelectServerPageState();
}

class _SelectServerPageState extends State<SelectServerPage> {
  late ScrollController _serverScrollController;
  final ServerScannerService _service = ServerScannerService();
  bool _isServerLoading = false;

  @override
  void initState() {
    _serverScrollController = ScrollController();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
                flex: 4,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Image(
                        image: AssetImage('assets/icon/icon.png'),
                        height: 64,
                        width: 64,
                      ),
                      const SizedBox(
                        height: 16,
                      ),
                      ThemeSwitcher(
                        clipper: const ThemeSwitcherBoxClipper(),
                        builder: (context) {
                          return GestureDetector(
                            onTap: () {
                              ThemeSwitcher.of(context).changeTheme(
                                theme: ThemeModelInheritedNotifier.of(context)
                                            .theme
                                            .brightness ==
                                        Brightness.light
                                    ? darkTheme
                                    : lightTheme,
                              );
                            },
                            child: _isServerLoading
                                ? CircularProgressIndicator(
                                    color: Theme.of(context).highlightColor,
                                  )
                                : Text(
                                    'Select a Server',
                                    style:
                                        Theme.of(context).textTheme.headlineMedium,
                                  ),
                          );
                        },
                      ),
                    ],
                  ),
                )),
            Expanded(
              flex: 6,
              child: StreamBuilder(
                stream: _service.stream,
                initialData: List<ServerInfo>.empty(),
                builder: (context, snapshot) {
                  var servers = snapshot.data as List<ServerInfo>;

                  if (servers.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(
                            color: Theme.of(context).highlightColor,
                          ),
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Text('Looking for servers...',
                                style: Theme.of(context).textTheme.titleMedium),
                          )
                        ],
                      ),
                    );
                  }

                  return Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 32.0),
                        child: Text(
                            servers.length > 1
                                ? '${servers.length} Servers Found'
                                : '1 Server Found',
                            style: Theme.of(context).textTheme.headlineSmall),
                      ),
                      Expanded(
                          child: FloatCard(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),
                        child: OrientationBuilder(
                          builder: (context, orientation) {
                            return FadingEdgeScrollView.fromScrollView(
                              child: GridView.builder(
                                controller: _serverScrollController,
                                itemCount: servers.length,
                                gridDelegate:
                                    SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount:
                                            orientation == Orientation.portrait
                                                ? 1
                                                : 2,
                                        childAspectRatio: 3.8),
                                itemBuilder: (context, index) {
                                  final serverInfo = servers[index];
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16.0),
                                    child:
                                        _buildServerCard(context, serverInfo),
                                  );
                                },
                              ),
                            );
                          },
                        ),
                      )),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildServerCard(BuildContext context, ServerInfo serverInfo) {
    return Material(
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        splashColor: Theme.of(context).splashColor,
        onTap: () async {
          _service.pause('navigating to Visualizer');
          WakelockPlus.enable();

          setState(() {
            _isServerLoading = true;
          });

          await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) {
              return DataVisualizerPage(serverInfo: serverInfo);
            }),
          );

          if (!mounted) return;

          _service.resume('returned from Visualizer');
          WakelockPlus.disable();

          setState(() {
            _isServerLoading = false;
          });
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: SizedBox(
            height: 96,
            child: Ink(
              child: Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Column(
                    children: [
                      BlendedAssetImage(
                          assetImageName: serverInfo.info.systemType ==
                                  ComputerInfo_SystemType.DESKTOP
                              ? 'assets/hw/desktop.png'
                              : 'assets/hw/laptop.png'),
                      Column(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(serverInfo.ip,
                              style: Theme.of(context).textTheme.titleLarge),
                          Text(serverInfo.info.computerName,
                              style: Theme.of(context).textTheme.bodySmall)
                        ],
                      ),
                    ],
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(serverInfo.info.systemMake,
                          style: Theme.of(context)
                              .textTheme
                              .bodyLarge!
                              .copyWith(fontStyle: FontStyle.italic)),
                      Text(serverInfo.info.cpuName,
                          style: Theme.of(context).textTheme.bodyMedium),
                      if (serverInfo.info.gpuName.isNotEmpty)
                        Text(serverInfo.info.gpuName,
                            style: Theme.of(context).textTheme.bodyMedium),
                      Text(serverInfo.info.memory,
                          style: Theme.of(context).textTheme.bodyMedium),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
