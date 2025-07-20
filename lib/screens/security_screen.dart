import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/security_model.dart';
import '../services/security_api_service.dart';
import '../widgets/filter_chip_widget.dart';

class SecurityScreen extends StatefulWidget {
  const SecurityScreen({super.key});

  @override
  State<SecurityScreen> createState() => _SecurityScreenState();
}

class _SecurityScreenState extends State<SecurityScreen> {
  String _selectedCategory = 'victims';
  String _selectedYear = '2024';
  String _selectedState = 'Todos';
  SecurityStatistics? _securityData;
  bool _isLoading = false;
  String _chartType = 'pie';

  final List<String> _years = ['2021', '2022', '2023', '2024', '2025'];
  final List<String> _states = [
    'Todos', 'AC', 'AL', 'AP', 'AM', 'BA', 'CE', 'DF', 'ES', 'GO',
    'MA', 'MT', 'MS', 'MG', 'PA', 'PB', 'PR', 'PE', 'PI', 'RJ',
    'RN', 'RS', 'RO', 'RR', 'SC', 'SP', 'SE', 'TO'
  ];

  @override
  void initState() {
    super.initState();
    _loadSecurityData();
  }

  Future<void> _loadSecurityData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final data = await SecurityApiService.getSecurityStatistics(
        category: _selectedCategory,
        year: _selectedYear,
        state: _selectedState == 'Todos' ? null : _selectedState,
      );

      setState(() {
        _securityData = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _securityData = _generateMockData();
      });
    }
  }

  SecurityStatistics _generateMockData() {
    final mockData = {
      'victims': {
        'total': 45320,
        'byState': {'SP': 12500, 'RJ': 8300, 'MG': 5200, 'BA': 4800, 'PR': 3900, 'RS': 3600, 'Outros': 7020},
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

    final categoryData = mockData[_selectedCategory] ?? mockData['victims']!;

    return SecurityStatistics(
      category: _selectedCategory,
      total: categoryData['total'] as int,
      byState: Map<String, int>.from(categoryData['byState'] as Map),
      byMonth: Map<String, int>.from(categoryData['byMonth'] as Map),
      year: _selectedYear,
    );
  }

  String get _categoryTitle {
    switch (_selectedCategory) {
      case 'victims': return 'Vítimas';
      case 'occurrences': return 'Ocorrências';
      case 'mandados': return 'Mandados';
      case 'fire': return 'Incêndios';
      case 'drugs': return 'Drogas';
      default: return 'Dados';
    }
  }

  String get _totalLabel {
    switch (_selectedCategory) {
      case 'victims': return 'Total de Vítimas';
      case 'occurrences': return 'Total de Ocorrências';
      case 'mandados': return 'Total de Mandados';
      case 'fire': return 'Total de Incêndios';
      case 'drugs': return 'Total de Apreensões';
      default: return 'Total';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Segurança Pública',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Theme.of(context).colorScheme.surface,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCategorySelector(),
            const SizedBox(height: 24),
            _buildFilters(),
            const SizedBox(height: 24),
            if (_isLoading)
              const Center(
                child: Column(
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Carregando dados de segurança...'),
                  ],
                ),
              )
            else if (_securityData != null) ...[
              _buildStatsCard(),
              const SizedBox(height: 24),
              _buildDetailsByState(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCategorySelector() {
    final categories = SecurityApiService.getSecurityCategories();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.security,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(width: 8),
            Text(
              'Categoria',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 2.5,
          ),
          itemCount: categories.length,
          itemBuilder: (context, index) {
            final category = categories[index];
            final isSelected = _selectedCategory == category.id;

            return GestureDetector(
              onTap: () {
                setState(() {
                  _selectedCategory = category.id;
                });
                _loadSecurityData();
              },
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isSelected
                      ? category.color.withOpacity(0.1)
                      : Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected
                        ? category.color
                        : Colors.grey.withOpacity(0.3),
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      category.icon,
                      color: isSelected ? category.color : Colors.grey[600],
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        category.name,
                        style: TextStyle(
                          color: isSelected ? category.color : Colors.grey[700],
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildFilters() {
    return Column(
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
              'Filtros',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        Text(
          'Ano',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
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
                      _loadSecurityData();
                    }
                  },
                ),
              );
            }).toList(),
          ),
        ),

        const SizedBox(height: 16),

        Text(
          'Estado',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.withOpacity(0.3)),
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedState,
              isExpanded: true,
              items: _states.map((state) {
                return DropdownMenuItem(
                  value: state,
                  child: Text(state),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedState = value;
                  });
                  _loadSecurityData();
                }
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatsCard() {
    if (_securityData == null) return const SizedBox();

    return Container(
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
                '$_totalLabel em $_selectedYear',
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
            _formatNumber(_securityData!.total),
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
    );
  }

  Widget _buildPieChart() {
    final data = _securityData!.byState.entries.toList();
    final total = _securityData!.total.toDouble();

    return PieChart(
      PieChartData(
        sections: data.map((entry) {
          final percentage = (entry.value / total) * 100;
          return PieChartSectionData(
            color: _getStateColor(entry.key),
            value: entry.value.toDouble(),
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
    final data = _securityData!.byMonth.entries.toList();
    final maxValue = data.map((e) => e.value).reduce((a, b) => a > b ? a : b);

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: maxValue * 1.1,
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                if (value.toInt() < data.length) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      data[value.toInt()].key,
                      style: const TextStyle(fontSize: 10),
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
                  _formatShortNumber(value),
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
        barGroups: data.asMap().entries.map((entry) {
          return BarChartGroupData(
            x: entry.key,
            barRods: [
              BarChartRodData(
                toY: entry.value.value.toDouble(),
                color: Theme.of(context).colorScheme.primary,
                width: 16,
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

  Widget _buildDetailsByState() {
    if (_securityData == null) return const SizedBox();

    final sortedStates = _securityData!.byState.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Detalhamento por Estado',
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
            childAspectRatio: 1.3,
          ),
          itemCount: sortedStates.length,
          itemBuilder: (context, index) {
            final state = sortedStates[index];
            final percentage = (_securityData!.total > 0)
                ? (state.value / _securityData!.total) * 100
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
                      color: _getStateColor(state.key),
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    state.key,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    _formatNumber(state.value),
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
    );
  }

  Color _getStateColor(String state) {
    final colors = [
      const Color(0xFF28a745),
      const Color(0xFFdc3545),
      const Color(0xFF007bff),
      const Color(0xFFfd7e14),
      const Color(0xFF6f42c1),
      const Color(0xFF20c997),
      const Color(0xFF17a2b8),
      const Color(0xFFffc107),
    ];

    return colors[state.hashCode % colors.length];
  }

  String _formatNumber(int number) {
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    } else {
      return number.toString();
    }
  }

  String _formatShortNumber(double number) {
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(0)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(0)}K';
    } else {
      return number.toStringAsFixed(0);
    }
  }
}