part of renderme;

enum EventType {
	repaint,
	move,
	resize,
	rotate,
	hide,
	show,
	fade,
	drop,
}

enum Property {
	x,
	y,
	width,
	height,
	angle,
	opacity
}

class EventDetails {
	const EventDetails({this.deltaX, this.deltaY, this.deltaWidth, this.deltaHeight, this.deltaAngle, this.deltaOpacity});
	final double? deltaX;
	final double? deltaY;
	final double? deltaWidth;
	final double? deltaHeight;
	final double? deltaAngle;
	final double? deltaOpacity;
}

class Event {
	const Event(this.type, this.handler);
	final EventType type;
	final void Function(EventDetails details) handler;
}

class Affection {
	const Affection(this.target, this.property, this.weight);
	final Entity target;
	final Property property;
	final double weight;
}

class AnimationStage {
	AnimationStage(this.property, this.value, this.duration, {this.curve = ml.Curves.linear, this.loop = false, this.callback, this.tick});
	final Property property;
	final double value;
	final int duration;
	final ml.Curve curve;
	final bool loop;
	final Function? callback;
	final Function? tick;
}

class Animation {
	Animation(Property property, double value, int duration, {ml.Curve curve = ml.Curves.linear, bool loop = false, Function? callback, Function? tick}) {
		append(property, value, duration, curve: curve, loop: loop, callback: callback, tick: tick);
	}

	final List<AnimationStage> _stages = <AnimationStage>[];
	int _index = 0;
	double _initial = 0;
	int _elapsed = 0;
	Property get property => _stages[_index].property;
	bool get complete => _elapsed == _stages[_index].duration;
	Function? get callback => _stages[_index].callback;
	Function? get tick => _stages[_index].tick;

	void initiate(Entity entity) {
		switch (_stages[_index].property) {
			case Property.x: _initial = entity.x; break;
			case Property.y: _initial = entity.y; break;
			case Property.width: _initial = entity.width; break;
			case Property.height: _initial = entity.height; break;
			case Property.angle: _initial = entity.angle; break;
			case Property.opacity: _initial = entity.opacity; break;
			default: _initial = 0;
		}
		_elapsed = 0;
	}

	double calc(int milliseconds) {
		_elapsed += milliseconds;
		if (_elapsed >= _stages[_index].duration) _elapsed = _stages[_index].duration;
		return _initial + _stages[_index].curve.transform(_elapsed / _stages[_index].duration) * (_stages[_index].value - _initial);
	}

	bool next() {
		if (_index + 1 < _stages.length) {
			_index++;
			return true;
		}
		else if (_stages[_index].loop) {
			while (_index - 1 >= 0 && _stages[_index - 1].loop) _index--;
			return true;
		}
		else return false;
	}

	Animation append(Property property, double value, int duration, {ml.Curve curve = ml.Curves.linear, bool loop = false, Function? callback, Function? tick}) {
		_stages.add(AnimationStage(property, value, duration, curve: curve, loop: loop, callback: callback, tick: tick));
		return this;
	}
}

class ImageResource {
	ImageResource(Uint8List data, {ml.Alignment align = ml.Alignment.topLeft, double width = 0, double height = 0, double scaleX = 1, double scaleY = 1, ui.TileMode tileX = ui.TileMode.decal, ui.TileMode tileY = ui.TileMode.decal}) :
		_data = data, _align = align, _width = width, _height = height, _scaleX = scaleX, _scaleY = scaleY, _tileX = tileX, _tileY = tileY {
		init();
	}

	final Uint8List _data;
	ml.Alignment _align;
	double _width;
	double _height;
	double _scaleX;
	double _scaleY;
	ui.TileMode _tileX;
	ui.TileMode _tileY;
	final List<ui.Image> _images = <ui.Image>[];
	final List<ui.ImageShader> _shaders = <ui.ImageShader>[];
	final List<int> _durations = <int>[];
	bool shadersOk = false;
	int _duration = 0;
	int _index = 0;

