import 'dart:async';
import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

void main() {
  tz.initializeTimeZones();
  runApp(
    ChangeNotifierProvider(
      create: (context) => TimeZoneProvider(),
      child: const MyApp(),
    ),
  );
}

class TimeZoneProvider with ChangeNotifier {
  final List<String> _selectedTimeZones = [
    'Asia/Kolkata',
    'America/Toronto',
    'Europe/London',
    'UTC',
  ];

  List<String> get selectedTimeZones => _selectedTimeZones;

  void addTimeZone(String timeZone) {
    if (!_selectedTimeZones.contains(timeZone)) {
      _selectedTimeZones.add(timeZone);
      notifyListeners();
    }
  }

  void removeTimeZone(String timeZone) {
    _selectedTimeZones.remove(timeZone);
    notifyListeners();
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'World Clock',
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF121212),
        textTheme: GoogleFonts.poppinsTextTheme(
          Theme.of(context).textTheme,
        ).apply(
          bodyColor: Colors.white,
          displayColor: Colors.white,
        ),
      ),
      home: const WorldClockScreen(),
    );
  }
}

class WorldClockScreen extends StatefulWidget {
  const WorldClockScreen({super.key});

  @override
  State<WorldClockScreen> createState() => _WorldClockScreenState();
}

class _WorldClockScreenState extends State<WorldClockScreen> {
  late Timer _timer;

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
    super.dispose();
  }

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
          SafeArea(
            child: GridView.builder(
              padding: const EdgeInsets.all(20.0),
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 300,
                childAspectRatio: 1.5,
                crossAxisSpacing: 20,
                mainAxisSpacing: 20,
              ),
              itemCount: timezones.length + 1,
              itemBuilder: (context, index) {
                if (index == timezones.length) {
                  return const AddTimeZoneNode();
                }
                final timeZoneName = timezones[index];
                return ClockCard(
                  timeZoneName: timeZoneName,
                  key: ValueKey(timeZoneName),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class ClockCard extends StatelessWidget {
  final String timeZoneName;

  const ClockCard({super.key, required this.timeZoneName});

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
    final dateFormat = DateFormat('E, MMM d');
    final color = _getColorForTimeZone();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: RadialGradient(
          colors: [color.withOpacity(0.3), const Color(0xFF1F1F1F)],
          center: Alignment.topLeft,
          radius: 1.5,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
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
                  Text(
                    'TIMEZONE',
                    style: GoogleFonts.poppins(
                        fontSize: 10, color: Colors.white70),
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
                  Text(
                    timeZoneName,
                    style: GoogleFonts.poppins(
                        fontSize: 12, color: Colors.white70),
                  ),
                ],
              ),
              const Spacer(),
              Row(
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
                  Text(
                    dateFormat.format(now),
                    style: GoogleFonts.poppins(
                        fontSize: 14, color: Colors.white),
                  ),
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
                'ADD TIMEZONE NODE',
                style: TextStyle(color: Colors.white54, fontSize: 12),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class TimeZoneListScreen extends StatefulWidget {
  const TimeZoneListScreen({super.key});

  @override
  _TimeZoneListScreenState createState() => _TimeZoneListScreenState();
}

class _TimeZoneListScreenState extends State<TimeZoneListScreen> {
  String _searchTerm = '';

  @override
  Widget build(BuildContext context) {
    final timeZoneProvider =
        Provider.of<TimeZoneProvider>(context, listen: false);
    final allTimeZones = tz.timeZoneDatabase.locations.keys
        .where((tz) => tz.toLowerCase().contains(_searchTerm.toLowerCase()))
        .toList();

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        title: const Text('Select a Time Zone'),
        backgroundColor: const Color(0xFF1F1F1F),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              onChanged: (value) {
                setState(() {
                  _searchTerm = value;
                });
              },
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Search...',
                hintStyle: const TextStyle(color: Colors.white54),
                prefixIcon: const Icon(Icons.search, color: Colors.white54),
                filled: true,
                fillColor: const Color(0xFF1F1F1F),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: allTimeZones.length,
              itemBuilder: (context, index) {
                final timeZoneName = allTimeZones[index];
                return ListTile(
                  title: Text(
                    timeZoneName.replaceAll('_', ' '),
                    style: const TextStyle(color: Colors.white),
                  ),
                  onTap: () {
                    timeZoneProvider.addTimeZone(timeZoneName);
                    Navigator.pop(context);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class DottedBorder extends StatelessWidget {
  final Widget child;
  final Color color;
  final double strokeWidth;
  final Radius radius;
  final List<double> dashPattern;

  const DottedBorder({
    super.key,
    required this.child,
    this.color = Colors.black,
    this.strokeWidth = 1,
    this.radius = const Radius.circular(0),
    this.dashPattern = const [3, 1],
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _DottedPainter(
        color: color,
        strokeWidth: strokeWidth,
        radius: radius,
        dashPattern: dashPattern,
      ),
      child: child,
    );
  }
}

class _DottedPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final Radius radius;
  final List<double> dashPattern;

  _DottedPainter({
    required this.color,
    required this.strokeWidth,
    required this.radius,
    required this.dashPattern,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final Path path = Path();
    path.addRRect(RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      radius,
    ));

    final Path dashPath = Path();
    double distance = 0.0;
    for (final PathMetric pathMetric in path.computeMetrics()) {
      while (distance < pathMetric.length) {
        dashPath.addPath(
          pathMetric.extractPath(distance, distance + dashPattern[0]),
          Offset.zero,
        );
        distance += dashPattern[0] + dashPattern[1];
      }
    }
    canvas.drawPath(dashPath, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class NoisePainter extends CustomPainter {
  final Random _random = Random();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white.withOpacity(0.03);
    for (int i = 0; i < 5000; i++) {
      canvas.drawRect(
        Rect.fromLTWH(
          _random.nextDouble() * size.width,
          _random.nextDouble() * size.height,
          1,
          1,
        ),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
