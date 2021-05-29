import 'dart:async';
import 'package:flutter/material.dart' hide Container;
import 'renderme.dart';

class RenderMe extends LeafRenderObjectWidget {
	RenderMe({Key? key, this.width, this.height, this.background = const Color(0xFFFFFFFF), bool debug = false}) :
			render = Render(debug: debug)..color = background,
			super(key: key);

	final Render render;
	final double? width;
	final double? height;
	final Color background;

	@override
	RenderObject createRenderObject(BuildContext context) {
		return _RenderBox(render);
	}

	@override
	void updateRenderObject(BuildContext context, covariant _RenderBox renderObject) {
		renderObject
			..width = width
			..height = height
			..markNeedsLayoutForSizedByParentChange();
		render.color = background;
	}
}

class _RenderBox extends RenderBox {
	_RenderBox(this.render) {
		render.on(EventType.repaint, (_) {
			if (!paintScheduled) {
				scheduleMicrotask(markNeedsPaint);
				paintScheduled = true;
			}
		});
	}

	final Render render;
	double? width;
	double? height;
	bool paintScheduled = false;

	@override
	bool get sizedByParent => true;

	@override
	Size computeDryLayout(BoxConstraints constraints) {
		final double w = width ?? (constraints.maxWidth.isFinite ? constraints.maxWidth : constraints.minWidth);
		final double h = height ?? (constraints.maxHeight.isFinite ? constraints.maxHeight : constraints.minHeight);
		final Size s = constraints.constrain(Size(w, h));
		render..width = s.width..height = s.height;
		return s;
	}

	@override
	void paint(PaintingContext context, Offset offset) {
		paintScheduled = false;
		if (render.position != offset) render.position = offset;
		render.render(context.canvas);
	}
}