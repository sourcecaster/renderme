part of renderme;

class Rectangle extends Entity {
	Rectangle(Render root, double x, double y, double width, double height, {ui.Color? color, double? strokeWidth, ui.Color? strokeColor}) : super(root) {
		_x = x;
		_y = y;
		_width = width;
		_height = height;
		this.color = color;
		if (strokeWidth != null) this.strokeWidth = strokeWidth;
		if (strokeColor != null) this.strokeColor = strokeColor;
	}

	double _topLeftRadius = 0;
	double _topRightRadius = 0;
	double _bottomRightRadius = 0;
	double _bottomLeftRadius = 0;

	double get topLeftRadius => _topLeftRadius;
	double get topRightRadius => _topRightRadius;
	double get bottomRightRadius => _bottomRightRadius;
	double get bottomLeftRadius => _bottomLeftRadius;

	set topLeftRadius(double value) {
		_topLeftRadius = value;
		updated = false;
		repaint();
	}
	set topRightRadius(double value) {
		_topRightRadius = value;
		updated = false;
		repaint();
	}
	set bottomRightRadius(double value) {
		_bottomRightRadius = value;
		updated = false;
		repaint();
	}
	set bottomLeftRadius(double value) {
		_bottomLeftRadius = value;
		updated = false;
		repaint();
	}

	void round(double topLeft, double topRight, double bottomRight, double bottomLeft) {
		_topLeftRadius = topLeft;
		_topRightRadius = topRight;
		_bottomRightRadius = bottomRight;
		_bottomLeftRadius = bottomLeft;
		updated = false;
		repaint();
	}

	@override
	void build() {
		pathCache.reset();
		final ui.Rect rect = ui.Rect.fromLTWH(0, 0, width, height);
		if (_topLeftRadius > 0 || _topRightRadius > 0 || _bottomRightRadius > 0 || _bottomLeftRadius > 0) {
			pathCache.addRRect(ui.RRect.fromRectAndCorners(rect,
				topLeft: ui.Radius.circular(_topLeftRadius),
				topRight: ui.Radius.circular(_topRightRadius),
				bottomRight: ui.Radius.circular(_bottomRightRadius),
				bottomLeft: ui.Radius.circular(_bottomLeftRadius),
			));
		}
		else {
			pathCache.addRect(rect);
		}
	}

}