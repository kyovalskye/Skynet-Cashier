import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:skynet_internet_cafe/presentation/logic/report_management_cubit.dart';
import 'package:skynet_internet_cafe/presentation/widgets/appbar_widget.dart';
import 'package:skynet_internet_cafe/presentation/widgets/navbar_widget.dart';

class ReportManagementPage extends StatelessWidget {
  const ReportManagementPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ReportManagementCubit()..loadReportData(),
      child: const ReportManagementView(),
    );
  }
}
        
class ReportManagementView extends StatelessWidget {
  const ReportManagementView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        toolbarHeight: 70,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Report Management',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'Manage your report',
              style: TextStyle(color: Colors.grey[500], fontSize: 12),
            ),
          ],
        ),
        actions: const [AppbarWidget(), SizedBox(width: 8)],
      ),
      bottomNavigationBar: NavbarWidget(),
      body: BlocBuilder<ReportManagementCubit, ReportManagementState>(
        builder: (context, state) {
          if (state.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Filter Buttons
                  Row(
                    children: [
                      _FilterButton(
                        label: 'Today',
                        isSelected: state.selectedFilter == 'Today',
                        onTap: () => context
                            .read<ReportManagementCubit>()
                            .setFilter('Today'),
                      ),
                      const SizedBox(width: 8),
                      _FilterButton(
                        label: 'This week',
                        isSelected: state.selectedFilter == 'This week',
                        onTap: () => context
                            .read<ReportManagementCubit>()
                            .setFilter('This week'),
                      ),
                      const SizedBox(width: 8),
                      _FilterButton(
                        label: 'This month',
                        isSelected: state.selectedFilter == 'This month',
                        onTap: () => context
                            .read<ReportManagementCubit>()
                            .setFilter('This month'),
                      ),
                      const SizedBox(width: 8),
                      _IconButton(icon: Icons.calendar_today_outlined),
                      const SizedBox(width: 8),
                      _IconButton(
                        icon: Icons.download_outlined,
                        label: 'Export',
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Stats Cards
                  Row(
                    children: [
                      Expanded(
                        child: _StatsCard(
                          icon: Icons.trending_up,
                          iconColor: Colors.purple,
                          title: 'Rp ${state.totalIncome}',
                          subtitle: 'Total Income',
                          backgroundColor: const Color(0xFF2D1B3D),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _StatsCard(
                          icon: Icons.receipt_outlined,
                          iconColor: Colors.cyan,
                          title: '${state.totalTransactions}',
                          subtitle: 'Transaction',
                          backgroundColor: const Color(0xFF1B2D3D),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _StatsCard(
                          icon: Icons.attach_money,
                          iconColor: Colors.green,
                          title: 'Rp ${state.sessionIncome}',
                          subtitle: 'Session Income',
                          backgroundColor: const Color(0xFF1B3D1B),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _StatsCard(
                          icon: Icons.shopping_bag_outlined,
                          iconColor: Colors.orange,
                          title: 'Rp ${state.productIncome}',
                          subtitle: 'Product Income',
                          backgroundColor: const Color(0xFF3D2D1B),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Frequently Purchased Products
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Frequently Purchased Products',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1A1A1A),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: Colors.grey[800]!),
                        ),
                        child: Row(
                          children: [
                            Text(
                              'Choose Product',
                              style: TextStyle(
                                color: Colors.grey[400],
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Icon(
                              Icons.keyboard_arrow_down,
                              color: Colors.grey[400],
                              size: 16,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF1A1A1A),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey[900]!),
                    ),
                    child: Column(
                      children: state.frequentProducts.map((product) {
                        return _ProductItem(
                          name: product['name'] as String? ?? '',
                          type: product['type'] as String? ?? '',
                          sold: product['sold'] as String? ?? '',
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Frequent Visiting Customers
                  const Text(
                    'Frequent Visiting Customers',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF1A1A1A),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey[900]!),
                    ),
                    child: Column(
                      children: state.frequentCustomers.map((customer) {
                        return _CustomerItem(
                          name: customer['name'] as String? ?? '',
                          visits: customer['visits'] as String? ?? '',
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _FilterButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterButton({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? Colors.cyan : const Color(0xFF1A1A1A),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.black : Colors.grey[400],
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}

class _IconButton extends StatelessWidget {
  final IconData icon;
  final String? label;

  const _IconButton({required this.icon, this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: label != null ? 12 : 10,
        vertical: 10,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey[400], size: 18),
          if (label != null) ...[
            const SizedBox(width: 6),
            Text(
              label!,
              style: TextStyle(color: Colors.grey[400], fontSize: 13),
            ),
          ],
        ],
      ),
    );
  }
}

class _StatsCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final Color backgroundColor;

  const _StatsCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(color: Colors.grey[400], fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ProductItem extends StatelessWidget {
  final String name;
  final String type;
  final String sold;

  const _ProductItem({
    required this.name,
    required this.type,
    required this.sold,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey[900]!, width: 1)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                type,
                style: TextStyle(color: Colors.grey[500], fontSize: 12),
              ),
            ],
          ),
          Text(sold, style: TextStyle(color: Colors.grey[500], fontSize: 12)),
        ],
      ),
    );
  }
}

class _CustomerItem extends StatelessWidget {
  final String name;
  final String visits;

  const _CustomerItem({required this.name, required this.visits});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey[900]!, width: 1)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            name,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(visits, style: TextStyle(color: Colors.grey[500], fontSize: 12)),
        ],
      ),
    );
  }
}
