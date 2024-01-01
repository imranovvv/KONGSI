import 'package:flutter/material.dart';

class Transactions extends StatefulWidget {
  const Transactions({Key? key}) : super(key: key);

  @override
  _TransactionsState createState() => _TransactionsState();
}

class _TransactionsState extends State<Transactions> {
  static const int aliInitialValue = 30;
  static const int abuInitialValue = -20;
  static const int angahInitialValue = -10; // New constant for Angah

  late RangeValues sliderValues1;
  late RangeValues sliderValues2;
  late RangeValues sliderValues3; // New RangeValues for Angah

  @override
  void initState() {
    super.initState();
    sliderValues1 = calculateRangeValues(aliInitialValue);
    sliderValues2 = calculateRangeValues(abuInitialValue);
    sliderValues3 =
        calculateRangeValues(angahInitialValue); // Initialize for Angah
  }

  RangeValues calculateRangeValues(int value) {
    double total = (aliInitialValue.abs() +
            abuInitialValue.abs() +
            angahInitialValue.abs())
        .toDouble(); // Include Angah in total

    if (value >= 0) {
      return RangeValues(0.5, 0.5 + (value.abs() / total));
    } else {
      return RangeValues(0.5 - (value.abs() / total), 0.5);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: 3, // Updated count for 3 sliders
      itemBuilder: (context, index) => buildItem(index),
    );
  }

  Widget buildItem(int index) {
    int initialValue = index == 0
        ? aliInitialValue
        : index == 1
            ? abuInitialValue
            : angahInitialValue; // Initial value for the respective person
    String personName = index == 0
        ? 'Ali'
        : index == 1
            ? 'Abu'
            : 'Angah'; // Name for the respective person
    Color activeTrackColor = initialValue > 0 ? Colors.green : Colors.red;

    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Transactions $personName', // Dynamic person name
            style: const TextStyle(fontSize: 25, fontWeight: FontWeight.w600),
          ),
          Text(
            initialValue > 0 ? '+$initialValue' : '$initialValue',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ), // Display the initial value above the slider
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: activeTrackColor,
              inactiveTrackColor: Colors.grey,
              thumbColor: Colors.black,
              rangeThumbShape:
                  const RoundRangeSliderThumbShape(enabledThumbRadius: 1.0),
              trackHeight: 2.0,
            ),
            child: RangeSlider(
              values: index == 0
                  ? sliderValues1
                  : index == 1
                      ? sliderValues2
                      : sliderValues3, // Use the correct slider values
              onChanged: (values) => _onSliderChanged(values, index),
              min: 0.0,
              max: 1.0,
            ),
          ),
        ],
      ),
    );
  }

  void _onSliderChanged(RangeValues values, int index) {
    setState(() {
      if (index == 0) {
        sliderValues1 = values;
      } else if (index == 1) {
        sliderValues2 = values;
      } else {
        sliderValues3 = values;
      }
    });
  }
}
