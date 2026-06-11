// lib/screens/home_screen.dart

import 'package:flutter/material.dart';
import 'package:kiddylingo/data/data.dart';
import 'package:kiddylingo/widgets/share_widget.dart';
import 'package:provider/provider.dart';
import '../../providers/app_provider.dart';
import '../../models/types.dart';
import '../../widgets/buddy_widget.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F9FF),
      body: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            Positioned.fill(
              child: CustomPaint(
                painter: _DotPatternPainter(),
              ),
            ),
            Column(
              children: [
                const KiddyTopBar(),
                Expanded(
                  child: _HomePathView(),
                ),
                const KiddyBottomNav(),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _HomePathView extends StatefulWidget {
  @override
  State<_HomePathView> createState() => _HomePathViewState();
}

class _HomePathViewState extends State<_HomePathView> {
  late final ScrollController _scrollController;

  /// One GlobalKey per unit so we can measure each section's position.
  final List<GlobalKey> _unitKeys = List.generate(
    categoryOrder.length,
    (_) => GlobalKey(),
  );

  final GlobalKey _activeStepKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  static bool _hasDoneFirstLaunchScroll = false;
  bool _hasDoneMountedScroll = false;

  void _checkAndScroll(AppProvider provider) {
    if (_hasDoneMountedScroll) return;

    if (provider.isProgressLoaded) {
      _hasDoneMountedScroll = true;
      final animate = !_hasDoneFirstLaunchScroll;
      _hasDoneFirstLaunchScroll = true;

      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToActive(animate: animate);
      });
    }
  }

  Future<void> _scrollToActive({required bool animate}) async {
    if (!mounted || !_scrollController.hasClients) return;

    final provider = context.read<AppProvider>();
    final activeIndex = provider.userProgress.completedUnitIndex
        .clamp(0, categoryOrder.length - 1);

    // Try to scroll to active step key
    final stepCtx = _activeStepKey.currentContext;
    if (stepCtx != null) {
      if (animate) {
        await Scrollable.ensureVisible(
          stepCtx,
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeInOutCubic,
          alignment: 0.5, // Center the active step in the viewport
        );
      } else {
        await Scrollable.ensureVisible(
          stepCtx,
          alignment: 0.5, // Center the active step in the viewport instantly
        );
      }
    } else {
      // Fallback to unit key
      final unitCtx = _unitKeys[activeIndex].currentContext;
      if (unitCtx != null) {
        if (animate) {
          await Scrollable.ensureVisible(
            unitCtx,
            duration: const Duration(milliseconds: 800),
            curve: Curves.easeInOutCubic,
            alignment: 0.0, // Align unit header to top
          );
        } else {
          await Scrollable.ensureVisible(
            unitCtx,
            alignment: 0.0, // Align unit header to top instantly
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    _checkAndScroll(provider);

    final activeUnitIndex = provider.userProgress.completedUnitIndex
        .clamp(0, categoryOrder.length - 1);

    return SingleChildScrollView(
      controller: _scrollController,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 20),
        child: Column(
          children: categoryOrder.asMap().entries.map((entry) {
            final unitIndex = entry.key;
            final category = entry.value;
            final meta = categoryMetadata[category]!;
            return UnitSection(
              key: _unitKeys[unitIndex],
              category: category,
              meta: meta,
              unitIndex: unitIndex,
              activeStepKey:
                  unitIndex == activeUnitIndex ? _activeStepKey : null,
            );
          }).toList(),
        ),
      ),
    );
  }
}

class UnitSection extends StatelessWidget {
  final Category category;
  final CategoryMeta meta;
  final int unitIndex;
  final GlobalKey? activeStepKey;

  const UnitSection({
    super.key,
    required this.category,
    required this.meta,
    required this.unitIndex,
    this.activeStepKey,
  });

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final steps = getUnitSteps(category);
    const stepHeight = 100.0;
    final totalHeight = steps.length * stepHeight + 40.0;
    final catColor = Color(meta.color);

    // Precompute zigzag positions
    final positions = List.generate(steps.length, (i) {
      return Offset(
        getZigzagX(i),
        (i * stepHeight) + 40,
      );
    });

    return Column(
      children: [
        // Unit header banner
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
          child: Container(
            decoration: BoxDecoration(
              color: catColor,
              borderRadius: BorderRadius.circular(20),
              border:
                  Border.all(color: Colors.white.withOpacity(0.5), width: 2),
              boxShadow: [
                BoxShadow(
                  color: catColor.withOpacity(0.4),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  alignment: Alignment.center,
                  child: Text(meta.icon, style: const TextStyle(fontSize: 26)),
                ),
                const SizedBox(width: 14),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      meta.title.toUpperCase(),
                      style: const TextStyle(
                        fontFamily: 'Fredoka',
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: -0.5,
                      ),
                    ),
                    Text(
                      'UNIT ${unitIndex + 1}',
                      style: TextStyle(
                        fontFamily: 'Fredoka',
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.white.withOpacity(0.85),
                        letterSpacing: 1.5,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),

        // Zigzag step nodes
        SizedBox(
          height: totalHeight,
          child: LayoutBuilder(builder: (context, constraints) {
            final width = constraints.maxWidth;

            return Stack(
              children: [
                // SVG Path
                CustomPaint(
                  size: Size(width, totalHeight),
                  painter: _PathPainter(
                    positions: positions,
                    width: width,
                    color: catColor,
                  ),
                ),

                // Step nodes
                ...positions.asMap().entries.expand((entry) {
                  final stepIdx = entry.key;
                  final pos = entry.value;
                  final step = steps[stepIdx];

                  final isUnitActive =
                      unitIndex == provider.userProgress.completedUnitIndex;
                  final isUnitCompleted =
                      unitIndex < provider.userProgress.completedUnitIndex;

                  final isCompleted = isUnitCompleted ||
                      (isUnitActive &&
                          stepIdx < provider.userProgress.completedStepIndex);
                  final isActive = isUnitActive &&
                      stepIdx == provider.userProgress.completedStepIndex;
                  final isLocked = !isCompleted && !isActive;

                  final btnColor = isCompleted
                      ? const Color(0xFFFFC800)
                      : isLocked
                          ? const Color(0xFFE2E8F0)
                          : catColor;

                  final x = pos.dx * width;
                  final y = pos.dy;

                  final widgets = [
                    Positioned(
                      left: x - 28,
                      top: y - 28,
                      child: _StepNode(
                        key: isActive ? activeStepKey : null,
                        stepMeta: step,
                        color: btnColor,
                        isActive: isActive,
                        isLocked: isLocked,
                        isCompleted: isCompleted,
                        onTap: isLocked
                            ? null
                            : () => context
                                .read<AppProvider>()
                                .startSession(category, stepIdx),
                      ),
                    ),
                  ];

                  // Show buddy only when this node is active
                  if (isActive) {
                    widgets.add(
                      Positioned(
                        left: -50,
                        top: y - 40,
                        child: const BuddyWidget(size: 120),
                      ),
                    );
                  }

                  return widgets;
                }),
              ],
            );
          }),
        ),
      ],
    );
  }
}

class _StepNode extends StatefulWidget {
  final UnitStepMeta stepMeta;
  final Color color;
  final bool isActive;
  final bool isLocked;
  final bool isCompleted;
  final VoidCallback? onTap;

  const _StepNode({
    super.key,
    required this.stepMeta,
    required this.color,
    required this.isActive,
    required this.isLocked,
    required this.isCompleted,
    required this.onTap,
  });

  @override
  State<_StepNode> createState() => _StepNodeState();
}

class _StepNodeState extends State<_StepNode>
    with SingleTickerProviderStateMixin {
  late AnimationController _bounceCtrl;
  late Animation<double> _bounceAnim;

  @override
  void initState() {
    super.initState();
    _bounceCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _bounceAnim = Tween<double>(begin: 0, end: -8).animate(
      CurvedAnimation(parent: _bounceCtrl, curve: Curves.easeInOut),
    );
    if (widget.isActive) _bounceCtrl.repeat(reverse: true);
  }

  @override
  void didUpdateWidget(_StepNode old) {
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
                        : Colors.white.withOpacity(0.6),
                    width: 3,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: widget.color.withOpacity(0.5),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
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

class _PathPainter extends CustomPainter {
  final List<Offset> positions;
  final double width;
  final Color color;

  _PathPainter({
    required this.positions,
    required this.width,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (positions.isEmpty) return;

    final path = Path();
    final first = positions.first;
    path.moveTo(first.dx * width, first.dy);

    for (int i = 1; i < positions.length; i++) {
      final prev = positions[i - 1];
      final curr = positions[i];
      final px = prev.dx * width;
      final py = prev.dy;
      final cx = curr.dx * width;
      final cy = curr.dy;
      final stepH = cy - py;

      path.cubicTo(
        px,
        py + stepH * 0.5,
        cx,
        cy - stepH * 0.5,
        cx,
        cy,
      );
    }

    // Shadow
    canvas.drawPath(
      path.shift(const Offset(0, 4)),
      Paint()
        ..color = Colors.black.withOpacity(0.1)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 18
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );

    // Main track
    canvas.drawPath(
      path,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 14
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );

    // Shine
    canvas.drawPath(
      path,
      Paint()
        ..color = Colors.white.withOpacity(0.3)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );
  }

  @override
  bool shouldRepaint(_PathPainter old) => false;
}

class _DotPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFCBD5E1)
      ..style = PaintingStyle.fill;

    const spacing = 24.0;
    const radius = 1.5;

    for (double x = 0; x < size.width; x += spacing) {
      for (double y = 0; y < size.height; y += spacing) {
        canvas.drawCircle(Offset(x, y), radius, paint);
      }
    }
  }

  @override
  bool shouldRepaint(_DotPatternPainter oldDelegate) => false;
}
