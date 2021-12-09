class_name Utils

static func or_default(val, default):
	return val if val else default

static func s_plural(noun, count):
	return str(count) + " " + noun + ("" if count == 1 else "s")
