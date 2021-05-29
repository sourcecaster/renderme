part of renderme;

class Point extends Entity {
	Point(Render root, this.owner) : super(root);

	Entity owner;

	@override
	void drop() {
		owner.updated = false;
		super.drop();
	}

	@override
	void move([double? x, double? y, bool silent = false]) {
		owner.updated = false;
		super.move(x, y, silent);
	}

	@override
	void build() {
	}
}