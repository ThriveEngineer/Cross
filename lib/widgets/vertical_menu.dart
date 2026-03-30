import 'package:flutter/material.dart';

class MenuCard extends StatelessWidget {
  final List<MenuItem> items;
  final double? width;

  const MenuCard({
    super.key,
    required this.items,
    this.width = 280,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(70),
            blurRadius: 35,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(
          items.length * 2 - 1,
          (index) {
            if (index.isOdd) {
              return const Divider(height: 0.1, color: Color.fromARGB(255, 216, 216, 216), endIndent: 15, indent: 15,);
            }
            final itemIndex = index ~/ 2;
            return MenuOption(
              label: items[itemIndex].label,
              icon: items[itemIndex].icon,
              onTap: items[itemIndex].onTap,
              isFirst: itemIndex == 0,
              isLast: itemIndex == items.length - 1,
            );
          },
        ),
      ),
    );
  }
}

class MenuItem {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const MenuItem({
    required this.label,
    required this.icon,
    required this.onTap,
  });
}

class MenuOption extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final bool isFirst;
  final bool isLast;

  const MenuOption({
    super.key,
    required this.label,
    required this.icon,
    required this.onTap,
    this.isFirst = false,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.vertical(
        top: isFirst ? const Radius.circular(12) : Radius.zero,
        bottom: isLast ? const Radius.circular(12) : Radius.zero,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w400,
                color: Colors.black87,
              ),
            ),
            Icon(
              icon,
              size: 20,
              color: Colors.black87,
            ),
          ],
        ),
      ),
    );
  }
}

// Helper function to show the menu positioned below a button
void showCustomMenu(BuildContext context, GlobalKey buttonKey, List<MenuItem> items) {
  final RenderBox renderBox = buttonKey.currentContext!.findRenderObject() as RenderBox;
  final offset = renderBox.localToGlobal(Offset.zero);
  final size = renderBox.size;
  final screenSize = MediaQuery.of(context).size;
  
  // Calculate menu width (default 280)
  final menuWidth = 280.0;
  final menuPadding = 16.0;
  
  // Calculate horizontal position
  double left = offset.dx;
  
  // If menu goes off right edge, align to right side of button
  if (left + menuWidth > screenSize.width - menuPadding) {
    left = offset.dx + size.width - menuWidth;
  }
  
  // If still off screen on left, align to left edge with padding
  if (left < menuPadding) {
    left = menuPadding;
  }
  
  // Calculate vertical position
  double top = offset.dy + size.height + 8;
  
  // If menu goes off bottom, show above button instead
  final estimatedMenuHeight = (items.length * 49.0) + 16;
  if (top + estimatedMenuHeight > screenSize.height - menuPadding) {
    top = offset.dy - estimatedMenuHeight - 8;
  }

  showDialog(
    context: context,
    barrierColor: Colors.transparent,
    barrierDismissible: true,
    builder: (context) => Stack(
      children: [
        Positioned(
          left: left,
          top: top,
          child: Material(
            color: Colors.transparent,
            child: MenuCard(items: items),
          ),
        ),
      ],
    ),
  );
}

// Example usage:
// final GlobalKey _buttonKey = GlobalKey();
// 
// ElevatedButton(
//   key: _buttonKey,
//   onPressed: () {
//     showCustomMenu(
//       context,
//       _buttonKey,
//       [
//         MenuItem(
//           label: 'View',
//           icon: Icons.edit_outlined,
//           onTap: () {
//             Navigator.pop(context);
//             print('View');
//           },
//         ),
//         MenuItem(
//           label: 'Select',
//           icon: Icons.content_copy_outlined,
//           onTap: () {
//             Navigator.pop(context);
//             print('Select');
//           },
//         ),
//         MenuItem(
//           label: 'Settings',
//           icon: Icons.settings_outlined,
//           onTap: () {
//             Navigator.pop(context);
//             print('Settings');
//           },
//         ),
//       ],
//     );
//   },
//   child: Text('Show Menu'),
// )