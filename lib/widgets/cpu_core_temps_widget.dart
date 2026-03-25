import 'package:flutter/material.dart';
import 'package:hird/generated/sensorcomms.pb.dart';
import 'package:hird/widgets_lib.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';

class CpuCoreTempsWidget extends StatelessWidget {
  CpuCoreTempsWidget({
    super.key,
    required this.coreTemps,
  });

  final List<ReadingData> coreTemps;

  late final int count = coreTemps.length;

  final double coolLimit = 45;
  final double warmLimit = 70;

  final Color coolColor = Colors.green;
  final Color warmColor = Colors.orange;
  final Color hotColor = Colors.red;

  @override
  Widget build(BuildContext context) {
    return CenteredColumn(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.max,
      children: [
        Expanded(
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: count,
            scrollDirection: Axis.horizontal,
            itemBuilder: (context, index) {
              var coreTempReadings = coreTemps[index];
              var t = coreTempReadings.current / 100;

              Color? currentColor;
              if (t < 65) {
                currentColor = Color.lerp(coolColor, warmColor, t * 0.65);
              } else if (t < 90) {
                currentColor = Color.lerp(warmColor, hotColor, t / 0.25);
              } else {
                currentColor = hotColor;
              }

              return SfLinearGauge(
                orientation: LinearGaugeOrientation.vertical,
                axisTrackStyle:
                    const LinearAxisTrackStyle(color: Colors.black12),
                showTicks: false,
                ranges: const [
                  LinearGaugeRange(
                    startValue: 0,
                    endValue: 100,
                    color: Colors.transparent,
                  )
                ],
                showLabels: false,
                barPointers: [
                  LinearBarPointer(
                      value: coreTempReadings.current,
                      color: currentColor,
                      position: LinearElementPosition.cross),
                ],
              );
            },
          ),
        ),
        const SizedBox(height: 6),
        Text('Core Temps', style: Theme.of(context).textTheme.labelSmall)
      ],
    );
  }
}
