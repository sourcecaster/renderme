part of renderme;

class Path extends Entity {
	Path(Render root, {ui.Color? color, double? strokeWidth, ui.Color? strokeColor}) : super(root) {
		this.color = color;
		if (strokeWidth != null) this.strokeWidth = strokeWidth;
		if (strokeColor != null) this.strokeColor = strokeColor;
	}

	double _lx = 0, _ly = 0;

	void _dashedLine(double x, double y, List<int> dash) {
		final double r = sqrt((y - _ly) * (y - _ly) + (x - _lx) * (x - _lx));
		final double sin = (y - _ly) / r;
		final double cos = (x - _lx) / r;
		bool draw = true;
		int j = 0;
		double distance = 0;
		while (distance <= r) {
			distance += dash[j];
			final double x = _lx + distance * cos;
			final double y = _ly + distance * sin;
			if (draw) pathCache.lineTo(x, y);
			else pathCache.moveTo(x, y);
			if (++j >= dash.length) j = 0;
			draw = !draw;
		}
	}

	void clear() {
		pathCache.reset();
		repaint();
	}

	void to(double x, double y) {
		pathCache.moveTo(x, y);
		_lx = x;
		_ly = y;
		repaint();
	}

	void line(double x, double y, {List<int> dash = const <int>[]}) {
		if (dash == null || dash.isEmpty) pathCache.lineTo(x, y);
		else _dashedLine(x, y, dash);
		_lx = x;
		_ly = y;
		repaint();
	}

	void curve(double cx, double cy, double x, double y) {
		pathCache.quadraticBezierTo(cx, cy, x, y);
		_lx = x;
		_ly = y;
		repaint();
	}

	void bezier(double cx1, double cy1, double cx2, double cy2, double x, double y) {
		pathCache.cubicTo(cx1, cy1, cx2, cy2, x, y);
		_lx = x;
		_ly = y;
		repaint();
	}

	void rect(double x, double y, double width, double height) {
		pathCache.addRect(ui.Rect.fromLTWH(x, y, width, height));
		repaint();
	}

	void arc(double x, double y, double r, double start, double end, [bool acw = false]) {
		pathCache.arcTo(ui.Rect.fromLTRB(x - r, y - r, x + r, y + r), start, acw ? start - end : end - start, false);
		repaint();
	}

	void ellipse(double x, double y, double rx, double ry, double start, double end, [bool acw = false]) {
		pathCache.arcTo(ui.Rect.fromLTRB(x - rx, y - ry, x + rx, y + ry), start, acw ? start - end : end - start, false);
		repaint();
	}

	void close() {
		pathCache.close();
		repaint();
	}

	@override
	void build() {
	}

}