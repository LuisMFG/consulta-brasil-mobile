import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:http/http.dart' as http;
import '../models/spending_model.dart';
import 'package:flutter/material.dart';

class GovernmentApisService {
  static const String portalTransparencia = 'https://api.portaldatransparencia.gov.br/api-de-dados';
  static const String siconv = 'https://api.convenios.gov.br/siconv/v1';
  static const String tesouroDireto = 'https://www.tesourotransparente.gov.br/ckan/api/3/action';
  static const String ibge = 'https://servicodados.ibge.gov.br/api/v1';
  static const String dataSus = 'https://apidadosabertos.saude.gov.br';
  static const String bcb = 'https://api.bcb.gov.br';

  static const Duration _timeout = Duration(seconds: 30);
  static String? _apiKey;

  static const Map<String, Map<String, dynamic>> _setoresSIAFI = {
    'Previdência': {
      'funcao': '09',
      'subfuncoes': ['271', '272', '273', '274'],
      'color': '#28a745'
    },
    'Saúde': {
      'funcao': '10',
      'subfuncoes': ['301', '302', '303', '304', '305', '306'],
      'color': '#dc3545'
    },
    'Educação': {
      'funcao': '12',
      'subfuncoes': ['361', '362', '363', '364', '365', '366', '367'],
      'color': '#007bff'
    },
    'Defesa': {
      'funcao': '05',
      'subfuncoes': ['151', '152', '153'],
      'color': '#fd7e14'
    },
    'Infraestrutura': {
      'funcoes': ['26', '25', '17'],
      'subfuncoes': ['781', '782', '783', '784', '785', '751', '752', '511', '512'],
      'color': '#6f42c1'
    },
    'Segurança': {
      'funcao': '06',
      'subfuncoes': ['181', '182', '183'],
      'color': '#20c997'
    }
  };

  static void setApiKey(String key) {
    _apiKey = key;
  }

  static Map<String, String> get _defaultHeaders => {
    'Accept': 'application/json',
    'Content-Type': 'application/json',
    'User-Agent': 'ConsultaBrasil/1.0.0',
  };

  static Map<String, String> get _transparenciaHeaders => {
    'Accept': 'application/json',
    'Content-Type': 'application/json',
    'User-Agent': 'ConsultaBrasil/1.0.0',
    if (_apiKey != null) 'chave-api-dados': _apiKey!,
  };

  static Future<bool> testApiKeyValida() async {
    if (_apiKey == null || _apiKey!.isEmpty) {
      print('🔑 Chave API não definida');
      return false;
    }

    try {
      print('🔑 Testando chave API: ${_apiKey!.substring(0, 8)}...');

      final url = '$portalTransparencia/despesas/por-orgao?ano=2024&pagina=1';
      final response = await http.get(
        Uri.parse(url),
        headers: _transparenciaHeaders,
      ).timeout(Duration(seconds: 15));

      print('📡 Status da requisição: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final count = data is List ? data.length : 0;
        print('✅ Chave VÁLIDA! Dados recebidos: $count registros');
        return true;
      } else if (response.statusCode == 401) {
        print('❌ Chave INVÁLIDA ou expirada (401)');
        print('📝 Resposta: ${response.body}');
        return false;
      } else {
        print('⚠️ Status inesperado: ${response.statusCode}');
        print('📝 Resposta: ${response.body}');
        return false;
      }
    } catch (e) {
      print('❌ Erro ao testar chave: $e');
      return false;
    }
  }

