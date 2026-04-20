import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/chat_provider.dart';
import 'chat_room_screen.dart';
import 'chat_request_screen.dart' as shilpkar;
import '../../../../features/auth/presentation/providers/auth_provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/api/api_endpoints.dart';
import '../../../../l10n/app_localizations.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      const baseUrl = ApiEndpoints.baseUrl;
      final role = context.read<AuthProvider>().role;
      final isAdmin = role == 'ADMIN' || role == 'SUPER_ADMIN';
      final provider = context.read<ChatProvider>();
      provider.setIsAdminContext(isAdmin);
      provider.initSocket(baseUrl);
      _refreshData(isInitial: true);
    });
  }

  Future<void> _refreshData({bool isInitial = false}) async {
    final role = context.read<AuthProvider>().role;
    final provider = context.read<ChatProvider>();
    final isAdmin = role == 'ADMIN' || role == 'SUPER_ADMIN';

    if (isAdmin) {
      await provider.fetchAdminRequests(refresh: true);
      await provider.fetchAdminSessions();
      return;
    }

    await provider.fetchMyRequests(refresh: true);
    await provider.fetchMyChats(refresh: true);
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ChatProvider>();
    final role = context.read<AuthProvider>().role;
    final isAdmin = role == 'ADMIN' || role == 'SUPER_ADMIN';

    return Scaffold(
      backgroundColor: AppColors.backgroundGrey,
      appBar: AppBar(
        title: const Text(
          "Live Chat",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            letterSpacing: 0.3,
          ),
        ),
        backgroundColor: AppColors.appBarBlue,
        elevation: 0,
        foregroundColor: Colors.white,
      ),
      body:
          provider.isLoading &&
                  provider.sessions.isEmpty &&
                  provider.requests.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : RefreshIndicator(
                  onRefresh: () => _refreshData(),
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                    children: [
                      _SectionHeader(
                        title: isAdmin ? "Incoming Requests" : "My Requests",
                        subtitle: isAdmin
                            ? "Reply quickly to keep the queue moving"
                            : "Track the status of your requests",
                      ),
                      if (provider.requests.isEmpty)
                        _buildInlineEmpty(
                          AppLocalizations.of(context)!.noRequestsFound,
                        )
                      else
                        ...provider.requests.map(
                          (req) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _buildRequestCard(
                              req,
                              role ?? '',
                              provider,
                            ),
                          ),
                        ),
                      if (provider.requests.isNotEmpty)
                        _ChatPaginationBar(
                          currentPage: provider.requestsPage,
                          totalPages: provider.requestsTotalPages,
                          total: provider.requestsTotal,
                          isLoading: provider.isLoading,
                          onPageChanged: (p) => provider.goToRequestsPage(
                            p,
                            isAdmin: isAdmin,
                          ),
                        ),
                      const SizedBox(height: 16),
                      const _SectionHeader(
                        title: "Active Conversations",
                        subtitle: "Unread messages rise to the top",
                      ),
                      if (provider.sessions.isEmpty)
                        _buildInlineEmpty(
                          AppLocalizations.of(context)!.noActiveChats,
                        )
                      else
                        ...provider.sessions.map(
                          (session) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _buildSessionCard(session, role ?? ''),
                          ),
                        ),
                      if (provider.sessions.isNotEmpty)
                        _ChatPaginationBar(
                          currentPage: provider.sessionsPage,
                          totalPages: provider.sessionsTotalPages,
                          total: provider.sessionsTotal,
                          isLoading: provider.isLoading,
                          onPageChanged: (p) => provider.goToSessionsPage(
                            p,
                            isAdmin: isAdmin,
                          ),
                        ),
                    ],
                  ),
                ),
      floatingActionButton: role != 'ADMIN' && role != 'SUPER_ADMIN'
          ? FloatingActionButton.extended(
              heroTag: 'add_request_btn',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const shilpkar.ChatRequestScreen(),
                  ),
                ).then((_) => _refreshData(isInitial: true));
              },
              backgroundColor: AppColors.primaryBlue,
              icon: const Icon(Icons.support_agent, color: Colors.white),
              label: Text(
                AppLocalizations.of(context)!.newRequest,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            )
          : null,
    );
  }

  Widget _buildSessionCard(dynamic session, String role) {
    final displayName = (role == 'SUPER_ADMIN' || role == 'ADMIN')
        ? session.requesterName ?? "User"
        : session.responderName ?? "Admin";
    final unreadCount = session.unreadCount ?? 0;

    return Card(
      elevation: 2,
      shadowColor: Colors.black.withValues(alpha: 0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: EdgeInsets.zero,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ChatRoomScreen(
                sessionId: session.id,
                topic: session.topic,
              ),
            ),
          ).then((_) => _refreshData());
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
          child: ListTile(
            leading: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.primaryBlue.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Icon(
                  Icons.forum_outlined,
                  color: AppColors.primaryBlue,
                  size: 24,
                ),
              ),
            ),
            title: Text(
              session.topic,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: AppColors.textPrimary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 4.0),
              child: Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: session.status == 'ACTIVE'
                          ? AppColors.secondaryGreen
                          : Colors.grey,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      "With: $displayName - ${session.status}",
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w500,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (unreadCount > 0) _UnreadBadge(count: unreadCount),
                const SizedBox(width: 6),
                Icon(
                  Icons.chevron_right,
                  color: Colors.grey.shade400,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInlineEmpty(String message) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Icon(
            Icons.chat_bubble_outline,
            size: 20,
            color: Colors.grey.shade500,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRequestCard(dynamic req, String role, ChatProvider provider) {
    final currentUserId = context.read<AuthProvider>().userId;
    final canAccept = (role == 'ADMIN' || role == 'SUPER_ADMIN');

    Color statusColor;
    switch (req.status) {
      case 'PENDING':
        statusColor = Colors.orange;
        break;
      case 'ACCEPTED':
      case 'IN_PROGRESS':
        statusColor = Colors.blue;
        break;
      case 'REJECTED':
      case 'CLOSED':
        statusColor = Colors.grey;
        break;
      default:
        statusColor = AppColors.secondaryGreen;
    }

    return Card(
      elevation: 2,
      shadowColor: Colors.black.withOpacity(0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: AppColors.primaryBlue.withValues(alpha: 0.1),
                  child: const Icon(
                    Icons.support_agent,
                    color: AppColors.primaryBlue,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        req.topic,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: AppColors.textPrimary,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      if (canAccept && req.requesterName != null)
                        Text(
                          AppLocalizations.of(
                            context,
                          )!.from_(req.requesterName, req.requesterRole),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      if (req.createdAt != null)
                        Text(
                          AppLocalizations.of(
                            context,
                          )!.createdOn(req.createdAt.toString().split(' ')[0]),
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey.shade500,
                          ),
                        ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: statusColor.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Text(
                    req.status,
                    style: TextStyle(
                      color: statusColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 10,
                    ),
                  ),
                ),
              ],
            ),
            if (req.requesterId == currentUserId)
              Padding(
                padding: const EdgeInsets.only(top: 8.0, left: 52.0),
                child: Text(
                  AppLocalizations.of(context)!.youSentThisRequest,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.blue.shade700,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (canAccept && req.status == 'PENDING') ...[
                  OutlinedButton(
                    onPressed: () async {
                      await provider.rejectRequest(req.id);
                      if (mounted && provider.errorMessage != null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(provider.errorMessage!)),
                        );
                      }
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: const BorderSide(color: Colors.red),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 0,
                      ),
                      minimumSize: const Size(0, 36),
                    ),
                    child: Text(
                      AppLocalizations.of(context)!.reject,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () async {
                      await provider.acceptRequest(req.id);
                      if (provider.currentSession != null && context.mounted) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ChatRoomScreen(
                              sessionId: provider.currentSession!.id,
                              topic: req.topic,
                            ),
                          ),
                        ).then((_) => _refreshData(isInitial: true));
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryBlue,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 0,
                      ),
                      minimumSize: const Size(0, 36),
                    ),
                    child: Text(
                      AppLocalizations.of(context)!.accept,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
                if (req.status == 'ACCEPTED' ||
                    req.status == 'IN_PROGRESS' ||
                    req.chatSessionId != null)
                  ElevatedButton.icon(
                    onPressed: () {
                      if (req.chatSessionId != null) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ChatRoomScreen(
                              sessionId: req.chatSessionId!,
                              topic: req.topic,
                            ),
                          ),
                        ).then((_) => _refreshData());
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: AppColors.primaryBlue,
                      elevation: 0,
                      side: const BorderSide(color: AppColors.primaryBlue),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 0,
                      ),
                      minimumSize: const Size(0, 36),
                    ),
                    icon: const Icon(Icons.forum, size: 16),
                    label: Text(
                      AppLocalizations.of(context)!.openChat,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final String? subtitle;

  const _SectionHeader({required this.title, this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: AppColors.textPrimary,
            ),
          ),
          if (subtitle != null)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                subtitle!,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _UnreadBadge extends StatelessWidget {
  final int count;

  const _UnreadBadge({required this.count});

  @override
  Widget build(BuildContext context) {
    final display = count > 99 ? "99+" : count.toString();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.red.shade600,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        display,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 11,
        ),
      ),
    );
  }
}

class _ChatPaginationBar extends StatelessWidget {
  final int currentPage;
  final int totalPages;
  final int total;
  final bool isLoading;
  final void Function(int page) onPageChanged;

  const _ChatPaginationBar({
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

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade200)),
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
            onPressed: hasPrev && !isLoading
                ? () => onPageChanged(currentPage - 1)
                : null,
            icon: Icon(
              Icons.chevron_left,
              color: hasPrev ? AppColors.appBarBlue : Colors.grey,
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "${AppLocalizations.of(context)!.page} $currentPage ${AppLocalizations.of(context)!.ofText} $totalPages",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ],
          ),
          IconButton(
            onPressed: hasNext && !isLoading
                ? () => onPageChanged(currentPage + 1)
                : null,
            icon: Icon(
              Icons.chevron_right,
              color: hasNext ? AppColors.appBarBlue : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}
