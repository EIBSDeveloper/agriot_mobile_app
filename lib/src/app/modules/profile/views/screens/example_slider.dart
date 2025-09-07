import 'package:flutter/material.dart';

import '../widgets/custom_slider_thumb_circle.dart';

class ExampleSlider extends StatefulWidget {
  final double min;
  final double max;
  final double initialValue;
  final bool showMinMaxText;
  final Color primaryColor;
  final TextStyle minMaxTextStyle;
  final Function(double) onChange;
  const ExampleSlider({
    required this.min,
    required this.max,
    this.initialValue = 0.0,
    required this.onChange,
    this.primaryColor = Colors.indigo,
    this.showMinMaxText = true,
    this.minMaxTextStyle = const TextStyle(fontSize: 14),
    super.key,
  });

  @override
  // ignore: library_private_types_in_public_api
  _ExampleSliderState createState() => _ExampleSliderState();
}

class _ExampleSliderState extends State<ExampleSlider> {
  late double _currentSliderValue;
  @override
  void initState() {
    super.initState();
    _currentSliderValue = widget.initialValue;
  }

  @override
  Widget build(BuildContext context) => SliderTheme(
      data: SliderTheme.of(context).copyWith(
        activeTrackColor: widget.primaryColor,
        inactiveTrackColor: widget.primaryColor.withAlpha(35),
        trackShape: const RoundedRectSliderTrackShape(),
        trackHeight: 4.0,
        thumbShape: CustomSliderThumbCircle(
          thumbRadius: 20,
          min: widget.min,
          max: widget.max,
        ),
        thumbColor: widget.primaryColor,
        overlayColor: widget.primaryColor.withAlpha(35),
        overlayShape: const RoundSliderOverlayShape(overlayRadius: 28.0),
        tickMarkShape: const RoundSliderTickMarkShape(),
        activeTickMarkColor: widget.primaryColor,
        inactiveTickMarkColor: widget.primaryColor.withAlpha(35),
        valueIndicatorShape: const PaddleSliderValueIndicatorShape(),
        valueIndicatorColor: widget.primaryColor.withAlpha(35),
        valueIndicatorTextStyle: const TextStyle(color: Colors.white),
      ),
      child: Slider(
        min: widget.min,
        max: widget.max,
        value: _currentSliderValue,
        onChanged: (value) {
          setState(() {
            _currentSliderValue = value;
          });
          widget.onChange(value);
        },
      ),
    );
}

