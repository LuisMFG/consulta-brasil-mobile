import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import '../models/news_model.dart';
import '../models/spending_model.dart';
import 'package:flutter/material.dart';
import 'government_apis.dart';

class ApiService {
  static bool _useRealApis = true;

  static void setUseRealApis(bool useReal) {
    _useRealApis = useReal;
  }

  static void setApiKey(String key) {
    GovernmentApisService.setApiKey(key);
  }

  static Future<List<NewsModel>> getNews() async {
    try {
      if (_useRealApis) {
        return await _getRealNews();
      } else {
        return await _getFallbackNews();
      }
    } catch (e) {
      print('Erro ao carregar notícias: $e');
      return await _getFallbackNews();
    }
  }

  static Future<SpendingModel> getSpendingData(String year) async {
    try {
      if (_useRealApis) {
        try {
          return await GovernmentApisService.getRealSpendingData(year);
        } catch (e) {
          print('APIs reais indisponíveis para $year: $e');
        }
      }

      return await _getFallbackSpendingData(year);
    } catch (e) {
      print('Erro geral ao buscar dados para $year: $e');
      return await _getFallbackSpendingData(year);
    }
  }

  static Future<List<NewsModel>> _getRealNews() async {
    final List<NewsModel> news = [];

    try {
      final apiStatus = await GovernmentApisService.checkApiStatus();
      final onlineApis = apiStatus.entries.where((e) => e.value).length;

      news.add(NewsModel(
        id: '1',
        title: '$onlineApis APIs governamentais ativas monitoradas em tempo real',
        description: 'Sistema monitora continuamente APIs do Portal da Transparência, IBGE, SICONV e Banco Central.',
        imageUrl: 'https://images.pexels.com/photos/590016/pexels-photo-590016.jpeg?auto=compress&cs=tinysrgb&w=800',
        date: _formatDate(DateTime.now()),
        category: 'Transparência',
      ));

      final estados = await GovernmentApisService.getEstadosIBGE();
      if (estados.isNotEmpty) {
        news.add(NewsModel(
          id: '2',
          title: 'IBGE disponibiliza dados atualizados de ${estados.length} estados',
          description: 'Base de dados de localidades do IBGE mantém informações geográficas atualizadas do Brasil.',
          imageUrl: 'https://images.pexels.com/photos/1181534/pexels-photo-1181534.jpeg?auto=compress&cs=tinysrgb&w=800',
          date: _formatDate(DateTime.now().subtract(const Duration(days: 1))),
          category: 'Estatísticas',
        ));
      }

      final convenios = await GovernmentApisService.getConveniosSICONV(limit: 10);
      if (convenios.isNotEmpty) {
        final valorTotal = convenios.fold(0.0, (sum, conv) => sum + (conv['valor'] as double));
        news.add(NewsModel(
          id: '3',
          title: '${convenios.length} convênios ativos no SICONV',
          description: 'Sistema registra R\$ ${_formatCurrency(valorTotal)} em convênios federais.',
          imageUrl: 'https://images.pexels.com/photos/1106468/pexels-photo-1106468.jpeg?auto=compress&cs=tinysrgb&w=800',
          date: _formatDate(DateTime.now().subtract(const Duration(days: 2))),
          category: 'Convênios',
        ));
      }

      final selic = await GovernmentApisService.getTaxasJuros();
      if (selic.isNotEmpty && selic.containsKey('taxas')) {
        final taxas = selic['taxas'] as List;
        if (taxas.isNotEmpty) {
          news.add(NewsModel(
            id: '4',
            title: 'Taxa Selic atual: ${taxas[0]['valor']}% ao ano',
            description: 'Banco Central mantém dados econômicos atualizados para transparência.',
            imageUrl: 'https://images.pexels.com/photos/259200/pexels-photo-259200.jpeg?auto=compress&cs=tinysrgb&w=800',
            date: _formatDate(DateTime.now().subtract(const Duration(days: 3))),
            category: 'Economia',
          ));
        }
      }

      return news.isNotEmpty ? news : await _getFallbackNews();
    } catch (e) {
      print('Erro ao buscar notícias reais: $e');
      return await _getFallbackNews();
    }
  }

