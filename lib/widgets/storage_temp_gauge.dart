import 'package:flutter/material.dart';
import 'package:hird/generated/sensorcomms.pb.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';

class StorageTempGauge extends StatelessWidget {
  final ReadingData reading;
  final String label;
  final double height;
  final double width;
  final double coolLimit = 45;
  final double warmLimit = 70;

  const StorageTempGauge({
    Key? key,
    required this.reading,
    required this.label,
    this.width = 120,
    this.height = 140,
  }) : super(key: key);

  final Color coolColor = Colors.green;
  final Color warmColor = Colors.orange;
  final Color hotColor = Colors.red;

  static const double startAngle = 145;
  static const double endAngle = 35;
  static const double radiusFactor = 1.15;

  Color _getColor(double value) {
    if (value <= coolLimit) {
      return coolColor;
    } else if (value <= warmLimit) {
      return warmColor;
    } else {
      return hotColor;
    }
  }

  @override
  Widget build(BuildContext context) {
    double rangeMinimum = reading.current < 20 ? reading.current : 20;
    double rangeMaximum = reading.current > 100 ? reading.current : 100;

    var currentColor = _getColor(reading.current);
    var minColor = _getColor(reading.min);
    var maxColor = _getColor(reading.max);
    var avgColor = _getColor(reading.avg);

    return SizedBox(
      width: width,
      height: height,
      child: SfRadialGauge(
        animationDuration: 500,
        enableLoadingAnimation: true,
        axes: <RadialAxis>[
          RadialAxis(
            minimum: rangeMinimum,
            maximum: rangeMaximum,
            startAngle: startAngle,
            endAngle: endAngle,
            radiusFactor: radiusFactor,
            ranges: <GaugeRange>[
              GaugeRange(
                startValue: reading.min,
                endValue: reading.max,
                gradient: SweepGradient(
                  colors: [minColor, maxColor],
                  stops: const [0, 1],
                ),
              )
            ],
          ),
          RadialAxis(
            minimum: rangeMinimum,
            maximum: rangeMaximum,
            startAngle: startAngle,
            endAngle: endAngle,
            radiusFactor: radiusFactor,
            showLabels: false,
            ranges: <GaugeRange>[
              GaugeRange(
                  startWidth: 2,
                  endWidth: 2,
                  startValue: reading.current < 0 ? reading.current : 0,
                  endValue: coolLimit,
                  color: coolColor.withOpacity(0.7)),
              GaugeRange(
                  startWidth: 2,
                  endWidth: 2,
                  startValue: coolLimit,
                  endValue: warmLimit,
                  color: warmColor.withOpacity(0.7)),
              GaugeRange(
                  startWidth: 2,
                  endWidth: 2,
                  startValue: warmLimit,
                  endValue: reading.max * 100,
                  color: hotColor.withOpacity(0.7)),
            ],
            pointers: <GaugePointer>[
              NeedlePointer(
                value: reading.current,
                enableAnimation: true,
                animationDuration: 100,
                needleStartWidth: 1,
                needleEndWidth: 3,
                needleColor: currentColor,
                knobStyle: KnobStyle(color: currentColor, knobRadius: 0.05),
              ),
              MarkerPointer(
                value: reading.avg,
                enableAnimation: true,
                color: Colors.black38,
                animationDuration: 50,
              )
            ],
            annotations: <GaugeAnnotation>[
              GaugeAnnotation(
                  widget: Text('${reading.current.round()} ºC',
                      style: Theme.of(context).textTheme.bodyLarge),
                  angle: 90,
                  positionFactor: 0.3),
              GaugeAnnotation(
                  widget: Text(label,
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall!
                          .copyWith(fontStyle: FontStyle.italic)),
                  angle: 90,
                  positionFactor: 0.5),
              GaugeAnnotation(
                  widget: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Text(
                        'MIN',
                        style: Theme.of(context).textTheme.labelSmall,
                        textScaleFactor: 0.7,
                      ),
                      Text(
                        'AVG',
                        style: Theme.of(context).textTheme.labelSmall,
                        textScaleFactor: 0.7,
                      ),
                      Text(
                        'MAX',
                        style: Theme.of(context).textTheme.labelSmall,
                        textScaleFactor: 0.7,
                      ),
                    ],
                  ),
                  angle: 90,
                  positionFactor: 0.8),
              GaugeAnnotation(
                  widget: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Text('${reading.min.round()} ºC',
                          style: Theme.of(context)
                              .textTheme
                              .labelSmall!
                              .copyWith(color: minColor)),
                      Text('${reading.avg.round()} ºC',
                          style: Theme.of(context)
                              .textTheme
                              .labelSmall!
                              .copyWith(color: avgColor)),
                      Text('${reading.max.round()} ºC',
                          style: Theme.of(context)
                              .textTheme
                              .labelSmall!
                              .copyWith(color: maxColor)),
                    ],
                  ),
                  angle: 90,
                  positionFactor: 0.95)
            ],
          ),
        ],
      ),
    );
  }
}
