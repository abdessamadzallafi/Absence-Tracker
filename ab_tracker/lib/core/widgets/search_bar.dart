import 'package:flutter/material.dart';

class AppSearchBar extends StatelessWidget {
  final String hint;
  final ValueChanged<String> onChanged;
  final VoidCallback? onClear;

  const AppSearchBar({
    super.key,
    required this.hint,
    required this.onChanged,
    this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      decoration: InputDecoration(
        prefixIcon: const Icon(Icons.search),
        hintText: hint,
        suffixIcon: IconButton(
          onPressed: onClear,
          icon: const Icon(Icons.clear),
        ),
      ),
      onChanged: onChanged,
    );
  }
}
