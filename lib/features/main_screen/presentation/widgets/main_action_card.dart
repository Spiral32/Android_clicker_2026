import 'package:flutter/material.dart';

class MainActionCard extends StatelessWidget {
  const MainActionCard({
    super.key,
    required this.title,
    required this.icon,
    required this.onTap,
    this.enabled = true,
    this.backgroundColor,   // ← новый параметр
    this.foregroundColor,   // ← новый параметр (цвет текста и иконок)
  });

  final String title;
  final IconData icon;
  final VoidCallback onTap;
  final bool enabled;
  final Color? backgroundColor;    // новый
  final Color? foregroundColor;    // новый

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    final bgColor = backgroundColor ?? theme.cardColor;           // по умолчанию — цвет Card
    final fgColor = foregroundColor ?? theme.textTheme.titleMedium?.color ?? theme.colorScheme.onSurface;

    return Opacity(
      opacity: enabled ? 1.0 : 0.55,
      child: Card(
        color: bgColor,                    // ← используем наш цвет
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: enabled ? onTap : null,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(
                  icon,
                  color: fgColor,            // ← цвет иконки
                  size: 28,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: fgColor,        // ← цвет текста
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Icon(
                  Icons.chevron_right,
                  color: fgColor.withOpacity(0.7),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
