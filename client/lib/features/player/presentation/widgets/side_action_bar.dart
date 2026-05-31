import 'package:flutter/material.dart';

import '../../../drama/domain/models/drama.dart';

class SideActionBar extends StatefulWidget {
  const SideActionBar({
    required this.drama,
    required this.onLike,
    required this.onComment,
    required this.onShare,
    required this.onCast,
    super.key,
  });

  final Drama drama;
  final VoidCallback onLike;
  final VoidCallback onComment;
  final VoidCallback onShare;
  final VoidCallback onCast;

  @override
  State<SideActionBar> createState() => _SideActionBarState();
}

class _SideActionBarState extends State<SideActionBar> {
  late var _likes = 8600 + widget.drama.id.length * 137;
  late var _comments = 280 + widget.drama.highlights.length * 31;
  late var _shares = 120 + widget.drama.episodeCount * 3;
  var _liked = false;
  var _followed = false;

  void _toggleFollow() {
    setState(() => _followed = true);
  }

  void _like() {
    setState(() {
      if (!_liked) {
        _likes++;
      }
      _liked = true;
    });
    widget.onLike();
  }

  void _comment() {
    setState(() => _comments++);
    widget.onComment();
  }

  void _share() {
    setState(() => _shares++);
    widget.onShare();
  }

  @override
  Widget build(BuildContext context) {
    final accent = Color(widget.drama.coverColor);

    return Positioned(
      right: 10,
      bottom: 188,
      child: SafeArea(
        top: false,
        left: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _AvatarAction(
              accent: accent,
              followed: _followed,
              onPressed: _toggleFollow,
            ),
            const SizedBox(height: 14),
            _ActionButton(
              icon: _liked ? Icons.favorite : Icons.favorite_border,
              label: _compactCount(_likes),
              activeColor: const Color(0xFFFF4F8B),
              isActive: _liked,
              onPressed: _like,
            ),
            const SizedBox(height: 13),
            _ActionButton(
              icon: Icons.mode_comment_outlined,
              label: _compactCount(_comments),
              onPressed: _comment,
            ),
            const SizedBox(height: 13),
            _ActionButton(
              icon: Icons.ios_share,
              label: _compactCount(_shares),
              onPressed: _share,
            ),
            const SizedBox(height: 13),
            _ActionButton(
              icon: Icons.auto_fix_high,
              label: '施法',
              activeColor: const Color(0xFFFFD166),
              onPressed: widget.onCast,
            ),
          ],
        ),
      ),
    );
  }
}

class _AvatarAction extends StatelessWidget {
  const _AvatarAction({
    required this.accent,
    required this.followed,
    required this.onPressed,
  });

  final Color accent;
  final bool followed;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                accent.withValues(alpha: 0.95),
                const Color(0xFFFFD166),
                const Color(0xFFFF4F8B),
              ],
            ),
            border: Border.all(color: Colors.white, width: 2),
            boxShadow: [
              BoxShadow(
                color: accent.withValues(alpha: 0.5),
                blurRadius: 18,
              ),
            ],
          ),
          child: const SizedBox.square(
            dimension: 48,
            child: Icon(Icons.person, color: Colors.white),
          ),
        ),
        const SizedBox(height: 5),
        SizedBox.square(
          dimension: 24,
          child: IconButton.filled(
            padding: EdgeInsets.zero,
            style: IconButton.styleFrom(
              backgroundColor:
                  followed ? const Color(0xFF24D18E) : const Color(0xFFFF3B72),
              foregroundColor: Colors.white,
            ),
            tooltip: followed ? '已关注' : '关注',
            onPressed: onPressed,
            icon: Icon(followed ? Icons.check : Icons.add, size: 16),
          ),
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onPressed,
    this.activeColor,
    this.isActive = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onPressed;
  final Color? activeColor;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    final color = isActive ? activeColor ?? Colors.white : Colors.white;

    return Column(
      children: [
        Tooltip(
          message: label,
          child: IconButton(
            onPressed: onPressed,
            iconSize: 31,
            style: IconButton.styleFrom(
              foregroundColor: color,
              shadowColor: Colors.black,
            ),
            icon: Icon(
              icon,
              shadows: const [
                Shadow(color: Colors.black87, blurRadius: 12),
              ],
            ),
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.w800,
            shadows: [
              Shadow(color: Colors.black, blurRadius: 8),
            ],
          ),
        ),
      ],
    );
  }
}

String _compactCount(int value) {
  if (value >= 10000) {
    final compact = value / 10000;
    return '${compact.toStringAsFixed(compact >= 10 ? 0 : 1)}w';
  }
  if (value >= 1000) {
    final compact = value / 1000;
    return '${compact.toStringAsFixed(compact >= 10 ? 0 : 1)}k';
  }
  return '$value';
}
