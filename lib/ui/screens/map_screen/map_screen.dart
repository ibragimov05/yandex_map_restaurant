import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:geolocator/geolocator.dart';
import 'package:lesson_16/data/models/restaurant.dart';
import 'package:lesson_16/logic/services/location_service.dart';
import 'package:lesson_16/logic/services/yandex_map_service.dart';
import 'package:lesson_16/ui/screens/map_screen/widgets/add_new_restaurant_widget.dart';
import 'package:lesson_16/ui/screens/map_screen/widgets/on_restaurant_tapped.dart';
import 'package:lesson_16/ui/screens/map_screen/widgets/show_error_dialog.dart';
import 'package:yandex_mapkit/yandex_mapkit.dart';

import 'widgets/custom_zoom_button.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  YandexMapController? _yandexMapController;
  Point? _userCurrentPosition;
  List<MapObject>? _polyLines;
  final TextEditingController _searchTextController = TextEditingController();
  final Set<PlacemarkMapObject> _set = {};
  bool _isFetchingAddress = true;

  void _onMapCreated(YandexMapController yandexMapController) {
    _yandexMapController = yandexMapController;
    if (_userCurrentPosition != null) {
      _yandexMapController?.moveCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(target: _userCurrentPosition!, zoom: 17),
        ),
      );
    }
  }

  final LocationSettings locationSettings = const LocationSettings(
    accuracy: LocationAccuracy.high,
    distanceFilter: 100,
  );

  @override
  void initState() {
    super.initState();
    LocationService.determinePosition().then(
      (value) async {
        if (value != null) {
          _userCurrentPosition = Point(
            latitude: value.latitude,
            longitude: value.longitude,
          );
        }
        _isFetchingAddress = false;
      },
    ).catchError((error) {
      showDialog(
        context: context,
        builder: (context) => ShowErrorDialog(errorText: error.toString()),
      );
    }).whenComplete(
      () {
        setState(() {});
      },
    );
  }

  @override
  void dispose() {
    _searchTextController.dispose();
    super.dispose();
  }

  void _onMyLocationTapped() {
    if (_userCurrentPosition != null || _yandexMapController != null) {
      _yandexMapController!.moveCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(target: _userCurrentPosition!, zoom: 17),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return _isFetchingAddress
        ? const Center(child: CircularProgressIndicator())
        : Scaffold(
            appBar: AppBar(
              backgroundColor: const Color.fromARGB(255, 10, 4, 45),
              actions: [
                IconButton(
                  onPressed: () {
                    FirebaseAuth.instance.signOut();
                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      '/sign-in',
                      (route) => false,
                    );
                  },
                  icon: const Icon(
                    Icons.logout,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            body: Stack(
              children: <Widget>[
                YandexMap(
                  nightModeEnabled: true,
                  onMapCreated: _onMapCreated,
                  zoomGesturesEnabled: true,
                  mapObjects: [
                    if (_userCurrentPosition != null)
                      PlacemarkMapObject(
                        text: const PlacemarkText(
                          text: 'My location',
                          style: PlacemarkTextStyle(
                            color: Colors.red,
                            outlineColor: Colors.red,
                          ),
                        ),
                        mapId: const MapObjectId('current_location'),
                        point: _userCurrentPosition!,
                        icon: PlacemarkIcon.single(
                          PlacemarkIconStyle(
                            image: BitmapDescriptor.fromAssetImage(
                                "assets/route_start.png"),
                          ),
                        ),
                      ),
                    ...?_polyLines,
                    ..._set
                  ],
                  onMapLongTap: FirebaseAuth.instance.currentUser!.email ==
                          'test@gmail.com'
                      ? (argument) async {
                          Restaurant? restaurant = await showDialog(
                            context: context,
                            builder: (context) =>
                                AddNewRestaurant(location: argument),
                          );
                          if (restaurant != null) {
                            _set.add(
                              PlacemarkMapObject(
                                text: PlacemarkText(
                                  text: restaurant.title,
                                  style: const PlacemarkTextStyle(
                                    color: Colors.white,
                                    outlineColor: Colors.white,
                                  ),
                                ),
                                onTap: (mapObject, point) async {
                                  bool? isPolyline = await showDialog(
                                    context: context,
                                    builder: (context) => OnRestaurantTapped(
                                      restaurant: restaurant,
                                      onDeleteTap: () {
                                        _set.removeWhere(
                                          (element) =>
                                              element.mapId ==
                                              MapObjectId(restaurant.id),
                                        );
                                        setState(() {});
                                      },
                                    ),
                                  );
                                  if (isPolyline != null && isPolyline) {
                                    _polyLines =
                                        await YandexMapService.getDirection(
                                            _userCurrentPosition!,
                                            restaurant.location);
                                    setState(() {});
                                  }
                                },
                                mapId: MapObjectId(restaurant.id),
                                point: argument,
                                icon: PlacemarkIcon.single(
                                  PlacemarkIconStyle(
                                    image: BitmapDescriptor.fromAssetImage(
                                      "assets/place.png",
                                    ),
                                  ),
                                ),
                              ),
                            );
                            setState(() {});
                          }
                        }
                      : null,
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 10.0),
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CustomZoomButton(
                          isZoomIn: true,
                          onTap: () {
                            _yandexMapController!.moveCamera(
                              CameraUpdate.zoomIn(),
                            );
                          },
                        ),
                        const Gap(10),
                        CustomZoomButton(
                          isZoomIn: false,
                          onTap: () {
                            _yandexMapController!.moveCamera(
                              CameraUpdate.zoomOut(),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            floatingActionButton: FloatingActionButton(
              backgroundColor: const Color(0xFF1C1D22),
              onPressed:
                  _userCurrentPosition != null ? _onMyLocationTapped : null,
              child: const Icon(
                Icons.navigation_outlined,
                color: Color(0xFFCCCCCC),
              ),
            ),
          );
  }
}
