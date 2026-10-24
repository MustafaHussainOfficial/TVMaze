import 'package:equatable/equatable.dart';

import '../../core/utils/text_utils.dart';

class Show extends Equatable {
  const Show({
    required this.id,
    required this.name,
    this.type,
    this.language,
    this.genres = const [],
    this.status,
    this.runtime,
    this.premiered,
    this.ended,
    this.officialSite,
    this.rating,
    this.weight = 0,
    this.network,
    this.imageMedium,
    this.imageOriginal,
    this.summary,
  });

  final int id;
  final String name;
  final String? type;
  final String? language;
  final List<String> genres;
  final String? status;
  final int? runtime;
  final String? premiered;
  final String? ended;
  final String? officialSite;
  final double? rating;
  final int weight;
  final String? network;
  final String? imageMedium;
  final String? imageOriginal;
  final String? summary;

  factory Show.fromJson(Map<String, dynamic> json) {
    final image = json['image'] as Map<String, dynamic>?;
    final rating = json['rating'] as Map<String, dynamic>?;
    final network = (json['network'] ?? json['webChannel']) as Map<String, dynamic>?;

    return Show(
      id: json['id'] as int,
      name: (json['name'] as String?)?.trim().isNotEmpty == true
          ? json['name'] as String
          : 'Untitled',
      type: json['type'] as String?,
      language: json['language'] as String?,
      genres: (json['genres'] as List<dynamic>? ?? const []).whereType<String>().toList(),
      status: json['status'] as String?,
      runtime: (json['runtime'] ?? json['averageRuntime']) as int?,
      premiered: json['premiered'] as String?,
      ended: json['ended'] as String?,
      officialSite: json['officialSite'] as String?,
      rating: (rating?['average'] as num?)?.toDouble(),
      weight: (json['weight'] as int?) ?? 0,
      network: network?['name'] as String?,
      imageMedium: image?['medium'] as String?,
      imageOriginal: image?['original'] as String?,
      summary: TextUtils.stripHtml(json['summary'] as String?),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'type': type,
        'language': language,
        'genres': genres,
        'status': status,
        'runtime': runtime,
        'premiered': premiered,
        'ended': ended,
        'officialSite': officialSite,
        'rating': {'average': rating},
        'weight': weight,
        'network': network == null ? null : {'name': network},
        'image': imageMedium == null && imageOriginal == null
            ? null
            : {'medium': imageMedium, 'original': imageOriginal},
        'summary': summary,
      };

  String? get posterUrl => imageMedium ?? imageOriginal;
  String? get backdropUrl => imageOriginal ?? imageMedium;

  String get yearRange {
    final start = premiered != null && premiered!.length >= 4 ? premiered!.substring(0, 4) : null;
    if (start == null) return 'Unknown';
    final end = ended != null && ended!.length >= 4 ? ended!.substring(0, 4) : null;
    if (status == 'Running' || status == 'In Development' || status == 'To Be Determined') {
      return '$start - Present';
    }
    if (end == null || end == start) return start;
    return '$start - $end';
  }

  String get genresLabel => genres.isEmpty ? 'No genre' : genres.join(', ');

  @override
  List<Object?> get props => [id, name, rating, status, imageMedium];
}
