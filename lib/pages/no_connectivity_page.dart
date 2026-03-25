import 'package:flutter/material.dart';

class NoConnectivityPage extends StatelessWidget {
  const NoConnectivityPage({Key? key}) : super(key: key);

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
                      Text('No network',
                          style: Theme.of(context)
                              .textTheme
                              .headlineMedium),
                    ],
                  ),
                )),
            Expanded(flex: 6, child: Container())
          ],
        ),
      ),
    );
  }
}
