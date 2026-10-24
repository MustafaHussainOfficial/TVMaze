import 'package:equatable/equatable.dart';

class Person extends Equatable {
  const Person({
    required this.id,
    required this.name,
    this.imageMedium,
    this.country,
    this.birthday,
    this.gender,
  });

  final int id;
  final String name;
  final String? imageMedium;
  final String? country;
  final String? birthday;
  final String? gender;

  factory Person.fromJson(Map<String, dynamic> json) {
    final image = json['image'] as Map<String, dynamic>?;
    final country = json['country'] as Map<String, dynamic>?;
    return Person(
      id: json['id'] as int,
      name: json['name'] as String? ?? 'Unknown',
      imageMedium: image?['medium'] as String?,
      country: country?['name'] as String?,
      birthday: json['birthday'] as String?,
      gender: json['gender'] as String?,
    );
  }

  @override
  List<Object?> get props => [id, name];
}
