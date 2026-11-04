abstract class Equatable {
  const Equatable();

  List<Object?> get props;

  bool? get stringify => null;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is Equatable &&
            runtimeType == other.runtimeType &&
            _equals(props, other.props);
  }

  static bool _equals(Object? a, Object? b) {
    if (identical(a, b)) return true;
    if (a is List && b is List) {
      if (a.length != b.length) return false;
      for (var i = 0; i < a.length; i++) {
        if (!_equals(a[i], b[i])) return false;
      }
      return true;
    }
    if (a is Map && b is Map) {
      if (a.length != b.length) return false;
      for (final key in a.keys) {
        if (!b.containsKey(key) || !_equals(a[key], b[key])) return false;
      }
      return true;
    }
    if (a is Set && b is Set) {
      if (a.length != b.length) return false;
      return a.every((e) => b.any((be) => _equals(e, be)));
    }
    return a == b;
  }

  @override
  int get hashCode => runtimeType.hashCode ^ _hash(props);

  static int _hash(Object? obj) {
    if (obj is List) {
      return Object.hashAll(obj.map(_hash));
    }
    if (obj is Map) {
      return Object.hashAll(obj.entries.map((e) => Object.hash(_hash(e.key), _hash(e.value))));
    }
    if (obj is Set) {
      return Object.hashAllUnordered(obj.map(_hash));
    }
    return obj.hashCode;
  }

  @override
  String toString() {
    return '$runtimeType(${props.join(', ')})';
  }
}
