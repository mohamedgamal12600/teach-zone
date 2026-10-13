// category.dart
// Domain model representing a product category in TechZone.

class Category {
  final String id;
  final String name;
  final String? iconName;

  const Category({required this.id, required this.name, this.iconName});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Category &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name;

  @override
  int get hashCode => id.hashCode ^ name.hashCode;
}
