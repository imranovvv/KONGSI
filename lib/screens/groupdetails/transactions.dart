import 'package:flutter/material.dart';

class Transactions extends StatefulWidget {
  const Transactions({Key? key}) : super(key: key);

  @override
  _TransactionsState createState() => _TransactionsState();
}

class _TransactionsState extends State<Transactions> {
  List<SliderData> slidersData = [
    SliderData(initialValue: 40),
    SliderData(initialValue: -20),
    SliderData(initialValue: -20),
  ];

  @override
  void initState() {
    super.initState();
    calculateRangeValues();
  }

  void calculateRangeValues() {
    double total = slidersData
        .fold(0, (sum, data) => sum + data.initialValue.abs())
        .toDouble();
    for (var sliderData in slidersData) {
      double valuePart = sliderData.initialValue.abs() / total;
      sliderData.rangeValues = sliderData.initialValue >= 0
          ? RangeValues(0.5, 0.5 + valuePart)
          : RangeValues(0.5 - valuePart, 0.5);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: slidersData.map((data) => _buildSlider(data)).toList(),
    );
  }

  Widget _buildSlider(SliderData data) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildTransactionText(data),
          _buildSliderWidget(data),
        ],
      ),
    );
  }

  Text _buildTransactionText(SliderData data) {
    String sign = data.initialValue > 0 ? '+' : '';
    return Text(
      'Transaction $sign${data.initialValue}',
      style: const TextStyle(fontSize: 25, fontWeight: FontWeight.w600),
    );
  }

  SliderTheme _buildSliderWidget(SliderData data) {
    Color activeTrackColor = data.initialValue > 0 ? Colors.green : Colors.red;

    return SliderTheme(
      data: SliderTheme.of(context).copyWith(
        activeTrackColor: activeTrackColor,
        inactiveTrackColor: Colors.grey,
        thumbColor: Colors.black,
        rangeThumbShape:
            const RoundRangeSliderThumbShape(enabledThumbRadius: 4.0),
        trackShape: const RectangularSliderTrackShape(),
      ),
      child: AbsorbPointer(
        absorbing: true,
        child: RangeSlider(
          values: data.rangeValues,
          onChanged: (values) => _onSliderChanged(values, data),
          min: 0.0,
          max: 1.0,
        ),
      ),
    );
  }

  void _onSliderChanged(RangeValues values, SliderData data) {
    setState(() {
      data.rangeValues = values;
    });
  }
}

class SliderData {
  int initialValue;
  late RangeValues rangeValues;

  SliderData({required this.initialValue});
}
