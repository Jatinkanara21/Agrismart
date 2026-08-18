import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../crops/crops_screen.dart';
import '../disease_detection/disease_detection_screen.dart';
import '../home/home_screen.dart';
import '../market/market_screen.dart';
import '../profile/profile_screen.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _index = 0;
  final _screens = const [HomeScreen(), CropsScreen(), DiseaseDetectionScreen(), MarketScreen(), ProfileScreen()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 250),
        child: KeyedSubtree(key: ValueKey(_index), child: _screens[_index]),
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(16, 0, 16, 10),
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface.withValues(alpha: .96),
            borderRadius: BorderRadius.circular(26),
            border: Border.all(color: Theme.of(context).dividerColor.withValues(alpha: .35)),
            boxShadow: const [BoxShadow(blurRadius: 22, offset: Offset(0, 9), color: Color(0x22000000))],
          ),
          child: Row(
            children: List.generate(5, (i) => Expanded(child: _NavItem(index: i, selected: _index == i, onTap: () => setState(() => _index = i)))),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final int index;
  final bool selected;
  final VoidCallback onTap;
  const _NavItem({required this.index, required this.selected, required this.onTap});

  static const items = [
    (Icons.home_outlined, Icons.home_rounded, 'Home'),
    (Icons.grass_outlined, Icons.grass_rounded, 'Crops'),
    (Icons.document_scanner_outlined, Icons.document_scanner_rounded, 'Scan'),
    (Icons.storefront_outlined, Icons.storefront_rounded, 'Market'),
    (Icons.person_outline_rounded, Icons.person_rounded, 'Profile'),
  ];

  @override
  Widget build(BuildContext context) {
    final item = items[index];
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 9),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 7),
            decoration: BoxDecoration(
              color: selected ? AppColors.primary.withValues(alpha: .12) : Colors.transparent,
              borderRadius: BorderRadius.circular(15),
            ),
            child: Icon(selected ? item.$2 : item.$1, color: selected ? AppColors.primary : AppColors.textSecondary, size: 21),
          ),
          const SizedBox(height: 2),
          Text(item.$3, style: Theme.of(context).textTheme.labelSmall?.copyWith(color: selected ? AppColors.primary : AppColors.textSecondary, fontWeight: selected ? FontWeight.w700 : FontWeight.w500)),
        ]),
      ),
    );
  }
}
