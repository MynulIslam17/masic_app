import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_task/core/widgets/widgets.dart';
import 'package:flutter_task/features/search/model/search_model.dart';
import 'package:flutter_task/features/search/widgets/search_item.dart';

class SearchListItem extends StatelessWidget {
  const SearchListItem({
    super.key,
    required this.query,
    required this.onSearch,
    this.onResultTap,
  });

  final String query;
  final Future<List<String>> Function(String query) onSearch;
  final void Function(String selectedItem)? onResultTap;

  @override
  Widget build(BuildContext context) {
    if (query.trim().isEmpty) {
      return const SizedBox.shrink();
    }

    return FutureBuilder<List<String>>(
      future: onSearch(query),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CustomText(
              text: 'Searching...',
              color: Colors.grey.shade400,
            ),
          );
        }

        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.wifi_off_rounded,
                    size: 56.r, color: Colors.grey.shade300),
                SizedBox(height: 12.h),
                Text(
                  snapshot.error.toString(),
                  style: TextStyle(
                      fontSize: 14.sp, color: Colors.grey.shade400),
                ),
              ],
            ),
          );
        }

        final results = snapshot.data ?? [];
        if (results.isEmpty) return _buildNoResult();
        final models = results
            .map((title) => SearchModel(title: title))
            .toList();

        return SearchItem(
          results: models,
          onTap: onResultTap,
        );
      },
    );
  }

  Widget _buildNoResult() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 56.r, color: Colors.grey.shade300),
          SizedBox(height: 12.h),
          Text(
            'No result for "$query"',
            style: TextStyle(
                fontSize: 14.sp, color: Colors.grey.shade400),
          ),
        ],
      ),
    );
  }
}