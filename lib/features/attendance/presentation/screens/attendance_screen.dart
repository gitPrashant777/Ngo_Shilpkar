import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../l10n/app_localizations.dart';
import '../providers/attendance_provider.dart';
import 'attendance_list_screen.dart';

class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({super.key});

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AttendanceProvider>().fetchTodayAttendance();
    });
  }

  String _formatTimer(Duration d) {
    final h = d.inHours.toString().padLeft(2, '0');
    final m = (d.inMinutes % 60).toString().padLeft(2, '0');
    final s = (d.inSeconds % 60).toString().padLeft(2, '0');
    return '$h:$m:$s';
  }

  String _formatTime(String? iso) {
    if (iso == null || iso.isEmpty) return '--:--';
    try {
      return DateFormat('hh:mm a').format(DateTime.parse(iso).toLocal());
    } catch (_) {
      return '--:--';
    }
  }

  Future<void> _handlePunchIn(AttendanceProvider provider) async {
    final l10n = AppLocalizations.of(context)!;
    final error = await provider.punchIn();
    if (!mounted) return;
    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(error),
        backgroundColor: AppColors.errorRed,
        behavior: SnackBarBehavior.floating,
      ));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(l10n.punchInSuccess),
        backgroundColor: AppColors.statusGreen,
        behavior: SnackBarBehavior.floating,
      ));
    }
  }

  Future<void> _handlePunchOut(AttendanceProvider provider) async {
    final l10n = AppLocalizations.of(context)!;
    final error = await provider.punchOut();
    if (!mounted) return;
    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(error),
        backgroundColor: AppColors.statusOrange,
        behavior: SnackBarBehavior.floating,
      ));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(l10n.punchOutSuccess),
        backgroundColor: AppColors.statusGreen,
        behavior: SnackBarBehavior.floating,
      ));
    }
  }

  Color _statusColor(String? status) {
    switch (status) {
      case 'PRESENT':
        return AppColors.statusGreen;
      case 'ACTIVE':
        return AppColors.statusActiveBlue;
      case 'ABSENT':
        return AppColors.statusRed;
      case 'HALF_DAY':
        return AppColors.statusOrange;
      default:
        return AppColors.textGrey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      appBar: AppBar(
        title: Text(l10n.attendance),
        backgroundColor: AppColors.appBarBlue,
        foregroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.list_alt_rounded),
            tooltip: l10n.viewAllRecords,
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => const AttendanceListScreen()),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () =>
                context.read<AttendanceProvider>().fetchTodayAttendance(),
          ),
        ],
      ),
      body: Consumer<AttendanceProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading && provider.todayRecord == null) {
            return const Center(child: CircularProgressIndicator());
          }

          final status = provider.todayStatus;
          final record = provider.todayRecord;
          final isActive = status == 'ACTIVE';
          final isCompleted = status == 'PRESENT' || status == 'HALF_DAY';

          return RefreshIndicator(
            onRefresh: provider.fetchTodayAttendance,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // ── Date/Greeting Banner ──────────────────────────────
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 16),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppColors.appBarBlue, AppColors.darkNavyBlue],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.calendar_today,
                            color: Colors.white70, size: 18),
                        const SizedBox(width: 8),
                        Text(
                          DateFormat('EEEE, dd MMMM yyyy')
                              .format(DateTime.now()),
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // ── Status Card ───────────────────────────────────────
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black.withOpacity(0.07),
                            blurRadius: 16,
                            offset: const Offset(0, 4))
                      ],
                    ),
                    child: Column(
                      children: [
                        // Status badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 6),
                          decoration: BoxDecoration(
                            color:
                                _statusColor(status).withOpacity(0.12),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            status ?? l10n.noRecord,
                            style: TextStyle(
                              color: _statusColor(status),
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Timer (only when ACTIVE)
                        if (isActive) ...[
                          Text(
                            _formatTimer(provider.elapsed),
                            style: const TextStyle(
                              fontSize: 44,
                              fontWeight: FontWeight.bold,
                              color: AppColors.statusActiveBlue,
                              fontFeatures: [FontFeature.tabularFigures()],
                            ),
                          ),
                          Text(l10n.timeSincePunchIn,
                              style:
                                  const TextStyle(color: AppColors.textGrey, fontSize: 12)),
                          const SizedBox(height: 16),
                        ],

                        // Punch times row
                        if (record != null)
                          Row(
                            mainAxisAlignment:
                                MainAxisAlignment.spaceEvenly,
                            children: [
                              _buildTimeItem(
                                  l10n.punchIn.toUpperCase(),
                                  _formatTime(record.punchIn),
                                  AppColors.statusGreen),
                              Container(
                                  height: 32,
                                  width: 1,
                                  color: AppColors.dividerGrey),
                              _buildTimeItem(
                                  l10n.punchOut.toUpperCase(),
                                  _formatTime(record.punchOut),
                                  AppColors.statusRed),
                            ],
                          ),

                        if (isCompleted && record?.totalHours != null) ...[
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 12),
                            decoration: BoxDecoration(
                              color: AppColors.statusGreen.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                  color: AppColors.statusGreen.withOpacity(0.3)),
                            ),
                            child: Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.check_circle,
                                    color: AppColors.statusGreen),
                                const SizedBox(width: 8),
                                Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(l10n.attendanceCompleted,
                                        style: const TextStyle(
                                            color: AppColors.statusGreen,
                                            fontWeight:
                                                FontWeight.bold)),
                                    Text(
                                      l10n.totalHoursLabel(record!.totalHours!.toStringAsFixed(1)),
                                      style: const TextStyle(
                                          color: AppColors.statusGreen,
                                          fontSize: 12),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],

                        const SizedBox(height: 24),

                        // ── Location permission warning ────────────────
                        if (provider.locationPermissionDenied)
                          Container(
                            padding: const EdgeInsets.all(12),
                            margin:
                                const EdgeInsets.only(bottom: 16),
                            decoration: BoxDecoration(
                              color: AppColors.statusOrange.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                  color: AppColors.statusOrange.withOpacity(0.3)),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.location_off,
                                    color: AppColors.statusOrange, size: 20),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    l10n.locationPermissionRequired,
                                    style: const TextStyle(
                                        color: AppColors.statusOrange,
                                        fontSize: 13),
                                  ),
                                ),
                              ],
                            ),
                          ),

                        // ── Action Button ──────────────────────────────
                        if (isCompleted)
                          const SizedBox.shrink()
                        else
                          SizedBox(
                            width: double.infinity,
                            height: 52,
                            child: ElevatedButton.icon(
                              icon: provider.isActionLoading
                                  ? const SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 2),
                                    )
                                  : Icon(
                                      isActive
                                          ? Icons.logout
                                          : Icons.login,
                                      color: Colors.white),
                              label: Text(
                                provider.isActionLoading
                                    ? l10n.gettingLocation
                                    : (isActive
                                        ? l10n.punchOut.toUpperCase()
                                        : l10n.punchIn.toUpperCase()),
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: Colors.white),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: provider.isActionLoading
                                    ? AppColors.textGrey
                                    : (isActive
                                        ? AppColors.statusRed
                                        : AppColors.statusGreen),
                                shape: RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.circular(12)),
                                elevation: 2,
                              ),
                              onPressed: provider.isActionLoading ||
                                      isCompleted
                                  ? null
                                  : () => isActive
                                      ? _handlePunchOut(provider)
                                      : _handlePunchIn(provider),
                            ),
                          ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // ── View All Button ───────────────────────────────────
                  OutlinedButton.icon(
                    icon: const Icon(Icons.history),
                    label: Text(l10n.viewFullHistory),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: const BorderSide(color: AppColors.appBarBlue),
                      foregroundColor: AppColors.appBarBlue,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const AttendanceListScreen()),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTimeItem(String label, String time, Color color) {
    return Column(
      children: [
        Text(label,
            style: TextStyle(
                color: color,
                fontSize: 11,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5)),
        const SizedBox(height: 4),
        Text(time,
            style: const TextStyle(
                fontSize: 16, fontWeight: FontWeight.w700)),
      ],
    );
  }
}
