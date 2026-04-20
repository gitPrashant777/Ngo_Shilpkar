import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../data/models/attendance_model.dart';
import '../providers/attendance_provider.dart';

class AttendanceOverrideScreen extends StatefulWidget {
  final AttendanceModel record;

  const AttendanceOverrideScreen({super.key, required this.record});

  @override
  State<AttendanceOverrideScreen> createState() =>
      _AttendanceOverrideScreenState();
}

class _AttendanceOverrideScreenState extends State<AttendanceOverrideScreen> {
  late DateTime? _punchIn;
  late DateTime? _punchOut;
  late String _status;

  final List<String> _statusOptions = ['PRESENT', 'ABSENT', 'HALF_DAY'];

  @override
  void initState() {
    super.initState();
    _punchIn = _parseDt(widget.record.punchIn);
    _punchOut = _parseDt(widget.record.punchOut);
    _status = _statusOptions.contains(widget.record.status)
        ? widget.record.status
        : 'PRESENT';
  }

  DateTime? _parseDt(String? iso) {
    if (iso == null || iso.isEmpty) return null;
    try {
      return DateTime.parse(iso).toLocal();
    } catch (_) {
      return null;
    }
  }

  String _formatDt(DateTime? dt) {
    if (dt == null) return 'Not set';
    return DateFormat('dd MMM yyyy  hh:mm a').format(dt);
  }

  Future<void> _pickDateTime(bool isPunchIn) async {
    final now = DateTime.now();
    final initial = isPunchIn
        ? (_punchIn ?? now)
        : (_punchOut ?? now);

    final date = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2023),
      lastDate: DateTime(2030),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light(
              primary: Color(0xFF55789A)),
        ),
        child: child!,
      ),
    );
    if (date == null || !mounted) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(initial),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light(
              primary: Color(0xFF55789A)),
        ),
        child: child!,
      ),
    );
    if (time == null || !mounted) return;

    final combined = DateTime(
        date.year, date.month, date.day, time.hour, time.minute);
    setState(() {
      if (isPunchIn) {
        _punchIn = combined;
      } else {
        _punchOut = combined;
      }
    });
  }

  Future<void> _submit() async {
    if (widget.record.id == null) return;

    final payload = <String, dynamic>{
      'status': _status,
    };
    if (_punchIn != null) {
      payload['punchIn'] = _punchIn!.toUtc().toIso8601String();
    }
    if (_punchOut != null) {
      payload['punchOut'] = _punchOut!.toUtc().toIso8601String();
    }

    final provider = context.read<AttendanceProvider>();
    final error =
        await provider.overrideAttendance(widget.record.id!, payload);

    if (!mounted) return;
    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(error),
        backgroundColor: Colors.red.shade700,
        behavior: SnackBarBehavior.floating,
      ));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('✅ Attendance updated successfully'),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ));
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AttendanceProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      appBar: AppBar(
        title: const Text('Override Attendance'),
        backgroundColor: const Color(0xFF55789A),
        foregroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Info Card ─────────────────────────────────────────────────
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF55789A).withOpacity(0.08),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                    color: const Color(0xFF55789A).withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline,
                      color: Color(0xFF55789A), size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.record.employeeName ?? 'Employee',
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                        Text(
                          'Record: ${widget.record.date.isNotEmpty ? DateFormat('dd MMM yyyy').format(DateTime.parse(widget.record.date).toLocal()) : '-'}',
                          style: const TextStyle(
                              color: Colors.grey, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // ── Punch In Picker ───────────────────────────────────────────
            _buildPickerTile(
              label: 'Punch In',
              icon: Icons.login,
              color: const Color(0xFF43A047),
              value: _formatDt(_punchIn),
              onTap: () => _pickDateTime(true),
            ),
            const SizedBox(height: 12),

            // ── Punch Out Picker ──────────────────────────────────────────
            _buildPickerTile(
              label: 'Punch Out',
              icon: Icons.logout,
              color: const Color(0xFFE53935),
              value: _formatDt(_punchOut),
              onTap: () => _pickDateTime(false),
            ),
            const SizedBox(height: 20),

            // ── Status Dropdown ───────────────────────────────────────────
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 8)
                ],
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _status,
                  isExpanded: true,
                  icon: const Icon(Icons.keyboard_arrow_down),
                  items: _statusOptions.map((s) {
                    Color c;
                    switch (s) {
                      case 'PRESENT':
                        c = const Color(0xFF43A047);
                        break;
                      case 'ABSENT':
                        c = const Color(0xFFE53935);
                        break;
                      case 'HALF_DAY':
                        c = const Color(0xFFFF9800);
                        break;
                      default:
                        c = Colors.grey;
                    }
                    return DropdownMenuItem(
                      value: s,
                      child: Row(
                        children: [
                          Container(
                              width: 10,
                              height: 10,
                              decoration: BoxDecoration(
                                  color: c, shape: BoxShape.circle)),
                          const SizedBox(width: 8),
                          Text(s,
                              style:
                                  const TextStyle(fontWeight: FontWeight.w600)),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (v) {
                    if (v != null) setState(() => _status = v);
                  },
                ),
              ),
            ),
            const SizedBox(height: 32),

            // ── Submit Button ─────────────────────────────────────────────
            SizedBox(
              height: 52,
              child: ElevatedButton(
                onPressed: provider.isActionLoading ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF55789A),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  elevation: 2,
                ),
                child: provider.isActionLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2),
                      )
                    : const Text(
                        'Save Override',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPickerTile({
    required String label,
    required IconData icon,
    required Color color,
    required String value,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.05), blurRadius: 8)
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 11,
                          fontWeight: FontWeight.w600)),
                  const SizedBox(height: 2),
                  Text(value,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 14)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}
