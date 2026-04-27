import 'package:flutter/material.dart';
import 'package:prog_set_touch/features/settings/presentation/pages/settings_page.dart';

@Deprecated(
  'Use SettingsPage instead. This wrapper is kept only for compatibility with old navigation targets.',
)
class DiagnosticsSettingsPage extends StatelessWidget {
  const DiagnosticsSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const SettingsPage();
  }
}