  static Future<SpendingModel?> _loadMockSpendingData(String year) async {
    try {
      final String jsonString = await rootBundle.loadString('assets/data/mock_data.json');
      final Map<String, dynamic> jsonData = json.decode(jsonString);

      String key = 'spending_$year';
      if (year == 'Todos') {
        key = 'spending_2024';
      }

      if (jsonData.containsKey(key)) {
        return SpendingModel.fromJson(jsonData[key]);
      }

      if (year == 'Todos') {
        final years = ['2021', '2022', '2023', '2024', '2025'];
        final Map<String, double> totalSetores = {};

        for (final y in years) {
          final yearKey = 'spending_$y';
          if (jsonData.containsKey(yearKey)) {
            final yearData = SpendingModel.fromJson(jsonData[yearKey]);
            for (final sector in yearData.sectors) {
              totalSetores[sector.name] = (totalSetores[sector.name] ?? 0) + sector.value;
            }
          }
        }

        final sectors = totalSetores.entries.map((entry) {
          return SectorSpending(
            name: entry.key,
            value: entry.value,
            color: _getSectorColor(entry.key),
          );
        }).toList();

        sectors.sort((a, b) => b.value.compareTo(a.value));
        return SpendingModel(sectors: sectors);
      }

      return null;
    } catch (e) {
      print('Erro ao carregar dados mock: $e');
      return null;
    }
  }

  static Color _getSectorColor(String sectorName) {
    final Map<String, String> coresMap = {
      'Previdência': '#28a745',
      'Saúde': '#dc3545',
      'Educação': '#007bff',
      'Defesa': '#fd7e14',
      'Infraestrutura': '#6f42c1',
      'Segurança': '#20c997',
      'Outros': '#6c757d',
    };

    final colorHex = coresMap[sectorName] ?? '#6c757d';
    return Color(int.parse(colorHex.substring(1), radix: 16) + 0xFF000000);
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

  static String _formatDate(DateTime date) {
    final months = [
      'Jan', 'Fev', 'Mar', 'Abr', 'Mai', 'Jun',
      'Jul', 'Ago', 'Set', 'Out', 'Nov', 'Dez'
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  static Future<List<NewsModel>> _getFallbackNews() async {
    try {
      final String jsonString = await rootBundle.loadString('assets/data/mock_data.json');
      final Map<String, dynamic> jsonData = json.decode(jsonString);
      final List<dynamic> newsData = jsonData['news'] ?? [];

      return newsData.map((item) => NewsModel.fromJson(item)).toList();
    } catch (e) {
      return [
        NewsModel(
          id: '1',
          title: 'Sistema funcionando em modo offline',
          description: 'Dados governamentais temporariamente indisponíveis. Exibindo informações de demonstração.',
          imageUrl: 'https://images.pexels.com/photos/590016/pexels-photo-590016.jpeg?auto=compress&cs=tinysrgb&w=800',
          date: _formatDate(DateTime.now()),
          category: 'Sistema',
        ),
      ];
    }
  }

  static Future<SpendingModel> _getFallbackSpendingData(String year) async {
    try {
      final mockData = await _loadMockSpendingData(year);
      if (mockData != null) {
        return mockData;
      }
    } catch (e) {
      print('Erro ao carregar dados de fallback: $e');
    }

    return SpendingModel(
      sectors: [
        SectorSpending(
          name: 'APIs Indisponíveis',
          value: 0.0,
          color: const Color(0xFF6c757d),
        ),
      ],
    );
  }

  static Future<Map<String, bool>> checkApiStatus() async {
    try {
      return await GovernmentApisService.checkApiStatus();
    } catch (e) {
      return {
        'Portal da Transparência': false,
        'IBGE': false,
        'SICONV': false,
        'Banco Central': false,
      };
    }
  }
}