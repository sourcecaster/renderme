part of renderme;

const List<EventType> _ownEvents = <EventType>[EventType.show, EventType.hide, EventType.fade, EventType.drop];

class Layer extends Container {
	Layer(Render root) : super(root);

	@override double get x => parent?.x ?? 0;
	@override double get y => parent?.y ?? 0;
	@override ui.Offset get position => parent?.position ?? ui.Offset.zero;
	@override double get angle => parent?.angle ?? 0;
	@override double get width => parent?.width ?? 0;
	@override double get height => parent?.height ?? 0;
	@override ui.Size get size => ui.Size(parent?.width ?? 0, parent?.height ?? 0);

	@override set x(double value) {}
	@override set y(double value) {}
	@override set position(ui.Offset value) {}
	@override set angle(double value) {}
	@override set pivotX(double value) {}
	@override set pivotY(double value) {}
	@override set pivot(ui.Offset value) {}
	@override set width(double value) {}
	@override set height(double value) {}
	@override set size(ui.Size value) {}

	@override
	void move([double? x, double? y, bool silent = false]) {}

	@override
	void rotate(double angle, [bool silent = false]) {}

	@override
	void resize([double? width, double? height, bool silent = false]) {}

	@override
	void affect(Property source, Entity target, Property property, [double weight = 1]) {
		parent?.affect(source, target, property, weight);
	}

	@override
	void disaffect([Property? source, Entity? target, Property? property]) {
		parent?.disaffect(source, target, property);
	}

	@override
	void on(EventType type, void Function(EventDetails details) handler) {
		if (_ownEvents.contains(type)) super.on(type, handler);
		else parent?.on(type, handler);
	}

	@override
	void off([EventType? type, void Function(EventDetails details)? handler]) {
		if (_ownEvents.contains(type)) super.off(type, handler);
		else parent?.off(type, handler);
	}

	@override
	void render(ui.Canvas canvas, int milliseconds) {
		for (final Entity child in children) {
			if (child.visible) child.render(canvas, milliseconds);
		}
	}
}