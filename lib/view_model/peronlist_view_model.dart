import 'package:flutter/foundation.dart';
import 'package:movies/repository/personList_repository.dart';

import '../model/person_model.dart';

class PersonListViewModel with ChangeNotifier {
  final PersonListRepository personRepo = PersonListRepository();

  int currentPage = 1;
  int totalPages = 1;
  List<Person> allPersonList = [];
  bool _isFetching = false;
  bool get isFetching => _isFetching;

  Future<void> fetchPersonList() async {
    if (_isFetching || currentPage > totalPages) return;
    _isFetching = true;
    notifyListeners();
    try {
      final personList = await personRepo.fetchPersonList(currentPage);
      totalPages = personList.totalPages ?? 1;
      allPersonList.addAll(personList.listOfPerson ?? []);
      currentPage++;
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print(e.toString());
      }
    } finally {
      _isFetching = false;
      notifyListeners();
    }
  }
}
