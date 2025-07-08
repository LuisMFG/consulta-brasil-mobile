import 'dart:convert';
import 'package:http/http.dart' as http;

/// Serviço especializado para integração com APIs oficiais do governo brasileiro
class GovernmentApisService {
  // URLs das APIs oficiais
  static const String portalTransparencia = 'https://api.portaldatransparencia.gov.br/api-de-dados';
  static const String siconv = 'https://api.convenios.gov.br/siconv/v1';
  static const String tesouroDireto = 'https://www.tesourotransparente.gov.br/ckan/api/3/action';
  static const String ibge = 'https://servicodados.ibge.gov.br/api/v1';
  static const String dataSus = 'https://apidadosabertos.saude.gov.br';
  static const String bcb = 'https://api.bcb.gov.br';
  static const String anp = 'https://www.gov.br/anp/pt-br/centrais-de-conteudo/dados-abertos';
  
  // Headers padrão para as requisições
  static Map<String, String> get _defaultHeaders => {
    'Accept': 'application/json',
    'Content-Type': 'application/json',
    'User-Agent': 'ConsultaBrasil/1.0.0',
  };

  /// Portal da Transparência - Gastos Diretos do Governo Federal
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
      
      final uri = Uri.parse('$portalTransparencia/gastos-diretos')
          .replace(queryParameters: params);
      
      final response = await http.get(uri, headers: _defaultHeaders);
      
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Erro ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      throw Exception('Erro ao buscar gastos diretos: $e');
    }
  }

  /// Portal da Transparência - Receitas Públicas
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
      
      final response = await http.get(uri, headers: _defaultHeaders);
      
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Erro ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      throw Exception('Erro ao buscar receitas: $e');
    }
  }

  /// SICONV - Sistema de Gestão de Convênios e Contratos de Repasse
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
      
      final response = await http.get(uri, headers: _defaultHeaders);
      
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Erro ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      throw Exception('Erro ao buscar convênios: $e');
    }
  }

  /// DataSUS - Cadastro Nacional de Estabelecimentos de Saúde
  static Future<Map<String, dynamic>> getEstabelecimentosSaude({
    String? uf,
    String? municipio,
    int limit = 100,
  }) async {
    try {
      final params = <String, String>{
        'limit': limit.toString(),
      };
      
      if (uf != null) params['uf'] = uf;
      if (municipio != null) params['municipio'] = municipio;
      
      final uri = Uri.parse('$dataSus/cnes/estabelecimentos')
          .replace(queryParameters: params);
      
      final response = await http.get(uri, headers: _defaultHeaders);
      
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Erro ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      throw Exception('Erro ao buscar estabelecimentos de saúde: $e');
    }
  }

  /// IBGE - Localidades (Estados e Municípios)
  static Future<List<dynamic>> getEstados() async {
    try {
      final uri = Uri.parse('$ibge/localidades/estados');
      final response = await http.get(uri, headers: _defaultHeaders);
      
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Erro ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      throw Exception('Erro ao buscar estados: $e');
    }
  }

  static Future<List<dynamic>> getMunicipios({String? uf}) async {
    try {
      String endpoint = '$ibge/localidades/municipios';
      if (uf != null) {
        endpoint = '$ibge/localidades/estados/$uf/municipios';
      }
      
      final uri = Uri.parse(endpoint);
      final response = await http.get(uri, headers: _defaultHeaders);
      
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Erro ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      throw Exception('Erro ao buscar municípios: $e');
    }
  }

  /// Banco Central do Brasil - Taxas de Juros
  static Future<Map<String, dynamic>> getTaxasJuros() async {
    try {
      final uri = Uri.parse('$bcb/dados/serie/bcdata.sgs.432/dados/ultimos/1?formato=json');
      final response = await http.get(uri, headers: _defaultHeaders);
      
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Erro ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      throw Exception('Erro ao buscar taxas de juros: $e');
    }
  }

  /// Tesouro Direto - Dados de Títulos Públicos
  static Future<Map<String, dynamic>> getTitulosPublicos() async {
    try {
      final uri = Uri.parse('$tesouroDireto/package_search?q=tesouro-direto');
      final response = await http.get(uri, headers: _defaultHeaders);
      
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Erro ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      throw Exception('Erro ao buscar títulos públicos: $e');
    }
  }

  /// Método genérico para fazer requisições com retry
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
          // Rate limit - aguardar antes de tentar novamente
          await Future.delayed(Duration(seconds: (attempts + 1) * 2));
          attempts++;
          continue;
        } else {
          throw Exception('Erro HTTP ${response.statusCode}: ${response.body}');
        }
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

  /// Verificar status das APIs
  static Future<Map<String, bool>> checkApiStatus() async {
    final apis = {
      'Portal da Transparência': '$portalTransparencia/gastos-diretos?pagina=1',
      'SICONV': '$siconv/consulta/convenios?limit=1',
      'IBGE': '$ibge/localidades/estados',
      'DataSUS': '$dataSus/cnes/estabelecimentos?limit=1',
      'Banco Central': '$bcb/dados/serie/bcdata.sgs.432/dados/ultimos/1?formato=json',
    };
    
    final status = <String, bool>{};
    
    for (final entry in apis.entries) {
      try {
        final response = await http.get(
          Uri.parse(entry.value),
          headers: _defaultHeaders,
        ).timeout(const Duration(seconds: 10));
        
        status[entry.key] = response.statusCode == 200;
      } catch (e) {
        status[entry.key] = false;
      }
    }
    
    return status;
  }
}