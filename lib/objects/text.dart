part of renderme;

Map<ml.Alignment, ui.TextAlign> _textAlignment = <ml.Alignment, ui.TextAlign>{
	ml.Alignment.topLeft: ui.TextAlign.left,
	ml.Alignment.centerLeft: ui.TextAlign.left,
	ml.Alignment.bottomLeft: ui.TextAlign.left,
	ml.Alignment.topCenter: ui.TextAlign.center,
	ml.Alignment.center: ui.TextAlign.center,
	ml.Alignment.bottomCenter: ui.TextAlign.center,
	ml.Alignment.topRight: ui.TextAlign.right,
	ml.Alignment.centerRight: ui.TextAlign.right,
	ml.Alignment.bottomRight: ui.TextAlign.right,
};

Map<ml.Alignment, double> _alignXMultiplier = <ml.Alignment, double>{
	ml.Alignment.topLeft: 0,
	ml.Alignment.centerLeft: 0,
	ml.Alignment.bottomLeft: 0,
	ml.Alignment.topCenter: 0.5,
	ml.Alignment.center: 0.5,
	ml.Alignment.bottomCenter: 0.5,
	ml.Alignment.topRight: 1,
	ml.Alignment.centerRight: 1,
	ml.Alignment.bottomRight: 1,
};

Map<ml.Alignment, double> _alignYMultiplier = <ml.Alignment, double>{
	ml.Alignment.topLeft: 0,
	ml.Alignment.centerLeft: 0.5,
	ml.Alignment.bottomLeft: 1,
	ml.Alignment.topCenter: 0,
	ml.Alignment.center: 0.5,
	ml.Alignment.bottomCenter: 1,
	ml.Alignment.topRight: 0,
	ml.Alignment.centerRight: 0.5,
	ml.Alignment.bottomRight: 1,
};

class Text extends Entity {
	Text(Render root, double x, double y, String text,
		{double size = 14, ml.Alignment align = ml.Alignment.topLeft, ui.Color? color, double? strokeWidth, ui.Color? strokeColor}) :
			_text = text, _size = size, _align = align, super(root) {
		_x = x;
		_y = y;
		this.color = color;
		if (strokeWidth != null) this.strokeWidth = strokeWidth;
		if (strokeColor != null) this.strokeColor = strokeColor;
	}

	String _text = '';
	ml.Alignment _align;
	double _alignmentPivotX = 0;
	double _alignmentPivotY = 0;
	double _size;
	ui.FontStyle _style = ui.FontStyle.normal;
	ui.FontWeight _weight = ui.FontWeight.normal;
	double _lineHeight = 1.2;
	ui.Color? _backgroundColor;
	ml.TextSpan? span;
	ml.TextPainter painter = ml.TextPainter();

	String get text => _text;
	ml.Alignment get align => _align;
	double get fontSize => _size;
	ui.FontStyle get style => _style;
	ui.FontWeight get weight => _weight;
	double get lineHeight => _lineHeight;
	ui.Color? get backgroundColor => _backgroundColor;

	set text(String value) {
		_text = value;
		updated = false;
		repaint();
	}
	set align(ml.Alignment value) {
		_align = value;
		updated = false;
		repaint();
	}
	set fontSize(double value) {
		_size = value;
		updated = false;
		repaint();
	}
	set style(ui.FontStyle value) {
		_style = value;
		updated = false;
		repaint();
	}
	set weight(ui.FontWeight value) {
		_weight = value;
		updated = false;
		repaint();
	}
	set lineHeight(double value) {
		_lineHeight = value;
		updated = false;
		repaint();
	}
	set backgroundColor(ui.Color? value) {
		_backgroundColor = value;
		updated = false;
		repaint();
	}

	@override
	void build() {
		span = ml.TextSpan(
			text: _text,
			style: ml.TextStyle(
				fontSize: _size,
				fontStyle: _style,
				fontWeight: _weight,
				height: _lineHeight,
				backgroundColor: _backgroundColor,
				color: color,
			),
		);
		painter
			..text = span
			..textAlign = _textAlignment[_align]!
			..textDirection = ui.TextDirection.ltr
			..layout();
		width = painter.width;
		height = painter.height;
		_alignmentPivotX = width * _alignXMultiplier[_align]!;
		_alignmentPivotY = height * _alignYMultiplier[_align]!;
	}

	@override
	void render(ui.Canvas canvas, int milliseconds) {
		process(milliseconds);
		canvas.save();
		if (!updated) {
			build();
			updated = true;
		}
		if (x != 0 || y != 0) canvas.translate(x, y);
		if (angle != 0) canvas.rotate(angle);
		if (pivotX + _alignmentPivotX != 0 || pivotY + _alignmentPivotY != 0) canvas.translate(-pivotX - _alignmentPivotX, -pivotY - _alignmentPivotY);
		painter.paint(canvas, ui.Offset.zero);
		canvas.restore();
	}

}