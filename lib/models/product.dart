// product.dart
import 'package:flutter/material.dart';

class Product {
  final String id;
  final String brand;
  final String name;
  final String category;
  final String image;
  final double price;
  final double? oldPrice;
  final List<Color> colors;
  final String views;
  final int likes;
  final int sold;
  final double rating;
  final String description;

  /// Key-value spec pairs, e.g. {'Processor': 'M4 Pro', 'RAM': '24 GB'}
  final Map<String, String> specs;

  const Product({
    required this.id,
    required this.brand,
    required this.name,
    required this.category,
    required this.image,
    required this.price,
    this.oldPrice,
    required this.colors,
    required this.views,
    required this.likes,
    required this.sold,
    this.rating = 4.5,
    this.description = '',
    this.specs = const {},
  });
}
