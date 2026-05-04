import 'package:flutter/material.dart';

void main() {
  runApp(const MultimediaFiltersApp());
}

class MultimediaFiltersApp extends StatelessWidget {
  const MultimediaFiltersApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HCI Photo Filter Studio',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6200EE),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: const FilterScreen(),
    );
  }
}

class FilterScreen extends StatefulWidget {
  const FilterScreen({super.key});

  @override
  State<FilterScreen> createState() => _FilterScreenState();
}

class _FilterScreenState extends State<FilterScreen> {
  double _brightness = 0.0;
  double _contrast = 1.0;
  double _saturation = 1.0;
  
  int _selectedFilterIndex = 0;

  final List<FilterPreset> _presets = [
    FilterPreset(name: 'Normal', brightness: 0.0, contrast: 1.0, saturation: 1.0, color: Colors.transparent),
    FilterPreset(name: 'B & W', brightness: 0.0, contrast: 1.2, saturation: 0.0, color: Colors.transparent),
    FilterPreset(name: 'Dark', brightness: -0.2, contrast: 1.1, saturation: 0.8, color: Colors.black26),
    FilterPreset(name: 'Bright', brightness: 0.2, contrast: 1.1, saturation: 1.2, color: Colors.transparent),
    FilterPreset(name: 'Sepia', brightness: 0.1, contrast: 0.9, saturation: 0.4, color: Colors.orange.withOpacity(0.2)),
  ];

  void _applyPreset(int index) {
    setState(() {
      _selectedFilterIndex = index;
      _brightness = _presets[index].brightness;
      _contrast = _presets[index].contrast;
      _saturation = _presets[index].saturation;
    });
  }

  void _resetFilters() {
    setState(() {
      _brightness = 0.0;
      _contrast = 1.0;
      _saturation = 1.0;
      _selectedFilterIndex = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('HCI Photo Studio', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _resetFilters,
            tooltip: 'Reset Filters',
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              flex: 5,
              child: Container(
                margin: const EdgeInsets.all(12.0),
                decoration: BoxDecoration(
                  color: Colors.black12,
                  borderRadius: BorderRadius.circular(16),
                ),
                clipBehavior: Clip.antiAlias,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    ColorFiltered(
                      colorFilter: ColorFilter.matrix(_calculateColorMatrix(_brightness, _contrast, _saturation)),
                      child: Image.asset(
                        'hci_multimedia_filters_web/Screenshot_26-Jan_10-10-08_kitty.png',
                        fit: BoxFit.contain,
                      ),
                    ),
                    Container(
                      color: _presets[_selectedFilterIndex].color,
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              flex: 5,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: const BoxDecoration(
                color: Color(0xFF1E1E1E),
                borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Presets', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                  const SizedBox(height: 15),
                  SizedBox(
                    height: 40,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _presets.length,
                      itemBuilder: (context, index) {
                        final isSelected = _selectedFilterIndex == index;
                        return Padding(
                          padding: const EdgeInsets.only(left: 10),
                          child: ChoiceChip(
                            label: Text(_presets[index].name),
                            selected: isSelected,
                            onSelected: (selected) {
                              if (selected) _applyPreset(index);
                            },
                            selectedColor: Theme.of(context).colorScheme.primary,
                            labelStyle: TextStyle(
                              color: isSelected ? Colors.white : Colors.white70,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Divider(color: Colors.white24),
                  const SizedBox(height: 10),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          _buildSliderControl('Brightness', _brightness, -1.0, 1.0, (val) {
                            setState(() { _brightness = val; _selectedFilterIndex = -1; });
                          }),
                          _buildSliderControl('Contrast', _contrast, 0.0, 2.0, (val) {
                            setState(() { _contrast = val; _selectedFilterIndex = -1; });
                          }),
                          _buildSliderControl('Saturation', _saturation, 0.0, 2.0, (val) {
                            setState(() { _saturation = val; _selectedFilterIndex = -1; });
                          }),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSliderControl(String label, double value, double min, double max, ValueChanged<double> onChanged) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: const TextStyle(fontSize: 14, color: Colors.white70)),
              Text(value.toStringAsFixed(2), style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white)),
            ],
          ),
          SliderTheme(
            data: SliderThemeData(
              activeTrackColor: Theme.of(context).colorScheme.primary,
              inactiveTrackColor: Colors.white12,
              thumbColor: Colors.white,
              overlayColor: Theme.of(context).colorScheme.primary.withOpacity(0.2),
              trackHeight: 4.0,
            ),
            child: Slider(
              value: value,
              min: min,
              max: max,
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }

  List<double> _calculateColorMatrix(double brightness, double contrast, double saturation) {
    final double t = (1.0 - contrast) / 2.0 * 255.0;
    List<double> mat = [
      contrast, 0, 0, 0, t + (brightness * 255.0),
      0, contrast, 0, 0, t + (brightness * 255.0),
      0, 0, contrast, 0, t + (brightness * 255.0),
      0, 0, 0, 1, 0,
    ];

    final double invSat = 1.0 - saturation;
    final double R = 0.213 * invSat;
    final double G = 0.715 * invSat;
    final double B = 0.072 * invSat;

    List<double> satMat = [
      R + saturation, G, B, 0, 0,
      R, G + saturation, B, 0, 0,
      R, G, B + saturation, 0, 0,
      0, 0, 0, 1, 0,
    ];

    List<double> result = List.filled(20, 0.0);
    for (int i = 0; i < 4; i++) {
      for (int j = 0; j < 5; j++) {
        for (int k = 0; k < 4; k++) {
          result[i * 5 + j] += mat[i * 5 + k] * satMat[k * 5 + j];
        }
      }
    }
    for (int i = 0; i < 4; i++) result[i * 5 + 4] += mat[i * 5 + 4];
    return result;
  }
}

class FilterPreset {
  final String name;
  final double brightness;
  final double contrast;
  final double saturation;
  final Color color;

  FilterPreset({
    required this.name,
    required this.brightness,
    required this.contrast,
    required this.saturation,
    required this.color,
  });
}
