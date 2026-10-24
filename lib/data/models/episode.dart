import 'package:equatable/equatable.dart';

import '../../core/utils/text_utils.dart';

class Episode extends Equatable {
  const Episode({
    required this.id,
    required this.name,
    required this.season,
    this.number,
    this.airdate,
    this.runtime,
    this.rating,
    this.imageMedium,
    this.summary,
  });

  final int id;
  final String name;
  final int season;

  final int? number;
  final DateTime? airdate;
  final int? runtime;
  final double? rating;
  final String? imageMedium;
  final String? summary;

  factory Episode.fromJson(Map<String, dynamic> json) {
    final image = json['image'] as Map<String, dynamic>?;
    final rating = json['rating'] as Map<String, dynamic>?;
    final airdate = json['airdate'] as String?;

    return Episode(
      id: json['id'] as int,
      name: json['name'] as String? ?? 'Untitled episode',
      season: json['season'] as int? ?? 0,
      number: json['number'] as int?,
      airdate: airdate == null || airdate.isEmpty ? null : DateTime.tryParse(airdate),
      runtime: json['runtime'] as int?,
      rating: (rating?['average'] as num?)?.toDouble(),
      imageMedium: image?['medium'] as String?,
      summary: TextUtils.stripHtml(json['summary'] as String?),
    );
  }

  @override
  List<Object?> get props => [id, name, season, number];
}
