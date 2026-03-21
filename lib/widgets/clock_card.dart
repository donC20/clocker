import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:provider/provider.dart';
import '../providers/time_zone_provider.dart';

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
    final random = Random(timeZoneName.hashCode);
    return Color.fromARGB(
      255,
      random.nextInt(155) + 100,
      random.nextInt(155) + 100,
      random.nextInt(155) + 100,
    );
  }

  Widget _buildSingleClock(String timeZoneName, {bool isMerged = false}) {
    final location = tz.getLocation(timeZoneName);
    final now = tz.TZDateTime.from(_currentTime, location);
    final timeFormat = DateFormat('HH:mm');
    final secondsFormat = DateFormat('ss');
    final dateFormat = DateFormat('E, MMM d, h : mm a');
    final color = _getColorForTimeZone(timeZoneName);
    
    final double cityFontSize = isMerged ? 12 : 16;
    final double timeFontSize = isMerged ? 32 : 48;
    final double secondsFontSize = isMerged ? 14 : 20;

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
            if (!isMerged)
            Flexible(
              child: Text(
                'TIMEZONE',
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.poppins(fontSize: 8, color: Colors.white70),
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                timeZoneName.split('/').last.replaceAll('_', ' '),
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
        const Spacer(),
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.bottomLeft,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                timeFormat.format(now),
                style: GoogleFonts.orbitron(
                  fontSize: timeFontSize,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              const SizedBox(width: 4),
              Padding(
                padding: const EdgeInsets.only(bottom: 6.0),
                child: Text(
                  secondsFormat.format(now),
                  style: GoogleFonts.orbitron(
                    fontSize: secondsFontSize,
                    fontWeight: FontWeight.bold,
                    color: Colors.white70,
                  ),
                ),
              ),
            ],
          ),
        ),
        const Spacer(),
        Text(
          'CURRENT DATE',
          style: GoogleFonts.poppins(fontSize: 8, color: Colors.white70),
        ),
        const SizedBox(height: 2),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  dateFormat.format(now),
                  style: GoogleFonts.poppins(fontSize: 10, color: Colors.white),
                ),
              ),
            ),
            const SizedBox(width: 4),
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

    return Container(
      decoration: BoxDecoration(
        gradient: RadialGradient(
          colors: [
            color1.withValues(alpha: 0.2),
            const Color(0xFF1F1F1F)
          ],
          center: Alignment.topLeft,
          radius: 1.5,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
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
    );
  }
}
