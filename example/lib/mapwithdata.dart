import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_place_picker_mb/google_maps_place_picker.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

import 'keys.dart';
import 'map/map.dart';

class MapwithData extends StatefulWidget {
  @override
  _MapwithData createState() => _MapwithData();
}

class _MapwithData extends State<MapwithData> {
  late Position _geolocatorStreamPosition;
  LatLng _geolocatorStream = LatLng(24, 120);
  PickResult? selectedPlace;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BlocMap, BlocStateMap>(
      buildWhen: (previous, current) => previous.timestamp != current.timestamp,
      builder: (_, stateMap) {
        // print('- Plugin -' 'GPS: ${stateMap.gps}');
        // print('- Plugin -' 'Timestamp: ${stateMap.timestamp}');
        // print('- Plugin -' 'selectStart: ${stateMap.selectStart}');
        // print('- Plugin -' 'selectEnd: ${stateMap.selectEnd}');

        _geolocatorStreamPosition = stateMap.gps;
        _geolocatorStream = LatLng(stateMap.gps.latitude, stateMap.gps.longitude);
        PlacePicker.updateGPS(stateMap.gps);

        return PlacePicker(
            resizeToAvoidBottomInset: false, // only works in page mode, less flickery
            apiKey: Platform.isAndroid ? APIKeys.androidApiKey : APIKeys.iosApiKey,
            hintText: "Find a place ...",
            searchingText: "Please wait ...",
            selectText: "Select place",
            outsideOfPickAreaText: "Place not in area",
            initialPosition: _geolocatorStream,
            useCurrentLocation: true,
            selectInitialPosition: true,
            usePinPointingSearch: false,
            usePlaceDetailSearch: false,
            zoomGesturesEnabled: true,
            zoomControlsEnabled: true,
            enableMapTypeButton: true,
            enableMyLocationButton: true,
            myLocationButtonCooldown: 0,
            initialMapStyle: true,
            automaticallyImplyAppBarLeading: true,
            streamPosition: _geolocatorStreamPosition,
            onMapCreated: (GoogleMapController controller) {
              print("Map created");
            },
            onPlacePicked: (PickResult result) {
              print("Place picked: ${result.formattedAddress}");
              setState(() {
                selectedPlace = result;
                Navigator.of(context).pop();
              });
            },
            onMapTypeChanged: (MapType mapType) {
              print("Map type changed to ${mapType.toString()}");
            },
            onCameraIdle: (result) {
              print("Map: ${result.cameraPosition}");
            },
            onPlacePickedByCamera: (result) {
              print("onPlacePickedByCamera: ${result.latlng}");

              setState(() {
                //selectedPlace = result;
                Navigator.of(context).pop();
              });
            });
      },
    );
  }
}
