part of renderme;

class Group extends Container {
	Group(Render root, double x, double y, double width, double height) : super(root) {
		_x = x;
		_y = y;
		_width = width;
		_height = height;
	}
}