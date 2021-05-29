library renderme;

import 'dart:async';
import 'dart:math';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart' as ml;
import 'package:meta/meta.dart';

part 'core/common.dart';
part 'core/container.dart';
part 'core/entity.dart';
part 'objects/arc.dart';
part 'objects/circle.dart';
part 'objects/ellipse.dart';
part 'objects/group.dart';
part 'objects/image.dart';
part 'objects/layer.dart';
part 'objects/line.dart';
part 'objects/path.dart';
part 'objects/point.dart';
part 'objects/rectangle.dart';
part 'objects/text.dart';

class Render extends Container {
	Render({this.debug = false}) : super(null) {
		root = this;
		clip = true;
	}

	bool _repaint = false;
	final bool debug;

	final ml.TextPainter _painter = ml.TextPainter()
		..textAlign = ui.TextAlign.right
		..textDirection = ui.TextDirection.ltr;
	final ml.TextSpan _spanFPS = const ml.TextSpan(
		text: 'FPS:',
		style: ml.TextStyle(
			fontSize: 12,
			color: ui.Color(0xFFFFFFFF),
		),
	);
	final List<int> _dFPS = <int>[];
	int _timestamp = DateTime.now().microsecondsSinceEpoch;

	@override
	void repaint() {
		if (!_repaint) {
			_repaint = true;
			if (events[EventType.repaint] != null && events[EventType.repaint]!.isNotEmpty) {
				for (final void Function(EventDetails details) handler in events[EventType.repaint]!) handler(const EventDetails());
			}
		}
	}

	@override
	void render(ui.Canvas canvas, [int milliseconds = 0]) {
		final int time = DateTime.now().microsecondsSinceEpoch;
		final int deltaTime = time - _timestamp;
		_timestamp = time;
		_repaint = false;

		canvas.save();
		if (x != 0 || y != 0) canvas.translate(x, y);
		if (clip) {
			if (!updated) {
				build();
				updated = true;
			}
			canvas.clipPath(pathCache);
		}
		if (color != null) canvas.drawColor(color!, ui.BlendMode.src);
		for (final Entity child in children) {
			child.render(canvas, deltaTime ~/ 1000);
		}

		if (debug) {
			_dFPS.add(deltaTime);
			if (_dFPS.length > 10) _dFPS.removeAt(0);
			int fps = 0;
			for (final int timestamp in _dFPS) fps += timestamp;
			fps = (1000000 / (fps / _dFPS.length)).floor();
			final ui.Paint paint = ui.Paint()..style = ui.PaintingStyle.fill..color = const ui.Color(0x70000000);
			final ml.TextSpan span = ml.TextSpan(
				text: fps.toString(),
				style: const ml.TextStyle(
					fontSize: 12,
					color: ui.Color(0xFFFFFFFF),
				),
			);
			canvas.drawRect(const ui.Rect.fromLTWH(0, 0, 57, 20), paint);
			_painter..text = _spanFPS..layout();
			_painter.paint(canvas, const ui.Offset(5, 3));
			_painter..text = span..layout();
			_painter.paint(canvas, ui.Offset(52 - _painter.width, 3));
		}
		canvas.restore();
	}
}