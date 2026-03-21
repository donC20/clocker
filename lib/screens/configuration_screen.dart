import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:reorderables/reorderables.dart';
import '../providers/time_zone_provider.dart';
import '../widgets/clock_card.dart';
import '../widgets/dotted_border.dart';
import '../painters/noise_painter.dart';
import 'time_zone_list_screen.dart';

class ConfigurationScreen extends StatelessWidget {
  const ConfigurationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final timeZoneProvider = Provider.of<TimeZoneProvider>(context);
    final timezones = timeZoneProvider.selectedTimeZones;

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Container(color: const Color(0xFF121212)),
          ),
          Positioned.fill(
            child: CustomPaint(
              painter: NoisePainter(),
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
                      // Increased height for list format to avoid vertical overflow (now 200.0 for safety)
                      final double cardHeight = columns == 1 ? 200.0 : max(cardWidth * 0.8, 150.0);
                      
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
                            ...timezones.map((tz) => SizedBox(
                                  width: cardWidth,
                                  height: cardHeight,
                                  key: ValueKey(tz),
                                  child: ClockCard(
                                    timeZoneName: tz,
                                    showRemoveButton: true,
                                  ),
                                )),
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
