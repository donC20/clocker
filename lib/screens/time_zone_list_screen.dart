import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:timezone/timezone.dart' as tz;
import '../providers/time_zone_provider.dart';

class TimeZoneListScreen extends StatefulWidget {
  const TimeZoneListScreen({super.key});

  @override
  State<TimeZoneListScreen> createState() => _TimeZoneListScreenState();
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
