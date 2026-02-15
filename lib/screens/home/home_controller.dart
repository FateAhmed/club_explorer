import 'dart:convert';

import 'package:explorify/config/api_config.dart';
import 'package:explorify/controllers/auth_controller.dart';
import 'package:explorify/models/tour.dart';
import 'package:explorify/models/tour_booking.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class HomeController extends GetxController {
  RxList<TourModel> allTours = RxList<TourModel>();
  RxList<TourBookingModel> tourBookings = RxList<TourBookingModel>();
  RxBool isLoading = false.obs;

  /// Map of tourId -> TourModel for quick lookup
  Map<String, TourModel> get tourMap =>
      {for (var tour in allTours) tour.id: tour};

  /// Legacy getter: unique booked tours (for home screen horizontal list)
  List<TourModel> get bookedTours {
    final bookedTourIds = tourBookings.map((b) => b.tourId).toSet();
    return allTours.where((tour) => bookedTourIds.contains(tour.id)).toList();
  }

  @override
  void onInit() {
    super.onInit();
    _loadData();
  }

  _loadData() async {
    await getTours();
    await getBookedTours();
  }

  getTours() async {
    isLoading.value = true;
    try {
      var request = http.Request('GET', Uri.parse(ApiConfig.tours));
      http.StreamedResponse response = await request.send();
      if (response.statusCode == 200) {
        var data = await response.stream.bytesToString();
        allTours.value = (jsonDecode(data)['tours'] as List).map((e) => TourModel.fromJson(e)).toList();
      }
    } catch (e) {
      debugPrint('Error loading tours: $e');
    } finally {
      isLoading.value = false;
    }
  }

  getBookedTours() async {
    try {
      final authController = Get.find<AuthController>();
      if (!authController.isLoggedIn) return;

      var request = http.Request('GET', Uri.parse('${ApiConfig.tours}/booking/my'));
      request.headers['Authorization'] = 'Bearer ${authController.token}';
      request.headers['Content-Type'] = 'application/json';

      http.StreamedResponse response = await request.send();

      if (response.statusCode == 200) {
        var data = await response.stream.bytesToString();
        var jsonData = jsonDecode(data);
        var bookings = jsonData['bookings'] as List;

        tourBookings.value = bookings
            .map((b) => TourBookingModel.fromJson(b))
            .toList();
      }
    } catch (e) {
      debugPrint('Error loading booked tours: $e');
    }
  }
}
