import 'package:flutter/material.dart';

import '../utilities/app_color.dart';

class MoviesDropDownViewModel with ChangeNotifier {
  String _selectedCategory = 'Popular';
  String? get selectedCategory => _selectedCategory;

  void setSelectedCategory(String name) {
    _selectedCategory = name;
    notifyListeners();
  }

  final Map<String, String> categoryMap = {
    'Popular': 'popular',
    'Upcoming': 'upcoming',
    'Now Playing': 'now_playing',
    'Top Rated': 'top_rated',
  };

  DropdownButton<String> buttonsList() {
    return DropdownButton(
      value: _selectedCategory,
      iconDisabledColor: whiteColor,
      iconEnabledColor: whiteColor,
      dropdownColor: whiteColor,
      style: const TextStyle(
        color: whiteColor,
        fontWeight: FontWeight.bold,
      ),
      underline: const SizedBox.shrink(),
      items: categoryMap.keys
          .map(
            (displayCategory) => DropdownMenuItem<String>(
              value: displayCategory,
              child: Text(
                displayCategory,
                style: const TextStyle(
                  color: blackColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          )
          .toList(),
      selectedItemBuilder: (context) {
        return categoryMap.keys
            .map((selectedCategory) => Center(
                  child: Text(
                    selectedCategory,
                    style: const TextStyle(
                      color: whiteColor,
                    ),
                  ),
                ))
            .toList();
      },
      onChanged: (newCategory) {
        if (newCategory != null) {
          setSelectedCategory(newCategory);
        }
      },
    );
  }
}
