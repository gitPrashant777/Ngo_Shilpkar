import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import '../../data/repository/scheme_repository.dart';
import '../../../auth/presentation/screens/edit_profile_screen.dart';

class ApplySchemeScreen extends StatefulWidget {
  final String schemeId;

  const ApplySchemeScreen({super.key, required this.schemeId});

  @override
  State<ApplySchemeScreen> createState() => _ApplySchemeScreenState();
}

class _ApplySchemeScreenState extends State<ApplySchemeScreen> {
  final SchemeRepository _repository = SchemeRepository();
  bool _isLoading = false;
  Future<void> _applyScheme() async {
    setState(() => _isLoading = true);

    try {
      await _repository.applyForScheme(widget.schemeId);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Application submitted successfully"),
            backgroundColor: Colors.green,
          ),
        );

        Navigator.pop(context);
      }
    } on DioException catch (e) {
      String errorMessage = "Something went wrong";

      if (e.response != null && e.response?.data != null) {
        final data = e.response?.data;

        if (data is Map && data["message"] != null) {
          errorMessage = data["message"];
        }
      }

      if (mounted) {
        if (errorMessage.toLowerCase().contains("bank details")) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(errorMessage),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 5),
              action: SnackBarAction(
                label: "Add Bank",
                textColor: Colors.white,
                onPressed: () {
                  Navigator.pop(context); // Close this apply screen
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const EditProfileScreen()),
                  );
                },
              ),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(errorMessage),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        String errorMessage = e.toString().replaceAll('Exception: ', '');
        
        if (errorMessage.toLowerCase().contains("bank details")) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(errorMessage),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 5),
              action: SnackBarAction(
                label: "Add Bank",
                textColor: Colors.white,
                onPressed: () {
                  Navigator.pop(context); // Close this apply screen
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const EditProfileScreen()),
                  );
                },
              ),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(errorMessage.isNotEmpty ? errorMessage : "Unexpected error"),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Apply for Scheme")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Text(
              "Are you sure you want to apply for this scheme?",
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _applyScheme,
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("Apply Now"),
              ),
            )
          ],
        ),
      ),
    );
  }
}
