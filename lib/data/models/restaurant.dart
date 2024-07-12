import 'package:yandex_mapkit/yandex_mapkit.dart';

class Restaurant {
  final String id;
  final String title;
  final String number;
  final double rating;
  final Point location;
  final String imageUrl;

  const Restaurant({
    required this.id,
    required this.title,
    required this.number,
    required this.rating,
    required this.location,
    required this.imageUrl,
  });
}
