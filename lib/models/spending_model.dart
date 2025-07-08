import 'package:flutter/material.dart';

class SectorSpending {
  final String name;
  final double value;
  final Color color;

  SectorSpending({
    required this.name,
    required this.value,
    required this.color,
  });

  factory SectorSpending.fromJson(Map<String, dynamic> json) {
    return SectorSpending(
      name: json['name'],
      value: json['value'].toDouble(),
      color: Color(int.parse(json['color'].substring(1), radix: 16) + 0xFF000000),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'value': value,
      'color': '#${color.value.toRadixString(16).substring(2)}',
    };
  }
}

class SpendingModel {
  final List<SectorSpending> sectors;

  SpendingModel({required this.sectors});

  factory SpendingModel.fromJson(Map<String, dynamic> json) {
    return SpendingModel(
      sectors: (json['sectors'] as List)
          .map((sector) => SectorSpending.fromJson(sector))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'sectors': sectors.map((sector) => sector.toJson()).toList(),
    };
  }
}