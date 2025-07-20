import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../services/real_data_service.dart';
import '../models/spending_model.dart';
import '../widgets/filter_chip_widget.dart';

class GastosScreen extends StatefulWidget {
  const GastosScreen({super.key});

  @override
  State<GastosScreen> createState() => _GastosScreenState();
}

class _GastosScreenState extends State<GastosScreen> {
  String _selectedYear = '2024';
  String _chartType = 'pie';
  SpendingModel? _spendingData;
  bool _isLoading = true;
  String? _errorMessage;

  final List<String> _years = ['2021', '2022', '2023', '2024', '2025'];

  @override
  void initState() {
    super.initState();
    _loadSpendingData();
  }

  Future<void> _loadSpendingData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final data = await RealDataService.getGastosPublicos(_selectedYear);
      setState(() {
        _spendingData = data;
        _isLoading = false;
        _errorMessage = 'Dados atualizados carregados';
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Erro ao carregar dados: $e';
      });
    }
  }

  double get _totalSpending {
    if (_spendingData == null) return 0;
    return _spendingData!.sectors.fold(0, (sum, sector) => sum + sector.value);
  }

  String _formatCurrency(double value) {
    if (value >= 1000000000000) {
      return 'R\$ ${(value / 1000000000000).toStringAsFixed(1)} trilhoes';
    } else if (value >= 1000000000) {
      return 'R\$ ${(value / 1000000000).toStringAsFixed(1)} bilhoes';
    } else if (value >= 1000000) {
      return 'R\$ ${(value / 1000000).toStringAsFixed(1)} milhoes';
    } else {
      return 'R\$ ${value.toStringAsFixed(2)}';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Gastos Publicos',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Theme.of(context).colorScheme.surface,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status dos dados
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                    color: Colors.orange.withOpacity(0.3)
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info,
                    color: Colors.orange,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _errorMessage ?? 'Dados atualizados carregados',
                      style: TextStyle(
                        color: Colors.orange[700],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Filtros por ano
            Row(
              children: [
                Icon(
                  Icons.filter_list,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Filtrar por Ano',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _years.map((year) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChipWidget(
                      label: year,
                      isSelected: _selectedYear == year,
                      onSelected: (selected) {
                        if (selected && _selectedYear != year) {
                          setState(() {
                            _selectedYear = year;
                          });
                          _loadSpendingData();
                        }
                      },
                    ),
                  );
                }).toList(),
              ),
            ),

            const SizedBox(height: 24),

            // Total de gastos
            if (!_isLoading && _spendingData != null) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Theme.of(context).colorScheme.primary.withOpacity(0.1),
                      Theme.of(context).colorScheme.primary.withOpacity(0.05),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                  ),
                ),
                child: Column(
                  children: [
                    Text(
                      'Total de Gastos em $_selectedYear',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _formatCurrency(_totalSpending),
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],

            // Controles do gráfico
            Row(
              children: [
                Icon(
                  Icons.bar_chart,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Tipo de Grafico',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            Row(
              children: [
                FilterChipWidget(
                  label: 'Pizza',
                  isSelected: _chartType == 'pie',
                  onSelected: (selected) {
                    if (selected) {
                      setState(() {
                        _chartType = 'pie';
                      });
                    }
                  },
                ),
                const SizedBox(width: 8),
                FilterChipWidget(
                  label: 'Barras',
                  isSelected: _chartType == 'bar',
                  onSelected: (selected) {
                    if (selected) {
                      setState(() {
                        _chartType = 'bar';
                      });
                    }
                  },
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Gráfico
            if (_isLoading)
              const Center(
                child: Column(
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Carregando dados...'),
                  ],
                ),
              )
            else if (_spendingData != null && _spendingData!.sectors.isNotEmpty)
              Container(
                height: 300,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: _chartType == 'pie' ? _buildPieChart() : _buildBarChart(),
                ),
              )
            else
              Container(
                height: 200,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
                  ),
                ),
                child: const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.info_outline, size: 48, color: Colors.grey),
                      SizedBox(height: 8),
                      Text('Nenhum dado disponivel'),
                    ],
                  ),
                ),
              ),

            const SizedBox(height: 24),

            // Legenda
            if (_spendingData != null && _spendingData!.sectors.isNotEmpty) ...[
              Text(
                'Distribuicao por Setor',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              ...(_spendingData!.sectors.map((sector) {
                final percentage = (_totalSpending > 0)
                    ? (sector.value / _totalSpending * 100)
                    : 0.0;

                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 16,
                        height: 16,
                        decoration: BoxDecoration(
                          color: sector.color,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              sector.name,
                              style: const TextStyle(fontWeight: FontWeight.w500),
                            ),
                            Text(
                              _formatCurrency(sector.value),
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        '${percentage.toStringAsFixed(1)}%',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                );
              }).toList()),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPieChart() {
    if (_spendingData == null || _spendingData!.sectors.isEmpty) {
      return const Center(child: Text('Nenhum dado disponivel'));
    }

    return PieChart(
      PieChartData(
        sections: _spendingData!.sectors.map((sector) {
          final percentage = (_totalSpending > 0)
              ? (sector.value / _totalSpending * 100)
              : 0.0;

          return PieChartSectionData(
            color: sector.color,
            value: sector.value,
            title: '${percentage.toStringAsFixed(1)}%',
            radius: 100,
            titleStyle: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          );
        }).toList(),
        sectionsSpace: 2,
        centerSpaceRadius: 40,
        pieTouchData: PieTouchData(
          touchCallback: (FlTouchEvent event, pieTouchResponse) {
            // Adicionar interatividade se necessário
          },
        ),
      ),
    );
  }

  Widget _buildBarChart() {
    if (_spendingData == null || _spendingData!.sectors.isEmpty) {
      return const Center(child: Text('Nenhum dado disponivel'));
    }

    final maxValue = _spendingData!.sectors
        .map((s) => s.value)
        .reduce((a, b) => a > b ? a : b) / 1000000000;

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: maxValue * 1.1,
        barTouchData: BarTouchData(
          touchTooltipData: BarTouchTooltipData(
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              final sector = _spendingData!.sectors[group.x.toInt()];
              return BarTooltipItem(
                '${sector.name}\n${_formatCurrency(sector.value)}',
                const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              );
            },
          ),
        ),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                if (value.toInt() < _spendingData!.sectors.length) {
                  final sector = _spendingData!.sectors[value.toInt()];
                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      sector.name.length > 8
                          ? '${sector.name.substring(0, 8)}...'
                          : sector.name,
                      style: const TextStyle(fontSize: 10),
                      textAlign: TextAlign.center,
                    ),
                  );
                }
                return const Text('');
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                return Text(
                  '${value.toStringAsFixed(0)}B',
                  style: const TextStyle(fontSize: 10),
                );
              },
            ),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        borderData: FlBorderData(show: false),
        barGroups: _spendingData!.sectors.asMap().entries.map((entry) {
          return BarChartGroupData(
            x: entry.key,
            barRods: [
              BarChartRodData(
                toY: entry.value.value / 1000000000,
                color: entry.value.color,
                width: 30,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(4),
                  topRight: Radius.circular(4),
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }
}