  static Future<SpendingModel> getRealSpendingData(String year) async {
    try {
      print('📊 Buscando dados reais para o ano $year');

      final currentYear = DateTime.now().year;
      final yearInt = int.tryParse(year) ?? currentYear;

      if (yearInt > currentYear) {
        throw Exception('Ano $year é futuro - dados não disponíveis');
      }

      final Map<String, double> setoresMap = {};

      for (final setorEntry in _setoresSIAFI.entries) {
        final setorNome = setorEntry.key;
        final setorConfig = setorEntry.value;

        try {
          double valorSetor = 0.0;

          if (setorConfig.containsKey('funcoes')) {
            final funcoes = setorConfig['funcoes'] as List<String>;
            for (final funcao in funcoes) {
              final valor = await _getGastosMovimentacaoPorFuncao(year, funcao);
              valorSetor += valor;
            }
          } else {
            final funcao = setorConfig['funcao'] as String;
            valorSetor = await _getGastosMovimentacaoPorFuncao(year, funcao);
          }

          if (valorSetor > 0) {
            setoresMap[setorNome] = valorSetor;
            print('✅ $setorNome: R\$ ${_formatCurrency(valorSetor)}');
          }

          await Future.delayed(Duration(milliseconds: 300));

        } catch (e) {
          print('⚠️ Erro ao buscar dados para $setorNome: $e');
        }
      }

      if (setoresMap.isEmpty) {
        print('🔄 Tentando API alternativa por-orgao...');
        return await _getFallbackSpendingData(year);
      }

      final sectors = setoresMap.entries
          .where((entry) => entry.value > 0)
          .map((entry) {
        final setorConfig = _setoresSIAFI[entry.key]!;
        return SectorSpending(
          name: entry.key,
          value: entry.value,
          color: Color(int.parse(setorConfig['color']!.substring(1), radix: 16) + 0xFF000000),
        );
      }).toList();

      sectors.sort((a, b) => b.value.compareTo(a.value));

      print('📈 Dados carregados: ${sectors.length} setores');
      return SpendingModel(sectors: sectors);

    } catch (e) {
      print('❌ Erro geral ao buscar dados reais: $e');
      return await _getFallbackSpendingData(year);
    }
  }

