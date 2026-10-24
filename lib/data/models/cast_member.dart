import 'package:equatable/equatable.dart';

class CastMember extends Equatable {
  const CastMember({
    required this.personId,
    required this.personName,
    required this.characterName,
    this.personImage,
    this.characterImage,
  });

  final int personId;
  final String personName;
  final String characterName;
  final String? personImage;
  final String? characterImage;

  factory CastMember.fromJson(Map<String, dynamic> json) {
    final person = json['person'] as Map<String, dynamic>? ?? const {};
    final character = json['character'] as Map<String, dynamic>? ?? const {};
    final personImage = person['image'] as Map<String, dynamic>?;
    final characterImage = character['image'] as Map<String, dynamic>?;

    return CastMember(
      personId: person['id'] as int? ?? 0,
      personName: person['name'] as String? ?? 'Unknown actor',
      characterName: character['name'] as String? ?? 'Unknown role',
      personImage: personImage?['medium'] as String?,
      characterImage: characterImage?['medium'] as String?,
    );
  }

  String? get imageUrl => personImage ?? characterImage;

  @override
  List<Object?> get props => [personId, personName, characterName];
}
