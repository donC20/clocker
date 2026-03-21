import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/time_zone_provider.dart';
import '../services/notification_service.dart';
import 'package:timezone/timezone.dart' as tz;

class AlarmDialog extends StatefulWidget {
  final TimeZoneItem item;
  final String? timeZoneName; // Specific timezone for merged cards

  const AlarmDialog({super.key, required this.item, this.timeZoneName});

  @override
  State<AlarmDialog> createState() => _AlarmDialogState();
}

class _AlarmDialogState extends State<AlarmDialog> {
  late List<String> _alarms;

  @override
  void initState() {
    super.initState();
    _alarms = List.from(widget.item.alarms);
  }

  Future<void> _addAlarm() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Colors.deepPurpleAccent,
              onPrimary: Colors.white,
              surface: Color(0xFF1E1E2C),
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      final String timeString = '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
      if (!_alarms.contains(timeString)) {
        setState(() {
          _alarms.add(timeString);
          _alarms.sort();
        });
        _saveAndSchedule();
      }
    }
  }

  void _removeAlarm(String timeString) {
    setState(() {
      _alarms.remove(timeString);
    });
    _saveAndSchedule();
  }

  Future<void> _saveAndSchedule() async {
    final provider = Provider.of<TimeZoneProvider>(context, listen: false);
    
    // Update provider
    await provider.updateItemMetadata(
      widget.item,
      alarms: _alarms,
    );
    
    // Schedule notifications
    final tzName = widget.timeZoneName ?? widget.item.timeZoneNames.first;
    for (int i = 0; i < 5; i++) {
        await NotificationService().cancelAlarm(tzName.hashCode + i);
    }

    final location = tz.getLocation(tzName);
    final nowInTz = tz.TZDateTime.now(location);

    for (int i = 0; i < _alarms.length; i++) {
      final parts = _alarms[i].split(':');
      final hour = int.parse(parts[0]);
      final minute = int.parse(parts[1]);
      
      tz.TZDateTime scheduledDate = tz.TZDateTime(location, nowInTz.year, nowInTz.month, nowInTz.day, hour, minute);
      
      if (scheduledDate.isBefore(nowInTz)) {
        scheduledDate = scheduledDate.add(const Duration(days: 1));
      }
      
      final alarmId = tzName.hashCode + i;
      final city = widget.item.customLabel ?? tzName.split('/').last.replaceAll('_', ' ');

      await NotificationService().scheduleAlarm(
        id: alarmId,
        title: 'Alarm for $city',
        body: 'It is now ${_alarms[i]} in $city.',
        scheduledTime: scheduledDate,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final tzName = widget.timeZoneName ?? widget.item.timeZoneNames.first;
    final city = widget.item.customLabel ?? tzName.split('/').last.replaceAll('_', ' ');

    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E2C).withValues(alpha: 0.9),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white.withValues(alpha: 0.1), width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.5),
              blurRadius: 20,
              spreadRadius: 5,
            )
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Alarms: $city',
                  style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white54),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_alarms.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 24.0),
                child: Center(
                  child: Text(
                    'No alarms set.',
                    style: GoogleFonts.outfit(color: Colors.white54),
                  ),
                ),
              )
            else
              ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 250),
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: _alarms.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(
                        _alarms[index],
                        style: GoogleFonts.outfit(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                        onPressed: () => _removeAlarm(_alarms[index]),
                      ),
                    );
                  },
                ),
              ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _addAlarm,
              icon: const Icon(Icons.add_alarm),
              label: const Text('Add Alarm'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurpleAccent,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
