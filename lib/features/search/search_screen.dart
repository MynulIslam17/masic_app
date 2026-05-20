import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_task/core/utils/assets_path/assets.gen.dart';
import 'package:flutter_task/features/search/widgets/custom_search_theme.dart';
import 'package:flutter_task/features/search/widgets/search_list_item.dart';

class SearchScreen extends SearchDelegate {

  SearchScreen({
    this.hintText = 'Search here . . .',
    this.onResultTap,
    required this.onSearch,
  });

  final String hintText;
  final void Function(String selectedItem)? onResultTap;
  final Future<List<String>> Function(String query) onSearch;

  @override
  String get searchFieldLabel => hintText;

  @override
  ThemeData appBarTheme(BuildContext context) {
    return CustomSearchTheme.instance.appBarTheme;
  }

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    final bool isRtl = Directionality.of(context) == TextDirection.rtl;
    return IconButton(
      icon: isRtl
          ? Assets.icons.backButton.svg(height: 24.h, width: 24.w).flipped
          : Assets.icons.backButton.svg(height: 24.h, width: 24.w),
      onPressed: () => close(context, null),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return SearchListItem(
      query: query,
      onSearch: onSearch,
      onResultTap: onResultTap,
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return SearchListItem(
      query: query,
      onSearch: onSearch,
      onResultTap: onResultTap,
    );
  }
}

extension on Widget {
  Widget get flipped {
    return Transform.flip(flipX: true, child: this);
  }
}