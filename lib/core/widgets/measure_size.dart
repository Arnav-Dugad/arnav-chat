import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

/// Reports its child's size after layout whenever it changes.
class MeasureSize extends SingleChildRenderObjectWidget {
  const MeasureSize({super.key, required this.onChange, required super.child});

  final ValueChanged<Size> onChange;

  @override
  RenderObject createRenderObject(BuildContext context) => _RenderMeasure(onChange);

  @override
  void updateRenderObject(BuildContext context, RenderObject renderObject) =>
      (renderObject as _RenderMeasure).onChange = onChange;
}

class _RenderMeasure extends RenderProxyBox {
  _RenderMeasure(this.onChange);

  ValueChanged<Size> onChange;
  Size? _old;

  @override
  void performLayout() {
    super.performLayout();
    final s = child?.size ?? Size.zero;
    if (s != _old) {
      _old = s;
      WidgetsBinding.instance.addPostFrameCallback((_) => onChange(s));
    }
  }
}
