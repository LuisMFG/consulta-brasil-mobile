import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../services/api_service.dart';
import '../services/government_apis.dart';
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
  bool _usingRealData = false;
  String? _apiKey;

  final List<String> _years = ['2021', '2022', '2023', '2024', '2025', 'Todos'];

  @override
  void initState() {
    super.initState();
    _loadSpendingData();
  }

  Future<void> _loadSpendingData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _usingRealData = false;
    });

    try {
      SpendingModel data;

      if (_apiKey != null && _apiKey!.isNotEmpty) {
        try {
          GovernmentApisService.setApiKey(_apiKey!);
          data = await GovernmentApisService.getRealSpendingData(_selectedYear);
          _usingRealData = true;
        } catch (e) {
          print('Falha ao usar dados reais: $e');
          data = await ApiService.getSpendingData(_selectedYear);
          _usingRealData = false;
          _errorMessage = 'API indisponível';
        }
      } else {
        data = await ApiService.getSpendingData(_selectedYear);
        _usingRealData = false;
      }

      setState(() {
        _spendingData = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString();
        _usingRealData = false;
      });

      final fallbackData = await ApiService.getSpendingData(_selectedYear);
      setState(() {
        _spendingData = fallbackData;
      });
    }
  }

  void _showApiKeyDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Chave API Portal da Transparência'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Para usar dados reais, você precisa de uma chave API:'),
            const SizedBox(height: 8),
            const Text('1. Acesse: portaldatransparencia.gov.br'),
            const Text('2. Vá em "API de dados" > "Cadastrar email"'),
            const Text('3. Faça login com Gov.br'),
            const Text('4. Cole a chave recebida por email:'),
            const SizedBox(height: 16),
            TextField(
              onChanged: (value) => _apiKey = value,
              decoration: const InputDecoration(
                hintText: 'Cole sua chave API aqui',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _loadSpendingData();
            },
            child: const Text('Usar Dados Reais'),
          ),
        ],
      ),
    );
  }

  double get _totalSpending {
    if (_spendingData == null) return 0;
    return _spendingData!.sectors.fold(0, (sum, sector) => sum + sector.value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Gastos Públicos',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Theme.of(context).colorScheme.surface,
        actions: [
          IconButton(
            icon: Icon(_usingRealData ? Icons.cloud_done : Icons.cloud_off),
            onPressed: _showApiKeyDialog,
            tooltip: _usingRealData ? 'Usando dados reais' : 'Configurar API real',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
                        if (selected) {
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

            if (_errorMessage != null) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _usingRealData ? Colors.green.withOpacity(0.1) : Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: _usingRealData ? Colors.green.withOpacity(0.3) : Colors.orange.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Icon(_usingRealData ? Icons.check_circle : Icons.warning,
                        color: _usingRealData ? Colors.green : Colors.orange),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _usingRealData
                            ? 'Exibindo dados REAIS do Portal da Transparência'
                            : 'Usando dados de demonstração. Toque no ícone ☁ para configurar API real.',
                        style: TextStyle(color: _usingRealData ? Colors.green[800] : Colors.orange[800]),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ] else if (_usingRealData) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.verified, color: Colors.green),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Dados REAIS do Portal da Transparência - Ano $_selectedYear',
                        style: TextStyle(
                          color: Colors.green[800],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            if (_isLoading)
              Center(
                child: Column(
                  children: [
                    const CircularProgressIndicator(),
                    const SizedBox(height: 16),
                    Text(
                      'Carregando dados de $_selectedYear...',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              )
            else if (_spendingData != null) ...[
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Theme.of(context).colorScheme.primary.withOpacity(0.1),
                      Theme.of(context).colorScheme.surface,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Total Gasto em $_selectedYear',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Row(
                          children: [
                            IconButton(
                              onPressed: () {
                                setState(() {
                                  _chartType = 'pie';
                                });
                              },
                              icon: Icon(
                                Icons.pie_chart,
                                color: _chartType == 'pie'
                                    ? Theme.of(context).colorScheme.primary
                                    : Colors.grey,
                              ),
                            ),
                            IconButton(
                              onPressed: () {
                                setState(() {
                                  _chartType = 'bar';
                                });
                              },
                              icon: Icon(
                                Icons.bar_chart,
                                color: _chartType == 'bar'
                                    ? Theme.of(context).colorScheme.primary
                                    : Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'R\$ ${(_totalSpending / 1000000000).toStringAsFixed(1)} bilhões',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      height: 300,
                      child: _chartType == 'pie'
                          ? _buildPieChart()
                          : _buildBarChart(),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              Text(
                'Detalhamento por Setor',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),

              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.2,
                ),
                itemCount: _spendingData!.sectors.length,
                itemBuilder: (context, index) {
                  final sector = _spendingData!.sectors[index];
                  final percentage = _totalSpending > 0
                      ? (sector.value / _totalSpending) * 100
                      : 0.0;

                  return Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: sector.color,
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          sector.name,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const Spacer(),
                        Text(
                          sector.value > 0
                              ? 'R\$ ${(sector.value / 1000000000).toStringAsFixed(1)}B'
                              : 'Sem dados',
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            color: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '${percentage.toStringAsFixed(1)}%',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPieChart() {
    if (_spendingData!.sectors.isEmpty || _totalSpending == 0) {
      return Center(
        child: Text(
          'Dados não disponíveis',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      );
    }

    return PieChart(
      PieChartData(
        sections: _spendingData!.sectors.map((sector) {
          final percentage = (sector.value / _totalSpending) * 100;
          return PieChartSectionData(
            color: sector.color,
            value: sector.value,
            title: percentage >= 5 ? '${percentage.toStringAsFixed(1)}%' : '',
            radius: 80,
            titleStyle: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          );
        }).toList(),
        centerSpaceRadius: 40,
        sectionsSpace: 2,
      ),
    );
  }

  Widget _buildBarChart() {
    if (_spendingData!.sectors.isEmpty || _totalSpending == 0) {
      return Center(
        child: Text(
          'Dados não disponíveis',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      );
    }

    final maxValue = _spendingData!.sectors
        .map((s) => s.value / 1000000000)
        .reduce((a, b) => a > b ? a : b);

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: maxValue * 1.1,
        barTouchData: BarTouchData(
          touchTooltipData: BarTouchTooltipData(
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              final sector = _spendingData!.sectors[group.x.toInt()];
              return BarTooltipItem(
                '${sector.name}\nR\$ ${(sector.value / 1000000000).toStringAsFixed(1)}B',
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