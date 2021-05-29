part of renderme;

// import 'package:vector_math/vector_math.dart';

abstract class Entity {
	Entity(this.root);

	Render? root;
	Container? parent;
	double _x = 0, _y = 0;
	double _angle = 0;
	int _order = 0;
	double _pivotX = 0, _pivotY = 0;
	double _width = 0, _height = 0;
	ui.Color? color;
	ImageResource? background;
	double strokeWidth = 0;
	ui.Color strokeColor = const ui.Color(0xFF000000);
	ui.BlendMode blend = ui.BlendMode.srcOver;
	ui.BlendMode backgroundBlend = ui.BlendMode.srcOver;
	ui.BlendMode strokeBlend = ui.BlendMode.srcOver;
	double _opacity = 1;
	bool visible = true;
	final Map<EventType, List<void Function(EventDetails details)>> _events = <EventType, List<void Function(EventDetails details)>>{};
	final List<Animation> _animations = <Animation>[];
	// Matrix3 _transformMatrix, _invertedMatrix;
	final Map<Property, List<Affection>> _affections = <Property, List<Affection>>{
		Property.x: <Affection>[],
		Property.y: <Affection>[],
		Property.width: <Affection>[],
		Property.height: <Affection>[],
		Property.angle: <Affection>[],
		Property.opacity: <Affection>[],
	};
	final Map<Property, bool> _affectedProps = <Property, bool>{
		Property.x: false,
		Property.y: false,
		Property.width: false,
		Property.height: false,
		Property.angle: false,
		Property.opacity: false,
	};
	@protected final ml.Path pathCache = ml.Path();
	@protected bool updated = false;

//- GETTERS --------------------------------------------------------------------

	int get order => _order;
	double get x => _x;
	double get y => _y;
	ui.Offset get position => ui.Offset(_x, _y);
	double get angle => _angle;
	double get pivotX => _pivotX;
	double get pivotY => _pivotY;
	ui.Offset get pivot => ui.Offset(_pivotX, _pivotY);
	double get width => _width;
	double get height => _height;
	ui.Size get size => ui.Size(_width, _height);
	double get opacity => _opacity;
	Map<EventType, List<void Function(EventDetails details)>> get events => _events;

//- SETTERS --------------------------------------------------------------------

	set order(int value) {
		_order = value;
		if (parent != null && !parent!.lazy) parent!.sort();
		repaint();
	}
	set x(double value) {
		move(value, null);
	}
	set y(double value) {
		move(null, value);
	}
	set position(ui.Offset value) {
		move(value.dx, value.dy);
	}
	set angle(double value) {
		rotate(value);
	}
	set pivotX(double value) {
		_pivotX = value;
		// _transformMatrix = null;
		// _invertedMatrix = null;
		repaint();
	}
	set pivotY(double value) {
		_pivotY = value;
		// _transformMatrix = null;
		// _invertedMatrix = null;
		repaint();
	}
	set pivot(ui.Offset value) {
		_pivotX = value.dx;
		_pivotY = value.dy;
		// _transformMatrix = null;
		// _invertedMatrix = null;
		repaint();
	}
	set width(double value) {
		resize(value, null);
	}
	set height(double value) {
		resize(null, value);
	}
	set size(ui.Size value) {
		resize(value.width, value.height);
	}
	set opacity(double value) {
		opacify(value);
	}

//= METHODS ====================================================================

	ui.Color _applyOpacity(ui.Color color) {
		double totalOpacity = _opacity;
		Entity node = this;
		while (node.parent != null && node.parent != node) {
			node = node.parent!;
			totalOpacity *= node.opacity;
		}
		return color.withOpacity(color.opacity * totalOpacity);
	}

	void drop() {
		parent?.children.remove(this);
		repaint();
	}

	void _apply(Property property, double delta) {
		switch (property) {
			case Property.x: x += delta; break;
			case Property.y: y += delta; break;
			case Property.width: width += delta; break;
			case Property.height: height += delta; break;
			case Property.angle: angle += delta; break;
			case Property.opacity: opacity += delta; break;
		}
	}

