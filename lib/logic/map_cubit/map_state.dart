import 'package:lesson_16/data/models/restaurant.dart';

sealed class MapState {}

final class InitialState extends MapState {}

final class LoadingState extends MapState {}

final class LoadedState extends MapState {
  List<Restaurant> restaurants;

  LoadedState({required this.restaurants});
}

final class ErrorState extends MapState {
  final String message;

  ErrorState({required this.message});
}
