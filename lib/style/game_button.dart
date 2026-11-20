import 'package:flutter/material.dart';

import 'palette.dart';

/// A big, chunky game button: a coloured face sitting on a darker edge,
/// which sinks when pressed. Used for the modes on the home screen.
class GameButton extends StatefulWidget {
  const GameButton({
    super.key,
    required this.icon,
    required this.label,
    required this.onPressed,
    this.subtitle,
    this.color = Palette.amber,
    this.edge = Palette.amberDeep,
    this.foreground = Palette.ink,
    this.large = false,
  });

  final IconData icon;
  final String label;

  /// A smaller line under the label, as a widget so it can hold a badge.
  final Widget? subtitle;
  final VoidCallback onPressed;
  final Color color;
  final Color edge;
  final Color foreground;

  /// The main button is taller, with a bigger icon.
  final bool large;

  @override
  State<GameButton> createState() => _GameButtonState();
}

class _GameButtonState extends State<GameButton> {
  static const _depth = 5.0;
  bool _down = false;

  void _set(bool down) {
    if (_down != down) setState(() => _down = down);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final iconBox = widget.large ? 52.0 : 40.0;
    return Semantics(
      button: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: (_) => _set(true),
        onTapUp: (_) => _set(false),
        onTapCancel: () => _set(false),
        onTap: widget.onPressed,
        child: Padding(
          padding: EdgeInsets.only(top: _down ? _depth : 0),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 60),
            decoration: BoxDecoration(
              color: widget.edge,
              borderRadius: BorderRadius.circular(22),
            ),
            padding: EdgeInsets.only(bottom: _down ? 0 : _depth),
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: 16,
                vertical: widget.large ? 16 : 12,
              ),
              decoration: BoxDecoration(
                color: widget.color,
                borderRadius: BorderRadius.circular(22),
              ),
              child: Row(
                children: [
                  Container(
                    width: iconBox,
                    height: iconBox,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.28),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      widget.icon,
                      color: widget.foreground,
                      size: iconBox * 0.56,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          widget.label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style:
                              (widget.large
                                      ? theme.textTheme.titleLarge
                                      : theme.textTheme.titleMedium)
                                  ?.copyWith(
                                    color: widget.foreground,
                                    fontWeight: FontWeight.w900,
                                  ),
                        ),
                        if (widget.subtitle case final sub?)
                          DefaultTextStyle.merge(
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: widget.foreground.withValues(alpha: 0.8),
                              fontWeight: FontWeight.w700,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            child: sub,
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
