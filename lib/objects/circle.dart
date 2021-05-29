part of renderme;

class Circle extends Entity {
	Circle(Render root, double x, double y, double radius,
		{ui.Color? color, double? strokeWidth, ui.Color? strokeColor}) :
			_radius = radius, super(root) {
		_x = x;
		_y = y;
		this.color = color;
		if (strokeWidth != null) this.strokeWidth = strokeWidth;
		if (strokeColor != null) this.strokeColor = strokeColor;
	}

	double _radius;

	double get radius => _radius;

	set radius(double value) {
		_radius = value;
		updated = false;
		repaint();
	}

	@override
	void build() {
		pathCache.reset();
		pathCache.addOval(ui.Rect.fromLTRB(-_radius, -_radius, _radius, _radius));
	}

}