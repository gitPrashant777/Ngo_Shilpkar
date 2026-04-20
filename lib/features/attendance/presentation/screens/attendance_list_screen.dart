import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../data/models/attendance_model.dart';
import '../providers/attendance_provider.dart';
import 'attendance_override_screen.dart';
import '../../../../features/auth/presentation/providers/auth_provider.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../core/constants/app_colors.dart';

class AttendanceListScreen extends StatefulWidget {
  const AttendanceListScreen({super.key});

  @override
  State<AttendanceListScreen> createState() => _AttendanceListScreenState();
}

class _AttendanceListScreenState extends State<AttendanceListScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AttendanceProvider>().fetchAttendanceList(refresh: true);
    });
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      context.read<AttendanceProvider>().loadNextPage();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Color _statusColor(String status) {
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

  String _formatDate(String iso) {
    try {
      return DateFormat('dd MMM yyyy').format(DateTime.parse(iso).toLocal());
    } catch (_) {
      return iso;
    }
  }

  String _formatTime(String? iso) {
    if (iso == null || iso.isEmpty) return '--:--';
    try {
      return DateFormat('hh:mm a').format(DateTime.parse(iso).toLocal());
    } catch (_) {
      return '--:--';
    }
  }

  @override
  Widget build(BuildContext context) {
    final role = context.read<AuthProvider>().role ?? '';
    final isSuperAdmin = role == 'SUPER_ADMIN';
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      appBar: AppBar(
        title: Text(l10n.attendanceRecords),
        backgroundColor: AppColors.appBarBlue,
        foregroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () =>
                context.read<AttendanceProvider>().fetchAttendanceList(refresh: true),
          ),
        ],
      ),
      body: Consumer<AttendanceProvider>(
        builder: (context, provider, _) {
          // ── Error ──────────────────────────────────────────────────────
          if (provider.errorMessage != null &&
              provider.attendanceList.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, color: AppColors.errorRed, size: 48),
                  const SizedBox(height: 12),
                  Text(provider.errorMessage!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: AppColors.errorRed)),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => provider.fetchAttendanceList(refresh: true),
                    child: Text(l10n.retry),
                  ),
                ],
              ),
            );
          }

          // ── Loading initial ────────────────────────────────────────────
          if (provider.isLoading && provider.attendanceList.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          // ── Empty ──────────────────────────────────────────────────────
          if (provider.attendanceList.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.event_busy_rounded,
                      size: 64, color: Colors.grey.shade300),
                  const SizedBox(height: 16),
                  Text(l10n.noAttendanceFound,
                      style: const TextStyle(color: AppColors.textGrey, fontSize: 16)),
                ],
              ),
            );
          }

          // ── List ───────────────────────────────────────────────────────
          return RefreshIndicator(
            onRefresh: () => provider.fetchAttendanceList(refresh: true),
            child: ListView.separated(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount:
                  provider.attendanceList.length + (provider.hasMore ? 1 : 0),
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                if (index == provider.attendanceList.length) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }

                final record = provider.attendanceList[index];
                return _buildRecordCard(
                    record, isSuperAdmin, provider, l10n);
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildRecordCard(AttendanceModel record, bool isSuperAdmin,
      AttendanceProvider provider, AppLocalizations l10n) {
    final statusColor = _statusColor(record.status);
    return Card(
      elevation: 1,
      shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Top row: Name + Status badge ──────────────────────────
            Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: statusColor.withOpacity(0.12),
                  child: Icon(Icons.person, color: statusColor, size: 20),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        record.employeeName ?? 'Employee',
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                      Text(
                        _formatDate(record.date),
                        style: const TextStyle(
                            fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    record.status,
                    style: TextStyle(
                        color: statusColor,
                        fontSize: 11,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 12),

            // ── Details row ───────────────────────────────────────────
            Row(
              children: [
                _buildInfoChip(
                    Icons.login, 'In', _formatTime(record.punchIn),
                    AppColors.statusGreen),
                const SizedBox(width: 8),
                _buildInfoChip(
                    Icons.logout, 'Out', _formatTime(record.punchOut),
                    AppColors.statusRed),
                const SizedBox(width: 8),
                if (record.totalHours != null)
                  _buildInfoChip(
                      Icons.timer,
                      'Hrs',
                      record.totalHours!.toStringAsFixed(1),
                      AppColors.appBarBlue),
              ],
            ),

            // ── Location ──────────────────────────────────────────────
            if (record.location != null &&
                (record.location!.district?.isNotEmpty == true ||
                    record.location!.village?.isNotEmpty == true)) ...[
              const SizedBox(height: 10),
              Row(
                children: [
                  const Icon(Icons.location_on_outlined,
                      size: 14, color: Colors.grey),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      [
                        record.location!.village,
                        record.location!.district
                      ]
                          .where((e) => e != null && e.isNotEmpty)
                          .join(', '),
                      style: const TextStyle(
                          fontSize: 12, color: Colors.grey),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],

            // ── SUPER ADMIN: Override button ──────────────────────────
            if (isSuperAdmin && record.id != null) ...[
              const SizedBox(height: 10),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  icon: const Icon(Icons.edit_note, size: 16),
                  label: Text(l10n.overrideBtn, style: const TextStyle(fontSize: 12)),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.appBarBlue,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: const BorderSide(
                            color: AppColors.appBarBlue, width: 0.8)),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => AttendanceOverrideScreen(
                          record: record,
                        ),
                      ),
                    ).then((_) => provider.fetchAttendanceList(refresh: true));
                  },
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoChip(
      IconData icon, String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 13, color: color),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                '$label: $value',
                style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: color),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
