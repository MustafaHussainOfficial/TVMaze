import 'package:mocktail/mocktail.dart';
import 'package:tvmaze_app/data/models/show.dart';
import 'package:tvmaze_app/data/repositories/show_repository.dart';

class MockShowRepository extends Mock implements ShowRepository {}

Show fakeShow(int id, {double? rating, int weight = 0, String? name}) =>
    Show(id: id, name: name ?? 'Show $id', rating: rating, weight: weight);
