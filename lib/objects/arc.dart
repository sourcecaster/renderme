part of renderme;

class Arc extends Entity {
	Arc(Render root, double x, double y, double radiusX, double radiusY,
		{required double startAngle, required double endAngle, ui.Color? color, double? strokeWidth, ui.Color? strokeColor}) :
			_radiusX = radiusX, _radiusY = radiusY, _startAngle = startAngle, _endAngle = endAngle, super(root) {
		_x = x;
		_y = y;
		this.color = color;
		if (strokeWidth != null) this.strokeWidth = strokeWidth;
		if (strokeColor != null) this.strokeColor = strokeColor;
	}

	double _radiusX;
	double _radiusY;
	double _startAngle;
	double _endAngle;
	bool _closed = true;

	double get radiusX => _radiusX;
	double get radiusY => _radiusY;
	double get startAngle => _startAngle;
	double get endAngle => _endAngle;
	bool get closed => _closed;

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
	set startAngle(double value) {
		_startAngle = value;
		updated = false;
		repaint();
	}
	set endAngle(double value) {
		_endAngle = value;
		updated = false;
		repaint();
	}
	set closed(bool value) {
		_closed = value;
		updated = false;
		repaint();
	}

	void radius(double x, double y) {
		_radiusX = x;
		_radiusY = y;
		updated = false;
		repaint();
	}

	void sector(double start, double end) {
		_startAngle = start;
		_endAngle = end;
		updated = false;
		repaint();
	}

	@override
	void build() {
		pathCache.reset();
		pathCache.addArc(ui.Rect.fromLTRB(-_radiusX, -_radiusY, _radiusX, _radiusY), _startAngle, _endAngle - _startAngle);
		if (closed) {
			if ((_endAngle - _startAngle) % pi != 0) pathCache.lineTo(0, 0);
			pathCache.close();
		}
	}

}