	ml.Alignment get align => _align;
	double get width => _width;
	double get height => _height;
	double get scaleX => _scaleX;
	double get scaleY => _scaleY;
	ui.TileMode get tileX => _tileX;
	ui.TileMode get tileY => _tileY;
	int? shaderCallTime;
	int? imageCallTime;

	set align(ml.Alignment value) {
		 _align = value;
		 shadersOk = false;
	}
	set width(double value) {
		 _width = value;
		 shadersOk = false;
	}
	set height(double value) {
		_height = value;
		shadersOk = false;
	}
	set scaleX(double value) {
		_scaleX = value;
		shadersOk = false;
	}
	set scaleY(double value) {
		_scaleY = value;
		shadersOk = false;
	}
	set tileX(ui.TileMode value) {
		 _tileX = value;
		 shadersOk = false;
	}
	set tileY(ui.TileMode value) {
		 _tileY = value;
		 shadersOk = false;
	}

	ui.ImageShader? shader() {
		if (_shaders.isEmpty) return null;
		if (_shaders.length == 1) return _shaders[0];
		final int now = DateTime.now().millisecondsSinceEpoch;
		final int milliseconds = now - (shaderCallTime ?? now);
		shaderCallTime = now;
		if (_duration >= _durations[_index]) {
			_index++;
			_duration = 0;
			if (_index >= _shaders.length) _index = 0;
		}
		_duration += milliseconds;
		return _shaders[_index];
	}

	ui.Image? image() {
		if (_images.isEmpty) return null;
		if (_images.length == 1) return _images[0];
		final int now = DateTime.now().millisecondsSinceEpoch;
		final int milliseconds = now - (imageCallTime ?? now);
		imageCallTime = now;
		if (_duration >= _durations[_index]) {
			_index++;
			_duration = 0;
			if (_index >= _images.length) _index = 0;
		}
		_duration += milliseconds;
		return _images[_index];
	}

	// Future<ui.Image> _load(Uint8List data, int width, int height) async {
	// 	final Completer<ui.Image> completer = Completer<ui.Image>();
	//
	// 	ui.decodeImageFromPixels(
	// 		data,
	// 		width,
	// 		height,
	// 		ui.PixelFormat.rgba8888,
	// 		(ui.Image image) => completer.complete(image),
	// 	);
	// 	return completer.future;
	// }

	Future<void> init() async {
		ui.Codec? codec;
		try {
			// print(context.callMethod('append'));
			// final img.Animation? animation = img.decodePngAnimation(_data);
			// if (animation != null) {
			// 	for (final img.Image frame in animation.frames) {
			// 		_images.add(await _load(Uint8List.fromList(img.encodePng(frame)), frame.width, frame.height));
			// 		_durations.add(frame.duration);
			// 		print(frame);
			// 	}
			// }
			codec = await ui.instantiateImageCodec(_data);
			for (int i = 0; i < codec.frameCount; i++) {
				final ui.FrameInfo frame = await codec.getNextFrame();
				_images.add(frame.image);
				_durations.add(frame.duration.inMilliseconds);
			}
			shadersOk = false;
		}
		catch (error) {
			print(error);
			_images.clear();
			_durations.clear();
		}
		finally {
			codec?.dispose();
		}
	}

	void compileShaders() {
		_shaders.clear();
		final ml.Matrix4 mx = ml.Matrix4.identity();
		for (int i = 0; i < _images.length; i++) {
			if (i == 0) {
				final double w = _width == 0 ? _images[i].width.toDouble() : _width;
				final double h = _height == 0 ? _images[i].height.toDouble() : _height;
				mx.translate(-(_align.x + 1) * 0.5 * w, -(_align.y + 1) * 0.5 * h);
				double sx, sy;
				if (_width == 0) sx = _scaleX;
				else sx = _width / _images[i].width;
				if (_height == 0) sy = _scaleY;
				else sy = _height / _images[i].height;
				mx.scale(sx, sy);
			}
			_shaders.add(ui.ImageShader(_images[i], _tileX, _tileY, mx.storage, filterQuality: ui.FilterQuality.high));
		}
		shadersOk = true;
	}
}