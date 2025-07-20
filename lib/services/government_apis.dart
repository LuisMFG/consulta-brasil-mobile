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

  static Future<Map<String, dynamic>> getReceitas({
    String? ano,
    String? mes,
    int pagina = 1,
  }) async {
    try {
      final params = <String, String>{
        'pagina': pagina.toString(),
      };

      if (ano != null) params['ano'] = ano;
      if (mes != null) params['mes'] = mes;

      final uri = Uri.parse('$portalTransparencia/receitas')
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
      throw Exception('Timeout ao consultar receitas');
    } catch (e) {
      throw Exception('Erro ao buscar receitas: $e');
    }
  }

  static Future<Map<String, dynamic>> getConvenios({
    String? uf,
    String? municipio,
    int offset = 0,
    int limit = 100,
  }) async {
    try {
      final params = <String, String>{
        'offset': offset.toString(),
        'limit': limit.toString(),
      };

      if (uf != null) params['uf'] = uf;
      if (municipio != null) params['municipio'] = municipio;

      final uri = Uri.parse('$siconv/consulta/convenios')
          .replace(queryParameters: params);

      final response = await http.get(uri, headers: _defaultHeaders).timeout(_timeout);

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw HttpException('Erro ${response.statusCode}: SICONV indisponível');
      }
    } on SocketException {
      throw Exception('Sem conexão com o SICONV');
    } on TimeoutException {
      throw Exception('Timeout ao consultar convênios');
    } catch (e) {
      throw Exception('Erro ao buscar convênios: $e');
    }
  }

  static Future<Map<String, dynamic>> getMunicipios({String? uf}) async {
    try {
      String endpoint = '$ibge/localidades/municipios';
      if (uf != null) {
        endpoint = '$ibge/localidades/estados/$uf/municipios';
      }

      final uri = Uri.parse(endpoint);
      final response = await http.get(uri, headers: _defaultHeaders).timeout(_timeout);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {'municipios': data is List ? data : []};
      } else {
        throw HttpException('Erro ${response.statusCode}: IBGE indisponível');
      }
    } on SocketException {
      throw Exception('Sem conexão com o IBGE');
    } on TimeoutException {
      throw Exception('Timeout ao consultar municípios');
    } catch (e) {
      throw Exception('Erro ao buscar municípios: $e');
    }
  }

  static Future<Map<String, dynamic>> getTaxasJuros() async {
    try {
      final uri = Uri.parse('$bcb/dados/serie/bcdata.sgs.432/dados/ultimos/1?formato=json');
      final response = await http.get(uri, headers: _defaultHeaders).timeout(_timeout);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {'taxas': data is List ? data : []};
      } else {
        throw HttpException('Erro ${response.statusCode}: BCB indisponível');
      }
    } on SocketException {
      throw Exception('Sem conexão com o Banco Central');
    } on TimeoutException {
      throw Exception('Timeout ao consultar taxas de juros');
    } catch (e) {
      throw Exception('Erro ao buscar taxas de juros: $e');
    }
  }

  static Future<Map<String, dynamic>> getTitulosPublicos() async {
    try {
      final uri = Uri.parse('$tesouroDireto/package_search?q=tesouro-direto&rows=10');
      final response = await http.get(uri, headers: _defaultHeaders).timeout(_timeout);

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw HttpException('Erro ${response.statusCode}: Tesouro indisponível');
      }
    } on SocketException {
      throw Exception('Sem conexão com o Tesouro Transparente');
    } on TimeoutException {
      throw Exception('Timeout ao consultar títulos públicos');
    } catch (e) {
      throw Exception('Erro ao buscar títulos públicos: $e');
    }
  }

  static Future<Map<String, dynamic>> makeRequest(
      String url, {
        Map<String, String>? headers,
        int maxRetries = 3,
        Duration timeout = const Duration(seconds: 30),
      }) async {
    int attempts = 0;

    while (attempts < maxRetries) {
      try {
        final response = await http.get(
          Uri.parse(url),
          headers: {..._defaultHeaders, ...?headers},
        ).timeout(timeout);

        if (response.statusCode == 200) {
          return json.decode(response.body);
        } else if (response.statusCode == 429) {
          await Future.delayed(Duration(seconds: (attempts + 1) * 2));
          attempts++;
          continue;
        } else {
          throw HttpException('Erro HTTP ${response.statusCode}');
        }
      } on SocketException {
        attempts++;
        if (attempts >= maxRetries) {
          throw Exception('Sem conexão após $maxRetries tentativas');
        }
        await Future.delayed(Duration(seconds: attempts * 2));
      } on TimeoutException {
        attempts++;
        if (attempts >= maxRetries) {
          throw Exception('Timeout após $maxRetries tentativas');
        }
        await Future.delayed(Duration(seconds: attempts));
      } catch (e) {
        attempts++;
        if (attempts >= maxRetries) {
          throw Exception('Erro após $maxRetries tentativas: $e');
        }
        await Future.delayed(Duration(seconds: attempts));
      }
    }

    throw Exception('Falha ao fazer requisição após $maxRetries tentativas');
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

      // 200 = sucesso, 401 = sem chave (mas API funciona)
      return response.statusCode == 200 || response.statusCode == 401;
    } catch (e) {
      print('Erro no teste do Portal da Transparência: $e');
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

  // Métodos específicos para gastos públicos
  static Future<SpendingModel> getRealSpendingData(String year) async {
    try {
      final gastosData = await _getGastosDirectosReais(year);

      if (gastosData.isEmpty) {
        throw Exception('Nenhum dado real encontrado para o ano $year');
      }

      final Map<String, double> setoresMap = {};
      final Map<String, String> coresMap = {
        'Previdência': '#28a745',
        'Saúde': '#dc3545',
        'Educação': '#007bff',
        'Defesa': '#fd7e14',
        'Infraestrutura': '#6f42c1',
        'Segurança': '#20c997',
        'Trabalho': '#17a2b8',
        'Agricultura': '#795548',
        'Justiça': '#9c27b0',
        'Meio Ambiente': '#4caf50',
        'Outros': '#6c757d',
      };

      for (final gasto in gastosData) {
        final orgao = gasto['nomeOrgao']?.toString() ?? 'Outros';
        final valor = _parseValue(gasto['valor']);

        String setor = _mapOrgaoToSetor(orgao);
        setoresMap[setor] = (setoresMap[setor] ?? 0) + valor;
      }

      final sectors = setoresMap.entries
          .where((entry) => entry.value > 0)
          .map((entry) {
        return SectorSpending(
          name: entry.key,
          value: entry.value,
          color: Color(int.parse(coresMap[entry.key]!.substring(1), radix: 16) + 0xFF000000),
        );
      }).toList();

      sectors.sort((a, b) => b.value.compareTo(a.value));

      return SpendingModel(sectors: sectors);
    } catch (e) {
      print('Erro ao buscar dados reais: $e');
      rethrow;
    }
  }

  static Future<List<dynamic>> _getGastosDirectosReais(String year) async {
    try {
      final currentYear = DateTime.now().year;
      final yearInt = int.tryParse(year) ?? currentYear;

      if (yearInt > currentYear) {
        throw Exception('Ano $year é futuro - dados não disponíveis');
      }

      final List<dynamic> allData = [];

      // Usar a API correta: despesas/por-orgao
      final url = '$portalTransparencia/despesas/por-orgao?ano=$year&pagina=1';
      final response = await http.get(
        Uri.parse(url),
        headers: _transparenciaHeaders,
      ).timeout(_timeout);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data is List && data.isNotEmpty) {
          allData.addAll(data);

          // Buscar páginas adicionais se houver
          for (int page = 2; page <= 3; page++) {
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
                  break; // Não há mais páginas
                }
              }

              await Future.delayed(Duration(milliseconds: 200)); // Rate limiting
            } catch (e) {
              print('Erro na página $page: $e');
              break;
            }
          }
        }
      } else if (response.statusCode == 401) {
        throw Exception('Chave API inválida ou não informada');
      } else if (response.statusCode == 400 || response.statusCode == 404) {
        // Tentar API alternativa: despesas/por-funcional-programatica
        final urlAlt = '$portalTransparencia/despesas/por-funcional-programatica?ano=$year&pagina=1';
        final responseAlt = await http.get(
          Uri.parse(urlAlt),
          headers: _transparenciaHeaders,
        ).timeout(_timeout);

        if (responseAlt.statusCode == 200) {
          final dataAlt = json.decode(responseAlt.body);
          if (dataAlt is List && dataAlt.isNotEmpty) {
            allData.addAll(dataAlt);
          }
        } else if (responseAlt.statusCode == 401) {
          throw Exception('Chave API inválida ou não informada');
        }
      } else {
        print('Erro API ${response.statusCode}: ${response.body}');
      }

      return allData;
    } catch (e) {
      print('Erro ao buscar gastos diretos reais: $e');
      throw Exception('Erro ao buscar gastos diretos: $e');
    }
  }

  static Future<List<Map<String, dynamic>>> getEstadosIBGE() async {
    try {
      final url = '$ibge/localidades/estados';
      final response = await http.get(
        Uri.parse(url),
        headers: _defaultHeaders,
      ).timeout(_timeout);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data is List) {
          return data.map<Map<String, dynamic>>((estado) => {
            'id': estado['id'],
            'nome': estado['nome'],
            'sigla': estado['sigla'],
            'regiao': estado['regiao']['nome'],
          }).toList();
        }
      }
      return [];
    } catch (e) {
      throw Exception('Erro ao buscar estados IBGE: $e');
    }
  }

  static Future<List<Map<String, dynamic>>> getConveniosSICONV({
    String? uf,
    int offset = 0,
    int limit = 20,
  }) async {
    try {
      final params = {
        'offset': offset.toString(),
        'limit': limit.toString(),
      };

      if (uf != null) {
        params['uf'] = uf;
      }

      final uri = Uri.parse('$siconv/consulta/convenios.json').replace(queryParameters: params);
      final response = await http.get(
        uri,
        headers: _defaultHeaders,
      ).timeout(_timeout);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data is Map && data.containsKey('convenio')) {
          final convenios = data['convenio'];
          if (convenios is List) {
            return convenios.map<Map<String, dynamic>>((convenio) => {
              'numero': convenio['numero_convenio'] ?? '',
              'objeto': convenio['objeto_convenio'] ?? '',
              'valor': _parseValue(convenio['valor_convenio']),
              'situacao': convenio['situacao_convenio'] ?? '',
              'uf': convenio['uf_convenente'] ?? '',
              'municipio': convenio['municipio_convenente'] ?? '',
            }).toList();
          }
        }
      }
      return [];
    } catch (e) {
      throw Exception('Erro ao buscar convênios SICONV: $e');
    }
  }

  static double _parseValue(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) {
      final cleaned = value.replaceAll(RegExp(r'[^\d.,]'), '').replaceAll(',', '.');
      return double.tryParse(cleaned) ?? 0.0;
    }
    return 0.0;
  }

  static String _mapOrgaoToSetor(String orgao) {
    final orgaoLower = orgao.toLowerCase();

    final Map<String, List<String>> setorMapping = {
      'Previdência': [
        'previdencia', 'inss', 'previdenciário', 'seguridade', 'instituto nacional do seguro social',
        'previdencia social', 'beneficios', 'aposentadoria', 'pensao'
      ],
      'Saúde': [
        'saude', 'sus', 'ministerio da saude', 'saúde', 'sanitaria', 'anvisa', 'fiocruz',
        'hospital', 'medicamento', 'vacina', 'epidemiologia', 'vigilancia sanitaria'
      ],
      'Educação': [
        'educacao', 'mec', 'ministerio da educacao', 'educação', 'universidade', 'escola',
        'ensino', 'professor', 'estudante', 'pesquisa', 'ciencia', 'tecnologia', 'capes', 'cnpq'
      ],
      'Defesa': [
        'defesa', 'militar', 'forcas armadas', 'exercito', 'marinha', 'aeronautica',
        'comando', 'defesa nacional', 'seguranca nacional', 'fab', 'exercito brasileiro'
      ],
      'Infraestrutura': [
        'infraestrutura', 'transporte', 'obras', 'estrada', 'rodovia', 'porto', 'aeroporto',
        'ferrovia', 'metro', 'mobilidade', 'construcao', 'dnit', 'desenvolvimento regional'
      ],
      'Segurança': [
        'seguranca', 'policia', 'publica', 'federal', 'civil', 'militar', 'bombeiro',
        'seguranca publica', 'policia federal', 'policia rodoviaria', 'susp'
      ],
      'Trabalho': [
        'trabalho', 'emprego', 'trabalhista', 'seguro desemprego', 'ministerio do trabalho',
        'trabalhador', 'empregador', 'sindicato', 'renda'
      ],
      'Agricultura': [
        'agricultura', 'rural', 'agrario', 'desenvolvimento rural', 'incra', 'ministerio da agricultura',
        'agropecuaria', 'funai', 'reforma agraria', 'agronegocio'
      ],
      'Justiça': [
        'justica', 'judiciario', 'tribunal', 'procuradoria', 'ministerio da justica',
        'direitos humanos', 'cidadania', 'advocacia', 'defensoria'
      ],
      'Meio Ambiente': [
        'meio ambiente', 'ambiental', 'ibama', 'icmbio', 'floresta', 'preservacao',
        'sustentabilidade', 'clima', 'recursos naturais'
      ],
    };

    for (final entry in setorMapping.entries) {
      for (final keyword in entry.value) {
        if (orgaoLower.contains(keyword)) {
          return entry.key;
        }
      }
    }

    return 'Outros';
  }
}