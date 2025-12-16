import 'dart:convert';

import 'package:explorify/config/api_config.dart';
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
    getTours();
    getBookedTours();
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
      // For now, we'll simulate booked tours by taking first 2 from all tours
      // In real app, this would be a separate API call to get user's booked tours
      await Future.delayed(Duration(milliseconds: 500)); // Simulate API delay
      if (allTours.isNotEmpty) {
        bookedTours.value = allTours.take(2).toList();
        debugPrint('Booked tours loaded: ${bookedTours.length}');
      }
    } catch (e) {
      debugPrint('Exception loading booked tours: $e');
    }
  }
}
