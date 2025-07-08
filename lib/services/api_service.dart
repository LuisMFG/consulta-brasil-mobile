import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/news_model.dart';
import '../models/spending_model.dart';
import 'package:flutter/material.dart';


class ApiService {
  // URLs das APIs oficiais do governo brasileiro
  static const String _transparenciaUrl = 'https://api.portaldatransparencia.gov.br/api-de-dados';
  static const String _siconvUrl = 'https://api.convenios.gov.br/siconv/v1';
  static const String _tesouroDiretoUrl = 'https://www.tesourotransparente.gov.br/ckan/api/3/action';
  static const String _ibgeUrl = 'https://servicodados.ibge.gov.br/api/v1';
  static const String _dataSusUrl = 'https://apidadosabertos.saude.gov.br';
  
  // Chave de API do Portal da Transparência (necessária para algumas consultas)
  static const String _apiKey = 'chave-api-dados'; // Substitua pela chave real
  
  static Future<List<NewsModel>> getNews() async {
    try {
      // Buscar dados de diferentes fontes para gerar notícias
      final List<NewsModel> news = [];
      
      // 1. Buscar dados de gastos recentes para gerar notícias
      final gastosData = await _getGastosDirectos();
      if (gastosData.isNotEmpty) {
        final totalGastos = gastosData.fold(0.0, (sum, item) => sum + (item['valor'] ?? 0.0));
        news.add(NewsModel(
          id: '1',
          title: 'Gastos públicos federais somam R\$ ${_formatCurrency(totalGastos)} em 2024',
          description: 'Portal da Transparência registra movimentação financeira do governo federal com foco em transparência e prestação de contas.',
          imageUrl: 'https://images.pexels.com/photos/590016/pexels-photo-590016.jpeg?auto=compress&cs=tinysrgb&w=800',
          date: _formatDate(DateTime.now()),
          category: 'Transparência',
        ));
      }
      
      // 2. Buscar dados de convênios do SICONV
      final conveniosData = await _getConvenios();
      if (conveniosData.isNotEmpty) {
        news.add(NewsModel(
          id: '2',
          title: '${conveniosData.length} convênios ativos registrados no SICONV',
          description: 'Sistema de Gestão de Convênios e Contratos de Repasse mantém registro atualizado de parcerias entre União e entes federados.',
          imageUrl: 'https://images.pexels.com/photos/1106468/pexels-photo-1106468.jpeg?auto=compress&cs=tinysrgb&w=800',
          date: _formatDate(DateTime.now().subtract(const Duration(days: 1))),
          category: 'Convênios',
        ));
      }
      
      // 3. Buscar dados de estabelecimentos de saúde
      final saudeData = await _getEstabelecimentosSaude();
      if (saudeData.isNotEmpty) {
        news.add(NewsModel(
          id: '3',
          title: 'Rede de saúde pública conta com ${saudeData.length} estabelecimentos',
          description: 'Cadastro Nacional de Estabelecimentos de Saúde (CNES) mantém registro atualizado da infraestrutura do SUS.',
          imageUrl: 'https://images.pexels.com/photos/263402/pexels-photo-263402.jpeg?auto=compress&cs=tinysrgb&w=800',
          date: _formatDate(DateTime.now().subtract(const Duration(days: 2))),
          category: 'Saúde',
        ));
      }
      
      // 4. Buscar dados do IBGE
      final ibgeData = await _getDadosIBGE();
      if (ibgeData.isNotEmpty) {
        news.add(NewsModel(
          id: '4',
          title: 'IBGE disponibiliza dados atualizados de ${ibgeData.length} municípios',
          description: 'Instituto Brasileiro de Geografia e Estatística mantém base de dados geográficos e estatísticos do país.',
          imageUrl: 'https://images.pexels.com/photos/1181534/pexels-photo-1181534.jpeg?auto=compress&cs=tinysrgb&w=800',
          date: _formatDate(DateTime.now().subtract(const Duration(days: 3))),
          category: 'Estatísticas',
        ));
      }
      
      return news;
    } catch (e) {
      print('Erro ao carregar notícias: $e');
      return _getFallbackNews();
    }
  }

  static Future<SpendingModel> getSpendingData(String year) async {
    try {
      // Buscar dados reais de gastos por órgão
      final gastosData = await _getGastosPorOrgao(year);
      
      if (gastosData.isEmpty) {
        throw Exception('Nenhum dado encontrado para o ano $year');
      }
      
      // Agrupar gastos por setor
      final Map<String, double> setoresMap = {};
      final Map<String, String> coresMap = {
        'Saúde': '#dc3545',
        'Educação': '#007bff',
        'Previdência': '#28a745',
        'Defesa': '#fd7e14',
        'Infraestrutura': '#6f42c1',
        'Segurança': '#20c997',
        'Outros': '#6c757d',
      };
      
      for (final gasto in gastosData) {
        final orgao = gasto['nomeOrgao'] ?? 'Outros';
        final valor = (gasto['valor'] ?? 0.0).toDouble();
        
        // Mapear órgãos para setores
        String setor = _mapOrgaoToSetor(orgao);
        setoresMap[setor] = (setoresMap[setor] ?? 0) + valor;
      }
      
      // Converter para lista de SectorSpending
      final sectors = setoresMap.entries.map((entry) {
        return SectorSpending(
          name: entry.key,
          value: entry.value,
          color: Color(int.parse(coresMap[entry.key]!.substring(1), radix: 16) + 0xFF000000),
        );
      }).toList();
      
      // Ordenar por valor (maior para menor)
      sectors.sort((a, b) => b.value.compareTo(a.value));
      
      return SpendingModel(sectors: sectors);
    } catch (e) {
      print('Erro ao carregar dados de gastos: $e');
      return _getFallbackSpendingData();
    }
  }

