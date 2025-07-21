import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../services/real_data_service.dart';
import '../widgets/filter_chip_widget.dart';
import '../widgets/security_status_widget.dart';
import '../utils/security_utils.dart';
import '../models/security_model.dart';

class SegurancaScreen extends StatefulWidget {
  const SegurancaScreen({super.key});

  @override
  State<SegurancaScreen> createState() => _SegurancaScreenState();
}

class _SegurancaScreenState extends State<SegurancaScreen> with TickerProviderStateMixin {
  String _selectedYear = '2024';
  String _selectedEstado = 'SP';
  String _selectedTab = 'Vítimas';
  Map<String, dynamic>? _dadosSeguranca;
  Map<String, dynamic>? _totaisNacionais;
  Map<String, Map<String, dynamic>>? _detalhamentoCrimes;
  bool _isLoading = true;
  String? _statusMessage;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  final List<String> _years = ['2021', '2022', '2023', '2024', '2025'];
  final List<Map<String, dynamic>> _tabs = SecurityUtils.getSecurityCategories();

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: Duration(milliseconds: 1200),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _loadData();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _statusMessage = null;
    });

    try {
      final dados = await RealDataService.getSegurancaPublica(_selectedYear, _selectedEstado);
      final totais = await RealDataService.getTotaisSegurancaNacional(_selectedYear);
      final detalhamento = await RealDataService.getDetalhamentoCrimes(_selectedYear, _selectedEstado);

      setState(() {
        _dadosSeguranca = dados;
        _totaisNacionais = totais;
        _detalhamentoCrimes = detalhamento;
        _isLoading = false;
        _statusMessage = 'Dados sobre ${_getTabDisplayName(_selectedTab)} carregados';
      });

      _animationController.forward();
    } catch (e) {
      setState(() {
        _isLoading = false;
        _statusMessage = 'Erro ao carregar dados: $e';
      });
    }
  }

  String _getTabDisplayName(String tab) {
    switch (tab) {
      case 'Vítimas': return 'Vítimas';
      case 'Ocorrências': return 'Ocorrências';
      case 'Mandados': return 'Mandados';
      case 'Incêndios': return 'Incêndios';
      case 'Drogas': return 'Drogas';
      default: return tab;
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
      default:
        return '0';
    }
  }

  String _formatNumber(dynamic value) {
    return SecurityUtils.formatNumber(value);
  }

  List<PieChartSectionData> _buildPieChartSections() {
    if (_detalhamentoCrimes == null || _detalhamentoCrimes!['crimes'] == null) return [];

    final crimes = _detalhamentoCrimes!['crimes']!;
    final data = [
      {'name': 'Homicídios', 'value': crimes['homicidios'] ?? 0, 'color': const Color(0xFFdc3545)},
      {'name': 'Furtos', 'value': crimes['furtos'] ?? 0, 'color': const Color(0xFF007bff)},
      {'name': 'Roubos', 'value': crimes['roubos'] ?? 0, 'color': const Color(0xFFfd7e14)},
      {'name': 'Estupros', 'value': crimes['estupros'] ?? 0, 'color': const Color(0xFF6f42c1)},
    ];

    final total = data.fold(0.0, (sum, item) => sum + (item['value'] as num).toDouble());

    return data.where((item) => (item['value'] as num) > 0).map((item) {
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
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  Theme.of(context).colorScheme.primary.withOpacity(0.3),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status dos dados com widget personalizado
            SecurityStatusWidget(
              isLoading: _isLoading,
              message: _statusMessage,
              currentTab: _getTabDisplayName(_selectedTab),
            ),

            const SizedBox(height: 24),

            // Filtros
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
                      ),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _selectedYear,
                        isExpanded: true,
                        items: _years.map((year) {
                          return DropdownMenuItem(
                            value: year,
                            child: Text('Ano $year'),
                          );
                        }).toList(),
                        onChanged: (newValue) {
                          if (newValue != null && newValue != _selectedYear) {
                            setState(() {
                              _selectedYear = newValue;
                            });
                            _loadData();
                          }
                        },
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
                      ),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _selectedEstado,
                        isExpanded: true,
                        items: RealDataService.estadosNomes.entries.map((entry) {
                          return DropdownMenuItem(
                            value: entry.key,
                            child: Text(entry.value),
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
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Valor principal da aba selecionada
            if (!_isLoading && _dadosSeguranca != null) ...[
              FadeTransition(
                opacity: _fadeAnimation,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Theme.of(context).colorScheme.primary.withOpacity(0.1),
                        Theme.of(context).colorScheme.primary.withOpacity(0.05),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                        blurRadius: 8,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Text(
                        'Total de ${_getTabDisplayName(_selectedTab)} em $_selectedYear',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        _getValueForTab(_selectedTab),
                        style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                          fontSize: 36,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        RealDataService.estadosNomes[_selectedEstado] ?? _selectedEstado,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],

            // Abas modernizadas
            Container(
              height: 100,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _tabs.length,
                itemBuilder: (context, index) {
                  final tab = _tabs[index];
                  final isSelected = _selectedTab == tab['key'];

                  return Container(
                    width: 110,
                    margin: EdgeInsets.only(right: 12),
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedTab = tab['key'];
                          _statusMessage = 'Dados sobre ${_getTabDisplayName(tab['key'])} carregados';
                        });
                      },
                      child: AnimatedContainer(
                        duration: Duration(milliseconds: 200),
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? tab['color'].withOpacity(0.15)
                              : Theme.of(context).colorScheme.surface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected
                                ? tab['color']
                                : Theme.of(context).colorScheme.outline.withOpacity(0.2),
                            width: isSelected ? 2 : 1,
                          ),
                          boxShadow: isSelected ? [
                            BoxShadow(
                              color: tab['color'].withOpacity(0.3),
                              blurRadius: 8,
                              offset: Offset(0, 2),
                            ),
                          ] : [],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              tab['icon'],
                              color: isSelected
                                  ? tab['color']
                                  : Theme.of(context).colorScheme.onSurfaceVariant,
                              size: 24,
                            ),
                            SizedBox(height: 8),
                            Text(
                              tab['key'],
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                                color: isSelected
                                    ? tab['color']
                                    : Theme.of(context).colorScheme.onSurfaceVariant,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            if (!_isLoading && _dadosSeguranca != null) ...[
                              SizedBox(height: 4),
                              Text(
                                _getValueForTab(tab['key']),
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: isSelected
                                      ? tab['color']
                                      : Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.7),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 32),

            // Gráfico de distribuição de crimes usando widget personalizado
            if (_selectedTab == 'Vítimas' && !_isLoading && _detalhamentoCrimes != null) ...[
              FadeTransition(
                opacity: _fadeAnimation,
                child: SecurityChartWidget(
                  title: 'Distribuição de Crimes - ${RealDataService.estadosNomes[_selectedEstado]}',
                  chart: PieChart(
                    PieChartData(
                      sections: _buildPieChartSections(),
                      centerSpaceRadius: 50,
                      sectionsSpace: 2,
                    ),
                  ),
                  legends: [
                    _buildLegendItem(
                      'Homicídios',
                      _detalhamentoCrimes!['crimes']!['homicidios'] ?? 0,
                      const Color(0xFFdc3545),
                    ),
                    SizedBox(height: 8),
                    _buildLegendItem(
                      'Furtos',
                      _detalhamentoCrimes!['crimes']!['furtos'] ?? 0,
                      const Color(0xFF007bff),
                    ),
                    SizedBox(height: 8),
                    _buildLegendItem(
                      'Roubos',
                      _detalhamentoCrimes!['crimes']!['roubos'] ?? 0,
                      const Color(0xFFfd7e14),
                    ),
                    SizedBox(height: 8),
                    _buildLegendItem(
                      'Estupros',
                      _detalhamentoCrimes!['crimes']!['estupros'] ?? 0,
                      const Color(0xFF6f42c1),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],

            // Detalhamento por tipo de crime com tooltips
            if (!_isLoading && _detalhamentoCrimes != null) ...[
              FadeTransition(
                opacity: _fadeAnimation,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.analytics,
                            color: Theme.of(context).colorScheme.primary,
                            size: 20,
                          ),
                          SizedBox(width: 8),
                          Text(
                            'Detalhamento por Tipo de Crime',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      Column(
                        children: [
                          _buildDetailedCrimeCard(
                            'Homicídios',
                            _detalhamentoCrimes!['crimes']!['homicidios'] ?? 0,
                            const Color(0xFFdc3545),
                            Icons.dangerous,
                            'Crime contra a vida praticado com intenção de matar',
                          ),
                          SizedBox(height: 12),
                          _buildDetailedCrimeCard(
                            'Furtos',
                            _detalhamentoCrimes!['crimes']!['furtos'] ?? 0,
                            const Color(0xFF007bff),
                            Icons.no_accounts,
                            'Subtração de bem sem violência ou grave ameaça',
                          ),
                          SizedBox(height: 12),
                          _buildDetailedCrimeCard(
                            'Roubos',
                            _detalhamentoCrimes!['crimes']!['roubos'] ?? 0,
                            const Color(0xFFfd7e14),
                            Icons.warning,
                            'Subtração de bem com violência ou grave ameaça',
                          ),
                          SizedBox(height: 12),
                          _buildDetailedCrimeCard(
                            'Estupros',
                            _detalhamentoCrimes!['crimes']!['estupros'] ?? 0,
                            const Color(0xFF6f42c1),
                            Icons.shield,
                            'Crime contra a dignidade sexual',
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],

            // Loading
            if (_isLoading)
              Center(
                child: Container(
                  padding: EdgeInsets.all(24),
                  child: Column(
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 16),
                      Text(
                        'Carregando dados de segurança...',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendItem(String label, dynamic value, Color color) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                _formatNumber(value),
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDetailedCrimeCard(
      String label,
      dynamic value,
      Color color,
      IconData icon,
      String description,
      ) {
    return Tooltip(
      message: description,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: color.withOpacity(0.2),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: color,
                size: 20,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: color,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 11,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  _formatNumber(value),
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                Text(
                  'casos',
                  style: TextStyle(
                    fontSize: 10,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}