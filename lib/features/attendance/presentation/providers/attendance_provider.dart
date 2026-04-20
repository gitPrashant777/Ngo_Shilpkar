import 'dart:async';
import 'package:flutter/material.dart';
import '../../data/models/attendance_model.dart';
import '../../data/repository/attendance_repository.dart';

class AttendanceProvider extends ChangeNotifier {
  final AttendanceRepository _repository = AttendanceRepository();

  // ── Today state ─────────────────────────────────────────────────────────
  AttendanceModel? _todayRecord;
  AttendanceModel? get todayRecord => _todayRecord;

  /// null = no record today
  String? get todayStatus => _todayRecord?.status;

  // ── List state ──────────────────────────────────────────────────────────
  List<AttendanceModel> _attendanceList = [];
  List<AttendanceModel> get attendanceList => _attendanceList;

  int _currentPage = 1;
  int _totalPages = 1;
  int get currentPage => _currentPage;
  int get totalPages => _totalPages;
  bool get hasMore => _currentPage < _totalPages;

  // ── Loading / Error ─────────────────────────────────────────────────────
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isActionLoading = false;
  bool get isActionLoading => _isActionLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  bool _locationPermissionDenied = false;
  bool get locationPermissionDenied => _locationPermissionDenied;

  // ── Live timer ──────────────────────────────────────────────────────────
  Timer? _timer;
  Duration _elapsed = Duration.zero;
  Duration get elapsed => _elapsed;

  void _startTimer() {
    _timer?.cancel();
    if (_todayRecord?.punchIn != null) {
      try {
        final punchInTime = DateTime.parse(_todayRecord!.punchIn!).toLocal();
        _elapsed = DateTime.now().difference(punchInTime);
      } catch (_) {
        _elapsed = Duration.zero;
      }
    }
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      _elapsed += const Duration(seconds: 1);
      notifyListeners();
    });
  }

  void _stopTimer() {
    _timer?.cancel();
    _timer = null;
  }

  // ─── Fetch Today ─────────────────────────────────────────────────────────
  Future<void> fetchTodayAttendance() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _todayRecord = await _repository.getTodayAttendance();
      if (todayStatus == 'ACTIVE') {
        _startTimer();
      } else {
        _stopTimer();
      }
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ─── Fetch List (paginated) ───────────────────────────────────────────────
  Future<void> fetchAttendanceList({bool refresh = false}) async {
    if (refresh) {
      _currentPage = 1;
      _attendanceList = [];
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result =
          await _repository.getAttendanceList(page: _currentPage, limit: 10);
      final records = result['records'] as List<AttendanceModel>;

      if (refresh) {
        _attendanceList = records;
      } else {
        _attendanceList.addAll(records);
      }

      _totalPages = result['totalPages'] as int;
      _currentPage = result['page'] as int;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadNextPage() async {
    if (hasMore && !_isLoading) {
      _currentPage++;
      await fetchAttendanceList();
    }
  }

  // ─── Punch In ─────────────────────────────────────────────────────────────
  /// Returns an error message string on failure, null on success.
  Future<String?> punchIn() async {
    _locationPermissionDenied = false;
    _isActionLoading = true;
    notifyListeners();

    try {
      final result = await _repository.punchIn();
      if (result['success'] == true) {
        await fetchTodayAttendance();
        return null;
      } else {
        return result['message']?.toString() ?? 'Punch In Failed';
      }
    } catch (e) {
      final msg = e.toString().replaceAll('Exception: ', '');
      if (msg == 'location_permission_denied') {
        _locationPermissionDenied = true;
        return 'Location permission required for attendance.';
      }
      return msg;
    } finally {
      _isActionLoading = false;
      notifyListeners();
    }
  }

  // ─── Punch Out ────────────────────────────────────────────────────────────
  /// Returns an error message string on failure, null on success.
  Future<String?> punchOut() async {
    _locationPermissionDenied = false;
    _isActionLoading = true;
    notifyListeners();

    try {
      final result = await _repository.punchOut();
      if (result['success'] == true) {
        _stopTimer();
        await fetchTodayAttendance();
        return null;
      } else {
        // e.g. "Minimum working hours not completed"
        return result['message']?.toString() ?? 'Punch Out Failed';
      }
    } catch (e) {
      final msg = e.toString().replaceAll('Exception: ', '');
      if (msg == 'location_permission_denied') {
        _locationPermissionDenied = true;
        return 'Location permission required for attendance.';
      }
      return msg;
    } finally {
      _isActionLoading = false;
      notifyListeners();
    }
  }

  // ─── Override (Super Admin) ───────────────────────────────────────────────
  Future<String?> overrideAttendance(
      String attendanceId, Map<String, dynamic> data) async {
    _isActionLoading = true;
    notifyListeners();
    try {
      await _repository.overrideAttendance(attendanceId, data);
      await fetchAttendanceList(refresh: true);
      return null;
    } catch (e) {
      return e.toString().replaceAll('Exception: ', '');
    } finally {
      _isActionLoading = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _stopTimer();
    super.dispose();
  }
}
