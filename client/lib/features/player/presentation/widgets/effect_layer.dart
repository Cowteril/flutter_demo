import 'package:flutter/material.dart';

class EffectEntry {
  EffectEntry({
    required this.id,
    required this.child,
    required this.duration,
  });

  final String id;
  final Widget child;
  final Duration duration;
}

class EffectLayer extends StatefulWidget {
  const EffectLayer({super.key});

  @override
  State<EffectLayer> createState() => EffectLayerState();
}

class EffectLayerState extends State<EffectLayer> {
  final List<EffectEntry> _effects = [];

  void addEffect(EffectEntry effect) {
    setState(() => _effects.add(effect));

    Future<void>.delayed(effect.duration, () {
      if (!mounted) {
        return;
      }
      setState(() {
        _effects.removeWhere((entry) => entry.id == effect.id);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Stack(
        fit: StackFit.expand,
        children: [for (final effect in _effects) effect.child],
      ),
    );
  }
}
