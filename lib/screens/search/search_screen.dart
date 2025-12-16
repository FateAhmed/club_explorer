import 'package:explorify/components/tour_card.dart';
import 'package:explorify/screens/search/search_controller.dart';
import 'package:explorify/utils/AppColors.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TourSearchController searchController = Get.put(TourSearchController());
  final FocusNode _searchFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _searchFocusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _buildFilterSheet(),
    );
  }

  Widget _buildFilterSheet() {
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.5,
      maxChildSize: 0.9,
      expand: false,
      builder: (context, scrollController) {
        return SingleChildScrollView(
          controller: scrollController,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.grey300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Filters',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        searchController.clearFilters();
                      },
                      child: Text(
                        'Clear All',
                        style: TextStyle(color: AppColors.primary1),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Price Range
                const Text(
                  'Price Range',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 10),
                Obx(() => RangeSlider(
                      values: RangeValues(
                        searchController.minPrice.value,
                        searchController.maxPrice.value,
                      ),
                      min: 0,
                      max: 5000,
                      divisions: 50,
                      activeColor: AppColors.primary1,
                      labels: RangeLabels(
                        '\$${searchController.minPrice.value.toInt()}',
                        '\$${searchController.maxPrice.value.toInt()}',
                      ),
                      onChanged: (values) {
                        searchController.minPrice.value = values.start;
                        searchController.maxPrice.value = values.end;
                      },
                    )),
                Obx(() => Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('\$${searchController.minPrice.value.toInt()}'),
                          Text('\$${searchController.maxPrice.value.toInt()}'),
                        ],
                      ),
                    )),

                const SizedBox(height: 20),

                // Duration
                const Text(
                  'Duration (days)',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 10),
                Obx(() => RangeSlider(
                      values: RangeValues(
                        searchController.minDuration.value.toDouble(),
                        searchController.maxDuration.value.toDouble(),
                      ),
                      min: 1,
                      max: 14,
                      divisions: 13,
                      activeColor: AppColors.primary1,
                      labels: RangeLabels(
                        '${searchController.minDuration.value}',
                        '${searchController.maxDuration.value}',
                      ),
                      onChanged: (values) {
                        searchController.minDuration.value = values.start.toInt();
                        searchController.maxDuration.value = values.end.toInt();
                      },
                    )),
                Obx(() => Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('${searchController.minDuration.value} day(s)'),
                          Text('${searchController.maxDuration.value} day(s)'),
                        ],
                      ),
                    )),

                const SizedBox(height: 20),

                // Location
                const Text(
                  'Location',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  onChanged: (value) => searchController.location.value = value,
                  decoration: InputDecoration(
                    hintText: 'Enter location',
                    prefixIcon: const Icon(CupertinoIcons.location),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: AppColors.grey300),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: AppColors.grey300),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: AppColors.primary1, width: 2),
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                // Apply Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      searchController.searchTours();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary1,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Apply Filters',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
        ),
        title: const Text(
          'Search Tours',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Search Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: searchController.searchTextController,
                      focusNode: _searchFocusNode,
                      onSubmitted: (_) => searchController.searchTours(),
                      decoration: InputDecoration(
                        hintText: 'Search tours...',
                        hintStyle: TextStyle(color: AppColors.grey),
                        prefixIcon: Icon(CupertinoIcons.search, color: AppColors.grey),
                        suffixIcon: ValueListenableBuilder<TextEditingValue>(
                            valueListenable: searchController.searchTextController,
                            builder: (context, value, child) {
                              if (value.text.isNotEmpty) {
                                return IconButton(
                                  icon: Icon(CupertinoIcons.clear_circled_solid, color: AppColors.grey),
                                  onPressed: () {
                                    searchController.searchTextController.clear();
                                    searchController.searchResults.clear();
                                    searchController.hasSearched.value = false;
                                  },
                                );
                              }
                              return const SizedBox.shrink();
                            },
                          ),
                        filled: true,
                        fillColor: AppColors.grey100,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  InkWell(
                    onTap: _showFilterSheet,
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.grey100,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(CupertinoIcons.slider_horizontal_3, color: AppColors.grey),
                    ),
                  ),
                  const SizedBox(width: 10),
                  InkWell(
                    onTap: () => searchController.searchTours(),
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.primary1,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(CupertinoIcons.search, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 10),

            // Results
            Expanded(
              child: Obx(() {
                if (searchController.isLoading.value && searchController.searchResults.isEmpty) {
                  return Center(
                    child: CircularProgressIndicator(color: AppColors.primary1),
                  );
                }

                if (!searchController.hasSearched.value) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          CupertinoIcons.search,
                          size: 64,
                          color: AppColors.grey300,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Search for tours',
                          style: TextStyle(
                            fontSize: 18,
                            color: AppColors.grey,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Enter keywords or use filters to find tours',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.grey,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                if (searchController.searchResults.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          CupertinoIcons.map,
                          size: 64,
                          color: AppColors.grey300,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No tours found',
                          style: TextStyle(
                            fontSize: 18,
                            color: AppColors.grey,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Try different keywords or filters',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.grey,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      child: Text(
                        '${searchController.totalResults.value} tours found',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.grey,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        itemCount: searchController.searchResults.length + 1,
                        itemBuilder: (context, index) {
                          if (index == searchController.searchResults.length) {
                            if (searchController.currentPage.value < searchController.totalPages.value) {
                              return Padding(
                                padding: const EdgeInsets.all(20),
                                child: Center(
                                  child: searchController.isLoading.value
                                      ? CircularProgressIndicator(color: AppColors.primary1)
                                      : TextButton(
                                          onPressed: () => searchController.loadMore(),
                                          child: Text(
                                            'Load More',
                                            style: TextStyle(color: AppColors.primary1),
                                          ),
                                        ),
                                ),
                              );
                            }
                            return const SizedBox.shrink();
                          }

                          final tour = searchController.searchResults[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: TourCard(tour: tour, isHorizontal: true),
                          );
                        },
                      ),
                    ),
                  ],
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}
