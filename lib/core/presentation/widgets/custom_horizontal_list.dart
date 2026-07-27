import 'package:flutter/material.dart';

class CustomHorizontalList extends StatelessWidget {
  const CustomHorizontalList({
    super.key,
    required this.list,
    required this.itemBuilder,
  });
  final dynamic list;
  final Widget Function(BuildContext, int) itemBuilder;
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      scrollDirection: Axis.horizontal,
      child: Row(
        children: List.generate(
          list.length,
          (index) => itemBuilder(
            context,
            index,
          ),
        ),
      ),
    );
  }
}
