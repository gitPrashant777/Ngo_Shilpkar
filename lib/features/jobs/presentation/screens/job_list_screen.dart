import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/widgets/form_fields.dart';
import '../../../../shared/widgets/job_info_row.dart';
import '../../data/models/job_model.dart';
import '../providers/job_provider.dart';
import 'job_detail_screen.dart';

class JobListScreen extends StatefulWidget {
  const JobListScreen({super.key});

  @override
  State<JobListScreen> createState() => _JobListScreenState();
}

class _JobListScreenState extends State<JobListScreen> {
  final TextEditingController _cityController = TextEditingController();
  String? _selectedCategory;
  final List<String> _categories = ['TECH', 'HEALTH', 'EDUCATION', 'FIELD_WORK', 'OTHER'];
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<JobProvider>(context, listen: false).fetchJobs(refresh: true);
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _cityController.dispose();
    super.dispose();
  }

  void _applyFilters() {
    Provider.of<JobProvider>(context, listen: false).fetchJobs(
      city: _cityController.text.trim().isNotEmpty ? _cityController.text.trim() : null,
      category: _selectedCategory,
      refresh: true,
    );
  }

  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return StatefulBuilder(builder: (ctx, setSheetState) {
          return Padding(
            padding: EdgeInsets.only(
              left: 20, right: 20, top: 20,
              bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Filter Jobs",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                LabeledTextField(
                  label: AppLocalizations.of(ctx)!.city,
                  controller: _cityController,
                  hint: "e.g. Pune",
                ),
                LabeledDropdown<String>(
                  label: AppLocalizations.of(ctx)!.category,
                  value: _selectedCategory,
                  items: [
                    const DropdownMenuItem(value: null, child: Text("All Categories")),
                    ..._categories.map((c) => DropdownMenuItem(value: c, child: Text(c))),
                  ],
                  onChanged: (val) => setSheetState(() => _selectedCategory = val),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          _cityController.clear();
                          setState(() => _selectedCategory = null);
                          Navigator.pop(ctx);
                          _applyFilters();
                        },
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: AppColors.appBarBlue),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        child: Text(AppLocalizations.of(ctx)!.clear),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          setState(() {});
                          Navigator.pop(ctx);
                          _applyFilters();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.appBarBlue,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        child: Text(
                          AppLocalizations.of(ctx)!.apply,
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: AppColors.backgroundGrey,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        titleSpacing: 16,
        title: Text(
          l10n.shilpkarFoundation,
          style: const TextStyle(
            color: AppColors.primaryBlue,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list, color: AppColors.primaryBlue),
            onPressed: _showFilterSheet,
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: Consumer<JobProvider>(
          builder: (context, provider, child) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── "Jobs" heading ──────────────────────────────────────────
                const Padding(
                  padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Text(
                    "Jobs",
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),

                // ── Active filter chips ────────────────────────────────────
                if (_cityController.text.isNotEmpty || _selectedCategory != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Wrap(
                      spacing: 8,
                      children: [
                        if (_cityController.text.isNotEmpty)
                          Chip(
                            label: Text(_cityController.text),
                            deleteIcon: const Icon(Icons.close, size: 14),
                            onDeleted: () { _cityController.clear(); _applyFilters(); },
                          ),
                        if (_selectedCategory != null)
                          Chip(
                            label: Text(_selectedCategory!),
                            deleteIcon: const Icon(Icons.close, size: 14),
                            onDeleted: () { setState(() => _selectedCategory = null); _applyFilters(); },
                          ),
                      ],
                    ),
                  ),

                // ── List / Loading / Empty ──────────────────────────────────
                Expanded(
                  child: provider.isLoading && provider.jobs.isEmpty
                      ? const Center(child: CircularProgressIndicator())
                      : provider.jobs.isEmpty
                          ? Center(
                              child: Text(
                                l10n.noJobsFound,
                                style: const TextStyle(color: AppColors.textSecondary),
                              ),
                            )
                          : RefreshIndicator(
                              onRefresh: () async => _applyFilters(),
                              child: ListView.builder(
                                controller: _scrollController,
                                padding: const EdgeInsets.fromLTRB(16, 4, 16, 20),
                                itemCount: provider.jobs.length,
                                itemBuilder: (context, index) {
                                  return _JobCard(
                                    job: provider.jobs[index],
                                    l10n: l10n,
                                    onTap: () => Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => JobDetailScreen(job: provider.jobs[index]),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                ),

                // ── Pagination ────────────────────────────────────────────
                _JobPaginationBar(
                  currentPage: provider.jobPage,
                  totalPages: provider.jobTotalPages,
                  total: provider.jobTotal,
                  isLoading: provider.isLoading,
                  onPageChanged: (p) => provider.goToJobPage(p),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

// ─── Job Card ──────────────────────────────────────────────────────────────────
class _JobCard extends StatelessWidget {
  final JobModel job;
  final AppLocalizations l10n;
  final VoidCallback onTap;

  const _JobCard({required this.job, required this.l10n, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final stipend = job.stipend.isNotEmpty ? '₹${job.stipend}' : l10n.unpaid;
    final duration = job.duration.isNotEmpty ? job.duration : 'N/A';

    return Card(
      elevation: 1.5,
      shadowColor: AppColors.dividerGrey,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.only(bottom: 12),
      color: AppColors.cardBackground,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Title + Logo ───────────────────────────────────────────────
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        job.title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 3),
                      Text(
                        job.organization,
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                const JobLogoPlaceholder(size: 52),
              ],
            ),

            const SizedBox(height: 10),

            // ── Location ───────────────────────────────────────────────────
            JobInfoRow(
              icon: Icons.location_on_outlined,
              text: job.city.isNotEmpty ? job.city : 'Location',
            ),

            const SizedBox(height: 6),

            // ── Duration + Stipend row ─────────────────────────────────────
            Row(
              children: [
                JobInfoRow(icon: Icons.calendar_today_outlined, text: duration),
                const SizedBox(width: 20),
                JobInfoRow(icon: Icons.payments_outlined, text: stipend),
              ],
            ),

            const SizedBox(height: 12),

            // ── Apply Now button ───────────────────────────────────────────
            Align(
              alignment: Alignment.centerRight,
              child: SizedBox(
                height: 36,
                child: ElevatedButton(
                  onPressed: onTap,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.lightBlueScheme,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                  ),
                  child: Text(
                    l10n.applyNowBtn,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Pagination Bar ────────────────────────────────────────────────────────────
class _JobPaginationBar extends StatelessWidget {
  final int currentPage;
  final int totalPages;
  final int total;
  final bool isLoading;
  final void Function(int page) onPageChanged;

  const _JobPaginationBar({
    required this.currentPage,
    required this.totalPages,
    required this.total,
    required this.isLoading,
    required this.onPageChanged,
  });

  @override
  Widget build(BuildContext context) {
    if (totalPages <= 1) return const SizedBox.shrink();

    final bool hasPrev = currentPage > 1;
    final bool hasNext = currentPage < totalPages;
    final l10n = AppLocalizations.of(context)!;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        border: Border(top: BorderSide(color: AppColors.dividerGrey)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 6,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: hasPrev && !isLoading ? () => onPageChanged(currentPage - 1) : null,
            icon: Icon(
              Icons.chevron_left,
              color: hasPrev ? AppColors.appBarBlue : AppColors.textSecondary,
            ),
          ),
          Text(
            "${l10n.page} $currentPage ${l10n.ofText} $totalPages",
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 13,
              color: AppColors.textPrimary,
            ),
          ),
          IconButton(
            onPressed: hasNext && !isLoading ? () => onPageChanged(currentPage + 1) : null,
            icon: Icon(
              Icons.chevron_right,
              color: hasNext ? AppColors.appBarBlue : AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
