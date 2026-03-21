import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:reorderables/reorderables.dart';
import '../providers/time_zone_provider.dart';
import '../widgets/clock_card.dart';
import '../painters/noise_painter.dart';

class ClockScreen extends StatefulWidget {
  const ClockScreen({super.key});

  @override
  State<ClockScreen> createState() => _ClockScreenState();
}

class _ClockScreenState extends State<ClockScreen> {
  late Timer _timer;
  bool _showCustomize = false;
  Timer? _hideTimer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    _hideTimer?.cancel();
    super.dispose();
  }

  void _handleScreenTouch() {
    setState(() {
      _showCustomize = true;
    });
    _hideTimer?.cancel();
    _hideTimer = Timer(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _showCustomize = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final timeZoneProvider = Provider.of<TimeZoneProvider>(context);
    final timezones = timeZoneProvider.selectedTimeZones;

    return Scaffold(
      body: GestureDetector(
        onTap: _handleScreenTouch,
        behavior: HitTestBehavior.translucent,
        child: Stack(
          children: [
            Positioned.fill(
              child: Container(color: const Color(0xFF121212)),
            ),
            Positioned.fill(
              child: CustomPaint(
                painter: NoisePainter(),
              ),
            ),
            LayoutBuilder(
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
                  padding: EdgeInsets.only(left: horizontalPadding, top: 20.0, right: horizontalPadding, bottom: 100.0),
                  child: ReorderableWrap(
                    spacing: spacing,
                    runSpacing: 20.0,
                    onReorder: (oldIndex, newIndex) {
                      timeZoneProvider.reorderTimeZones(oldIndex, newIndex);
                    },
                    children: timezones.map((tz) => SizedBox(
                      width: cardWidth,
                      height: cardHeight,
                      key: ValueKey(tz),
                      child: ClockCard(
                        timeZoneName: tz,
                        showRemoveButton: false,
                      ),
                    )).toList(),
                  ),
                );
              },
            ),
            if (_showCustomize)
              Positioned(
                bottom: 32,
                right: 32,
                child: FloatingActionButton.extended(
                  onPressed: () {
                    timeZoneProvider.setConfigured(false);
                  },
                  label: const Text('Customize'),
                  icon: const Icon(Icons.edit),
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
