import 'package:finance_tracker/core/models/tx_type.dart';
import 'package:finance_tracker/core/widgets/app_badge.dart';
import 'package:flutter/material.dart';

class TypeBadge extends StatelessWidget {
  const TypeBadge(this.type, {super.key});

  final TxType type;

  @override
  Widget build(BuildContext context) {
    return AppBadge(
      text: type.label,
      background: type.badgeBg,
      foreground: type.badgeFg,
    );
  }
}
