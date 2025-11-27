import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:skynet_internet_cafe/presentation/logic/home_cubit.dart';
import 'package:skynet_internet_cafe/presentation/widgets/navbar_widget.dart';
import 'package:skynet_internet_cafe/presentation/widgets/appbar_widget.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => HomeCubit(),
      child: const HomePageView(),
    );
  }
}

class HomePageView extends StatelessWidget {
  const HomePageView({super.key});

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
              'Wednesday, 15 October 2025',
              style: TextStyle(color: Colors.grey[500], fontSize: 12),
            ),
          ],
        ),
        actions: const [AppbarWidget(), SizedBox(width: 8)],
      ),
      bottomNavigationBar: const NavbarWidget(),
      backgroundColor: Colors.black,
      body: BlocBuilder<HomeCubit, HomeState>(
        builder: (context, state) {
          if (state.isLoading) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.cyan),
            );
          }

          if (state.errorMessage != null) {
            return Center(
              child: Text(
                state.errorMessage!,
                style: const TextStyle(color: Colors.red),
              ),
            );
          }

          return SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: _buildVIPSeatsCard(
                            context,
                            seatNumber: state.activeSeatsVIP.toString(),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildRegularSeatsCard(
                            context,
                            seatNumber: state.activeSeatsRegular.toString(),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    _buildIncomeCard(context, state.todayIncome),

                    const SizedBox(height: 12),

                    Row(
                      children: [
                        Expanded(
                          child: _buildActionButton(
                            context,
                            icon: Icons.add,
                            label: 'Add customer',
                            onTap: () => _showAddCustomerDialog(context),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildActionButton(
                            context,
                            icon: Icons.shopping_cart,
                            label: 'Purchase',
                            onTap: () {},
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildActionButton(
                            context,
                            icon: Icons.event_seat,
                            label: 'Seats',
                            onTap: () {},
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    const Text(
                      'Last 7 days sales',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildBarChartWithSummary(
                      context,
                      state.last7DaysSales,
                      state.last7DaysSummary,
                    ),
                    const SizedBox(height: 20),

                    const Text(
                      'Monthly sales',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildBarChartWithSummary(
                      context,
                      state.monthlySales,
                      state.monthlySummary,
                    ),
                    const SizedBox(height: 20),

                    const Text(
                      'Transactions List',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ...state.transactions.map(
                      (transaction) => _buildTransactionItem(
                        transaction.invoiceNumber,
                        transaction.dueDate,
                        transaction.amount,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildVIPSeatsCard(
    BuildContext context, {
    required String seatNumber,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(width: 2, color: Color(0xff005d76)),
        color: Color(0xff091316),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Color(0xff083740),
              borderRadius: BorderRadius.circular(5),
            ),
            height: 35,
            width: 35,
            child: Icon(Icons.show_chart, color: Colors.cyan, size: 24),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                seatNumber,
                style: const TextStyle(
                  color: Colors.cyan,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Seats remaining',
                style: TextStyle(color: Colors.grey[200], fontSize: 11),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRegularSeatsCard(
    BuildContext context, {
    required String seatNumber,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(width: 2, color: Color(0xff005627)),
        color: Color(0xff091316),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Color(0xff005627),
              borderRadius: BorderRadius.circular(5),
            ),
            height: 35,
            width: 35,
            child: Icon(Icons.show_chart, color: Color(0xff00ff80), size: 24),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                seatNumber,
                style: const TextStyle(
                  color: Colors.green,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Active seats',
                style: TextStyle(color: Colors.grey[200], fontSize: 11),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildIncomeCard(BuildContext context, String income) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xff130d19),
        border: Border.all(width: 2, color: Color(0xff360d60)),
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
                Text(
                  income,
                  style: const TextStyle(
                    color: Colors.purple,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Today\'s income',
                  style: TextStyle(color: Colors.grey[200], fontSize: 11),
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
          border: Border.all(width: 2, color: Color(0xff374151)),
          color: Color(0xff131316),
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

  Widget _buildBarChartWithSummary(
    BuildContext context,
    List<ChartData> chartData,
    ChartSummary summary,
  ) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Color(0xff131316),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.cyan.withOpacity(0.3), width: 1),
      ),
      child: Column(
        children: [
          SizedBox(
            height: 200,
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
                        if (value.toInt() < chartData.length) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              chartData[value.toInt()].label,
                              style: TextStyle(
                                color: Colors.grey[500],
                                fontSize: 10,
                              ),
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
                barGroups: chartData.asMap().entries.map((entry) {
                  int index = entry.key;
                  List<double> values = entry.value.values;
                  return BarChartGroupData(
                    x: index,
                    barRods: [
                      BarChartRodData(
                        toY: values[0],
                        color: Colors.cyan,
                        width: 16,
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(3),
                        ),
                      ),
                      BarChartRodData(
                        toY: values[1],
                        color: Colors.orange,
                        width: 16,
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(3),
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Divider(height: 2, color: Color(0xff1B394B)),
          const SizedBox(height: 5),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildSummaryItem('Sessions', summary.sessions, Colors.blue),
              _buildSummaryItem('Product', summary.product, Color(0xffff9800)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value, Color labelColor) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            color: labelColor,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            color: Colors.grey[400],
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
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

  void _showAddCustomerDialog(BuildContext context) {
    final cubit = context.read<HomeCubit>();

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: Colors.grey[900],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            padding: const EdgeInsets.all(20),
            width: 400,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Center(
                  child: Text(
                    "Start New Session",
                    style: TextStyle(
                      color: Colors.cyan,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  "Customer Name",
                  style: TextStyle(color: Colors.white),
                ),
                const SizedBox(height: 6),
                TextField(
                  decoration: InputDecoration(
                    hintText: "Enter name",
                    hintStyle: const TextStyle(color: Colors.grey),
                    filled: true,
                    fillColor: Colors.black54,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  style: const TextStyle(color: Colors.white),
                ),
                const SizedBox(height: 16),
                const Text(
                  "Seat Number",
                  style: TextStyle(color: Colors.white),
                ),
                const SizedBox(height: 6),
                DropdownButtonFormField(
                  dropdownColor: Colors.black,
                  style: const TextStyle(color: Colors.white),
                  items: const [
                    DropdownMenuItem(value: 1, child: Text("1")),
                    DropdownMenuItem(value: 2, child: Text("2")),
                    DropdownMenuItem(value: 3, child: Text("3")),
                    DropdownMenuItem(value: 4, child: Text("4")),
                    DropdownMenuItem(value: 5, child: Text("5")),
                  ],
                  onChanged: (v) {},
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.black54,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Text("Package", style: TextStyle(color: Colors.white)),
                const SizedBox(height: 6),
                DropdownButtonFormField(
                  dropdownColor: Colors.black,
                  style: const TextStyle(color: Colors.white),
                  items: const [
                    DropdownMenuItem(value: "1h", child: Text("1 Hour")),
                    DropdownMenuItem(value: "2h", child: Text("2 Hours")),
                    DropdownMenuItem(value: "3h", child: Text("3 Hours")),
                  ],
                  onChanged: (v) {},
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.black54,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.cyan,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    onPressed: () {
                      Navigator.of(dialogContext).pop();
                    },
                    child: const Text(
                      "Start Session",
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
