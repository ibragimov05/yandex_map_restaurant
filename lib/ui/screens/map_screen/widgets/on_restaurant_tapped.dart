import 'package:flutter/material.dart';
import 'package:lesson_16/data/models/restaurant.dart';

class OnRestaurantTapped extends StatelessWidget {
  final Restaurant restaurant;
  final void Function() onDeleteTap;

  const OnRestaurantTapped({
    super.key,
    required this.restaurant,
    required this.onDeleteTap,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(restaurant.title),
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Restaurant number: ${restaurant.number}'),
          Text('Location: ${restaurant.location}'),
          Text('Rating: ${restaurant.rating}'),
          Image.network(
            restaurant.imageUrl,
            height: 100,
            width: 200,
            fit: BoxFit.cover,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            onDeleteTap();
            Navigator.of(context).pop();
          },
          child: const Text('Delete'),
        ),
        TextButton(
          onPressed: () {
            Navigator.pop(context, true);
          },
          child: const Text('Go'),
        ),
      ],
    );
  }
}
