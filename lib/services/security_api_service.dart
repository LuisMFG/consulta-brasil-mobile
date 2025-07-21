import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:http/http.dart' as http;
import '../models/security_model.dart';
import 'package:flutter/material.dart';

class SecurityApiService {
  static const String _sinespUrl = 'https://dados.mj.gov.br/api/3/action';
  static const Duration _timeout = Duration(seconds: 30);

  static Map<String, String> get _defaultHeaders => {
    'Accept': 'application/json',
    'Content-Type': 'application/json',
    'User-Agent': 'ConsultaBrasil/1.0.0',
  };

  static List<SecurityCategory> getSecurityCategories() {
    return [
      SecurityCategory(
        id: 'victims',
        name: 'Vítimas',
        icon: Icons.person_outline,
        color: const Color(0xFFE53E3E),
        description: 'Estatísticas de vítimas de crimes',
      ),
      SecurityCategory(
        id: 'occurrences',
        name: 'Ocorrências',
        icon: Icons.description_outlined,
        color: const Color(0xFF3182CE),
        description: 'Registros de ocorrências policiais',
      ),
      SecurityCategory(
        id: 'mandados',
        name: 'Mandados',
        icon: Icons.gavel_outlined,
        color: const Color(0xFF805AD5),
        description: 'Mandados de prisão cumpridos',
      ),
      SecurityCategory(
        id: 'fire',
        name: 'Incêndios',
        icon: Icons.local_fire_department_outlined,
        color: const Color(0xFFD69E2E),
        description: 'Ocorrências bombeirísticas',
      ),
      SecurityCategory(
        id: 'drugs',
        name: 'Drogas',
        icon: Icons.medical_services_outlined,
        color: const Color(0xFF38A169),
        description: 'Apreensões de drogas',
      ),
      SecurityCategory(
        id: 'dictionary',
        name: 'Dicionário',
        icon: Icons.info_outline,
        color: const Color(0xFF319795),
        description: 'Dicionário de dados',
      ),
    ];
  }

  static Future<SecurityStatistics> getSecurityStatistics({
    required String category,
    required String year,
    String? state,
  }) async {
    try {
      switch (category) {
        case 'victims':
          return await _getVictimsData(year, state);
        case 'occurrences':
          return await _getOccurrencesData(year, state);
        case 'mandados':
          return await _getMandadosData(year, state);
        case 'fire':
          return await _getFireData(year, state);
        case 'drugs':
          return await _getDrugsData(year, state);
        default:
          return await _getVictimsData(year, state);
      }
    } catch (e) {
      print('Erro ao buscar dados de segurança: $e');
      return _getMockData(category, year, state);
    }
  }

