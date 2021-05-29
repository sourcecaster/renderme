part of renderme;

class Line extends Entity {
	Line(Render root, double x, double y, {bool closed = false, ui.Color? color, double? strokeWidth, ui.Color? strokeColor}) : _closed = closed, super(root) {
		to(x, y);
		this.color = color;
		if (strokeWidth != null) this.strokeWidth = strokeWidth;
		if (strokeColor != null) this.strokeColor = strokeColor;
	}

	final List<Point> _points = <Point>[];
	bool _closed;

	List<Point> get points => _points;
	List<int> _dash = <int>[];
	bool get closed => _closed;
	List<int> get dash => _dash;

	set closed(bool value) {
		_closed = value;
		updated = false;
		repaint();
	}

	set dash(List<int> value) {
		_dash = value;
		updated = false;
		repaint();
	}

	void _dashedLine(int a, int b) {
		final double r = sqrt((points[b].y - points[a].y) * (points[b].y - points[a].y) + (points[b].x - points[a].x) * (points[b].x - points[a].x));
		final double sin = (points[b].y - points[a].y) / r;
		final double cos = (points[b].x - points[a].x) / r;
		bool draw = true;
		int j = 0;
		double distance = 0;
		while (distance <= r) {
			distance += dash[j];
			final double x = points[a].x + distance * cos;
			final double y = points[a].y + distance * sin;
			if (draw) pathCache.lineTo(x, y);
			else pathCache.moveTo(x, y);
			if (++j >= dash.length) j = 0;
			draw = !draw;
		}
	}

	void clear() {
		_points.clear();
		updated = false;
		repaint();
	}

	void to(double x, double y) {
		final Point point = Point(root!, this)
		..move(x, y);
		_points.add(point);
		updated = false;
		repaint();
	}

	@override
	void build() {
		pathCache.reset();
		if (points.isNotEmpty) {
			pathCache.moveTo(points[0].x, points[0].y);
			for (int i = 1; i < points.length; i++) {
				if (dash.isEmpty) pathCache.lineTo(points[i].x, points[i].y);
				else _dashedLine(i - 1, i);
			}
			if (closed) {
				if (dash.isEmpty) pathCache.close();
				else _dashedLine(points.length - 1, 0);
			}
		}
	}

}