part of renderme;

class Ellipse extends Entity {
	Ellipse(Render root, double x, double y, double radiusX, double radiusY,
		{ui.Color? color, double? strokeWidth, ui.Color? strokeColor}) :
			_radiusX = radiusX, _radiusY = radiusY, super(root) {
		_x = x;
		_y = y;
		this.color = color;
		if (strokeWidth != null) this.strokeWidth = strokeWidth;
		if (strokeColor != null) this.strokeColor = strokeColor;
	}

	double _radiusX;
	double _radiusY;

	double get radiusX => _radiusX;
	double get radiusY => _radiusY;

	set radiusX(double value) {
		_radiusX = value;
		updated = false;
		repaint();
	}
	set radiusY(double value) {
		_radiusY = value;
		updated = false;
		repaint();
	}

	void radius(double x, double y) {
		_radiusX = x;
		_radiusY = y;
		updated = false;
		repaint();
	}

	@override
	void build() {
		pathCache.reset();
		pathCache.addOval(ui.Rect.fromLTRB(-_radiusX, -_radiusY, _radiusX, _radiusY));
	}

}