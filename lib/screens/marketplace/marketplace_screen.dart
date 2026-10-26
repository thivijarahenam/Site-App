import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../providers/app_data_provider.dart';
import '../../theme/app_theme.dart';
import '../admin/material_request_detail_screen.dart';
import '../admin/material_request_form_screen.dart';

class MarketplaceScreen extends StatefulWidget {
  const MarketplaceScreen({super.key});

  @override
  State<MarketplaceScreen> createState() => _MarketplaceScreenState();
}

class _MarketplaceScreenState extends State<MarketplaceScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('B2B Construction Marketplace'),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primaryOrange,
          unselectedLabelColor: AppColors.textSecondary,
          indicatorColor: AppColors.primaryOrange,
          indicatorWeight: 3,
          labelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
          tabs: const [
            Tab(text: 'Materials RFQ'),
            Tab(text: 'Machinery Rental'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          _MaterialsTab(),
          _EquipmentTab(),
        ],
      ),
    );
  }
}

class _MaterialsTab extends StatelessWidget {
  const _MaterialsTab();

  @override
  Widget build(BuildContext context) {
    final data = context.watch<AppDataProvider>();
    final requests = data.requests;

    return ListView(
      padding: const EdgeInsets.all(18),
      children: [
        // Action Card to Request Materials
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF1E3A8A), Color(0xFF2563EB)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(18),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'Procure Construction Materials',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Request quotes from 8+ verified hardware & cement suppliers in Jaffna.',
                      style: TextStyle(fontSize: 11, color: Colors.white70),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFF1E3A8A),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const MaterialRequestFormScreen(),
                    ),
                  );
                },
                child: const Text('Create RFQ', style: TextStyle(fontWeight: FontWeight.w700)),
              ),
            ],
          ),
        ),

        const SizedBox(height: 18),

        const Text(
          'Active Requests & Quotes',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w800,
            color: AppColors.primaryNavy,
          ),
        ),
        const SizedBox(height: 10),

        if (requests.isEmpty)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(32),
              child: Text('No material requests currently active.'),
            ),
          )
        else
          ...requests.map((r) {
            final hasQuote = r.response != null;
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppColors.cardBorder),
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.all(14),
                title: Row(
                  children: [
                    Expanded(
                      child: Text(
                        r.materialName,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primaryNavy,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: hasQuote
                            ? AppColors.pastelGreenBg
                            : AppColors.pastelAmberBg,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        hasQuote ? 'Quote Received' : 'Pending Quote',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: hasQuote
                              ? AppColors.pastelGreenText
                              : AppColors.pastelAmberText,
                        ),
                      ),
                    ),
                  ],
                ),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Quantity: ${r.requiredQuantity} ${r.unit} • Needed by ${DateFormat('d MMM').format(r.requiredDate)}',
                        style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                      ),
                      if (hasQuote) ...[
                        const SizedBox(height: 4),
                        Text(
                          'Quoted Price: LKR ${r.response!.unitPrice.toStringAsFixed(0)} / ${r.unit} (Total: LKR ${(r.response!.unitPrice * r.requiredQuantity).toStringAsFixed(0)})',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF16A34A),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => MaterialRequestDetailScreen(requestId: r.id),
                    ),
                  );
                },
              ),
            );
          }),
      ],
    );
  }
}

class _EquipmentTab extends StatelessWidget {
  const _EquipmentTab();

  @override
  Widget build(BuildContext context) {
    final data = context.watch<AppDataProvider>();
    final rentals = data.rentals;

    return ListView(
      padding: const EdgeInsets.all(18),
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFEA580C), Color(0xFFFF5B22)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(18),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'Heavy Machinery & Formwork',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Rent excavators, concrete mixers, steel scaffolding, and props with verified operators.',
                      style: TextStyle(fontSize: 11, color: Colors.white70),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.precision_manufacturing_rounded, size: 40, color: Colors.white),
            ],
          ),
        ),

        const SizedBox(height: 18),

        const Text(
          'Available Equipment on Rent',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w800,
            color: AppColors.primaryNavy,
          ),
        ),
        const SizedBox(height: 10),

        ...rentals.map((item) {
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.cardBorder),
            ),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.pastelOrangeBg,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(
                    Icons.construction_rounded,
                    color: AppColors.primaryOrange,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.name,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primaryNavy,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Category: ${item.category} • In stock: ${item.availableStock}',
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'LKR ${item.dailyRate.toStringAsFixed(0)} / day',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primaryOrange,
                        ),
                      ),
                    ],
                  ),
                ),
                FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primaryNavy,
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    minimumSize: const Size(64, 36),
                  ),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Rental request submitted for ${item.name}!')),
                    );
                  },
                  child: const Text('Book', style: TextStyle(fontSize: 11)),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }
}

