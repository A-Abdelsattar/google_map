import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:permission_handler/permission_handler.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home:MapScreen() ,
    );
  }
}


class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
   CameraPosition? initialCameraPosition;
  GoogleMapController? googleMapController;
   String? mapStyle;
   Set<Marker> setMarkers={};
   LatLng? _currentPosition;
   @override
  void initState() {
     _checkUserPermission();
     initialCameraPosition=CameraPosition(target:_currentPosition?? LatLng(30.031405553213364, 31.263887601781075),
         zoom: 14
     );
    _loadStyle();
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            myLocationEnabled: true,
            style:mapStyle,
           markers: setMarkers,
          initialCameraPosition: initialCameraPosition!,
            onMapCreated: (controller)async{
            googleMapController=controller;
            setMarkers.addAll({
              Marker(markerId: MarkerId("marker1"),
                  position: LatLng(30.031405553213364, 31.263887601781075),
                  icon:await _loadCustomMarkerIcon()

              ),
              Marker(markerId: MarkerId("marker2"),
                  position: LatLng(30.031362054984978, 31.256372826490725),
                  icon:await _loadCustomMarkerIcon()
              ),
            });

            },

          ),
          Positioned(
            bottom: 50,
            left: 0,
            right: 0,
            child: InkWell(
              onTap: (){
               _moveToCurrentPosition();
              },
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: 16),
                width: double.infinity,
                height: 50,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.blue
                ),
                child: Text("Change camera",style: TextStyle(
                  fontSize: 14,
                  color: Colors.white
                ),),
              ),
            ),
          )
        ],
      ),
      
    );

  }


  _moveToCurrentPosition(){
    googleMapController?.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(target:_currentPosition?? LatLng(30.01010058328396, 31.433634374339793),
        zoom: 14
    )));
  }
   _loadStyle()async{
    final style=await DefaultAssetBundle.of(context).loadString("assets/map_styles/map_dark_style.json");
      setState(() {
      mapStyle=style;
      });
   }

   _loadCustomMarkerIcon()async{
    return await BitmapDescriptor.asset(ImageConfiguration(size: Size(50, 50)), "assets/marker_icon.jpg");
   }

   _checkUserPermission()async{
    PermissionStatus status= await Permission.location.request();
    if(status.isGranted){
      _getCurrentLocation();
    }else if(status.isDenied){

    }
   }

  _getCurrentLocation()async{
    Position currentPosition= await Geolocator.getCurrentPosition(
      locationSettings: LocationSettings(
        accuracy: LocationAccuracy.high
      )
    );
    setState(() {
      _currentPosition=LatLng(currentPosition.latitude, currentPosition.longitude);
      _startTracking();
    });
  }

  _startTracking()async{
     Geolocator.getPositionStream().listen((pos){
       setState(() {
         _currentPosition=LatLng(pos.latitude, pos.longitude);
       });
       googleMapController?.animateCamera(CameraUpdate.newLatLng(_currentPosition!));
     });
  }

}
