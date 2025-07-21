import 'package:flutter/material.dart';

class SecurityUtils {
  static String formatNumber(dynamic value) {
    if (value == null) return '0';
    final num = value is int ? value : int.tryParse(value.toString()) ?? 0;

    if (num >= 1000000) {
      return '${(num / 1000000).toStringAsFixed(1)}M';
    } else if (num >= 1000) {
      return '${(num / 1000).toStringAsFixed(1)}K';
    } else {
      return _addThousandsSeparator(num);
    }
  }

  static String _addThousandsSeparator(int number) {
    return number.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]}.',
    );
  }

  static String formatPercentage(double percentage) {
    return '${percentage.toStringAsFixed(1)}%';
  }

  static Color getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'vítimas':
      case 'victims':
        return const Color(0xFFE53E3E);
      case 'ocorrências':
      case 'occurrences':
        return const Color(0xFF3182CE);
      case 'mandados':
      case 'warrants':
        return const Color(0xFF805AD5);
      case 'incêndios':
      case 'fires':
        return const Color(0xFFD69E2E);
      case 'drogas':
      case 'drugs':
        return const Color(0xFF38A169);
      default:
        return const Color(0xFF718096);
    }
  }

  static IconData getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'vítimas':
      case 'victims':
        return Icons.person_outline;
      case 'ocorrências':
      case 'occurrences':
        return Icons.description_outlined;
      case 'mandados':
      case 'warrants':
        return Icons.gavel_outlined;
      case 'incêndios':
      case 'fires':
        return Icons.local_fire_department_outlined;
      case 'drogas':
      case 'drugs':
        return Icons.medical_services_outlined;
      default:
        return Icons.info_outline;
    }
  }

  static String getCategoryDescription(String category) {
    switch (category.toLowerCase()) {
      case 'vítimas':
      case 'victims':
        return 'Estatísticas de vítimas de crimes';
      case 'ocorrências':
      case 'occurrences':
        return 'Registros de ocorrências policiais';
      case 'mandados':
      case 'warrants':
        return 'Mandados de prisão cumpridos';
      case 'incêndios':
      case 'fires':
        return 'Ocorrências bombeirísticas';
      case 'drogas':
      case 'drugs':
        return 'Apreensões de drogas';
      default:
        return 'Dados de segurança pública';
    }
  }

  static String getYearDisplayName(String year) {
    return 'Ano $year';
  }

  static String getStateDisplayName(String stateCode, String stateName) {
    return '$stateName ($stateCode)';
  }

  static List<String> getAvailableYears() {
    return ['2021', '2022', '2023', '2024', '2025'];
  }

  static Map<String, String> getBrazilianStates() {
    return {
      'SP': 'São Paulo',
      'RJ': 'Rio de Janeiro',
      'MG': 'Minas Gerais',
      'BA': 'Bahia',
      'RS': 'Rio Grande do Sul',
      'PR': 'Paraná',
      'PE': 'Pernambuco',
      'CE': 'Ceará',
      'SC': 'Santa Catarina',
      'GO': 'Goiás',
      'MA': 'Maranhão',
      'PB': 'Paraíba',
      'PA': 'Pará',
      'ES': 'Espírito Santo',
      'AL': 'Alagoas',
      'MT': 'Mato Grosso',
      'MS': 'Mato Grosso do Sul',
      'SE': 'Sergipe',
      'RN': 'Rio Grande do Norte',
      'PI': 'Piauí',
      'DF': 'Distrito Federal',
      'TO': 'Tocantins',
      'AC': 'Acre',
      'RO': 'Rondônia',
      'AM': 'Amazonas',
      'RR': 'Roraima',
      'AP': 'Amapá',
    };
  }

  static String getCrimeTypeDescription(String crimeType) {
    switch (crimeType.toLowerCase()) {
      case 'homicídios':
      case 'homicides':
        return 'Crime contra a vida praticado com intenção de matar';
      case 'furtos':
      case 'thefts':
        return 'Subtração de bem sem violência ou grave ameaça';
      case 'roubos':
      case 'robberies':
        return 'Subtração de bem com violência ou grave ameaça';
      case 'estupros':
      case 'rapes':
        return 'Crime contra a dignidade sexual';
      case 'feminicídios':
      case 'feminicides':
        return 'Homicídio cometido contra mulher por razões de gênero';
      case 'latrocínios':
      case 'robberies_with_death':
        return 'Roubo seguido de morte';
      default:
        return 'Tipo de crime registrado pela segurança pública';
    }
  }

  static Color getCrimeTypeColor(String crimeType) {
    switch (crimeType.toLowerCase()) {
      case 'homicídios':
      case 'homicides':
        return const Color(0xFFdc3545);
      case 'furtos':
      case 'thefts':
        return const Color(0xFF007bff);
      case 'roubos':
      case 'robberies':
        return const Color(0xFFfd7e14);
      case 'estupros':
      case 'rapes':
        return const Color(0xFF6f42c1);
      case 'feminicídios':
      case 'feminicides':
        return const Color(0xFFe83e8c);
      case 'latrocínios':
      case 'robberies_with_death':
        return const Color(0xFF6c757d);
      default:
        return const Color(0xFF28a745);
    }
  }

  static IconData getCrimeTypeIcon(String crimeType) {
    switch (crimeType.toLowerCase()) {
      case 'homicídios':
      case 'homicides':
        return Icons.dangerous;
      case 'furtos':
      case 'thefts':
        return Icons.no_accounts;
      case 'roubos':
      case 'robberies':
        return Icons.warning;
      case 'estupros':
      case 'rapes':
        return Icons.shield;
      case 'feminicídios':
      case 'feminicides':
        return Icons.woman;
      case 'latrocínios':
      case 'robberies_with_death':
        return Icons.local_police;
      default:
        return Icons.security;
    }
  }

  static double calculatePercentage(int value, int total) {
    if (total == 0) return 0.0;
    return (value / total) * 100;
  }

  static String getDataSource() {
    return 'Fonte: Sistema Nacional de Informações de Segurança Pública (SINESP)';
  }

  static String getLastUpdateInfo() {
    final now = DateTime.now();
    return 'Última atualização: ${now.day}/${now.month}/${now.year}';
  }

  static bool isValidYear(String year) {
    return getAvailableYears().contains(year);
  }

  static bool isValidState(String stateCode) {
    return getBrazilianStates().containsKey(stateCode);
  }

  static String getStatusMessage(bool isLoading, String? error, String category) {
    if (isLoading) {
      return 'Carregando dados de $category...';
    }
    if (error != null) {
      return 'Erro: $error';
    }
    return 'Dados sobre $category carregados com sucesso';
  }

  static Map<String, dynamic> getDefaultSecurityData() {
    return {
      'vitimas': 0,
      'ocorrencias': 0,
      'mandados': 0,
      'incendios': 0,
      'drogas': 0,
      'detalhamento': {
        'homicidios': 0,
        'furtos': 0,
        'roubos': 0,
        'estupros': 0,
      },
    };
  }

  static List<Map<String, dynamic>> getSecurityCategories() {
    return [
      {
        'key': 'Vítimas',
        'icon': Icons.person_outline,
        'color': const Color(0xFFE53E3E),
        'description': getCategoryDescription('Vítimas'),
      },
      {
        'key': 'Ocorrências',
        'icon': Icons.description_outlined,
        'color': const Color(0xFF3182CE),
        'description': getCategoryDescription('Ocorrências'),
      },
      {
        'key': 'Mandados',
        'icon': Icons.gavel_outlined,
        'color': const Color(0xFF805AD5),
        'description': getCategoryDescription('Mandados'),
      },
      {
        'key': 'Incêndios',
        'icon': Icons.local_fire_department_outlined,
        'color': const Color(0xFFD69E2E),
        'description': getCategoryDescription('Incêndios'),
      },
      {
        'key': 'Drogas',
        'icon': Icons.medical_services_outlined,
        'color': const Color(0xFF38A169),
        'description': getCategoryDescription('Drogas'),
      },
    ];
  }
}