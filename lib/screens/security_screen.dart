import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../services/real_data_service.dart';
import '../widgets/filter_chip_widget.dart';

class SegurancaScreen extends StatefulWidget {
  const SegurancaScreen({super.key});

  @override
  State<SegurancaScreen> createState() => _SegurancaScreenState();
}

class _SegurancaScreenState extends State<SegurancaScreen> {
  String _selectedYear = '2024';
  String _selectedEstado = 'SP';
  String _selectedTab = 'Ocorrências';
  Map<String, dynamic>? _dadosSeguranca;
  Map<String, dynamic>? _totaisNacionais;
  bool _isLoading = true;
  String? _errorMessage;

  final List<String> _years = ['2021', '2022', '2023', '2024', '2025'];
  final List<String> _tabs = ['Vítimas', 'Ocorrências', 'Mandados', 'Incêndios', 'Drogas', 'Dicionário'];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final dados = await RealDataService.getSegurancaPublica(_selectedYear, _selectedEstado);
      final totais = await RealDataService.getTotaisSegurancaNacional(_selectedYear);

      setState(() {
        _dadosSeguranca = dados;
        _totaisNacionais = totais;
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

  String _getValueForTab(String tab) {
    if (_dadosSeguranca == null) return '0';

    switch (tab) {
      case 'Vítimas':
        return _formatNumber(_dadosSeguranca!['vitimas'] ?? 0);
      case 'Ocorrências':
        return _formatNumber(_dadosSeguranca!['ocorrencias'] ?? 0);
      case 'Mandados':
        return _formatNumber(_dadosSeguranca!['mandados'] ?? 0);
      case 'Incêndios':
        return _formatNumber(_dadosSeguranca!['incendios'] ?? 0);
      case 'Drogas':
        return _formatNumber(_dadosSeguranca!['drogas'] ?? 0);
      case 'Dicionário':
        return _formatNumber(_dadosSeguranca!['dicionario'] ?? 0);
      default:
        return '0';
    }
  }

  String _formatNumber(dynamic value) {
    if (value == null) return '0';
    final num = value is int ? value : int.tryParse(value.toString()) ?? 0;

    if (num >= 1000000) {
      return '${(num / 1000000).toStringAsFixed(1)}M';
    } else if (num >= 1000) {
      return '${(num / 1000).toStringAsFixed(1)}K';
    } else {
      return num.toString();
    }
  }

  List<PieChartSectionData> _buildPieChartSections() {
    if (_dadosSeguranca == null) return [];

    final data = [
      {'name': 'Homicídios', 'value': _dadosSeguranca!['homicidios'] ?? 0, 'color': const Color(0xFFdc3545)},
      {'name': 'Furtos', 'value': _dadosSeguranca!['furtos'] ?? 0, 'color': const Color(0xFF007bff)},
      {'name': 'Roubos', 'value': _dadosSeguranca!['roubos'] ?? 0, 'color': const Color(0xFFfd7e14)},
      {'name': 'Estupros', 'value': _dadosSeguranca!['estupros'] ?? 0, 'color': const Color(0xFF6f42c1)},
      {'name': 'Drogas', 'value': _dadosSeguranca!['drogas'] ?? 0, 'color': const Color(0xFF20c997)},
      {'name': 'Outros', 'value': (_dadosSeguranca!['vitimas'] ?? 0) * 0.15, 'color': const Color(0xFF6c757d)},
    ];

    final total = data.fold(0.0, (sum, item) => sum + (item['value'] as num).toDouble());

    return data.map((item) {
      final value = (item['value'] as num).toDouble();
      final percentage = total > 0 ? (value / total * 100) : 0.0;

      return PieChartSectionData(
        color: item['color'] as Color,
        value: value,
        title: '${percentage.toStringAsFixed(1)}%',
        radius: 80,
        titleStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }).toList();
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

            // Filtros
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

            // Filtro por Ano
            Text(
              'Ano',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
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
                        if (selected && _selectedYear != year) {
                          setState(() {
                            _selectedYear = year;
                          });
                          _loadData();
                        }
                      },
                    ),
                  );
                }).toList(),
              ),
            ),

            const SizedBox(height: 16),

            // Filtro por Estado
            Text(
              'Estado',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.withOpacity(0.3)),
                borderRadius: BorderRadius.circular(8),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedEstado,
                  isExpanded: true,
                  items: RealDataService.estadosDisponiveis.map((estado) {
                    return DropdownMenuItem(
                      value: estado,
                      child: Text(RealDataService.estadosNomes[estado] ?? estado),
                    );
                  }).toList(),
                  onChanged: (newValue) {
                    if (newValue != null && newValue != _selectedEstado) {
                      setState(() {
                        _selectedEstado = newValue;
                      });
                      _loadData();
                    }
                  },
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Valor principal da aba selecionada
            if (!_isLoading && _dadosSeguranca != null) ...[
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
                      'Total de $_selectedTab em $_selectedYear',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _getValueForTab(_selectedTab),
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

            // Abas
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _tabs.map((tab) {
                  final isSelected = _selectedTab == tab;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedTab = tab;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? Theme.of(context).colorScheme.primary
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isSelected
                                ? Theme.of(context).colorScheme.primary
                                : Colors.grey.withOpacity(0.3),
                          ),
                        ),
                        child: Text(
                          tab,
                          style: TextStyle(
                            color: isSelected
                                ? Colors.white
                                : Theme.of(context).colorScheme.onSurface,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),

            const SizedBox(height: 24),

            // Gráfico de Pizza
            if (!_isLoading && _dadosSeguranca != null) ...[
              Text(
                'Distribuicao de Crimes - ${RealDataService.estadosNomes[_selectedEstado]}',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
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
                  child: PieChart(
                    PieChartData(
                      sections: _buildPieChartSections(),
                      centerSpaceRadius: 40,
                      sectionsSpace: 2,
                      pieTouchData: PieTouchData(enabled: true),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],

            // Legenda
            if (!_isLoading && _dadosSeguranca != null) ...[
              Text(
                'Detalhamento por Tipo de Crime',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              _buildLegendItem('Homicídios', _dadosSeguranca!['homicidios'] ?? 0, const Color(0xFFdc3545)),
              _buildLegendItem('Furtos', _dadosSeguranca!['furtos'] ?? 0, const Color(0xFF007bff)),
              _buildLegendItem('Roubos', _dadosSeguranca!['roubos'] ?? 0, const Color(0xFFfd7e14)),
              _buildLegendItem('Estupros', _dadosSeguranca!['estupros'] ?? 0, const Color(0xFF6f42c1)),
              _buildLegendItem('Apreensões de Drogas', _dadosSeguranca!['drogas'] ?? 0, const Color(0xFF20c997)),
            ],

            // Loading
            if (_isLoading)
              const Center(
                child: Column(
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Carregando dados de segurança...'),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendItem(String label, dynamic value, Color color) {
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
              color: color,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Text(
            _formatNumber(value),
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}