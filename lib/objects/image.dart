part of renderme;

class Image extends Entity {
	Image(Render root, double x, double y, this.data, {double? width, double? height, ui.Color? background}) : super(root) {
		_x = x;
		_y = y;
		if (width != null) _width = width;
		if (height != null) _height = height;
		if (background != null) color = background;
	}

	ImageResource data;

	@override
	void build() {}

	@override
	void render(ui.Canvas canvas, int milliseconds) {
		process(milliseconds);
		canvas.save();
		if (x != 0 || y != 0) canvas.translate(x, y);
		if (angle != 0) canvas.rotate(angle);
		if (pivotX != 0 || pivotY != 0) canvas.translate(-pivotX, -pivotY);
		final ui.Image? image = data.image();
		if (image != null) {
			if (_width == 0) _width = image.width.toDouble();
			if (_height == 0) _height = image.height.toDouble();
			final ui.Paint paint = ui.Paint()..color = _applyOpacity(const ui.Color(0xFF000000));
			paint.isAntiAlias = true;
			final ui.Rect srcRect = ui.Rect.fromLTWH(0, 0, image.width.toDouble(), image.height.toDouble());
			final ui.Rect dstRect = ui.Rect.fromLTWH(0, 0, _width, _height);
			canvas.drawImageRect(image, srcRect, dstRect, paint);
		}
		canvas.restore();
	}
}