import 'package:flutter/material.dart';
import 'package:native_kit/native_kit.dart';

class ControlsPage extends StatefulWidget {
  const ControlsPage({super.key});

  @override
  State<ControlsPage> createState() => _ControlsPageState();
}

class _ControlsPageState extends State<ControlsPage> {
  // Switch
  bool _switch1 = true;
  bool _switch2 = false;
  final bool _switch3 = true;

  // Slider
  double _volume = 0.5;
  double _brightness = 75;

  // Segmented control
  int _segmentIndex = 0;

  // Progress
  double _progress = 0.3;

  // Date picker
  DateTime _selectedDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        // --- NKSegmentedControl ---
        _sectionHeader('NKSegmentedControl'),
        NKSegmentedControl(
          labels: const ['Day', 'Week', 'Month'],
          selectedIndex: _segmentIndex,
          onValueChanged: (i) => setState(() => _segmentIndex = i),
          tintColor: Colors.blue,
        ),
        const SizedBox(height: 8),
        Text('Selected: $_segmentIndex', textAlign: TextAlign.center),

        // --- NKSwitch ---
        _sectionHeader('NKSwitch'),
        _switchRow('Default', _switch1, (v) => setState(() => _switch1 = v)),
        _switchRow(
          'Custom color',
          _switch2,
          (v) => setState(() => _switch2 = v),
          activeColor: Colors.green,
        ),
        _switchRow('Disabled', _switch3, null, enabled: false),

        // --- NKSlider ---
        _sectionHeader('NKSlider'),
        Text('Continuous: ${_volume.toStringAsFixed(2)}'),
        const SizedBox(height: 8),
        NKSlider(
          value: _volume,
          onChanged: (v) => setState(() => _volume = v),
          activeColor: Colors.blue,
        ),
        const SizedBox(height: 16),
        Text('Stepped (0–100, step 25): ${_brightness.round()}'),
        const SizedBox(height: 8),
        NKSlider(
          value: _brightness,
          min: 0,
          max: 100,
          step: 25,
          onChanged: (v) => setState(() => _brightness = v),
          activeColor: Colors.orange,
        ),

        // --- NKProgressView ---
        _sectionHeader('NKProgressView'),
        NKProgressView(
          style: NKProgressViewStyle.bar,
          value: _progress,
          tintColor: Colors.blue,
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Text('${(_progress * 100).round()}%'),
            const Spacer(),
            TextButton(
              onPressed: () => setState(
                () => _progress = (_progress + 0.1).clamp(0.0, 1.0),
              ),
              child: const Text('+10%'),
            ),
            TextButton(
              onPressed: () => setState(() => _progress = 0.0),
              child: const Text('Reset'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Column(
              children: [
                NKProgressView(
                  style: NKProgressViewStyle.spinner,
                  spinnerSize: NKSpinnerSize.small,
                ),
                SizedBox(height: 4),
                Text('Small', style: TextStyle(fontSize: 12)),
              ],
            ),
            Column(
              children: [
                NKProgressView(
                  style: NKProgressViewStyle.spinner,
                  spinnerSize: NKSpinnerSize.medium,
                ),
                SizedBox(height: 4),
                Text('Medium', style: TextStyle(fontSize: 12)),
              ],
            ),
            Column(
              children: [
                NKProgressView(
                  style: NKProgressViewStyle.spinner,
                  spinnerSize: NKSpinnerSize.large,
                  tintColor: Colors.orange,
                ),
                SizedBox(height: 4),
                Text('Large', style: TextStyle(fontSize: 12)),
              ],
            ),
          ],
        ),

        // --- NKDatePicker ---
        _sectionHeader('NKDatePicker'),
        const Text('Compact', style: TextStyle(fontSize: 13, color: Colors.grey)),
        const SizedBox(height: 8),
        NKDatePicker(
          mode: NKDatePickerMode.dateAndTime,
          style: NKDatePickerStyle.compact,
          initialDate: _selectedDate,
          onDateChanged: (date) => setState(() => _selectedDate = date),
        ),
        const SizedBox(height: 8),
        Text(
          'Selected: ${_selectedDate.toString().split('.').first}',
          style: const TextStyle(fontSize: 13, color: Colors.grey),
        ),
        const SizedBox(height: 16),
        const Text('Inline', style: TextStyle(fontSize: 13, color: Colors.grey)),
        const SizedBox(height: 8),
        NKDatePicker(
          mode: NKDatePickerMode.date,
          style: NKDatePickerStyle.inline,
          initialDate: _selectedDate,
          onDateChanged: (date) => setState(() => _selectedDate = date),
          tintColor: Colors.blue,
        ),
        const SizedBox(height: 32),
      ],
    );
  }

  Widget _switchRow(
    String label,
    bool value,
    ValueChanged<bool>? onChanged, {
    Color? activeColor,
    bool enabled = true,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 16)),
          NKSwitch(
            value: value,
            onChanged: onChanged,
            activeColor: activeColor,
            enabled: enabled,
          ),
        ],
      ),
    );
  }
}

Widget _sectionHeader(String title) {
  return Padding(
    padding: const EdgeInsets.only(top: 24, bottom: 12),
    child: Text(
      title,
      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
    ),
  );
}