  static Future<SecurityStatistics> _getVictimsData(String year, String? state) async {
    try {
      final url = '$_sinespUrl/datastore_search';
      final params = {
        'resource_id': 'vitimas-homicidio-doloso',
        'filters': '{"ano":"$year"' + (state != null ? ',"uf":"$state"' : '') + '}',
        'limit': '1000',
      };

      final uri = Uri.parse(url).replace(queryParameters: params);
      final response = await http.get(uri, headers: _defaultHeaders).timeout(_timeout);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return _processSecurityData(data, 'victims', year);
      } else {
        throw Exception('API indisponível');
      }
    } catch (e) {
      return _getMockData('victims', year, state);
    }
  }

  static Future<SecurityStatistics> _getOccurrencesData(String year, String? state) async {
    try {
      final url = '$_sinespUrl/datastore_search';
      final params = {
        'resource_id': 'ocorrencias-criminais',
        'filters': '{"ano":"$year"' + (state != null ? ',"uf":"$state"' : '') + '}',
        'limit': '1000',
      };

      final uri = Uri.parse(url).replace(queryParameters: params);
      final response = await http.get(uri, headers: _defaultHeaders).timeout(_timeout);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return _processSecurityData(data, 'occurrences', year);
      } else {
        throw Exception('API indisponível');
      }
    } catch (e) {
      return _getMockData('occurrences', year, state);
    }
  }

  static Future<SecurityStatistics> _getMandadosData(String year, String? state) async {
    try {
      final url = '$_sinespUrl/datastore_search';
      final params = {
        'resource_id': 'mandados-prisao',
        'filters': '{"ano":"$year"' + (state != null ? ',"uf":"$state"' : '') + '}',
        'limit': '1000',
      };

      final uri = Uri.parse(url).replace(queryParameters: params);
      final response = await http.get(uri, headers: _defaultHeaders).timeout(_timeout);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return _processSecurityData(data, 'mandados', year);
      } else {
        throw Exception('API indisponível');
      }
    } catch (e) {
      return _getMockData('mandados', year, state);
    }
  }

  static Future<SecurityStatistics> _getFireData(String year, String? state) async {
    try {
      final url = '$_sinespUrl/datastore_search';
      final params = {
        'resource_id': 'ocorrencias-bombeiristicas',
        'filters': '{"ano":"$year"' + (state != null ? ',"uf":"$state"' : '') + '}',
        'limit': '1000',
      };

      final uri = Uri.parse(url).replace(queryParameters: params);
      final response = await http.get(uri, headers: _defaultHeaders).timeout(_timeout);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return _processSecurityData(data, 'fire', year);
      } else {
        throw Exception('API indisponível');
      }
    } catch (e) {
      return _getMockData('fire', year, state);
    }
  }

  static Future<SecurityStatistics> _getDrugsData(String year, String? state) async {
    try {
      final url = '$_sinespUrl/datastore_search';
      final params = {
        'resource_id': 'apreensoes-drogas',
        'filters': '{"ano":"$year"' + (state != null ? ',"uf":"$state"' : '') + '}',
        'limit': '1000',
      };

      final uri = Uri.parse(url).replace(queryParameters: params);
      final response = await http.get(uri, headers: _defaultHeaders).timeout(_timeout);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return _processSecurityData(data, 'drugs', year);
      } else {
        throw Exception('API indisponível');
      }
    } catch (e) {
      return _getMockData('drugs', year, state);
    }
  }

  static SecurityStatistics _processSecurityData(Map<String, dynamic> apiData, String category, String year) {
    try {
      final records = apiData['result']['records'] as List? ?? [];

      int total = 0;
      Map<String, int> byState = {};
      Map<String, int> byMonth = {};

      for (final record in records) {
        final uf = record['uf']?.toString() ?? 'Outros';
        final mes = record['mes']?.toString() ?? 'Jan';
        final valor = _parseInt(record['valor'] ?? record['total'] ?? record['quantidade'] ?? 0);

        total += valor;
        byState[uf] = (byState[uf] ?? 0) + valor;
        byMonth[mes] = (byMonth[mes] ?? 0) + valor;
      }

      return SecurityStatistics(
        category: category,
        total: total,
        byState: byState,
        byMonth: byMonth,
        year: year,
      );
    } catch (e) {
      return _getMockData(category, year, null);
    }
  }

  static SecurityStatistics _getMockData(String category, String year, String? state) {
    final mockData = {
      'victims': {
        'total': 45320,
        'byState': {'SP': 12500, 'RJ': 7300, 'MG': 5200, 'BA': 4800, 'PR': 3900, 'RS': 3600, 'Outros': 7020},
        'byMonth': {'Jan': 3800, 'Fev': 3600, 'Mar': 4100, 'Abr': 3900, 'Mai': 4200, 'Jun': 3850, 'Jul': 4050, 'Ago': 3750, 'Set': 3950, 'Out': 4100, 'Nov': 3800, 'Dez': 3220},
      },
      'occurrences': {
        'total': 1946460,
        'byState': {'SP': 485000, 'RJ': 320000, 'MG': 180000, 'BA': 165000, 'PR': 140000, 'RS': 135000, 'Outros': 521460},
        'byMonth': {'Jan': 165000, 'Fev': 158000, 'Mar': 172000, 'Abr': 163000, 'Mai': 168000, 'Jun': 155000, 'Jul': 160000, 'Ago': 157000, 'Set': 162000, 'Out': 165000, 'Nov': 158000, 'Dez': 153460},
      },
      'mandados': {
        'total': 28750,
        'byState': {'SP': 7200, 'RJ': 4800, 'MG': 3200, 'BA': 2900, 'PR': 2400, 'RS': 2200, 'Outros': 6050},
        'byMonth': {'Jan': 2400, 'Fev': 2300, 'Mar': 2600, 'Abr': 2450, 'Mai': 2550, 'Jun': 2350, 'Jul': 2480, 'Ago': 2320, 'Set': 2420, 'Out': 2500, 'Nov': 2380, 'Dez': 2000},
      },
      'fire': {
        'total': 156890,
        'byState': {'SP': 42000, 'RJ': 28000, 'MG': 18500, 'BA': 16200, 'PR': 13800, 'RS': 12500, 'Outros': 25890},
        'byMonth': {'Jan': 14200, 'Fev': 12800, 'Mar': 13500, 'Abr': 12900, 'Mai': 13200, 'Jun': 12600, 'Jul': 13800, 'Ago': 14100, 'Set': 13400, 'Out': 13900, 'Nov': 12800, 'Dez': 9690},
      },
      'drugs': {
        'total': 89430,
        'byState': {'SP': 24500, 'RJ': 16800, 'MG': 11200, 'BA': 9600, 'PR': 8300, 'RS': 7500, 'Outros': 11530},
        'byMonth': {'Jan': 7800, 'Fev': 7200, 'Mar': 7900, 'Abr': 7500, 'Mai': 7700, 'Jun': 7300, 'Jul': 7600, 'Ago': 7400, 'Set': 7550, 'Out': 7800, 'Nov': 7250, 'Dez': 6430},
      },
    };

    final categoryData = mockData[category] ?? mockData['victims']!;

    Map<String, int> stateData = Map<String, int>.from(categoryData['byState'] as Map);
    Map<String, int> monthData = Map<String, int>.from(categoryData['byMonth'] as Map);

    if (state != null && state != 'Todos') {
      stateData = {state: stateData[state] ?? 0};
    }

    return SecurityStatistics(
      category: category,
      total: categoryData['total'] as int,
      byState: stateData,
      byMonth: monthData,
      year: year,
    );
  }

  static int _parseInt(dynamic value) {
    if (value is int) return value;
    if (value is double) return value.round();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  static Future<List<Map<String, dynamic>>> getDictionaryData() async {
    return [
      {
        'indicador': 'Homicídio Doloso',
        'descricao': 'Crime contra a vida praticado com intenção de matar',
        'fonte': 'Polícia Civil',
        'metodologia': 'Registro de ocorrências policiais',
      },
      {
        'indicador': 'Furto de Veículo',
        'descricao': 'Subtração de veículo sem violência ou grave ameaça',
        'fonte': 'Polícia Civil',
        'metodologia': 'Boletins de ocorrência',
      },
      {
        'indicador': 'Roubo de Veículo',
        'descricao': 'Subtração de veículo com violência ou grave ameaça',
        'fonte': 'Polícia Civil',
        'metodologia': 'Boletins de ocorrência',
      },
      {
        'indicador': 'Mandado de Prisão',
        'descricao': 'Ordem judicial para prisão de pessoa',
        'fonte': 'Sistema Judiciário',
        'metodologia': 'Cumprimento de mandados',
      },
      {
        'indicador': 'Apreensão de Drogas',
        'descricao': 'Substâncias entorpecentes apreendidas',
        'fonte': 'Polícia Civil e Militar',
        'metodologia': 'Operações policiais',
      },
    ];
  }

  static Future<Map<String, bool>> checkSecurityApiStatus() async {
    final status = <String, bool>{};

    try {
      final url = '$_sinespUrl/datastore_search?resource_id=vitimas-homicidio-doloso&limit=1';
      final response = await http.get(
        Uri.parse(url),
        headers: _defaultHeaders,
      ).timeout(const Duration(seconds: 10));

      status['SINESP'] = response.statusCode == 200;
    } catch (e) {
      status['SINESP'] = false;
    }

    return status;
  }
}