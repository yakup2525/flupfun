import 'dart:async';
import 'package:flutter/material.dart';
import '../services/update_service.dart';
import '../services/monetization_service.dart';
import 'settings/settings_page.dart';
import 'game/home_page.dart';

class UpdateGate extends StatefulWidget {
  const UpdateGate({super.key});
  @override
  State<UpdateGate> createState() => _UpdateGateState();
}

class _UpdateGateState extends State<UpdateGate> with WidgetsBindingObserver {
  final updates = UpdateService();
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    updates.addListener(_changed);
    unawaited(updates.check());
    unawaited(MonetizationService.instance.start());
  }

  void _changed() {
    if (!mounted) return;
    if (updates.required) {
      // Close any Settings/game-over route before presenting the mandatory gate.
      Navigator.of(context).popUntil((route) => route.isFirst);
    }
    setState(() {});
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) unawaited(updates.check());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    updates.removeListener(_changed);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!updates.required) return const HomePage();
    return PopScope(
      canPop: false,
      child: Scaffold(
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.system_update, size: 56),
                    const SizedBox(height: 24),
                    Text(
                      'Update Flup Fun',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'A newer version is required to keep playing. Update Flup Fun from Google Play, then reopen the app.',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    FilledButton(
                      onPressed: () => openExternal(context, playStoreUrl),
                      child: const Text('Update on Google Play'),
                    ),
                    TextButton(
                      onPressed: updates.checking ? null : updates.check,
                      child: const Text('Check again'),
                    ),
                    TextButton(
                      onPressed: () => openExternal(context, privacyPolicyUrl),
                      child: const Text('Privacy Policy'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
