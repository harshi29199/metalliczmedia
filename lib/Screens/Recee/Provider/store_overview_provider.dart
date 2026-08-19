import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';

class StoreOverviewProvider with ChangeNotifier {
  final LatLng storeLocation = const LatLng(22.5726, 88.3639); // Kolkata

  File? buildingImage;
  File? gsbImage;
  int photoStep = 0; // 0 = none, 1 = building taken, 2 = gsp taken
  Future<void> startRecee(StoreOverviewProvider provider) async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      if (provider.photoStep == 0) {
        provider.setBuildingImage(File(pickedFile.path));
      } else if (provider.photoStep == 1) {
        provider.setgsbImage(File(pickedFile.path));
      }
    }
    notifyListeners();
  }
  void setBuildingImage(File image) {
    buildingImage = image;
    photoStep = 1;
    notifyListeners();
  }

  void setgsbImage(File image) {
    gsbImage = image;
    photoStep = 2;
    notifyListeners();
  }

  void resetPhotos() {
    buildingImage = null;
    gsbImage = null;
    photoStep = 0;
    notifyListeners();
  }
}
