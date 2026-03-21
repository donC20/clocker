import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:provider/provider.dart';
import '../providers/time_zone_provider.dart';

class ClockCard extends StatelessWidget {
  final String timeZoneName;
  final bool showRemoveButton;

  const ClockCard({
    super.key,
    required this.timeZoneName,
    this.showRemoveButton = false,
  });

  Color _getColorForTimeZone() {
    final random = Random(timeZoneName.hashCode);
    return Color.fromARGB(
      255,
      random.nextInt(155) + 100,
      random.nextInt(155) + 100,
      random.nextInt(155) + 100,
    );
  }

  @override
  Widget build(BuildContext context) {
    final location = tz.getLocation(timeZoneName);
    final now = tz.TZDateTime.now(location);
    final timeFormat = DateFormat('HH:mm');
    final secondsFormat = DateFormat('ss');
    final dateFormat = DateFormat('E, MMM d, h : mm a');
    final color = _getColorForTimeZone();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: RadialGradient(
          colors: [color.withValues(alpha: 0.3), const Color(0xFF1F1F1F)],
          center: Alignment.topLeft,
          radius: 1.5,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'LOCATION',
                    style: GoogleFonts.poppins(
                        fontSize: 10, color: Colors.white70),
                  ),
                  Flexible(
                    child: Text(
                      'TIMEZONE',
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(
                          fontSize: 10, color: Colors.white70),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    timeZoneName.split('/').last.replaceAll('_', ' '),
                    style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                  Flexible(
                    child: Text(
                      timeZoneName,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(
                          fontSize: 12, color: Colors.white70),
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.bottomLeft,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            timeFormat.format(now),
                            style: GoogleFonts.orbitron(
                              fontSize: 48,
                              fontWeight: FontWeight.bold,
                              color: color,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: Text(
                              secondsFormat.format(now),
                              style: GoogleFonts.orbitron(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white70,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Text(
                'CURRENT DATE',
                style:
                    GoogleFonts.poppins(fontSize: 10, color: Colors.white70),
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        dateFormat.format(now),
                        style: GoogleFonts.poppins(
                            fontSize: 14, color: Colors.white),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                    ),
                  )
                ],
              ),
            ],
          ),
          if (showRemoveButton)
            Positioned(
              top: -8,
              right: -8,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white54, size: 18),
                onPressed: () {
                  Provider.of<TimeZoneProvider>(context, listen: false)
                      .removeTimeZone(timeZoneName);
                },
              ),
            ),
        ],
      ),
    );
  }
}
