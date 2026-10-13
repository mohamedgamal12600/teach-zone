// brand.dart
// Domain model representing an electronics manufacturer brand.

class Brand {
  final String name;
  final String logoUrl;

  const Brand({required this.name, required this.logoUrl});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Brand &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          logoUrl == other.logoUrl;

  @override
  int get hashCode => name.hashCode ^ logoUrl.hashCode;
}
