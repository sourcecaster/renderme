part of renderme;

class Container extends Entity {
	Container(Render? root) : super(root);

	final List<Entity> children = <Entity>[];
	bool clip = false;
	bool lazy = false;

	void sort() {
		children.sort((Entity a, Entity b) => (a.order > b.order) ? 1 : (a.order < b.order) ? -1 : 0);
	}

	T add<T>(Entity child) {
		child.parent = this;
		children.add(child);
		if (!lazy) sort();
		repaint();
		return child as T;
	}

	bool has(Entity child) {
		return children.contains(child);
	}

	void clear() {
		children.clear();
		repaint();
	}

	Group group(double x, double y, double width, double height) {
		return add(Group(root!, x, y, width, height));
	}

	Layer layer() {
		return add(Layer(root!));
	}

	Rectangle rectangle(double x, double y, double width, double height, {ui.Color? color, double? strokeWidth, ui.Color? strokeColor}) {
		return add<Rectangle>(Rectangle(root!, x, y, width, height,
			color: color,
			strokeWidth: strokeWidth,
			strokeColor: strokeColor,
		));
	}

	Arc arc(double x, double y, double radiusX, double radiusY, {double startAngle = 0, double endAngle = 2 * pi, ui.Color? color, double? strokeWidth, ui.Color? strokeColor}) {
		return add(Arc(root!, x, y, radiusX, radiusY,
			startAngle: startAngle,
			endAngle: endAngle,
			color: color,
			strokeWidth: strokeWidth,
			strokeColor: strokeColor,
		));
	}

	Circle circle(double x, double y, double radius, {ui.Color? color, double? strokeWidth, ui.Color? strokeColor}) {
		return add(Circle(root!, x, y, radius,
			color: color,
			strokeWidth: strokeWidth,
			strokeColor: strokeColor,
		));
	}

	Ellipse ellipse(double x, double y, double radiusX, double radiusY, {ui.Color? color, double? strokeWidth, ui.Color? strokeColor}) {
		return add(Ellipse(root!, x, y, radiusX, radiusY,
			color: color,
			strokeWidth: strokeWidth,
			strokeColor: strokeColor,
		));
	}

	Text text(double x, double y, String text, {double size = 14, ml.Alignment align = ml.Alignment.topLeft, ui.Color? color, double? strokeWidth, ui.Color? strokeColor}) {
		return add(Text(root!, x, y, text,
			size: size,
			align: align,
			color: color,
			strokeWidth: strokeWidth,
			strokeColor: strokeColor,
		));
	}

	Line line(double x, double y, {ui.Color? color, double? strokeWidth, ui.Color? strokeColor, bool closed = false}) {
		return add(Line(root!, x, y,
			closed: closed,
			color: color,
			strokeWidth: strokeWidth,
			strokeColor: strokeColor,
		));
	}

	Path path({ui.Color? color, double? strokeWidth, ui.Color? strokeColor}) {
		return add(Path(root!,
			color: color,
			strokeWidth: strokeWidth,
			strokeColor: strokeColor,
		));
	}

	Image image(ImageResource data, double x, double y, {double? width, double? height, ui.Color? background}) {
		return add(Image(root!, x, y, data,
			width: width,
			height: height,
			background: background,
		));
	}

	@override
	void build() {
		if (clip) {
			pathCache.reset();
			pathCache.addRect(ui.Rect.fromLTWH(0, 0, _width, _height));
		}
	}

	@override
	void render(ui.Canvas canvas, int milliseconds) {
		process(milliseconds);
		canvas.save();
		if (x != 0 || y != 0) canvas.translate(x, y);
		if (angle != 0) canvas.rotate(angle);
		if (pivotX != 0 || pivotY != 0) canvas.translate(-pivotX, -pivotY);
		if (clip) {
			if (!updated) {
				build();
				updated = true;
			}
			canvas.clipPath(pathCache);
		}
		for (final Entity child in children) {
			if (child.visible) child.render(canvas, milliseconds);
		}
		canvas.restore();
	}

}