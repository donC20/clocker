import 'package:google_fonts/google_fonts.dart';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:reorderables/reorderables.dart';
import '../providers/time_zone_provider.dart';
import '../widgets/clock_card.dart';
import '../widgets/dotted_border.dart';
import '../widgets/space_background_painter.dart';
import 'time_zone_list_screen.dart';

class ConfigurationScreen extends StatefulWidget {
  const ConfigurationScreen({super.key});

  @override
  State<ConfigurationScreen> createState() => _ConfigurationScreenState();
}

class _ConfigurationScreenState extends State<ConfigurationScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 30),
    )..repeat();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final timeZoneProvider = Provider.of<TimeZoneProvider>(context);
    final timezones = timeZoneProvider.selectedItems;

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                return CustomPaint(
                  painter: SpaceBackgroundPainter(animationValue: _animationController.value),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Configure Clocks',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          timeZoneProvider.setConfigured(true);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                        ),
                        child: const Text('Save & Launch'),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      const double spacing = 20.0;
                      const double horizontalPadding = 20.0;
                      // Switch to 1 column (list) for portrait/mobile, scale for landscape
                      int columns = constraints.maxWidth < 600 ? 1 : (constraints.maxWidth / 300).floor().clamp(2, 5);
                      final double cardWidth = (constraints.maxWidth - (horizontalPadding * 2) - (spacing * (columns - 1))) / columns;
                      int rows = (timezones.length / columns).ceil();
                      bool isSingleRowLandscape = columns > 1 && rows == 1;
                      final double cardHeight = columns == 1 
                          ? 200.0 
                          : (isSingleRowLandscape 
                              ? (constraints.maxHeight - 60.0).clamp(150.0, 600.0) 
                              : max(cardWidth * 0.8, 150.0));
                      
                      return SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.all(horizontalPadding),
                        child: ReorderableWrap(
                          spacing: spacing,
                          runSpacing: 20.0,
                          onReorder: (oldIndex, newIndex) {
                            timeZoneProvider.reorderTimeZones(oldIndex, newIndex);
                          },
                          children: [
                            for (int i = 0; i < timezones.length; i++)
                              SizedBox(
                                width: cardWidth,
                                height: cardHeight,
                                key: ValueKey(timezones[i]),
                                child: Stack(
                                  children: [
                                    ClockCard(
                                      item: timezones[i],
                                      showRemoveButton: true,
                                    ),
                                    Positioned(
                                      bottom: 8,
                                      left: 8,
                                      child: IconButton(
                                        onPressed: () => _showEditDialog(context, timezones[i], timeZoneProvider),
                                        icon: const Icon(Icons.edit, size: 18, color: Colors.white70),
                                        tooltip: 'Edit identity',
                                      ),
                                    ),
                                    if (!timezones[i].isMerged && i < timezones.length - 1 && !timezones[i + 1].isMerged)
                                      Positioned(
                                        bottom: 8,
                                        right: 40,
                                        child: IconButton(
                                          onPressed: () => timeZoneProvider.mergeItems(i),
                                          icon: const Icon(Icons.merge_type, size: 18, color: Colors.white70),
                                          tooltip: 'Merge with next',
                                        ),
                                      ),
                                    if (timezones[i].isMerged)
                                      Positioned(
                                        bottom: 8,
                                        right: 40,
                                        child: IconButton(
                                          onPressed: () => timeZoneProvider.unmergeItem(i),
                                          icon: const Icon(Icons.call_split, size: 18, color: Colors.white70),
                                          tooltip: 'Unmerge',
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            SizedBox(
                              width: cardWidth,
                              height: cardHeight,
                              key: const ValueKey('add_button'),
                              child: const AddTimeZoneNode(),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showEditDialog(BuildContext context, TimeZoneItem item, TimeZoneProvider provider) {
    final TextEditingController controller = TextEditingController(text: item.customLabel);
    int? selectedColorValue = item.customColorValue;
    bool isAnalog = item.isAnalog == true;
    bool isDayNightEnabled = item.isDayNightEnabled == true;
    String? selectedTheme = item.themePreset;
    
    const List<int> neonColors = [
      0xFFC66AF6, // Purple
      0xFF00E5FF, // Cyan
      0xFF39FF14, // Green
      0xFFFFD700, // Gold
      0xFFFF2400, // Scarlet
      0xFF4B0082, // Indigo
    ];

    const List<Map<String, String>> themes = [
      {'id': 'cyberpunk', 'name': 'Cyberpunk'},
      {'id': 'midnight', 'name': 'Midnight'},
      {'id': 'solarized', 'name': 'Solarized'},
      {'id': 'matrix', 'name': 'Matrix'},
    ];

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: const Color(0xFF1D1B20),
          title: Text(
            'Customize Card',
            style: GoogleFonts.orbitron(color: Colors.white, fontSize: 18),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'LABEL',
                  style: GoogleFonts.poppins(color: Colors.white70, fontSize: 10, letterSpacing: 1),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: controller,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'e.g. Home, Office',
                    hintStyle: const TextStyle(color: Colors.white24),
                    filled: true,
                    fillColor: Colors.white.withValues(alpha: 10 / 255.0),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                SwitchListTile(
                  title: Text('Analog Mode', style: GoogleFonts.poppins(color: Colors.white, fontSize: 14)),
                  value: isAnalog,
                  thumbColor: WidgetStatePropertyAll(selectedColorValue != null ? Color(selectedColorValue!) : Colors.purpleAccent),
                  trackColor: WidgetStatePropertyAll((selectedColorValue != null ? Color(selectedColorValue!) : Colors.purpleAccent).withValues(alpha: 0.5)),
                  onChanged: (val) => setDialogState(() => isAnalog = val),
                  contentPadding: EdgeInsets.zero,
                ),
                SwitchListTile(
                  title: Text('Day/Night Logic', style: GoogleFonts.poppins(color: Colors.white, fontSize: 14)),
                  subtitle: Text('Auto-color based on time', style: GoogleFonts.poppins(color: Colors.white54, fontSize: 10)),
                  value: isDayNightEnabled,
                  thumbColor: WidgetStatePropertyAll(selectedColorValue != null ? Color(selectedColorValue!) : Colors.purpleAccent),
                  trackColor: WidgetStatePropertyAll((selectedColorValue != null ? Color(selectedColorValue!) : Colors.purpleAccent).withValues(alpha: 0.5)),
                  onChanged: (val) => setDialogState(() => isDayNightEnabled = val),
                  contentPadding: EdgeInsets.zero,
                ),
                const SizedBox(height: 12),
                Text(
                  'THEME PRESET',
                  style: GoogleFonts.poppins(color: Colors.white70, fontSize: 10, letterSpacing: 1),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: themes.map((t) => ChoiceChip(
                    label: Text(t['name']!, style: TextStyle(color: selectedTheme == t['id'] ? Colors.black : Colors.white)),
                    selected: selectedTheme == t['id'],
                    selectedColor: Colors.white,
                    backgroundColor: Colors.white.withValues(alpha: 20 / 255.0),
                    onSelected: (selected) {
                      setDialogState(() => selectedTheme = selected ? t['id'] : null);
                    },
                  )).toList(),
                ),
                const SizedBox(height: 20),
                Text(
                  'THEME COLOR',
                  style: GoogleFonts.poppins(color: Colors.white70, fontSize: 10, letterSpacing: 1),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    for (int colorValue in neonColors)
                      GestureDetector(
                        onTap: () {
                          setDialogState(() {
                            selectedColorValue = colorValue;
                          });
                        },
                        child: Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: Color(colorValue),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: selectedColorValue == colorValue ? Colors.white : Colors.transparent,
                              width: 2,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel', style: GoogleFonts.poppins(color: Colors.white70)),
            ),
            ElevatedButton(
              onPressed: () {
                provider.updateItemMetadata(
                  item,
                  label: controller.text.trim().isEmpty ? null : controller.text.trim(),
                  colorValue: selectedColorValue,
                  isAnalog: isAnalog,
                  isDayNightEnabled: isDayNightEnabled,
                  themePreset: selectedTheme,
                );
                Navigator.pop(context);
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}

class AddTimeZoneNode extends StatelessWidget {
  const AddTimeZoneNode({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const TimeZoneListScreen(),
          ),
        );
      },
      child: DottedBorder(
        color: Colors.white30,
        strokeWidth: 2,
        radius: const Radius.circular(12),
        dashPattern: const [8, 6],
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.add, color: Colors.white54, size: 32),
              SizedBox(height: 8),
              Text(
                'ADD TIMEZONE',
                style: TextStyle(color: Colors.white54, fontSize: 12),
              )
            ],
          ),
        ),
      ),
    );
  }
}
