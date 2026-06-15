// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:masic_generation/core/theme/app_colors.dart';
// import 'package:masic_generation/core/widgets/widgets.dart';
// import 'package:shared_preferences/shared_preferences.dart';
//
// // ── Model ────────────────────────────────────────────────────────────────────
//
// class SearchItem {
//   final int id;
//   final String name;
//   final String? image;
//   final String? subtitle;
//   final dynamic raw;
//
//   const SearchItem({
//     required this.id,
//     required this.name,
//     this.image,
//     this.subtitle,
//     this.raw,
//   });
// }
//
// // ── Search History Cache ─────────────────────────────────────────────────────
//
// class _SearchHistoryCache {
//   static const String _key = 'global_search_history';
//   static const int _maxHistory = 10;
//
//   // In-memory result cache: term → results
//   static final Map<String, List<SearchItem>> _resultCache = {};
//   static const int _maxResultCache = 30;
//
//   // ── History (SharedPreferences) ──────────────────────────────────────────
//
//   static Future<List<String>> getHistory() async {
//     final prefs = await SharedPreferences.getInstance();
//     return prefs.getStringList(_key) ?? [];
//   }
//
//   static Future<void> addToHistory(String term) async {
//     if (term.trim().isEmpty) return;
//     final prefs = await SharedPreferences.getInstance();
//     final list = prefs.getStringList(_key) ?? [];
//     list.remove(term); // remove duplicate
//     list.insert(0, term); // insert at top
//     if (list.length > _maxHistory) list.removeLast();
//     await prefs.setStringList(_key, list);
//   }
//
//   static Future<void> removeFromHistory(String term) async {
//     final prefs = await SharedPreferences.getInstance();
//     final list = prefs.getStringList(_key) ?? [];
//     list.remove(term);
//     await prefs.setStringList(_key, list);
//   }
//
//   static Future<void> clearHistory() async {
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.remove(_key);
//   }
//
//   // ── Result Cache (In-Memory) ─────────────────────────────────────────────
//
//   static bool hasResult(String term) => _resultCache.containsKey(term);
//
//   static List<SearchItem>? getResult(String term) => _resultCache[term];
//
//   static void setResult(String term, List<SearchItem> results) {
//     if (_resultCache.length >= _maxResultCache) {
//       _resultCache.remove(_resultCache.keys.first);
//     }
//     _resultCache[term] = results;
//   }
//
//   static void clearResultCache() => _resultCache.clear();
// }
//
// // ── TextField Style Options ──────────────────────────────────────────────────
//
// class SearchFieldStyle {
//   final Color? fillColor;
//   final Color? borderColor;
//   final Color? iconBgColor;
//   final Color? iconColor;
//   final Color? hintColor;
//   final Color? textColor;
//   final double? borderRadius;
//   final double? fontSize;
//   final double? iconSize;
//   final EdgeInsetsGeometry? contentPadding;
//   final TextStyle? hintStyle;
//   final TextStyle? textStyle;
//   final bool showShadow;
//   final double? elevation;
//
//   const SearchFieldStyle({
//     this.fillColor,
//     this.borderColor,
//     this.iconBgColor,
//     this.iconColor,
//     this.hintColor,
//     this.textColor,
//     this.borderRadius,
//     this.fontSize,
//     this.iconSize,
//     this.contentPadding,
//     this.hintStyle,
//     this.textStyle,
//     this.showShadow = false,
//     this.elevation,
//   });
//
//   /// Light clean style
//   static const SearchFieldStyle light = SearchFieldStyle(
//     fillColor: Color(0xFFF5F5F5),
//     borderColor: Colors.transparent,
//     iconBgColor: AppColors.primaryColor,
//     iconColor: Colors.white,
//     hintColor: Color(0xFFAAAAAA),
//     textColor: Color(0xFF1A1A1A),
//     borderRadius: 50,
//     fontSize: 14,
//   );
//
//   /// Dark modern style
//   static const SearchFieldStyle dark = SearchFieldStyle(
//     fillColor: Color(0xFF2A2A2A),
//     borderColor: Color(0xFF3A3A3A),
//     iconBgColor: AppColors.primaryColor,
//     iconColor: Colors.white,
//     hintColor: Color(0xFF888888),
//     textColor: Colors.white,
//     borderRadius: 12,
//     fontSize: 14,
//     showShadow: true,
//   );
//
//   /// Outlined style
//   static const SearchFieldStyle outlined = SearchFieldStyle(
//     fillColor: Colors.white,
//     borderColor: AppColors.primaryColor,
//     iconBgColor: AppColors.primaryColor,
//     iconColor: Colors.white,
//     hintColor: Color(0xFFBBBBBB),
//     textColor: Color(0xFF1A1A1A),
//     borderRadius: 8,
//     fontSize: 14,
//   );
// }
//
// // ── Widget ───────────────────────────────────────────────────────────────────
//
// class GlobalSearchField extends StatefulWidget {
//   // Core
//   final Future<List<SearchItem>> Function(String term) onSearch;
//   final Widget Function(SearchItem item, VoidCallback onTap) cardBuilder;
//
//   // Behavior
//   final String hintText;
//   final Duration debounceDuration;
//   final double maxOverlayHeight;
//   final int minSearchLength;
//   final bool enableHistory;
//   final bool enableResultCache;
//   final int maxHistoryItems;
//   final VoidCallback? onClearHistory;
//
//   // Style
//   final SearchFieldStyle style;
//   final EdgeInsetsGeometry? outerPadding;
//   final Widget? prefixIcon;
//   final Widget? customSuffixIcon;
//   final bool autofocus;
//
//   // Callbacks
//   final void Function(String term)? onSubmitted;
//   final void Function(SearchItem item)? onItemSelected;
//   final void Function(String term)? onSearchStarted;
//
//   const GlobalSearchField({
//     super.key,
//     required this.onSearch,
//     required this.cardBuilder,
//     this.hintText = 'Search...',
//     this.debounceDuration = const Duration(milliseconds: 400),
//     this.maxOverlayHeight = 320,
//     this.minSearchLength = 1,
//     this.enableHistory = true,
//     this.enableResultCache = true,
//     this.maxHistoryItems = 10,
//     this.onClearHistory,
//     this.style = SearchFieldStyle.light,
//     this.outerPadding,
//     this.prefixIcon,
//     this.customSuffixIcon,
//     this.autofocus = false,
//     this.onSubmitted,
//     this.onItemSelected,
//     this.onSearchStarted,
//   });
//
//   @override
//   State<GlobalSearchField> createState() => _GlobalSearchFieldState();
// }
//
// class _GlobalSearchFieldState extends State<GlobalSearchField> {
//   final _ctrl = TextEditingController();
//   final _focusNode = FocusNode();
//   final _layerLink = LayerLink();
//   OverlayEntry? _overlay;
//
//   bool _loading = false;
//   List<SearchItem> _results = [];
//   List<String> _history = [];
//   String _currentTerm = '';
//   bool _showHistory = false;
//
//   @override
//   void initState() {
//     super.initState();
//     _focusNode.addListener(_onFocusChange);
//     if (widget.enableHistory) _loadHistory();
//   }
//
//   Future<void> _loadHistory() async {
//     final h = await _SearchHistoryCache.getHistory();
//     if (mounted) setState(() => _history = h);
//   }
//
//   void _onFocusChange() {
//     if (_focusNode.hasFocus && _ctrl.text.trim().isEmpty && _history.isNotEmpty) {
//       _showHistory = true;
//       _showOverlay();
//     } else if (!_focusNode.hasFocus) {
//       Future.delayed(const Duration(milliseconds: 150), _removeOverlay);
//     }
//   }
//
//   void _onChanged(String value) {
//     final term = value.trim();
//     _currentTerm = term;
//
//     if (term.length < widget.minSearchLength) {
//       if (widget.enableHistory && _history.isNotEmpty && _focusNode.hasFocus) {
//         _showHistory = true;
//         _results = [];
//         _showOverlay();
//       } else {
//         _removeOverlay();
//       }
//       return;
//     }
//
//     _showHistory = false;
//
//     // Check in-memory cache first
//     if (widget.enableResultCache && _SearchHistoryCache.hasResult(term)) {
//       setState(() {
//         _results = _SearchHistoryCache.getResult(term)!;
//         _loading = false;
//       });
//       _showOverlay();
//       return;
//     }
//
//     _showOverlay();
//     Future.delayed(widget.debounceDuration, () => _hit(term));
//   }
//
//   Future<void> _hit(String term) async {
//     if (term != _currentTerm || !mounted) return;
//
//     widget.onSearchStarted?.call(term);
//     setState(() => _loading = true);
//     _overlay?.markNeedsBuild();
//
//     try {
//       final res = await widget.onSearch(term);
//       if (term != _currentTerm || !mounted) return;
//
//       if (widget.enableResultCache) {
//         _SearchHistoryCache.setResult(term, res);
//       }
//
//       setState(() {
//         _results = res;
//         _loading = false;
//       });
//     } catch (_) {
//       if (!mounted) return;
//       setState(() {
//         _results = [];
//         _loading = false;
//       });
//     }
//     _overlay?.markNeedsBuild();
//   }
//
//   Future<void> _onItemTap(SearchItem item) async {
//     _ctrl.text = item.name;
//     _currentTerm = item.name;
//     widget.onItemSelected?.call(item);
//
//     if (widget.enableHistory) {
//       await _SearchHistoryCache.addToHistory(item.name);
//       await _loadHistory();
//     }
//
//     _removeOverlay();
//     _focusNode.unfocus();
//   }
//
//   Future<void> _onHistoryTap(String term) async {
//     _ctrl.text = term;
//     _currentTerm = term;
//     _showHistory = false;
//     _onChanged(term);
//   }
//
//   Future<void> _removeHistoryItem(String term) async {
//     await _SearchHistoryCache.removeFromHistory(term);
//     await _loadHistory();
//     _overlay?.markNeedsBuild();
//   }
//
//   Future<void> _clearAllHistory() async {
//     await _SearchHistoryCache.clearHistory();
//     await _loadHistory();
//     widget.onClearHistory?.call();
//     if (_ctrl.text.trim().isEmpty) {
//       _removeOverlay();
//     } else {
//       _overlay?.markNeedsBuild();
//     }
//   }
//
//   void _showOverlay() {
//     if (_overlay != null) {
//       _overlay!.markNeedsBuild();
//       return;
//     }
//     _overlay = OverlayEntry(builder: _buildOverlay);
//     Overlay.of(context).insert(_overlay!);
//   }
//
//   void _removeOverlay() {
//     _overlay?.remove();
//     _overlay = null;
//     if (mounted) setState(() { _results = []; _loading = false; _showHistory = false; });
//   }
//
//   Widget _buildOverlay(BuildContext _) {
//     final s = widget.style;
//     return Positioned(
//       width: MediaQuery.of(context).size.width -
//           (widget.outerPadding != null ? 32.w : 32.w),
//       child: CompositedTransformFollower(
//         link: _layerLink,
//         showWhenUnlinked: false,
//         offset: Offset(0, 58.h),
//         child: Material(
//           color: Colors.transparent,
//           child: Container(
//             constraints: BoxConstraints(maxHeight: widget.maxOverlayHeight.h),
//             decoration: BoxDecoration(
//               color: s.fillColor ?? Colors.white,
//               borderRadius: BorderRadius.circular((s.borderRadius ?? 14).r),
//               border: Border.all(
//                 color: s.borderColor ?? Colors.grey.shade200,
//                 width: 1,
//               ),
//               boxShadow: [
//                 BoxShadow(
//                   color: Colors.black.withOpacity(0.10),
//                   blurRadius: 24,
//                   offset: const Offset(0, 6),
//                 ),
//               ],
//             ),
//             child: ClipRRect(
//               borderRadius: BorderRadius.circular((s.borderRadius ?? 14).r),
//               child: _showHistory && _history.isNotEmpty
//                   ? _buildHistoryList()
//                   : _loading
//                   ? _Loader(color: s.iconBgColor ?? AppColors.primaryColor)
//                   : _results.isEmpty
//                   ? const _Empty()
//                   : _buildResultList(),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildHistoryList() {
//     final s = widget.style;
//     return Column(
//       mainAxisSize: MainAxisSize.min,
//       children: [
//         // Header
//         Padding(
//           padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
//           child: Row(
//             children: [
//               Icon(Icons.history_rounded, size: 15.sp, color: s.hintColor ?? Colors.grey),
//               SizedBox(width: 6.w),
//               Text(
//                 'Recent Searches',
//                 style: TextStyle(
//                   fontSize: 12.sp,
//                   fontWeight: FontWeight.w600,
//                   color: s.hintColor ?? Colors.grey,
//                 ),
//               ),
//               const Spacer(),
//               GestureDetector(
//                 onTap: _clearAllHistory,
//                 child: Text(
//                   'Clear all',
//                   style: TextStyle(
//                     fontSize: 11.sp,
//                     color: s.iconBgColor ?? AppColors.primaryColor,
//                     fontWeight: FontWeight.w500,
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//         Divider(height: 1, color: Colors.grey.shade100),
//         Flexible(
//           child: ListView.builder(
//             padding: EdgeInsets.symmetric(vertical: 4.h),
//             shrinkWrap: true,
//             itemCount: _history.length,
//             itemBuilder: (_, i) {
//               final term = _history[i];
//               return InkWell(
//                 onTap: () => _onHistoryTap(term),
//                 child: Padding(
//                   padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
//                   child: Row(
//                     children: [
//                       Icon(Icons.north_west_rounded,
//                           size: 14.sp, color: Colors.grey[400]),
//                       SizedBox(width: 10.w),
//                       Expanded(
//                         child: Text(
//                           term,
//                           style: TextStyle(
//                             fontSize: 13.sp,
//                             color: s.textColor ?? const Color(0xFF1A1A1A),
//                           ),
//                           overflow: TextOverflow.ellipsis,
//                         ),
//                       ),
//                       GestureDetector(
//                         onTap: () => _removeHistoryItem(term),
//                         child: Icon(Icons.close_rounded,
//                             size: 15.sp, color: Colors.grey[400]),
//                       ),
//                     ],
//                   ),
//                 ),
//               );
//             },
//           ),
//         ),
//       ],
//     );
//   }
//
//   Widget _buildResultList() {
//     return ListView.builder(
//       padding: EdgeInsets.symmetric(vertical: 6.h),
//       shrinkWrap: true,
//       itemCount: _results.length,
//       itemBuilder: (_, i) {
//         final item = _results[i];
//         return widget.cardBuilder(item, () => _onItemTap(item));
//       },
//     );
//   }
//
//   @override
//   void dispose() {
//     _ctrl.dispose();
//     _focusNode.removeListener(_onFocusChange);
//     _focusNode.dispose();
//     _removeOverlay();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final s = widget.style;
//     return Padding(
//       padding: widget.outerPadding ?? EdgeInsets.symmetric(horizontal: 16.w),
//       child: CompositedTransformTarget(
//         link: _layerLink,
//         child: CustomTextField(
//           controller: _ctrl,
//           focusNode: _focusNode,
//           autofocus: widget.autofocus,
//           onChanged: _onChanged,
//           onFieldSubmitted: (v) {
//             widget.onSubmitted?.call(v.trim());
//             if (widget.enableHistory && v.trim().isNotEmpty) {
//               _SearchHistoryCache.addToHistory(v.trim()).then((_) => _loadHistory());
//             }
//           },
//           hintextSize: (s.fontSize ?? 14).sp,
//           borderRadio: (s.borderRadius ?? 50).r,
//           contentPaddingVertical: 0,
//           borderColor: s.borderColor ?? Colors.transparent,
//           validator: (_) => null,
//           hintText: widget.hintText,
//           prefixIcon: widget.prefixIcon,
//           suffixIcon: widget.customSuffixIcon ??
//               GestureDetector(
//                 onTap: () {
//                   if (_ctrl.text.trim().isNotEmpty) {
//                     _ctrl.clear();
//                     _currentTerm = '';
//                     _removeOverlay();
//                     if (_history.isNotEmpty && _focusNode.hasFocus) {
//                       _showHistory = true;
//                       _showOverlay();
//                     }
//                   }
//                 },
//                 child: AnimatedSwitcher(
//                   duration: const Duration(milliseconds: 200),
//                   child: _ctrl.text.trim().isNotEmpty
//                       ? CustomContainer(
//                     key: const ValueKey('clear'),
//                     marginAll: 2.r,
//                     paddingAll: 8.r,
//                     shape: BoxShape.circle,
//                     color: Colors.grey.shade300,
//                     child: Icon(Icons.close_rounded,
//                         color: Colors.grey[600], size: 16.sp),
//                   )
//                       : CustomContainer(
//                     key: const ValueKey('search'),
//                     marginAll: 2.r,
//                     paddingAll: 8.r,
//                     shape: BoxShape.circle,
//                     color: s.iconBgColor ?? AppColors.primaryColor,
//                     child: Icon(Icons.search_rounded,
//                         color: s.iconColor ?? Colors.white, size: 18.sp),
//                   ),
//                 ),
//               ),
//         ),
//       ),
//     );
//   }
// }
//
// // ── Helpers ──────────────────────────────────────────────────────────────────
//
// class _Loader extends StatelessWidget {
//   final Color color;
//   const _Loader({required this.color});
//
//   @override
//   Widget build(BuildContext context) => Padding(
//     padding: EdgeInsets.symmetric(vertical: 24.h),
//     child: Center(
//       child: SizedBox(
//         width: 22.w,
//         height: 22.w,
//         child: CircularProgressIndicator(strokeWidth: 2, color: color),
//       ),
//     ),
//   );
// }
//
// class _Empty extends StatelessWidget {
//   const _Empty();
//
//   @override
//   Widget build(BuildContext context) => Padding(
//     padding: EdgeInsets.symmetric(vertical: 20.h, horizontal: 16.w),
//     child: Row(children: [
//       Icon(Icons.search_off_rounded, color: Colors.grey[400], size: 18.sp),
//       SizedBox(width: 8.w),
//       Text(
//         'No results found',
//         style: TextStyle(fontSize: 13.sp, color: Colors.grey[500]),
//       ),
//     ]),
//   );
// }