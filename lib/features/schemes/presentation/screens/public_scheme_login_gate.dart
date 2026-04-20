import 'package:flutter/material.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../auth/presentation/screens/beneficiary_login_screen.dart';
import '../../presentation/providers/scheme_provider.dart';
import 'package:provider/provider.dart';
import '../../data/models/scheme_model.dart';
import '../../../../core/constants/app_colors.dart';

class PublicSchemeLoginGate extends StatefulWidget {
  const PublicSchemeLoginGate({super.key});

  @override
  State<PublicSchemeLoginGate> createState() => _PublicSchemeLoginGateState();
}

class _PublicSchemeLoginGateState extends State<PublicSchemeLoginGate>
    with SingleTickerProviderStateMixin {
  late AnimationController _animCtrl;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 700));
    _fadeAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeIn);
    _slideAnim = Tween<Offset>(begin: const Offset(0, 0.12), end: Offset.zero)
        .animate(CurvedAnimation(parent: _animCtrl, curve: Curves.easeOutCubic));
    _animCtrl.forward();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SchemeProvider>().fetchPublishedSchemes();
    });
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    super.dispose();
  }

  void _goToLogin() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const BeneficiaryLoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnim,
          child: SlideTransition(
            position: _slideAnim,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSchemePreview(l10n),
                  const SizedBox(height: 16),
                  _buildLoginCard(l10n),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────
  Widget _buildSchemePreview(AppLocalizations l10n) {
    return Consumer<SchemeProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading && provider.publishedSchemes.isEmpty) {
          return const Padding(
            padding: EdgeInsets.all(40),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        final schemes = provider.publishedSchemes;

        if (schemes.isEmpty) {
          return Padding(
            padding: const EdgeInsets.all(24),
            child: Center(
              child: Column(
                children: [
                  Icon(Icons.assignment_outlined,
                      size: 56, color: Colors.grey.shade300),
                  const SizedBox(height: 8),
                  Text(
                    l10n.noSchemesAvailable,
                    style: TextStyle(
                        color: Colors.grey.shade400, fontSize: 14),
                  ),
                ],
              ),
            ),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
              child: Row(
                children: [
                  Container(
                    width: 3,
                    height: 16,
                    decoration: BoxDecoration(
                      color: AppColors.lightBlueScheme,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    l10n.availableSchemesCount(schemes.length),
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
            ...schemes.take(5).toList().asMap().entries.map((entry) {
              final delay = entry.key * 80;
              return TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: 1),
                duration: Duration(milliseconds: 400 + delay),
                builder: (_, v, child) =>
                    Opacity(opacity: v, child: child),
                child: _buildSchemeCard(entry.value),
              );
            }),
            if (schemes.length > 5)
              Padding(
                padding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                child: Text(
                  l10n.moreSchemesAfterLogin(schemes.length - 5),
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade500,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildSchemeCard(SchemeModel scheme) {
    final isPaid = scheme.price > 0;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 3),
          )
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color:
              AppColors.lightBlueScheme.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.assignment_rounded,
              color: AppColors.lightBlueScheme,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  scheme.name,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 14),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 3),
                Text(
                  scheme.description,
                  style: TextStyle(
                      fontSize: 11, color: Colors.grey.shade500),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: isPaid
                      ? Colors.orange.shade50
                      : Colors.green.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  isPaid
                      ? '₹${scheme.price.toInt()}'
                      : 'FREE',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: isPaid
                        ? Colors.orange.shade700
                        : Colors.green.shade700,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Icon(
                Icons.lock_outline_rounded,
                size: 13,
                color: Colors.grey.shade400,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLoginCard(AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.statusGreen, Colors.green.shade900],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color:
              AppColors.statusGreen.withValues(alpha: 0.3),
              blurRadius: 16,
              offset: const Offset(0, 6),
            )
          ],
        ),
        child: Column(
          children: [
            const Icon(Icons.verified_user_outlined,
                color: Colors.white, size: 44),
            const SizedBox(height: 12),
            Text(
              l10n.unlockAllSchemes,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.loginBeneficiarySchemeDesc,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.85),
                fontSize: 13,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _goToLogin,
                icon: Icon(Icons.login_rounded,
                    color: Colors.green.shade900, size: 18),
                label: Text(
                  l10n.loginAsBeneficiaryBtn,
                  style: TextStyle(
                      color: Colors.green.shade900,
                      fontWeight: FontWeight.bold,
                      fontSize: 15),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  padding:
                  const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius:
                      BorderRadius.circular(12)),
                  elevation: 0,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}