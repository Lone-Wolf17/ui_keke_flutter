import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_google_places/flutter_google_places.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:ui_keke_flutter/requests/google_map_requests.dart';
import 'package:ui_keke_flutter/utils/protected_data.dart';
import 'package:ui_keke_flutter/utils/utils_core.dart';

class AppState with ChangeNotifier {
  static LatLng _initialPosition;
  LatLng _lastPosition = _initialPosition;

  bool locationServiceActive;

  final Set<Marker> _markers = {};
  final Set<Polyline> _polyLines = {};

  GoogleMapsServices _googleMapsServices = GoogleMapsServices();
  GoogleMapController _mapController;

  TextEditingController locationController = TextEditingController();
  TextEditingController destinationController = TextEditingController();

  LatLng get initialPosition => _initialPosition;

  LatLng get lastPosition => _lastPosition;

  GoogleMapsServices get googleMapServices => _googleMapsServices;

  Set get markers => _markers;

  Set get polyLines => _polyLines;

  GoogleMapController get mapController => _mapController;

  AppState() {
    _getUserLocation();
    _loadingInitialPosition();
  }

  // ! AUTO COMPLETE USER LOCATION SEARCH
  void autoCompleteLocationSearch(BuildContext context) async {
    Prediction prediction = await PlacesAutocomplete.show(
        context: context,
        apiKey: google_maps_api_key,
        language: "en",
        components: [Component(Component.country, "ng")]);
    if (prediction != null) {
      GoogleMapsPlaces _places = GoogleMapsPlaces(apiKey: google_maps_api_key);
      PlacesDetailsResponse details =
          await _places.getDetailsByPlaceId(prediction.placeId);
//      double latitude =
//          details.result.geometry.location.lat;
//      double longitude =
//          details.result.geometry.location.lat;
      String address = prediction.description;

      sendRequest(address);
      destinationController.text = address;
    }
    notifyListeners();
  }

  //! TO GET THE USERS LOCATION
  void _getUserLocation() async {
    print("GET USER METHOD RUNNING =====");
    Position position = await Geolocator()
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    List<Placemark> placemark = await Geolocator()
        .placemarkFromCoordinates(position.latitude, position.longitude);

    _initialPosition = LatLng(position.latitude, position.longitude);
    locationController.text = placemark[0].name;

    print(
        "the latitude is: ${position.latitude} and the longitude is: ${position.longitude}");
//    print("initial position is : ${ini}")
    locationController.text = placemark[0].name;
    notifyListeners();
  }

  // ! TO CREATE ROUTE OR ADD POLYLINE
  void _createRoute(String encodedPoly) {
    _polyLines.add(Polyline(
        polylineId: PolylineId(_lastPosition.toString()),
        width: 5,
        points: _convertToLatLng(_decodePoly(encodedPoly)),
        color: black));
    notifyListeners();
  }

  // ! ADD A MARKER ON THE MAP
  void _addMarker(LatLng location, String address) {
    _markers.add(Marker(
        markerId: MarkerId(_lastPosition.toString()),
        position: location,
        infoWindow: InfoWindow(title: address, snippet: "go here"),
        icon: BitmapDescriptor.defaultMarker));
    notifyListeners();
  }

  // !DECODE POLY
  List _decodePoly(String poly) {
    var list = poly.codeUnits;
    var lList = List();
    int index = 0;
    int len = poly.length;
    int c = 0;
    // repeating until all attributes are decoded

    do {
      var shift = 0;
      int result = 0;

      // for decoding value of one attribute
      do {
        c = list[index] - 63;
        result |= (c & 0x1F) << (shift * 5);
        index++;
        shift++;
      } while (c >= 32);

      // if value is negative then bitwise not the value

      if (result & 1 == 1) {
        result = ~result;
      }

      var result1 = (result >> 1) * 0.00001;
      lList.add(result1);
    } while (index < len);

    // adding to previous value as done in encoding
    for (var i = 2; i < lList.length; i++) lList[i] += lList[i - 2];

    print(lList.toString());

    return lList;
  }

  /*this method will convert list of doubles such as the one below into LatLng

  * [12.12, 312.2, 321.3, 231.4, 234.5, 2342.6, 2341.7, 1321.48]
  * (0-------1------2------3------4------5--------6------7)
  * */
  List<LatLng> _convertToLatLng(List points) {
    List<LatLng> result = <LatLng>[];
    for (int i = 0; i < points.length; i++) {
      if (i % 2 != 0) {
        result.add(LatLng(points[i - 1], points[i]));
      }
    }

    return result;
  }

//  ! SEND REQUEST USING ADDRESS
  void sendRequest(String intendedLocation) async {
    List<Placemark> placemark =
        await Geolocator().placemarkFromAddress(intendedLocation);
    double latitude = placemark[0].position.latitude;
    double longitude = placemark[0].position.longitude;
    LatLng destination = LatLng(latitude, longitude);
    _addMarker(destination, intendedLocation);
    String route = await _googleMapsServices.getRouteCoordinates(
        _initialPosition, destination);
    _createRoute(route);
    notifyListeners();
  }

//  ! On Camera Moved
  void onCameraMoved(CameraPosition position) {
    _lastPosition = position.target;
    notifyListeners();
  }

//  ! ON MAP CREATED
  void onCreated(GoogleMapController controller) {
    _mapController = controller;
    notifyListeners();
  }

//  ! LOADING INITIAL POSITION
  void _loadingInitialPosition() async {
    if (_initialPosition == null) {
      locationServiceActive = await Geolocator().isLocationServiceEnabled();
    }

    notifyListeners();
  }
}