  static Future<double> _getGastosMovimentacaoPorFuncao(String year, String funcao) async {
    try {
      print('🔍 Buscando função $funcao para ano $year...');

      final url = '$portalTransparencia/despesas/por-funcional-programatica/movimentacao-liquida'
          '?ano=$year&funcao=$funcao&pagina=1';

      final response = await http.get(
        Uri.parse(url),
        headers: _transparenciaHeaders,
      ).timeout(Duration(seconds: 15));

      print('📡 Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data is List && data.isNotEmpty) {
          double total = 0.0;

          for (final item in data) {
            final valor = _parseValue(item['valor'] ?? item['valorLiquidado'] ?? item['valorEmpenhado']);
            total += valor;
          }

          print('✅ Função $funcao: R\$ ${_formatCurrency(total)}');
          return total;
        } else {
          print('⚠️ Função $funcao: Nenhum dado encontrado');
          return 0.0;
        }
      } else if (response.statusCode == 401) {
        throw Exception('Chave API inválida');
      } else if (response.statusCode == 400) {
        print('⚠️ Função $funcao: Parâmetros inválidos (400)');
        return 0.0;
      } else if (response.statusCode == 404) {
        print('⚠️ Função $funcao: Endpoint não encontrado (404)');
        return 0.0;
      } else {
        print('❌ Função $funcao: Status ${response.statusCode}');
        return 0.0;
      }

    } catch (e) {
      print('❌ Erro função $funcao: $e');
      return 0.0;
    }
  }

  static Future<double> _getGastosPorFuncaoFallback(String year, String funcao) async {
    try {
      final url = '$portalTransparencia/despesas/por-funcional-programatica'
          '?ano=$year&funcao=$funcao&pagina=1';

      final response = await http.get(
        Uri.parse(url),
        headers: _transparenciaHeaders,
      ).timeout(_timeout);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data is List && data.isNotEmpty) {
          double total = 0.0;

          for (final item in data) {
            final valor = _parseValue(item['valorLiquidado'] ?? item['valor']);
            total += valor;
          }

          return total;
        }
      }

      return 0.0;

    } catch (e) {
      print('Erro no fallback para função $funcao: $e');
      return 0.0;
    }
  }

  static Future<SpendingModel> _getFallbackSpendingData(String year) async {
    try {
      final List<dynamic> allData = [];

      final url = '$portalTransparencia/despesas/por-orgao?ano=$year&pagina=1';
      final response = await http.get(
        Uri.parse(url),
        headers: _transparenciaHeaders,
      ).timeout(_timeout);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data is List && data.isNotEmpty) {
          allData.addAll(data);

          for (int page = 2; page <= 5; page++) {
            try {
              final urlPage = '$portalTransparencia/despesas/por-orgao?ano=$year&pagina=$page';
              final responsePage = await http.get(
                Uri.parse(urlPage),
                headers: _transparenciaHeaders,
              ).timeout(_timeout);

              if (responsePage.statusCode == 200) {
                final dataPage = json.decode(responsePage.body);
                if (dataPage is List && dataPage.isNotEmpty) {
                  allData.addAll(dataPage);
                } else {
                  break;
                }
              }

              await Future.delayed(Duration(milliseconds: 200));
            } catch (e) {
              print('Erro na página $page: $e');
              break;
            }
          }
        }
      }

      if (allData.isNotEmpty) {
        return _processOrgaoData(allData);
      }

      throw Exception('Nenhum dado encontrado');

    } catch (e) {
      print('Erro no fallback completo: $e');
      return _getMockSpendingData(year);
    }
  }

  static SpendingModel _processOrgaoData(List<dynamic> data) {
    final Map<String, double> setoresMap = {};

    for (final item in data) {
      final orgao = item['nomeOrgao']?.toString() ?? 'Outros';
      final valor = _parseValue(item['valor']);

      final setor = _mapOrgaoToSetor(orgao);
      setoresMap[setor] = (setoresMap[setor] ?? 0) + valor;
    }

    final sectors = setoresMap.entries
        .where((entry) => entry.value > 0)
        .map((entry) {
      final setorConfig = _setoresSIAFI[entry.key];
      final color = setorConfig != null
          ? Color(int.parse(setorConfig['color']!.substring(1), radix: 16) + 0xFF000000)
          : Color(0xFF6c757d);

      return SectorSpending(
        name: entry.key,
        value: entry.value,
        color: color,
      );
    }).toList();

    sectors.sort((a, b) => b.value.compareTo(a.value));
    return SpendingModel(sectors: sectors);
  }

  static String _mapOrgaoToSetor(String orgao) {
    final orgaoLower = orgao.toLowerCase();

    if (orgaoLower.contains('previdencia') || orgaoLower.contains('inss')) {
      return 'Previdência';
    } else if (orgaoLower.contains('saude') || orgaoLower.contains('sus')) {
      return 'Saúde';
    } else if (orgaoLower.contains('educacao') || orgaoLower.contains('universidade') || orgaoLower.contains('capes')) {
      return 'Educação';
    } else if (orgaoLower.contains('defesa') || orgaoLower.contains('exercito') || orgaoLower.contains('marinha') || orgaoLower.contains('aeronautica')) {
      return 'Defesa';
    } else if (orgaoLower.contains('transporte') || orgaoLower.contains('infraestrutura') || orgaoLower.contains('energia') || orgaoLower.contains('saneamento')) {
      return 'Infraestrutura';
    } else if (orgaoLower.contains('seguranca') || orgaoLower.contains('policia') || orgaoLower.contains('justica')) {
      return 'Segurança';
    } else {
      return 'Outros';
    }
  }

  static double _parseValue(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) {
      final cleanValue = value.replaceAll(RegExp(r'[^\d.]'), '');
      return double.tryParse(cleanValue) ?? 0.0;
    }
    return 0.0;
  }

  static SpendingModel _getMockSpendingData(String year) {
    final Map<String, double> mockData = {
      '2021': 871000000000,
      '2022': 920000000000,
      '2023': 970000000000,
      '2024': 1020000000000,
      '2025': 1080000000000,
    };

    final total = mockData[year] ?? mockData['2024']!;

    return SpendingModel(sectors: [
      SectorSpending(name: 'Previdência', value: total * 0.63, color: Color(0xFF28a745)),
      SectorSpending(name: 'Saúde', value: total * 0.13, color: Color(0xFFdc3545)),
      SectorSpending(name: 'Educação', value: total * 0.11, color: Color(0xFF007bff)),
      SectorSpending(name: 'Defesa', value: total * 0.10, color: Color(0xFFfd7e14)),
      SectorSpending(name: 'Infraestrutura', value: total * 0.014, color: Color(0xFF6f42c1)),
      SectorSpending(name: 'Segurança', value: total * 0.013, color: Color(0xFF20c997)),
    ]);
  }

  static String _formatCurrency(double value) {
    if (value >= 1000000000) {
      return '${(value / 1000000000).toStringAsFixed(1)} bilhões';
    } else if (value >= 1000000) {
      return '${(value / 1000000).toStringAsFixed(1)} milhões';
    } else if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(1)} mil';
    } else {
      return 'R\$ ${value.toStringAsFixed(2)}';
    }
  }

  static Future<Map<String, dynamic>> getGastosDirectos({
    String? ano,
    String? mes,
    String? orgao,
    int pagina = 1,
  }) async {
    try {
      final params = <String, String>{
        'pagina': pagina.toString(),
      };

      if (ano != null) params['ano'] = ano;
      if (mes != null) params['mes'] = mes;
      if (orgao != null) params['codigoOrgao'] = orgao;

      final uri = Uri.parse('$portalTransparencia/despesas/por-orgao')
          .replace(queryParameters: params);

      final response = await http.get(uri, headers: _transparenciaHeaders).timeout(_timeout);

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else if (response.statusCode == 401) {
        throw Exception('Chave API inválida ou não informada');
      } else {
        throw HttpException('Erro ${response.statusCode}: Portal indisponível');
      }
    } on SocketException {
      throw Exception('Sem conexão com o Portal da Transparência');
    } on TimeoutException {
      throw Exception('Timeout ao consultar gastos diretos');
    } catch (e) {
      throw Exception('Erro ao buscar gastos diretos: $e');
    }
  }

  static Future<List<dynamic>> getEstadosIBGE() async {
    try {
      final response = await http.get(
        Uri.parse('$ibge/localidades/estados'),
        headers: _defaultHeaders,
      ).timeout(_timeout);

      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  static Future<List<dynamic>> getConveniosSICONV({int limit = 50}) async {
    try {
      final response = await http.get(
        Uri.parse('$siconv/consulta/convenios.json?limit=$limit'),
        headers: _defaultHeaders,
      ).timeout(_timeout);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['convenios'] ?? [];
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  static Future<Map<String, dynamic>> getTaxasJuros() async {
    try {
      final response = await http.get(
        Uri.parse('$bcb/dados/serie/bcdata.sgs.432/dados/ultimos/1?formato=json'),
        headers: _defaultHeaders,
      ).timeout(_timeout);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {'taxas': data};
      }
      return {};
    } catch (e) {
      return {};
    }
  }

  static Future<Map<String, bool>> checkApiStatus() async {
    final status = <String, bool>{};

    final apis = {
      'Portal da Transparência': () => _testPortalTransparencia(),
      'IBGE': () => _testIBGE(),
      'SICONV': () => _testSICONV(),
      'Banco Central': () => _testBCB(),
    };

    for (final entry in apis.entries) {
      try {
        status[entry.key] = await entry.value();
      } catch (e) {
        status[entry.key] = false;
      }
    }

    return status;
  }

  static Future<bool> _testPortalTransparencia() async {
    try {
      final url = '$portalTransparencia/despesas/por-orgao?ano=2024&pagina=1';
      final response = await http.get(
        Uri.parse(url),
        headers: _transparenciaHeaders,
      ).timeout(Duration(seconds: 10));

      return response.statusCode == 200 || response.statusCode == 401;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> _testIBGE() async {
    try {
      final url = '$ibge/localidades/estados';
      final response = await http.get(
        Uri.parse(url),
        headers: _defaultHeaders,
      ).timeout(Duration(seconds: 10));

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> _testSICONV() async {
    try {
      final url = '$siconv/consulta/convenios.json?limit=1';
      final response = await http.get(
        Uri.parse(url),
        headers: _defaultHeaders,
      ).timeout(Duration(seconds: 10));

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> _testBCB() async {
    try {
      final url = '$bcb/dados/serie/bcdata.sgs.432/dados/ultimos/1?formato=json';
      final response = await http.get(
        Uri.parse(url),
        headers: _defaultHeaders,
      ).timeout(Duration(seconds: 10));

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}