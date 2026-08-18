import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class MarketScreen extends StatelessWidget {
  const MarketScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> items = [
      {'name': 'Tomato', 'price': '\$2.50/kg', 'trend': 'up', 'change': '+5%'},
      {'name': 'Wheat', 'price': '\$450/ton', 'trend': 'down', 'change': '-2%'},
      {'name': 'Corn', 'price': '\$180/ton', 'trend': 'up', 'change': '+1%'},
      {'name': 'Potato', 'price': '\$1.20/kg', 'trend': 'stable', 'change': '0%'},
      {'name': 'Carrot', 'price': '\$1.80/kg', 'trend': 'up', 'change': '+3%'},
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Agricultural Market')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildPriceTrendCard(),
            const SizedBox(height: 24),
            const Text('Live Market Prices', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                return _buildMarketItem(item);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPriceTrendCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      height: 200,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Market Trend (Monthly)', style: TextStyle(fontWeight: FontWeight.bold)),
              DropdownButton<String>(
                value: 'Tomato',
                items: ['Tomato', 'Wheat', 'Corn'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                onChanged: (v) {},
                underline: const SizedBox(),
              ),
            ],
          ),
          const Expanded(
            child: Center(
              child: Text('Chart Placeholder', style: TextStyle(color: Colors.grey)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMarketItem(Map<String, dynamic> item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: AppColors.primary.withOpacity(0.1),
            child: const Icon(Icons.shopping_basket_outlined, color: AppColors.primary, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item['name'], style: const TextStyle(fontWeight: FontWeight.bold)),
                const Text('Local Market', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(item['price'], style: const TextStyle(fontWeight: FontWeight.bold)),
              Row(
                children: [
                  Icon(
                    item['trend'] == 'up' ? Icons.trending_up : (item['trend'] == 'down' ? Icons.trending_down : Icons.trending_flat),
                    size: 14,
                    color: item['trend'] == 'up' ? Colors.green : (item['trend'] == 'down' ? Colors.red : Colors.grey),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    item['change'],
                    style: TextStyle(
                      fontSize: 12,
                      color: item['trend'] == 'up' ? Colors.green : (item['trend'] == 'down' ? Colors.red : Colors.grey),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
