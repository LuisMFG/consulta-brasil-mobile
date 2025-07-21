import 'package:flutter/material.dart';

class SecurityData {
  final String year;
  final String state;
  final int victims;
  final int occurrences;
  final int warrants;
  final int fires;
  final int drugs;
  final CrimeDetails details;

  SecurityData({
    required this.year,
    required this.state,
    required this.victims,
    required this.occurrences,
    required this.warrants,
    required this.fires,
    required this.drugs,
    required this.details,
  });

  factory SecurityData.fromJson(Map<String, dynamic> json) {
    return SecurityData(
      year: json['year'] ?? '',
      state: json['state'] ?? '',
      victims: json['vitimas'] ?? 0,
      occurrences: json['ocorrencias'] ?? 0,
      warrants: json['mandados'] ?? 0,
      fires: json['incendios'] ?? 0,
      drugs: json['drogas'] ?? 0,
      details: CrimeDetails.fromJson(json['detalhamento'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'year': year,
      'state': state,
      'vitimas': victims,
      'ocorrencias': occurrences,
      'mandados': warrants,
      'incendios': fires,
      'drogas': drugs,
      'detalhamento': details.toJson(),
    };
  }
}

class CrimeDetails {
  final int homicides;
  final int thefts;
  final int robberies;
  final int rapes;

  CrimeDetails({
    required this.homicides,
    required this.thefts,
    required this.robberies,
    required this.rapes,
  });

  factory CrimeDetails.fromJson(Map<String, dynamic> json) {
    return CrimeDetails(
      homicides: json['homicidios'] ?? 0,
      thefts: json['furtos'] ?? 0,
      robberies: json['roubos'] ?? 0,
      rapes: json['estupros'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'homicidios': homicides,
      'furtos': thefts,
      'roubos': robberies,
      'estupros': rapes,
    };
  }

  int get total => homicides + thefts + robberies + rapes;

  List<CrimeItem> get crimeList => [
    CrimeItem(
      name: 'Homicídios',
      value: homicides,
      color: const Color(0xFFdc3545),
      icon: Icons.dangerous,
      description: 'Crime contra a vida praticado com intenção de matar',
    ),
    CrimeItem(
      name: 'Furtos',
      value: thefts,
      color: const Color(0xFF007bff),
      icon: Icons.no_accounts,
      description: 'Subtração de bem sem violência ou grave ameaça',
    ),
    CrimeItem(
      name: 'Roubos',
      value: robberies,
      color: const Color(0xFFfd7e14),
      icon: Icons.warning,
      description: 'Subtração de bem com violência ou grave ameaça',
    ),
    CrimeItem(
      name: 'Estupros',
      value: rapes,
      color: const Color(0xFF6f42c1),
      icon: Icons.shield,
      description: 'Crime contra a dignidade sexual',
    ),
  ];
}

class CrimeItem {
  final String name;
  final int value;
  final Color color;
  final IconData icon;
  final String description;

  CrimeItem({
    required this.name,
    required this.value,
    required this.color,
    required this.icon,
    required this.description,
  });

  double getPercentage(int total) {
    if (total == 0) return 0.0;
    return (value / total) * 100;
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

  factory SecurityStatistics.fromJson(Map<String, dynamic> json) {
    return SecurityStatistics(
      category: json['category'] ?? '',
      total: json['total'] ?? 0,
      byState: Map<String, int>.from(json['byState'] ?? {}),
      byMonth: Map<String, int>.from(json['byMonth'] ?? {}),
      year: json['year'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'category': category,
      'total': total,
      'byState': byState,
      'byMonth': byMonth,
      'year': year,
    };
  }
}

class NationalSecurityTotals {
  final int homicides;
  final int feminicides;
  final int robberies;
  final int thefts;
  final int rapes;
  final int policeDeaths;
  final int policeVictims;
  final String year;

  NationalSecurityTotals({
    required this.homicides,
    required this.feminicides,
    required this.robberies,
    required this.thefts,
    required this.rapes,
    required this.policeDeaths,
    required this.policeVictims,
    required this.year,
  });

  factory NationalSecurityTotals.fromJson(Map<String, dynamic> json, String year) {
    return NationalSecurityTotals(
      homicides: json['homicidios'] ?? 0,
      feminicides: json['feminicidios'] ?? 0,
      robberies: json['roubos'] ?? 0,
      thefts: json['furtos'] ?? 0,
      rapes: json['estupros'] ?? 0,
      policeDeaths: json['mortes_policiais'] ?? 0,
      policeVictims: json['vitimas_policiais'] ?? 0,
      year: year,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'homicidios': homicides,
      'feminicidios': feminicides,
      'roubos': robberies,
      'furtos': thefts,
      'estupros': rapes,
      'mortes_policiais': policeDeaths,
      'vitimas_policiais': policeVictims,
      'year': year,
    };
  }

  int get totalCrimes => homicides + robberies + thefts + rapes;
  int get totalPolice => policeDeaths + policeVictims;
}