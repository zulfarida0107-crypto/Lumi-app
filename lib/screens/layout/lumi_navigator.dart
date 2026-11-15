import 'package:flutter/material.dart';

/// ============================================================================
/// KOMPONEN NAVIGATOR BAWAH RESMI LUMI (BOTTOM NAVIGATION BAR)
/// ============================================================================
/// 4 Tab:
/// 0: Hari Ini
/// 1: Catatan
/// 2: Matriks
/// 3: Sheet
/// Tab aktif memiliki kapsul/pill bulat berwarna pink lembut seperti desain.
class LumiNavigator extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTabSelected;

  const LumiNavigator({
    super.key,
    required this.currentIndex,
    required this.onTabSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _navItem(
                index: 0,
                label: 'Hari Ini',
                icon: Icons.calendar_today_outlined,
                selectedIcon: Icons.calendar_today_rounded,
              ),
              _navItem(
                index: 1,
                label: 'Catatan',
                icon: Icons.edit_note_rounded,
                selectedIcon: Icons.edit_note_rounded,
              ),
              _navItem(
                index: 2,
                label: 'Matriks',
                icon: Icons.grid_view_outlined,
                selectedIcon: Icons.grid_view_rounded,
              ),
              _navItem(
                index: 3,
                label: 'Chart',
                icon: Icons.bar_chart_outlined,
                selectedIcon: Icons.bar_chart_rounded,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _navItem({
    required int index,
    required String label,
    required IconData icon,
    required IconData selectedIcon,
  }) {
    final bool isSelected = currentIndex == index;

    return InkWell(
      onTap: () => onTabSelected(index),
      borderRadius: BorderRadius.circular(24),
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: isSelected
            ? const EdgeInsets.symmetric(horizontal: 20, vertical: 6)
            : const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFFFDDE3) : Colors.transparent,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? selectedIcon : icon,
              size: 22,
              color: isSelected ? const Color(0xFF355070) : const Color(0xFF595D78),
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Plus Jakarta Sans',
                fontSize: 11.5,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? const Color(0xFF355070) : const Color(0xFF595D78),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
