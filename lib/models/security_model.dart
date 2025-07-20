import 'package:flutter/material.dart';

class SecurityData {
  final String indicator;
  final String uf;
  final String region;
  final int value;
  final String year;
  final String month;

  SecurityData({
    required this.indicator,
    required this.uf,
    required this.region,
    required this.value,
    required this.year,
    required this.month,
  });

  factory SecurityData.fromJson(Map<String, dynamic> json) {
    return SecurityData(
      indicator: json['indicador'] ?? json['indicator'] ?? '',
      uf: json['uf'] ?? '',
      region: json['regiao'] ?? json['region'] ?? '',
      value: _parseInt(json['valor'] ?? json['value'] ?? 0),
      year: json['ano'] ?? json['year'] ?? '',
      month: json['mes'] ?? json['month'] ?? '',
    );
  }

  static int _parseInt(dynamic value) {
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }
}

class SecurityCategory {
  final String id;
  final String name;
  final IconData icon;
  final Color color;
  final String description;

  SecurityCategory({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
    required this.description,
  });
}

class SecurityStatistics {
  final String category;
  final int total;
  final Map<String, int> byState;
  final Map<String, int> byMonth;
  final String year;

  SecurityStatistics({
    required this.category,
    required this.total,
    required this.byState,
    required this.byMonth,
    required this.year,
  });
}

class SecurityFilter {
  final String year;
  final String state;
  final String category;

  SecurityFilter({
    required this.year,
    required this.state,
    required this.category,
  });

  SecurityFilter copyWith({
    String? year,
    String? state,
    String? category,
  }) {
    return SecurityFilter(
      year: year ?? this.year,
      state: state ?? this.state,
      category: category ?? this.category,
    );
  }
}