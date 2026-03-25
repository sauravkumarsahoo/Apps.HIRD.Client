import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';
import 'package:hird/generated/sensorcomms.pb.dart';
import 'package:hird/settings.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';

_cardDecoration(BuildContext context) => BoxDecoration(
      borderRadius: BorderRadius.circular(10),
      color: Theme.of(context).cardColor,
      boxShadow: [
        BoxShadow(
            color: Theme.of(context).shadowColor.withValues(alpha: 0.7),
            blurRadius: 30,
            offset: const Offset(0, 10))
      ],
    );

class CenteredColumn extends Column {
  const CenteredColumn({
    super.key,
    super.mainAxisSize,
    super.crossAxisAlignment,
    super.textDirection,
    super.verticalDirection,
    super.textBaseline,
    super.children,
  }) : super(
          mainAxisAlignment: MainAxisAlignment.center,
        );
}

class ExpandableFloatCard extends StatefulWidget {
  final String title;
  final String? subtitle;
  final Widget body;
  final String? assetImageName;

  const ExpandableFloatCard(
      {super.key,
      required this.title,
      required this.body,
      this.subtitle,
      this.assetImageName});

  @override
  State<ExpandableFloatCard> createState() => _ExpandableFloatCardState();
}

class _ExpandableFloatCardState extends State<ExpandableFloatCard> {
  late ExpandableController _expandableController;

  @override
  void initState() {
    _expandableController = ExpandableController(
        initialExpanded: Settings().cardsExpandedByDefault);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ExpandableNotifier(
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: FloatCard(
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: <Widget>[
              ScrollOnExpand(
                scrollOnExpand: true,
                scrollOnCollapse: false,
                child: ExpandablePanel(
                  theme: const ExpandableThemeData(
                    headerAlignment: ExpandablePanelHeaderAlignment.center,
                    tapBodyToCollapse: true,
                  ),
                  header: Stack(
                    children: [
                      if (widget.assetImageName != null)
                        Positioned(
                          left: 12,
                          top: 6,
                          child: BlendedAssetImage(
                              assetImageName: widget.assetImageName!),
                        ),
                      Padding(
                        padding: EdgeInsets.only(
                            left: widget.assetImageName != null ? 68 : 20,
                            top: 20,
                            bottom: 12),
                        child: Row(
                          children: [
                            widget.subtitle == null
                                ? Text(
                                    widget.title,
                                    style:
                                        Theme.of(context).textTheme.titleLarge,
                                  )
                                : Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Text(
                                        widget.title,
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleLarge,
                                      ),
                                      const SizedBox(
                                        width: 8,
                                      ),
                                      Text(
                                        widget.subtitle!,
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleMedium!
                                            .copyWith(
                                                fontStyle: FontStyle.italic,
                                                color: Theme.of(context)
                                                    .disabledColor),
                                      ),
                                    ],
                                  ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  collapsed: Container(),
                  expanded: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 10.0),
                    child: widget.body,
                  ),
                  controller: _expandableController,
                  builder: (_, collapsed, expanded) {
                    return Expandable(
                      collapsed: collapsed,
                      expanded: Column(
                        children: [
                          const Divider(),
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: expanded,
                          ),
                        ],
                      ),
                      theme: const ExpandableThemeData(crossFadePoint: 0),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class BlendedAssetImage extends StatelessWidget {
  const BlendedAssetImage({
    super.key,
    required this.assetImageName,
  });

  final String assetImageName;

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      shaderCallback: (rect) {
        return const LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [Colors.black, Colors.black26],
        ).createShader(Rect.fromLTRB(0, 0, rect.width, rect.height));
      },
      blendMode: BlendMode.dstIn,
      child: Image(
        image: AssetImage(assetImageName),
      ),
    );
  }
}

class FloatCard extends StatelessWidget {
  final AlignmentGeometry? alignment;
  final Color? color;
  final EdgeInsetsGeometry? padding;
  final Decoration? foregroundDecoration;
  final double? width;
  final double? height;
  final BoxConstraints? constraints;
  final EdgeInsetsGeometry? margin;
  final Matrix4? transform;
  final AlignmentGeometry? transformAlignment;
  final Widget? child;
  final Clip clipBehavior;

  const FloatCard({
    super.key,
    required this.child,
    this.alignment,
    this.padding,
    this.color,
    this.foregroundDecoration,
    this.width,
    this.height,
    this.constraints,
    this.margin,
    this.transform,
    this.transformAlignment,
    this.clipBehavior = Clip.none,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      key: key,
      alignment: alignment,
      color: color,
      width: width,
      height: height,
      padding: padding,
      clipBehavior: clipBehavior,
      constraints: constraints,
      decoration: _cardDecoration(context),
      foregroundDecoration: foregroundDecoration,
      margin: margin,
      transform: transform,
      transformAlignment: transformAlignment,
      child: child,
    );
  }
}

class LinearTempGauge extends StatelessWidget {
  final ReadingData reading;
  final String label;
  final double height;
  final double width;
  final double coolLimit;
  final double warmLimit;

  final Color coolColor = Colors.green;
  final Color warmColor = Colors.orange;
  final Color hotColor = Colors.red;

  static const double startAngle = 145;
  static const double endAngle = 35;
  static const double radiusFactor = 1.15;

  const LinearTempGauge(
      {super.key,
      required this.reading,
      required this.label,
      required this.coolLimit,
      required this.warmLimit,
      this.width = 160,
      this.height = 40});

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

    return SizedBox(
      width: width,
      height: height,
      child: SfLinearGauge(
        minimum: rangeMinimum,
        maximum: rangeMaximum,
        minorTicksPerInterval: 0,
        animateAxis: true,
        axisTrackStyle: const LinearAxisTrackStyle(thickness: 1),
        axisLabelStyle: Theme.of(context).textTheme.labelSmall,
        useRangeColorForAxis: true,
        ranges: [
          LinearGaugeRange(
            startValue: reading.min,
            endValue: reading.max,
            position: LinearElementPosition.inside,
            shaderCallback: (bounds) => LinearGradient(
              colors: [
                minColor,
                maxColor,
              ],
            ).createShader(bounds),
          )
        ],
        barPointers: <LinearBarPointer>[
          LinearBarPointer(
              value: reading.current,
              thickness: 6,
              position: LinearElementPosition.outside,
              color: currentColor),
        ],
        markerPointers: <LinearMarkerPointer>[
          LinearShapePointer(
            value: reading.avg,
            offset: 0,
            height: 8,
            width: 6,
            position: LinearElementPosition.inside,
            shapeType: LinearShapePointerType.triangle,
          ),
        ],
      ),
    );
  }
}
