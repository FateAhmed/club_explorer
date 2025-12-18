import 'dart:convert';

import 'package:explorify/config/api_config.dart';
import 'package:explorify/controllers/auth_controller.dart';
import 'package:explorify/models/tour.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class HomeController extends GetxController {
  RxList<TourModel> allTours = RxList<TourModel>();
  RxList<TourModel> bookedTours = RxList<TourModel>();
  RxBool isLoading = false.obs;

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
      debugPrint('Response: ${response.statusCode}');
      if (response.statusCode == 200) {
        var data = await response.stream.bytesToString();
        debugPrint('Data: $data');
        allTours.value = (jsonDecode(data)['tours'] as List).map((e) => TourModel.fromJson(e)).toList();
        debugPrint('All tours loaded: ${allTours.length}');
      } else {
        debugPrint('Error loading tours: ${response.statusCode}');
        debugPrint(await response.stream.bytesToString());
      }
    } catch (e) {
      debugPrint('Exception loading tours: $e');
    } finally {
      isLoading.value = false;
    }
  }

  getBookedTours() async {
    try {
      // Get auth controller to access token
      final authController = Get.find<AuthController>();

      // Skip if user is not logged in
      if (!authController.isLoggedIn) {
        debugPrint('User not logged in, skipping booked tours');
        return;
      }

      var request = http.Request('GET', Uri.parse('${ApiConfig.tours}/booking/my'));
      request.headers['Authorization'] = 'Bearer ${authController.token}';
      request.headers['Content-Type'] = 'application/json';

      http.StreamedResponse response = await request.send();
      debugPrint('Bookings response: ${response.statusCode}');

      if (response.statusCode == 200) {
        var data = await response.stream.bytesToString();
        debugPrint('Bookings data: $data');

        var jsonData = jsonDecode(data);
        var bookings = jsonData['bookings'] as List;
        debugPrint('Found ${bookings.length} bookings');

        // Extract tour IDs from bookings
        List<String> bookedTourIds = bookings
            .map((booking) => booking['tourId']?.toString() ?? '')
            .where((id) => id.isNotEmpty)
            .toList();

        // Match bookings with tours from allTours
        bookedTours.value = allTours
            .where((tour) => bookedTourIds.contains(tour.id))
            .toList();

        debugPrint('Booked tours loaded: ${bookedTours.length}');

        // If we have bookings but no matching tours in allTours, fetch tour details
        if (bookedTourIds.isNotEmpty && bookedTours.isEmpty) {
          debugPrint('No matching tours found in allTours, they may still be loading');
        }
      } else {
        debugPrint('Error loading bookings: ${response.statusCode}');
        debugPrint(await response.stream.bytesToString());
      }
    } catch (e) {
      debugPrint('Exception loading booked tours: $e');
    }
  }
}
