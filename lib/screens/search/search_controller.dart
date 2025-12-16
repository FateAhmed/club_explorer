import 'dart:convert';

import 'package:explorify/config/api_config.dart';
import 'package:explorify/models/tour.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class TourSearchController extends GetxController {
  final TextEditingController searchTextController = TextEditingController();

  RxList<TourModel> searchResults = RxList<TourModel>();
  RxBool isLoading = false.obs;
  RxBool hasSearched = false.obs;
  RxString errorMessage = ''.obs;

  // Filter values
  RxDouble minPrice = 0.0.obs;
  RxDouble maxPrice = 5000.0.obs;
  RxInt minDuration = 1.obs;
  RxInt maxDuration = 14.obs;
  Rx<DateTime?> startDate = Rx<DateTime?>(null);
  Rx<DateTime?> endDate = Rx<DateTime?>(null);
  RxString location = ''.obs;

  // Pagination
  RxInt currentPage = 1.obs;
  RxInt totalPages = 1.obs;
  RxInt totalResults = 0.obs;

  @override
  void onClose() {
    searchTextController.dispose();
    super.onClose();
  }

  Future<void> searchTours({bool resetPage = true}) async {
    if (resetPage) {
      currentPage.value = 1;
    }

    isLoading.value = true;
    hasSearched.value = true;
    errorMessage.value = '';

    try {
      final queryParams = <String, String>{};

      final query = searchTextController.text.trim();
      if (query.isNotEmpty) {
        queryParams['query'] = query;
      }

      if (location.value.isNotEmpty) {
        queryParams['location'] = location.value;
      }

      if (minPrice.value > 0) {
        queryParams['minPrice'] = minPrice.value.toInt().toString();
      }

      if (maxPrice.value < 5000) {
        queryParams['maxPrice'] = maxPrice.value.toInt().toString();
      }

      if (minDuration.value > 1) {
        queryParams['minDuration'] = minDuration.value.toString();
      }

      if (maxDuration.value < 14) {
        queryParams['maxDuration'] = maxDuration.value.toString();
      }

      if (startDate.value != null) {
        queryParams['startDate'] = startDate.value!.toIso8601String();
      }

      if (endDate.value != null) {
        queryParams['endDate'] = endDate.value!.toIso8601String();
      }

      queryParams['page'] = currentPage.value.toString();
      queryParams['limit'] = '20';

      final uri = Uri.parse('${ApiConfig.tours}/search').replace(queryParameters: queryParams);

      debugPrint('Search URL: $uri');

      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final tours = (data['tours'] as List).map((e) => TourModel.fromJson(e)).toList();

        if (resetPage) {
          searchResults.value = tours;
        } else {
          searchResults.addAll(tours);
        }

        final pagination = data['pagination'];
        if (pagination != null) {
          totalPages.value = pagination['pages'] ?? 1;
          totalResults.value = pagination['total'] ?? 0;
        }

        debugPrint('Search results: ${searchResults.length}');
      } else {
        errorMessage.value = 'Failed to search tours';
        debugPrint('Search error: ${response.statusCode}');
      }
    } catch (e) {
      errorMessage.value = 'Error searching tours: $e';
      debugPrint('Search exception: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void loadMore() {
    if (currentPage.value < totalPages.value && !isLoading.value) {
      currentPage.value++;
      searchTours(resetPage: false);
    }
  }

  void clearFilters() {
    minPrice.value = 0.0;
    maxPrice.value = 5000.0;
    minDuration.value = 1;
    maxDuration.value = 14;
    startDate.value = null;
    endDate.value = null;
    location.value = '';
  }

  void clearSearch() {
    searchTextController.clear();
    searchResults.clear();
    hasSearched.value = false;
    clearFilters();
  }
}
