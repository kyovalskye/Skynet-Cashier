import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:skynet_internet_cafe/presentation/widgets/navbar_widget.dart';
import 'package:skynet_internet_cafe/presentation/widgets/appbar_widget.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        toolbarHeight: 70,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Ambanet Cafe',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'Rabu, 15 Oktober 2025',
              style: TextStyle(color: Colors.grey[500], fontSize: 12),
            ),
          ],
        ),
        actions: const [AppbarWidget(), SizedBox(width: 8)],
      ),
      bottomNavigationBar: const NavbarWidget(),
      backgroundColor: Colors.black,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Active Seats Cards
                Row(
                  children: [
                    Expanded(
                      child: _buildActiveSeatsCard(
                        context,
                        seatNumber: '3',
                        color: Colors.cyan,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildActiveSeatsCard(
                        context,
                        seatNumber: '3',
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Income Card
                _buildIncomeCard(context),

                const SizedBox(height: 12),

                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: _buildActionButton(
                        context,
                        icon: Icons.add,
                        label: 'Add customer',
                        onTap: () {},
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildActionButton(
                        context,
                        icon: Icons.add,
                        label: 'Purchase',
                        onTap: () {},
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildActionButton(
                        context,
                        icon: Icons.add,
                        label: 'Seats',
                        onTap: () {},
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Last 7 days sales
                const Text(
                  'Last 7 days sales',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                _buildBarChart(
                  [
                    [80, 40, 20],
                    [60, 90, 30],
                    [50, 30, 100],
                    [40, 80, 60],
                    [90, 50, 70],
                    [70, 100, 50],
                    [60, 40, 90],
                  ],
                  ['Rp 30.000', 'Rp 50.000', '', 'Rp 30.000'],
                ),
                const SizedBox(height: 20),

                // Monthly sales
                const Text(
                  'Monthly sales',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                _buildBarChart(
                  [
                    [80, 50, 30],
                    [40, 100, 50],
                    [70, 60, 80],
                    [90, 70, 60],
                    [60, 80, 100],
                    [80, 50, 70],
                    [50, 90, 60],
                    [100, 60, 80],
                  ],
                  ['Rp 30.000', 'Rp 30.000', '', 'Rp 30.000'],
                ),
                const SizedBox(height: 20),

                // Transactions List
                const Text(
                  'Transactions List',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                _buildTransactionItem(
                  'INV-A1B2C3D4',
                  'Due date: Monday, 30 October 2025',
                  'Rp 56.000',
                ),
                _buildTransactionItem(
                  'INV-A1B2C3D4',
                  'Due date: Monday, 30 October 2025',
                  'Rp 56.000',
                ),
                _buildTransactionItem(
                  'INV-A1B2C3D4',
                  'Due date: Monday, 30 October 2025',
                  'Rp 56.000',
                ),
                _buildTransactionItem(
                  'INV-A1B2C3D4',
                  'Due date: Monday, 30 October 2025',
                  'Rp 56.000',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActiveSeatsCard(
    BuildContext context, {
    required String seatNumber,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(Icons.show_chart, color: color, size: 24),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                seatNumber,
                style: TextStyle(
                  color: color,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Active seats',
                style: TextStyle(color: Colors.grey[500], fontSize: 11),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildIncomeCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF4A148C).withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.purple.withOpacity(0.3),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.attach_money,
              color: Colors.purple,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Rp 50.000',
                  style: TextStyle(
                    color: Colors.purple,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Today\'s income',
                  style: TextStyle(color: Colors.grey[500], fontSize: 11),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () {},
            child: const Text(
              'View',
              style: TextStyle(
                color: Colors.purple,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: Colors.grey[900],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.cyan.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: Colors.cyan, size: 24),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(color: Colors.grey[400], fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBarChart(List<List<double>> dataGroups, List<String> labels) {
    return Container(
      height: 200,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(12),
      ),
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: 120,
          barTouchData: BarTouchData(enabled: false),
          titlesData: FlTitlesData(
            show: true,
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (double value, TitleMeta meta) {
                  if (value.toInt() < labels.length &&
                      labels[value.toInt()].isNotEmpty) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        labels[value.toInt()],
                        style: TextStyle(color: Colors.grey[500], fontSize: 10),
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
            leftTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
          ),
          borderData: FlBorderData(show: false),
          gridData: const FlGridData(show: false),
          barGroups: dataGroups.asMap().entries.map((entry) {
            int index = entry.key;
            List<double> values = entry.value;
            return BarChartGroupData(
              x: index,
              barRods: [
                BarChartRodData(
                  toY: values[0],
                  color: Colors.cyan,
                  width: 8,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(4),
                  ),
                ),
                BarChartRodData(
                  toY: values[1],
                  color: Colors.green,
                  width: 8,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(4),
                  ),
                ),
                BarChartRodData(
                  toY: values[2],
                  color: Colors.red,
                  width: 8,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(4),
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildTransactionItem(String invoice, String dueDate, String amount) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                invoice,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                dueDate,
                style: TextStyle(color: Colors.grey[500], fontSize: 11),
              ),
            ],
          ),
          Text(
            amount,
            style: const TextStyle(
              color: Colors.cyan,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