	void move([double? x, double? y, bool silent = false]) {
		if (_affectedProps[Property.x]! || _affectedProps[Property.y]!) return;
		if (!silent) {
			_affectedProps[Property.x] = true;
			_affectedProps[Property.y] = true;
		}
		double dx = 0, dy = 0;
		if (x != null) {
			dx = x - _x;
			_x = x;
		}
		if (y != null) {
			dy = y - _y;
			_y = y;
		}
		// _transformMatrix = null;
		// _invertedMatrix = null;
		if (!silent) {
			if (dx != 0) for (final Affection affection in _affections[Property.x]!) {
				affection.target._apply(affection.property, affection.weight * dx);
			}
			if (dy != 0) for (final Affection affection in _affections[Property.y]!) {
				affection.target._apply(affection.property, affection.weight * dy);
			}
			_affectedProps[Property.x] = false;
			_affectedProps[Property.y] = false;
		}
		if (_events[EventType.move] != null && _events[EventType.move]!.isNotEmpty) {
			for (final void Function(EventDetails details) handler in _events[EventType.move]!) handler(EventDetails(deltaX: dx, deltaY: dy));
		}
		repaint();
	}

	void rotate(double angle, [bool silent = false]) {
		if (_affectedProps[Property.angle]!) return;
		if (!silent) _affectedProps[Property.angle] = true;
		final double delta = angle - _angle;
		_angle = angle;
		// _transformMatrix = null;
		// _invertedMatrix = null;
		if (!silent) {
			if (delta != 0) for (final Affection affection in _affections[Property.angle]!) {
				affection.target._apply(affection.property, affection.weight * delta);
			}
			_affectedProps[Property.angle] = false;
		}
		if (_events[EventType.rotate] != null && _events[EventType.rotate]!.isNotEmpty) {
			for (final void Function(EventDetails details) handler in _events[EventType.rotate]!) handler(EventDetails(deltaAngle: delta));
		}
		repaint();
	}

	void resize([double? width, double? height, bool silent = false]) {
		if (_affectedProps[Property.width]! || _affectedProps[Property.height]!) return;
		if (!silent) {
			_affectedProps[Property.width] = true;
			_affectedProps[Property.height] = true;
		}
		double dw = 0, dh = 0;
		if (width != null) {
			dw = width - _width;
			_width = width;
		}
		if (height != null) {
			dh = height - _height;
			_height = height;
		}
		updated = false;
		if (!silent) {
			if (dw != 0) for (final Affection affection in _affections[Property.width]!) {
				affection.target._apply(affection.property, affection.weight * dw);
			}
			if (dh != 0) for (final Affection affection in _affections[Property.height]!) {
				affection.target._apply(affection.property, affection.weight * dh);
			}
			_affectedProps[Property.width] = false;
			_affectedProps[Property.height] = false;
		}
		if (_events[EventType.resize] != null && _events[EventType.resize]!.isNotEmpty) {
			for (final void Function(EventDetails details) handler in _events[EventType.resize]!) handler(EventDetails(deltaWidth: dw, deltaHeight: dh));
		}
		repaint();
	}

	void opacify(double opacity, [bool silent = false]) {
		if (_affectedProps[Property.opacity]!) return;
		if (!silent) _affectedProps[Property.opacity] = true;
		final double delta = opacity - _opacity;
		_opacity = opacity;
		// _transformMatrix = null;
		// _invertedMatrix = null;
		if (!silent) {
			if (delta != 0) for (final Affection affection in _affections[Property.opacity]!) {
				affection.target._apply(affection.property, affection.weight * delta);
			}
			_affectedProps[Property.opacity] = false;
		}
		if (_events[EventType.fade] != null && _events[EventType.fade]!.isNotEmpty) {
			for (final void Function(EventDetails details) handler in _events[EventType.fade]!) handler(EventDetails(deltaOpacity: delta));
		}
		repaint();
	}

	void show() {
		visible = true;
		if (_events[EventType.show] != null && _events[EventType.show]!.isNotEmpty) {
			for (final void Function(EventDetails details) handler in _events[EventType.show]!) handler(const EventDetails());
		}
		if (_events[EventType.fade] != null && _events[EventType.fade]!.isNotEmpty) {
			for (final void Function(EventDetails details) handler in _events[EventType.fade]!) handler(EventDetails(deltaOpacity: _opacity));
		}
		repaint();
	}

