import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_place_picker_mb/google_maps_place_picker.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
// ignore: implementation_imports, unused_import
import 'package:google_maps_place_picker_mb/src/google_map_place_picker.dart'; // do not import this yourself
import 'dart:io' show Platform;

// Your api key storage.
import 'keys.dart';

// Only to control hybrid composition and the renderer in Android
import 'package:google_maps_flutter_android/google_maps_flutter_android.dart';
import 'package:google_maps_flutter_platform_interface/google_maps_flutter_platform_interface.dart';

import 'map/bloc/bloc_map.dart';
import 'mapwithdata.dart';

void main() {
  return runApp(
    MyApp(),
  );
}

class MyApp extends StatelessWidget {
  // Light Theme
  final ThemeData lightTheme = ThemeData.light().copyWith(
    // Background color of the FloatingCard
    cardColor: Colors.white,
  );

  // Dark Theme
  final ThemeData darkTheme = ThemeData.dark().copyWith(
    // Background color of the FloatingCard
    cardColor: Colors.grey,
  );

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (BuildContext context) => BlocMap(),
        ),
      ],
      child: MaterialApp(
        title: 'Google Map Place Picker Demo',
        theme: lightTheme,
        darkTheme: darkTheme,
        themeMode: ThemeMode.light,
        home: HomePage(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  HomePage({Key? key}) : super(key: key);

  static final kInitialPosition = LatLng(-33.8567844, 151.213108);

  final GoogleMapsFlutterPlatform mapsImplementation = GoogleMapsFlutterPlatform.instance;

  @override
  _HomePageState createState() => _HomePageState();
}

class GeoUtil {
  Geolocator _geoLocator = Geolocator();
}

class _HomePageState extends State<HomePage> with GeoUtil {
  PickResult? selectedPlace;
  bool _showPlacePickerInContainer = false;
  bool _showGoogleMapInContainer = false;

  bool _mapsInitialized = false;
  String _mapsRenderer = "latest";
  String TAG = 'Home';

  void initRenderer() {
    if (_mapsInitialized) return;
    if (widget.mapsImplementation is GoogleMapsFlutterAndroid) {
      switch (_mapsRenderer) {
        case "legacy":
          (widget.mapsImplementation as GoogleMapsFlutterAndroid)
              .initializeWithRenderer(AndroidMapRenderer.legacy);
          break;
        case "latest":
          (widget.mapsImplementation as GoogleMapsFlutterAndroid)
              .initializeWithRenderer(AndroidMapRenderer.latest);
          break;
      }
    }
    setState(() {
      _mapsInitialized = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    //Geolocator _geolocator = Geolocator();
    LatLng _geolocatorStream = LatLng(24, 120);
    late Position _geolocatorStreamPosition;

    void repositoryPrint(String TAG, dynamic ex) {
      print('$TAG, $ex');
    }

    return BlocBuilder<BlocMap, BlocStateMap>(
      buildWhen: (previous, current) => previous.timestamp != current.timestamp,
      builder: (_, stateMap) {
        // repositoryPrint(TAG, 'GPS: ${stateMap.gps}');
        // repositoryPrint(TAG, 'Timestamp: ${stateMap.timestamp}');
        // repositoryPrint(TAG, 'selectStart: ${stateMap.selectStart}');
        // repositoryPrint(TAG, 'selectEnd: ${stateMap.selectEnd}');

        _geolocatorStreamPosition = stateMap.gps;
        return Scaffold(
          appBar: AppBar(
            title: Text("Google Map Place Picker Demo"),
          ),
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (!_mapsInitialized &&
                        widget.mapsImplementation is GoogleMapsFlutterAndroid) ...[
                      Switch(
                          value: (widget.mapsImplementation as GoogleMapsFlutterAndroid)
                              .useAndroidViewSurface,
                          onChanged: (value) {
                            setState(() {
                              (widget.mapsImplementation as GoogleMapsFlutterAndroid)
                                  .useAndroidViewSurface = value;
                            });
                          }),
                      Text("Hybrid Composition"),
                    ]
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (!_mapsInitialized &&
                        widget.mapsImplementation is GoogleMapsFlutterAndroid) ...[
                      Text("Renderer: "),
                      Radio(
                          groupValue: _mapsRenderer,
                          value: "auto",
                          onChanged: (value) {
                            setState(() {
                              _mapsRenderer = "auto";
                            });
                          }),
                      Text("Auto"),
                      Radio(
                          groupValue: _mapsRenderer,
                          value: "legacy",
                          onChanged: (value) {
                            setState(() {
                              _mapsRenderer = "legacy";
                            });
                          }),
                      Text("Legacy"),
                      Radio(
                          groupValue: _mapsRenderer,
                          value: "latest",
                          onChanged: (value) {
                            setState(() {
                              _mapsRenderer = "latest";
                            });
                          }),
                      Text("Latest"),
                    ]
                  ],
                ),
                !_showPlacePickerInContainer
                    ? ElevatedButton(
                        child: Text("Load Place Picker"),
                        onPressed: () {
                          initRenderer();
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) {
                                return MapwithData();
                              },
                            ),
                          );
                        },
                      )
                    : Container(),
                !_showPlacePickerInContainer
                    ? ElevatedButton(
                        child: Text("Load Place Picker in Container"),
                        onPressed: () {
                          initRenderer();
                          setState(() {
                            _showPlacePickerInContainer = true;
                          });
                        },
                      )
                    : Container(
                        width: MediaQuery.of(context).size.width * 0.75,
                        height: MediaQuery.of(context).size.height * 0.35,
                        child: PlacePicker(
                            forceAndroidLocationManager: true,
                            apiKey:
                                Platform.isAndroid ? APIKeys.androidApiKey : APIKeys.iosApiKey,
                            hintText: "Find a place ...",
                            searchingText: "Please wait ...",
                            selectText: "Select place",
                            initialPosition: _geolocatorStream!,
                            streamPosition: _geolocatorStreamPosition,
                            useCurrentLocation: true,
                            selectInitialPosition: true,
                            initialMapStyle: true,
                            usePinPointingSearch: true,
                            usePlaceDetailSearch: true,
                            zoomGesturesEnabled: true,
                            zoomControlsEnabled: true,
                            onPlacePicked: (PickResult result) {
                              setState(() {
                                selectedPlace = result;
                                _showPlacePickerInContainer = false;
                              });
                            },
                            onTapBack: () {
                              setState(() {
                                _showPlacePickerInContainer = false;
                              });
                            })),
                if (selectedPlace != null) ...[
                  Text(selectedPlace!.formattedAddress!),
                  Text("(lat: " +
                      selectedPlace!.geometry!.location.lat.toString() +
                      ", lng: " +
                      selectedPlace!.geometry!.location.lng.toString() +
                      ")"),
                ],
                // #region Google Map Example without provider
                _showPlacePickerInContainer
                    ? Container()
                    : ElevatedButton(
                        child: Text("Toggle Google Map w/o Provider"),
                        onPressed: () {
                          initRenderer();
                          setState(() {
                            _showGoogleMapInContainer = !_showGoogleMapInContainer;
                          });
                        },
                      ),
                !_showGoogleMapInContainer
                    ? Container()
                    : Container(
                        width: MediaQuery.of(context).size.width * 0.75,
                        height: MediaQuery.of(context).size.height * 0.25,
                        child: GoogleMap(
                          zoomGesturesEnabled: false,
                          zoomControlsEnabled: false,
                          myLocationButtonEnabled: false,
                          compassEnabled: false,
                          mapToolbarEnabled: false,
                          initialCameraPosition:
                              new CameraPosition(target: HomePage.kInitialPosition, zoom: 15),
                          mapType: MapType.normal,
                          myLocationEnabled: true,
                          onMapCreated: (GoogleMapController controller) {},
                          onCameraIdle: () {},
                          onCameraMoveStarted: () {},
                          onCameraMove: (CameraPosition position) {},
                        )),
                !_showGoogleMapInContainer ? Container() : TextField(),
                // #endregion
              ],
            ),
          ),
        );
      },
    );
  }
}
