import 'package:bloc/bloc.dart';
import 'package:lesson_16/data/models/restaurant.dart';
import 'package:lesson_16/logic/map_cubit/map_state.dart';

class MapCubit extends Cubit<MapState> {
  MapCubit() : super(InitialState());

  final List<Restaurant> _restaurant = [];

  List<Restaurant> get restaurants => _restaurant;

  void getRestaurants() {
    try {
      emit(LoadingState());

      /// getting restaurant from database
      emit(LoadedState(restaurants: restaurants));
    } catch (e) {
      emit(ErrorState(message: e.toString()));
    }
  }

  void addRestaurant({required Restaurant restaurant}) {
    try {
      emit(LoadingState());

      _restaurant.add(restaurant);

      emit(LoadedState(restaurants: restaurants));
    } catch (e) {
      emit(ErrorState(message: e.toString()));
    }
  }
}