	void hide() {
		visible = false;
		if (_events[EventType.hide] != null && _events[EventType.hide]!.isNotEmpty) {
			for (final void Function(EventDetails details) handler in _events[EventType.hide]!) handler(const EventDetails());
		}
		if (_events[EventType.fade] != null && _events[EventType.fade]!.isNotEmpty) {
			for (final void Function(EventDetails details) handler in _events[EventType.fade]!) handler(EventDetails(deltaOpacity: -_opacity));
		}
		repaint();
	}

	void affect(Property source, Entity target, Property property, [double weight = 1]) {
		_affections[source]!.add(Affection(target, property, weight));
	}

	void disaffect([Property? source, Entity? target, Property? property]) {
		if (source == null) {
			for (final Property prop in Property.values) _affections[prop]!.clear();
		}
		else if (target == null) {
			_affections[source]!.clear();
		}
		else {
			for (final Affection af in _affections[source]!) {
				if (af.target == target && (property == null || af.property == property)) _affections[source]!.remove(af);
			}
		}
	}

	@protected void process(int milliseconds) {
		if (_animations.isNotEmpty) {
			final Map<Property, double?> changes = <Property, double?>{
				Property.x: null,
				Property.y: null,
				Property.width: null,
				Property.height: null,
				Property.angle: null,
				Property.opacity: null,
			};
			for (int i = _animations.length - 1; i >= 0; i--) {
				final Animation animation = _animations[i];
				changes[animation.property] = animation.calc(milliseconds);
				if (animation.complete) {
					if (animation.next()) animation.initiate(this);
					else _animations.remove(animation);
				}
			}
			if (changes[Property.x] != null) x = changes[Property.x]!;
			if (changes[Property.y] != null) y = changes[Property.y]!;
			if (changes[Property.width] != null) width = changes[Property.width]!;
			if (changes[Property.height] != null) height = changes[Property.height]!;
			if (changes[Property.angle] != null) angle = changes[Property.angle]!;
			if (changes[Property.opacity] != null) opacity = changes[Property.opacity]!;
		}
	}

	Animation animate(Property property, double value, int duration, {ml.Curve curve = ml.Curves.linear, bool loop = false, Function? callback, Function? tick}) {
		final Animation animation = Animation(property, value, duration, curve: curve, loop: loop, callback: callback, tick: tick);
		animation.initiate(this);
		_animations.add(animation);
		repaint();
		return animation;
	}

//	void force(List<Affect> properties) {
//		for (int i = _animations.length - 1; i >= 0; i--) {
//			Animation animation = _animations[i];
//			if (properties.isEmpty || properties.contains(animation.property)) {
//
//			}
//		}
//	}
//
//	void stop() {
//
//	}

	void on(EventType type, void Function(EventDetails details) handler) {
		if (_events[type] == null) _events[type] = <void Function(EventDetails details)>[];
		_events[type]!.add(handler);
	}

	void off([EventType? type, void Function(EventDetails details)? handler]) {
		if (type != null) {
			if (_events[type] == null) return;
			if (handler != null) _events[type]!.remove(handler);
			else _events[type]!.clear();
		}
		else _events.clear();
	}

	void build();

	@protected void render(ui.Canvas canvas, int milliseconds) {
		process(milliseconds);
		canvas.save();
		if (!updated) {
			build();
			updated = true;
		}
		if (_x != 0 || _y != 0) canvas.translate(_x, _y);
		if (_angle != 0) canvas.rotate(_angle);
		if (_pivotX != 0 || _pivotY != 0) canvas.translate(-_pivotX, -_pivotY);
		final ui.Paint paint = ui.Paint()..blendMode = backgroundBlend;
		if (background != null) {
			if (!background!.shadersOk) background!.compileShaders();
			final ui.ImageShader? shader = background!.shader();
			if (shader != null) paint
				..shader = shader
				..color = _applyOpacity(const ui.Color(0xFF000000));
			else paint.color = _applyOpacity(const ui.Color(0x00000000));
			canvas.drawPath(pathCache, paint);
		}
		if (color != null) {
			paint
				..shader = null
				..blendMode = blend
				..color = _applyOpacity(color!);
			canvas.drawPath(pathCache, paint);
		}
		if (strokeWidth > 0) {
			paint
				..shader = null
				..blendMode = strokeBlend
				..style = ui.PaintingStyle.stroke
				..strokeWidth = strokeWidth
				..color = _applyOpacity(strokeColor);
			canvas.drawPath(pathCache, paint);
		}
		canvas.restore();
	}

	@protected void repaint() {
		root!.repaint();
	}

}