import 'package:flutter/material.dart';

class SearchBar extends StatelessWidget {
  const SearchBar({super.key});

  @override
  Widget build(BuildContext context) {
    return const TextField(
      maxLines: 1,
      style: TextStyle(fontSize: 30.0, color: Colors.white),
      decoration: InputDecoration(
        hintText: '输入城市',
        prefixIcon: Icon(Icons.search, color: Colors.white),
      ),
    );
  }
}
