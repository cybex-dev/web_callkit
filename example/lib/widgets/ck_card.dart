import 'package:flutter/material.dart';

class CKCard extends StatelessWidget {
  final Widget? title;
  final Widget? description;
  final double headerHeight;
  final double padding;
  final List<Widget>? actions;
  final Widget child;

  const CKCard({
    super.key,
    this.title,
    required this.child,
    this.description,
    this.headerHeight = 4,
    this.padding = 4,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(padding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null || actions != null)
            Row(
              children: [
                if (title != null) Expanded(child: title!) else const Spacer(),
                if (actions != null) ...actions!,
              ],
            ),
          if (description != null) description!,
          if (title != null || actions != null || description != null)
            SizedBox(height: headerHeight),
          // Expanded(child: child),
          child,
        ],
      ),
    );
  }
}
