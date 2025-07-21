import 'package:flutter/material.dart';

class SecurityStatusWidget extends StatelessWidget {
  final bool isLoading;
  final String? message;
  final String currentTab;

  const SecurityStatusWidget({
    Key? key,
    required this.isLoading,
    this.message,
    required this.currentTab,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 300),
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _getStatusColor(context).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _getStatusColor(context).withOpacity(0.3),
        ),
        boxShadow: [
          BoxShadow(
            color: _getStatusColor(context).withOpacity(0.1),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          AnimatedSwitcher(
            duration: Duration(milliseconds: 300),
            child: _buildStatusIcon(context),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _getStatusTitle(),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: _getStatusColor(context),
                  ),
                ),
                if (message != null) ...[
                  SizedBox(height: 2),
                  Text(
                    message!,
                    style: TextStyle(
                      fontSize: 11,
                      color: _getStatusColor(context).withOpacity(0.8),
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (isLoading)
            Container(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(_getStatusColor(context)),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStatusIcon(BuildContext context) {
    if (isLoading) {
      return Container(
        width: 16,
        height: 16,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(_getStatusColor(context)),
        ),
      );
    }

    return Icon(
      Icons.check_circle,
      color: _getStatusColor(context),
      size: 16,
    );
  }

  Color _getStatusColor(BuildContext context) {
    if (isLoading) {
      return Colors.blue;
    }
    return Colors.green;
  }

  String _getStatusTitle() {
    if (isLoading) {
      return 'Carregando dados...';
    }
    return 'Dados sobre $currentTab';
  }
}

class SecurityMetricCard extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;

  const SecurityMetricCard({
    Key? key,
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.color,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              color.withOpacity(0.1),
              color.withOpacity(0.05),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: color.withOpacity(0.3),
          ),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.1),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: EdgeInsets.all(8),
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
                if (onTap != null)
                  Icon(
                    Icons.arrow_forward_ios,
                    color: color.withOpacity(0.7),
                    size: 12,
                  ),
              ],
            ),
            SizedBox(height: 12),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            SizedBox(height: 2),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 11,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SecurityChartWidget extends StatelessWidget {
  final String title;
  final Widget chart;
  final List<Widget> legends;

  const SecurityChartWidget({
    Key? key,
    required this.title,
    required this.chart,
    required this.legends,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
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
                Icons.pie_chart,
                color: Theme.of(context).colorScheme.primary,
                size: 20,
              ),
              SizedBox(width: 8),
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          Container(
            height: 250,
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: chart,
                ),
                SizedBox(width: 16),
                Expanded(
                  flex: 1,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: legends,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}