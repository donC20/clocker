import 'dart:async';
import 'dart:math';
import 'dart:ui' show ImageFilter;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'analog_clock_painter.dart';
import 'celestial_indicator.dart';
import 'package:intl/intl.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:provider/provider.dart';
import '../providers/time_zone_provider.dart';
import '../screens/alarm_dialog.dart';

class ClockCard extends StatefulWidget {
  final TimeZoneItem item;
  final bool showRemoveButton;

  const ClockCard({
    super.key,
    required this.item,
    this.showRemoveButton = false,
  });

  @override
  State<ClockCard> createState() => _ClockCardState();
}

class _ClockCardState extends State<ClockCard> {
  late Timer _timer;
  DateTime _currentTime = DateTime.now();

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _currentTime = DateTime.now();
        });
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  Color _getColorForTimeZone(String timeZoneName) {
    // 1. Day/Night Logic takes high priority if enabled
    if (widget.item.isDayNightEnabled == true) {
      final location = tz.getLocation(timeZoneName);
      final localNow = tz.TZDateTime.from(_currentTime, location);
      final hour = localNow.hour;
      if (hour < 6 || hour >= 18) {
        return const Color(0xFF7B1FA2); // Night: Purple
      } else {
        return const Color(0xFFFFB300); // Day: Amber
      }
    }

    // 2. Custom Color Picker next
    if (widget.item.customColorValue != null) {
      return Color(widget.item.customColorValue!);
    }
    
    // 3. Theme Presets
    if (widget.item.themePreset == 'matrix') return const Color(0xFF39FF14);
    if (widget.item.themePreset == 'solarized') return const Color(0xFFFFD700);
    if (widget.item.themePreset == 'midnight') return const Color(0xFFC66AF6);

    final random = Random(timeZoneName.hashCode);
    return Color.fromARGB(
      255,
      random.nextInt(155) + 100,
      random.nextInt(155) + 100,
      random.nextInt(155) + 100,
    );
  }

  TextStyle _getClockStyle(Color color, double fontSize, bool isBold) {
    final preset = widget.item.themePreset;
    if (preset == 'matrix') {
      return GoogleFonts.jetBrainsMono(
        fontSize: fontSize,
        fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
        color: color,
      );
    }
    if (preset == 'solarized') {
      return GoogleFonts.roboto(
        fontSize: fontSize,
        fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
        color: color,
      );
    }
    if (preset == 'midnight') {
      return GoogleFonts.montserrat(
        fontSize: fontSize,
        fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
        color: color,
      );
    }
    // Default: Orbitron
    return GoogleFonts.orbitron(
      fontSize: fontSize,
      fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
      color: color,
    );
  }
  Widget _buildSingleClock(String timeZoneName, {bool isMerged = false}) {
    final location = tz.getLocation(timeZoneName);
    final now = tz.TZDateTime.from(_currentTime, location);
    
    // Calculate time difference
    final localSystemNow = DateTime.now();
    final diffMinutes = now.timeZoneOffset.inMinutes - localSystemNow.timeZoneOffset.inMinutes;
    final diffHours = diffMinutes / 60.0;
    
    String diffString = '';
    if (diffHours == 0) {
      diffString = 'LOCAL';
    } else {
      final sign = diffHours > 0 ? '+' : '';
      final formattedHours = diffHours == diffHours.toInt() 
          ? diffHours.toInt().toString() 
          : diffHours.toStringAsFixed(1);
      diffString = '$sign${formattedHours}H';
    }

    final timeFormat = DateFormat('HH:mm');
    final secondsFormat = DateFormat('ss');
    final dateFormat = DateFormat('E, MMM d, h : mm a');
    final color = _getColorForTimeZone(timeZoneName);
    
    final String city = (!isMerged && widget.item.customLabel != null) 
        ? widget.item.customLabel! 
        : timeZoneName.split('/').last.replaceAll('_', ' ');

    final double cityFontSize = isMerged ? 12 : 16;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'LOCATION',
              style: GoogleFonts.poppins(fontSize: 8, color: Colors.white70),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (widget.item.isDayNightEnabled == true)
                  Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: CelestialIndicator(
                      type: now.hour >= 6 && now.hour < 18 ? CelestialType.sun : CelestialType.moon,
                      size: isMerged ? 14 : 18,
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: InkWell(
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (context) => AlarmDialog(
                          item: widget.item,
                          timeZoneName: timeZoneName,
                        ),
                      );
                    },
                    child: Icon(
                      widget.item.alarms.isNotEmpty ? Icons.notifications_active : Icons.notifications_none,
                      size: 16,
                      color: widget.item.alarms.isNotEmpty ? Colors.amber : Colors.white70,
                    ),
                  ),
                ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      diffString,
                      style: GoogleFonts.poppins(
                        fontSize: 8, 
                        fontWeight: FontWeight.bold,
                        color: Colors.white70,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 2),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                city,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.poppins(
                    fontSize: cityFontSize,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
            ),
            if (!isMerged)
            Flexible(
              child: Text(
                timeZoneName,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.poppins(fontSize: 10, color: Colors.white70),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (widget.item.isAnalog == true)
          Expanded(
            child: Center(
              child: AspectRatio(
                aspectRatio: 1,
                child: CustomPaint(
                  painter: AnalogClockPainter(dateTime: now, color: color),
                ),
              ),
            ),
          )
        else
          Expanded(
            child: FittedBox(
              fit: BoxFit.contain,
              alignment: Alignment.centerLeft,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    timeFormat.format(now),
                    style: _getClockStyle(color, isMerged ? 32 : 48, true),
                  ),
                  const SizedBox(width: 4),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 6.0),
                    child: Text(
                      secondsFormat.format(now),
                      style: _getClockStyle(color, isMerged ? 14 : 20, false),
                    ),
                  ),
                ],
              ),
            ),
          ),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                dateFormat.format(now),
                style: GoogleFonts.poppins(
                    fontSize: isMerged ? 10 : 12, color: Colors.white60),
              ),
            ),
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
            )
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isMerged = widget.item.isMerged;
    final color1 = _getColorForTimeZone(widget.item.timeZoneNames[0]);

    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          margin: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: Colors.white.withValues(alpha: 0.05),
            border: Border.all(color: color1.withValues(alpha: 0.2), width: 1),
            boxShadow: [
              BoxShadow(
                color: color1.withValues(alpha: 0.1),
                blurRadius: 20,
                spreadRadius: 2,
              )
            ],
          ),
          child: Stack(
            children: [
              // Subtle World Map/Globe Overlay
              Positioned(
                right: -30,
                bottom: -30,
                child: Icon(
                  Icons.public,
                  size: 180,
                  color: color1.withValues(alpha: 0.04), // Very subtle
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (!isMerged && widget.item.customLabel != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Text(
                          widget.item.customLabel!.toUpperCase(),
                          style: GoogleFonts.poppins(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Color(widget.item.customColorValue ?? 0xFFC66AF6).withValues(alpha: 200 / 255.0),
                            letterSpacing: 2,
                            shadows: [const Shadow(color: Colors.black, blurRadius: 4)],
                          ),
                        ),
                      ),
                    Expanded(
                      child: isMerged
                          ? Row(
                              children: [
                                Expanded(child: _buildSingleClock(widget.item.timeZoneNames[0], isMerged: true)),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                  child: Container(
                                    width: 1,
                                    height: double.infinity,
                                    color: Colors.white10,
                                  ),
                                ),
                                Expanded(child: _buildSingleClock(widget.item.timeZoneNames[1], isMerged: true)),
                              ],
                            )
                          : _buildSingleClock(widget.item.timeZoneNames[0]),
                    ),
                  ],
                ),
              ),
          if (widget.showRemoveButton)
            Positioned(
              top: -4,
              right: -4,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white54, size: 16),
                onPressed: () {
                  Provider.of<TimeZoneProvider>(context, listen: false)
                      .removeTimeZone(widget.item);
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
