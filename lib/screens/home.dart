import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:ui_keke_flutter/utils/utils_core.dart';
import 'package:uuid/uuid.dart';

class MyHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Uber Clone"),
      ),
      body: Map(),
    );
  }
}

class Map extends StatefulWidget {
  @override
  _MapState createState() => _MapState();
}

class _MapState extends State<Map> {
  GoogleMapController _mapController;
  static LatLng _center = LatLng(6.573261, 3.348889);
  LatLng _lastPosition = _center;

//  GoogleMapsPlaces googlePlaces;
//  GoogleMapsServices googleMapsServices = Goo
  final Set<Marker> _markers = {};
  final Set<Polyline> poly = {};

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Stack(
          children: [
            GoogleMap(
              initialCameraPosition:
                  CameraPosition(target: _center, zoom: 15.0),
              onMapCreated: onCreated,
              myLocationEnabled: true,
              mapType: MapType.normal,
              compassEnabled: true,
              markers: _markers,
              onCameraMove: _onCameraMoved,
            ),
            Positioned(
                top: 45.0,
                right: 15.0,
                left: 15.0,
                child: Container(
                  height: 50.0,
                  width: double.infinity,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(3.0),
                      color: white,
                      boxShadow: [
                        BoxShadow(
                            color: grey,
                            offset: Offset(1.0, 5.0),
                            blurRadius: 10,
                            spreadRadius: 3)
                      ]),
                  child: TextField(
                    cursorColor: black,
                    decoration: InputDecoration(
                      icon: Container(
                        margin: EdgeInsets.only(left: 20, top: 5),
                        width: 10,
                        height: 10,
                        child: Icon(
                          Icons.location_on,
                          color: black,
                        ),
                      ),
                      hintText: 'pick up',
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.only(left: 15.0, top: 16.0),
                    ),
                  ),
                )),

            Positioned(
                top: 100.0,
                right: 15.0,
                left: 15.0,
                child: Container(
                  height: 50.0,
                  width: double.infinity,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(3.0),
                      color: white,
                      boxShadow: [
                        BoxShadow(
                            color: grey,
                            offset: Offset(1.0, 5.0),
                            blurRadius: 10,
                            spreadRadius: 3)
                      ]),
                  child: TextField(
                    cursorColor: black,
                    textInputAction: TextInputAction.go,
                    decoration: InputDecoration(
                      icon: Container(
                        margin: EdgeInsets.only(left: 20, top: 5),
                        width: 10,
                        height: 10,
                        child: Icon(Icons.local_taxi, color: Colors.black,),
                      ),
                      hintText: 'destination?',
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.only(left: 15.0, top: 16.0),
                    ),
                  ),
                ))
//            Positioned(
//              top: 40,
//              right: 10,
//              child: FloatingActionButton(
//                onPressed: _onAddMarkerPressed,
//                tooltip: "add marker",
//                backgroundColor: Colors.blue,
//                child: Icon(
//                  Icons.add_location,
//                  color: white,
//                ),
//              ),
//            )
          ],
        )
      ],
    );
  }

  void onCreated(GoogleMapController controller) {
    setState(() {
      _mapController = controller;
    });
  }

  void _onCameraMoved(CameraPosition position) {
    setState(() {
      _lastPosition = position.target;
    });
  }

  void _onAddMarkerPressed() {
    var uuid = Uuid();

    setState(() {
      _markers.add(Marker(
          markerId: MarkerId(_lastPosition.toString()),
          position: _lastPosition,
          infoWindow: InfoWindow(title: "remember me", snippet: "good place"),
          icon: BitmapDescriptor.defaultMarker));
    });
  }
}