  // Métodos privados para chamadas às APIs reais

  static Future<List<dynamic>> _getGastosDirectos() async {
    try {
      final now = DateTime.now();
      final mesAtual = now.month.toString().padLeft(2, '0');
      final anoAtual = now.year.toString();
      
      final url = '$_transparenciaUrl/gastos-diretos?mesAno=${anoAtual}${mesAtual}&pagina=1';
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'chave-api-dados': _apiKey,
          'Accept': 'application/json',
        },
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data is List ? data : [];
      }
      return [];
    } catch (e) {
      print('Erro ao buscar gastos diretos: $e');
      return [];
    }
  }

  static Future<List<dynamic>> _getGastosPorOrgao(String year) async {
    try {
      final url = '$_transparenciaUrl/gastos-diretos?ano=$year&pagina=1';
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'chave-api-dados': _apiKey,
          'Accept': 'application/json',
        },
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data is List ? data : [];
      }
      return [];
    } catch (e) {
      print('Erro ao buscar gastos por órgão: $e');
      return [];
    }
  }

  static Future<List<dynamic>> _getConvenios() async {
    try {
      final url = '$_siconvUrl/consulta/convenios?offset=0&limit=100';
      final response = await http.get(
        Uri.parse(url),
        headers: {'Accept': 'application/json'},
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['convenios'] ?? [];
      }
      return [];
    } catch (e) {
      print('Erro ao buscar convênios: $e');
      return [];
    }
  }

  static Future<List<dynamic>> _getEstabelecimentosSaude() async {
    try {
      final url = '$_dataSusUrl/cnes/estabelecimentos?limit=100';
      final response = await http.get(
        Uri.parse(url),
        headers: {'Accept': 'application/json'},
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['estabelecimentos'] ?? [];
      }
      return [];
    } catch (e) {
      print('Erro ao buscar estabelecimentos de saúde: $e');
      return [];
    }
  }

  static Future<List<dynamic>> _getDadosIBGE() async {
    try {
      final url = '$_ibgeUrl/localidades/municipios';
      final response = await http.get(
        Uri.parse(url),
        headers: {'Accept': 'application/json'},
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data is List ? data.take(100).toList() : [];
      }
      return [];
    } catch (e) {
      print('Erro ao buscar dados do IBGE: $e');
      return [];
    }
  }

  // Métodos auxiliares

  static String _mapOrgaoToSetor(String orgao) {
    final orgaoLower = orgao.toLowerCase();
    
    if (orgaoLower.contains('saúde') || orgaoLower.contains('sus')) {
      return 'Saúde';
    } else if (orgaoLower.contains('educação') || orgaoLower.contains('mec')) {
      return 'Educação';
    } else if (orgaoLower.contains('previdência') || orgaoLower.contains('inss')) {
      return 'Previdência';
    } else if (orgaoLower.contains('defesa') || orgaoLower.contains('militar')) {
      return 'Defesa';
    } else if (orgaoLower.contains('infraestrutura') || orgaoLower.contains('transporte')) {
      return 'Infraestrutura';
    } else if (orgaoLower.contains('segurança') || orgaoLower.contains('polícia')) {
      return 'Segurança';
    } else {
      return 'Outros';
    }
  }

  static String _formatCurrency(double value) {
    if (value >= 1000000000) {
      return '${(value / 1000000000).toStringAsFixed(1)} bilhões';
    } else if (value >= 1000000) {
      return '${(value / 1000000).toStringAsFixed(1)} milhões';
    } else if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(1)} mil';
    } else {
      return value.toStringAsFixed(2);
    }
  }

  static String _formatDate(DateTime date) {
    final months = [
      'Jan', 'Fev', 'Mar', 'Abr', 'Mai', 'Jun',
      'Jul', 'Ago', 'Set', 'Out', 'Nov', 'Dez'
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  // Dados de fallback em caso de erro nas APIs
  static List<NewsModel> _getFallbackNews() {
    return [
      NewsModel(
        id: '1',
        title: 'Portal da Transparência disponível para consulta',
        description: 'Acesse dados públicos do governo federal de forma transparente e organizada.',
        imageUrl: 'https://images.pexels.com/photos/590016/pexels-photo-590016.jpeg?auto=compress&cs=tinysrgb&w=800',
        date: _formatDate(DateTime.now()),
        category: 'Transparência',
      ),
    ];
  }

  static SpendingModel _getFallbackSpendingData() {
    return SpendingModel(
      sectors: [
        SectorSpending(
          name: 'Dados Indisponíveis',
          value: 0,
          color: const Color(0xFF6c757d),
        ),
      ],
    );
  }
}