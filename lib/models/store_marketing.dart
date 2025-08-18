// store_marketing.dart
class StoreMarketing {
  final List<String>? tags;
  final String? metaTitle;
  final String? metaDescription;
  final double? ratingAverage;
  final int? ratingCount;
  final String? instagram;
  final String? facebook;
  final String? tiktok;

  StoreMarketing({
    this.tags,
    this.metaTitle,
    this.metaDescription,
    this.ratingAverage,
    this.ratingCount,
    this.instagram,
    this.facebook,
    this.tiktok,
  });

  factory StoreMarketing.fromJson(Map<String, dynamic> json) {
    return StoreMarketing(
      tags: json['tags'] != null ? List<String>.from(json['tags']) : null,
      metaTitle: json['meta_title'],
      metaDescription: json['meta_description'],
      ratingAverage: json['rating_average']?.toDouble(),
      ratingCount: json['rating_count'] as int?,
      instagram: json['instagram'],
      facebook: json['facebook'],
      tiktok: json['tiktok'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'tags': tags,
      'meta_title': metaTitle,
      'meta_description': metaDescription,
      'rating_average': ratingAverage,
      'rating_count': ratingCount,
      'instagram': instagram,
      'facebook': facebook,
      'tiktok': tiktok,
    };
  }

  StoreMarketing copyWith({
    List<String>? tags,
    String? metaTitle,
    String? metaDescription,
    double? ratingAverage,
    int? ratingCount,
    String? instagram,
    String? facebook,
    String? tiktok,
  }) {
    return StoreMarketing(
      tags: tags ?? this.tags,
      metaTitle: metaTitle ?? this.metaTitle,
      metaDescription: metaDescription ?? this.metaDescription,
      ratingAverage: ratingAverage ?? this.ratingAverage,
      ratingCount: ratingCount ?? this.ratingCount,
      instagram: instagram ?? this.instagram,
      facebook: facebook ?? this.facebook,
      tiktok: tiktok ?? this.tiktok,
    );
  }
}