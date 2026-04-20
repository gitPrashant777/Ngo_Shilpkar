import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/chat_provider.dart';
import '../../../../features/auth/presentation/providers/auth_provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../l10n/app_localizations.dart';

class ChatRequestScreen extends StatefulWidget {
  const ChatRequestScreen({super.key});

  @override
  State<ChatRequestScreen> createState() => _ChatRequestScreenState();
}

class _ChatRequestScreenState extends State<ChatRequestScreen> {
  final _topicController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final chatProvider = Provider.of<ChatProvider>(context);
    final role = context.read<AuthProvider>().role;

    // Determine target label and logic
    String targetLabel = "Admin";
    if (role == 'ADMIN') {
      targetLabel = "Super Admin";
    } else if (role == 'SUPER_ADMIN') {
      targetLabel = "Admin"; // If Super Admin creates a request? Rare case.
    }

    return Scaffold(
      backgroundColor: AppColors.backgroundGrey,
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.newRequest),
        backgroundColor: AppColors.appBarBlue,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: AppColors.primaryBlue.withValues(
                            alpha: 0.1,
                          ),
                          child: const Icon(
                            Icons.support_agent,
                            color: AppColors.primaryBlue,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            AppLocalizations.of(context)!.helpUsUnderstandIssue,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.appBarBlue,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Text(
                      AppLocalizations.of(context)!.topicSubject,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: TextFormField(
                        controller: _topicController,
                        decoration: InputDecoration(
                          hintText: AppLocalizations.of(context)!.topicHint,
                          hintStyle: TextStyle(color: Colors.grey.shade400),
                          prefixIcon: const Icon(
                            Icons.title,
                            color: AppColors.primaryBlue,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide(
                              color: AppColors.primaryBlue.withValues(
                                alpha: 0.5,
                              ),
                            ),
                          ),
                          filled: true,
                          fillColor: Colors.grey.shade50,
                        ),
                        maxLines: 4,
                        validator: (value) => value!.isEmpty
                            ? AppLocalizations.of(context)!.pleaseEnterTopic
                            : null,
                      ),
                    ),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton(
                        onPressed: chatProvider.isLoading
                            ? null
                            : () async {
                                if (_formKey.currentState!.validate()) {
                                  try {
                                    await chatProvider.createRequest(
                                      _topicController.text.trim(),
                                      role ?? 'BENEFICIARY',
                                    );
                                    if (mounted) {
                                      Navigator.pop(context);
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            AppLocalizations.of(
                                              context,
                                            )!.requestSentSuccess,
                                          ),
                                        ),
                                      );
                                    }
                                  } catch (e) {
                                    if (mounted) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            '${AppLocalizations.of(context)!.errorOccurred}: $e',
                                          ),
                                          backgroundColor: Colors.red,
                                        ),
                                      );
                                    }
                                  }
                                }
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryBlue,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: chatProvider.isLoading
                            ? const SizedBox(
                                height: 24,
                                width: 24,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.send,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    AppLocalizations.of(context)!.submitRequest,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
