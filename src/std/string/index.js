export function uppercase(s) {
	return s.toUpperCase();
}

export function lowercase(s) {
	return s.toLowerCase();
}

export function trim(s) {
	return s.trim();
}

export function length(s) {
	return s.length;
}

export function slice(s, start, end) {
	return s.slice(start, end);
}

export function includes(s, sub) {
	return s.includes(sub);
}

export function split(s, sep) {
	return s.split(sep);
}

export function replace(s, from, to) {
	return s.replace(from, to);
}

export function concat(a, b) {
	return a + b;
}
