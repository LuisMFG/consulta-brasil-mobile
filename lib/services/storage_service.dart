import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static const String _evaluationsKey = 'evaluations';
  static const String _userPreferencesKey = 'userPreferences';

  // Salvar avaliação
  static Future<void> saveEvaluation(Map<String, int> evaluation) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final evaluations = await getEvaluations();
      
      final newEvaluation = {
        ...evaluation,
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'timestamp': DateTime.now().toIso8601String(),
      };
      
      evaluations.add(newEvaluation);
      await prefs.setString(_evaluationsKey, json.encode(evaluations));
    } catch (e) {
      throw Exception('Erro ao salvar avaliação: $e');
    }
  }

  // Obter avaliações
  static Future<List<Map<String, dynamic>>> getEvaluations() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final evaluationsJson = prefs.getString(_evaluationsKey);
      
      if (evaluationsJson != null) {
        final List<dynamic> evaluationsList = json.decode(evaluationsJson);
        return evaluationsList.cast<Map<String, dynamic>>();
      }
      
      return [];
    } catch (e) {
      return [];
    }
  }

  // Limpar avaliações
  static Future<void> clearEvaluations() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_evaluationsKey);
    } catch (e) {
      throw Exception('Erro ao limpar avaliações: $e');
    }
  }

  // Salvar preferências do usuário
  static Future<void> saveUserPreferences(Map<String, dynamic> preferences) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_userPreferencesKey, json.encode(preferences));
    } catch (e) {
      throw Exception('Erro ao salvar preferências: $e');
    }
  }

  // Obter preferências do usuário
  static Future<Map<String, dynamic>> getUserPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final preferencesJson = prefs.getString(_userPreferencesKey);
      
      if (preferencesJson != null) {
        return json.decode(preferencesJson);
      }
      
      return {};
    } catch (e) {
      return {};
    }
  }

  // Métodos auxiliares para estatísticas
  static Future<Map<String, double>> getEvaluationStats() async {
    try {
      final evaluations = await getEvaluations();
      
      if (evaluations.isEmpty) {
        return {
          'averageSpeed': 0.0,
          'averageUsability': 0.0,
          'averageAccessibility': 0.0,
          'averageSecurity': 0.0,
          'averageOverall': 0.0,
          'totalEvaluations': 0.0,
        };
      }

      double totalSpeed = 0;
      double totalUsability = 0;
      double totalAccessibility = 0;
      double totalSecurity = 0;
      double totalOverall = 0;

      for (final evaluation in evaluations) {
        totalSpeed += (evaluation['speed'] ?? 0).toDouble();
        totalUsability += (evaluation['usability'] ?? 0).toDouble();
        totalAccessibility += (evaluation['accessibility'] ?? 0).toDouble();
        totalSecurity += (evaluation['security'] ?? 0).toDouble();
        totalOverall += (evaluation['overall'] ?? 0).toDouble();
      }

      final count = evaluations.length.toDouble();

      return {
        'averageSpeed': totalSpeed / count,
        'averageUsability': totalUsability / count,
        'averageAccessibility': totalAccessibility / count,
        'averageSecurity': totalSecurity / count,
        'averageOverall': totalOverall / count,
        'totalEvaluations': count,
      };
    } catch (e) {
      return {
        'averageSpeed': 0.0,
        'averageUsability': 0.0,
        'averageAccessibility': 0.0,
        'averageSecurity': 0.0,
        'averageOverall': 0.0,
        'totalEvaluations': 0.0,
      };
    }
  }
}