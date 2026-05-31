import 'package:flutter/material.dart';
import 'package:kiddylingo/models/types.dart' show UnitStepMeta;

class StepNode extends StatefulWidget {
  final UnitStepMeta stepMeta;
  final Color color;
  final bool isActive;
  final bool isLocked;
  final bool isCompleted;
  final VoidCallback? onTap;

  const StepNode({
    required this.stepMeta,
    required this.color,
    required this.isActive,
    required this.isLocked,
    required this.isCompleted,
    required this.onTap,
  });

  @override
  State<StepNode> createState() => _StepNodeState();
}

class _StepNodeState extends State<StepNode>
    with SingleTickerProviderStateMixin {
  late AnimationController _bounceCtrl;
  late Animation<double> _bounceAnim;

  @override
  void initState() {
    super.initState();
    _bounceCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 700));
    _bounceAnim = Tween<double>(begin: 0, end: -8).animate(
      CurvedAnimation(parent: _bounceCtrl, curve: Curves.easeInOut),
    );
    if (widget.isActive) _bounceCtrl.repeat(reverse: true);
  }

  @override
  void didUpdateWidget(StepNode old) {
    super.didUpdateWidget(old);
    if (widget.isActive && !_bounceCtrl.isAnimating) {
      _bounceCtrl.repeat(reverse: true);
    } else if (!widget.isActive && _bounceCtrl.isAnimating) {
      _bounceCtrl.stop();
      _bounceCtrl.value = 0;
    }
  }

  @override
  void dispose() {
    _bounceCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _bounceCtrl,
      builder: (_, __) => Transform.translate(
        offset: Offset(0, widget.isActive ? _bounceAnim.value : 0),
        child: GestureDetector(
          onTapDown: widget.onTap != null ? (_) => widget.onTap!() : null,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.isActive)
                Container(
                  margin: const EdgeInsets.only(bottom: 4),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF58CC02),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.white, width: 2),
                    boxShadow: const [
                      BoxShadow(
                          color: Color(0x3358CC02),
                          blurRadius: 8,
                          offset: Offset(0, 3)),
                    ],
                  ),
                  child: Text(
                    widget.stepMeta.label.toUpperCase(),
                    style: const TextStyle(
                      fontFamily: 'Fredoka',
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: widget.color,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: widget.isLocked
                        ? const Color(0xFFCBD5E1)
                        : Colors.white.withAlpha(153),
                    width: 3,
                  ),
                  boxShadow: [
                    BoxShadow(
                        color: widget.color.withAlpha(128),
                        blurRadius: 8,
                        offset: const Offset(0, 4)),
                  ],
                ),
                alignment: Alignment.center,
                child: widget.isLocked
                    ? const Icon(Icons.lock, color: Color(0xFF94A3B8), size: 22)
                    : Text(widget.stepMeta.icon,
                        style: const TextStyle(fontSize: 22)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
