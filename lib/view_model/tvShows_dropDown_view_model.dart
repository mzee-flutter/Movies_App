import 'package:flutter/material.dart';

import '../utilities/app_color.dart';

class TvShowsDropDownViewModel with ChangeNotifier {
  String _selectedCategory = 'Popular';
  String get selectedCategory => _selectedCategory;

  void setSelectedCategory(String newCategory) {
    _selectedCategory = newCategory;
    notifyListeners();
  }

  Map<String, String> tvShowsCategory = {
    'Popular': 'popular',
    'Top Rated': 'top_rated',
    'On The Air': 'on_the_air',
    'Airing Today': 'airing_today',
  };

  DropdownButton<String> getButtonList() {
    return DropdownButton(
      value: _selectedCategory,
      iconEnabledColor: Colors.white,
      iconDisabledColor: Colors.white,
      underline: const SizedBox.shrink(),
      style: const TextStyle(color: Colors.white),
      onChanged: (newCategory) {
        if (newCategory != null) {
          setSelectedCategory(newCategory);
        }
      },
      items: tvShowsCategory.keys
          .map(
            (displayCategory) => DropdownMenuItem<String>(
              value: displayCategory,
              child: Text(
                displayCategory,
                style: const TextStyle(color: Colors.black),
              ),
            ),
          )
          .toList(),
      selectedItemBuilder: (context) {
        return tvShowsCategory.keys
            .map((selectedShow) => Center(
                  child: Text(
                    selectedShow,
                    style: const TextStyle(
                      color: whiteColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ))
            .toList();
      },
    );
  }
}
