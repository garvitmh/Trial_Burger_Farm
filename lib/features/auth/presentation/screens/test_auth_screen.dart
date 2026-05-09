import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:burger_farm_app/features/auth/presentation/providers/auth_provider.dart';

class TestAuthScreen extends ConsumerStatefulWidget {
  const TestAuthScreen({super.key});

  @override
  ConsumerState<TestAuthScreen> createState() => _TestAuthScreenState();
}

class _TestAuthScreenState extends ConsumerState<TestAuthScreen> {
  final _phoneController = TextEditingController();
  final _otpController = TextEditingController();

  @override
  void dispose() {
    _phoneController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Burger Farm — Phase 0 OTP'),
        backgroundColor: Colors.deepOrange,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Phase 0 label
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.orange.shade100,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange),
              ),
              child: const Text(
                '⚡ Phase 0 — Firebase Phone Auth Test',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 24),

            if (authState.user != null) ...[
              const Icon(Icons.check_circle, color: Colors.green, size: 80),
              const SizedBox(height: 20),
              Text(
                '✅ Signed in!',
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text('Phone: ${authState.user!.phone}',
                  style: const TextStyle(fontSize: 16)),
              Text('Firebase UID: ${authState.user!.id}',
                  style: const TextStyle(fontSize: 12, color: Colors.grey)),
              if (authState.user!.token != null)
                Text('Backend JWT: ${authState.user!.token!.substring(0, 20)}...',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 12)),
              const SizedBox(height: 8),
              const Text(
                '(Backend JWT: skipped — Phase 0 Firebase-only mode)',
                style: TextStyle(fontSize: 11, color: Colors.orange),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => ref.read(authProvider.notifier).signOut(),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: const Text('Sign Out', style: TextStyle(color: Colors.white)),
              ),
            ] else ...[
              if (authState.error != null)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    border: Border.all(color: Colors.red),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(authState.error!,
                      style: const TextStyle(color: Colors.red)),
                ),

              const SizedBox(height: 20),

              if (authState.verificationId == null) ...[
                TextField(
                  controller: _phoneController,
                  decoration: const InputDecoration(
                    labelText: 'Phone Number (with country code)',
                    hintText: '+919876543210',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.phone),
                  ),
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: authState.isLoading
                        ? null
                        : () => ref
                            .read(authProvider.notifier)
                            .sendOtp(_phoneController.text.trim()),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepOrange,
                    ),
                    child: authState.isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('Send OTP',
                            style: TextStyle(color: Colors.white, fontSize: 16)),
                  ),
                ),
              ] else ...[
                const Text(
                  'OTP sent! Enter the 6-digit code below.',
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _otpController,
                  decoration: const InputDecoration(
                    labelText: 'Enter 6-digit OTP',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.lock),
                  ),
                  keyboardType: TextInputType.number,
                  maxLength: 6,
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: authState.isLoading
                        ? null
                        : () => ref
                            .read(authProvider.notifier)
                            .verifyOtp(_otpController.text.trim()),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                    ),
                    child: authState.isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('Verify OTP',
                            style: TextStyle(color: Colors.white, fontSize: 16)),
                  ),
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () =>
                      ref.read(authProvider.notifier).resetVerificationId(),
                  child: const Text('← Change Phone Number'),
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }
}
