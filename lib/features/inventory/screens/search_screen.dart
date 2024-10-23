import 'dart:developer';

import 'package:assets_inventory_app_ghum/common/models/items_model.dart';
import 'package:assets_inventory_app_ghum/features/inventory/screens/show_search_inventory.dart';
import 'package:assets_inventory_app_ghum/features/inventory/widgets/search_items.dart';
import 'package:assets_inventory_app_ghum/services/controller/item_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SearchInventoryScreen extends ConsumerStatefulWidget {
  const SearchInventoryScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _SearchInventoryScreenState();
}

class _SearchInventoryScreenState extends ConsumerState<SearchInventoryScreen> {
  final FocusNode _focusNode = FocusNode();
  final TextEditingController _searchController = TextEditingController();
  final Map<String, List<ItemModel>> _cachedResults = {};
  List<ItemModel> _searchResults = [];
  bool _isLoading = false;
  bool _isFetchingMore = false;
  String _errorMessage = '';
  DocumentSnapshot? _lastDocument;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_performSearch);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _searchController.removeListener(_performSearch);
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _performSearch() async {
    final query = _searchController.text.trim().toLowerCase();

    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
        _errorMessage = '';
      });
      return;
    }

    // Check if the query is already in the cache
    if (_cachedResults.containsKey(query)) {
      log("message: in cache");
      setState(() {
        _searchResults = _cachedResults[query]!;
        _errorMessage = '';
      });
      return;
    }

    // Fetch results from the API
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final querySnapshot = await ref
          .read(itemControllerProvider.notifier)
          .fetchItems(query: query, limit: 10, context: context);

      final results = querySnapshot.docs
          .map((doc) => ItemModel.fromMap(doc.data() as Map<String, dynamic>))
          .toList();

      setState(() {
        _searchResults = results;
        _cachedResults[query] = results;
        _isLoading = false;
        _errorMessage = '';
        _lastDocument =
            querySnapshot.docs.isNotEmpty ? querySnapshot.docs.last : null;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'An unexpected error occurred';
      });
    }
  }

  Future<void> _fetchMoreResults() async {
    if (_isFetchingMore || _lastDocument == null) return;

    setState(() {
      _isFetchingMore = true;
    });

    final query = _searchController.text.trim().toLowerCase();

    try {
      final querySnapshot = await ref
          .read(itemControllerProvider.notifier)
          .fetchItems(
              query: query,
              lastDocument: _lastDocument,
              limit: 10,
              context: context);

      final results = querySnapshot.docs
          .map((doc) => ItemModel.fromMap(doc.data() as Map<String, dynamic>))
          .toList();

      setState(() {
        _searchResults.addAll(results);
        _cachedResults[query] = _searchResults;
        _isFetchingMore = false;
        _lastDocument =
            querySnapshot.docs.isNotEmpty ? querySnapshot.docs.last : null;
      });
    } catch (e) {
      setState(() {
        _isFetchingMore = false;
        _errorMessage =
            'An unexpected error occurred while fetching more results';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: _searchController,
                focusNode: _focusNode,
                decoration: const InputDecoration(
                  hintText: 'Search for an Inventory',
                  suffixIcon: Icon(Icons.search),
                ),
              ),
            ),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _errorMessage.isNotEmpty
                      ? Center(child: Text(_errorMessage))
                      : _searchResults.isEmpty
                          ? const Center(child: Text('No results found.'))
                          : NotificationListener<ScrollNotification>(
                              onNotification: (ScrollNotification scrollInfo) {
                                if (scrollInfo.metrics.pixels ==
                                    scrollInfo.metrics.maxScrollExtent) {
                                  _fetchMoreResults();
                                }
                                return false;
                              },
                              child: ListView.builder(
                                itemCount: _searchResults.length + 1,
                                itemBuilder: (context, index) {
                                  if (index == _searchResults.length) {
                                    return _isFetchingMore
                                        ? const Center(
                                            child: CircularProgressIndicator())
                                        : const SizedBox();
                                  }
                                  final inventoryItem = _searchResults[index];
                                  return SearchInventoryItem(
                                    onTap: () => Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            ShowSearchInventory(
                                          inventory: inventoryItem,
                                        ),
                                      ),
                                    ),
                                    imageUrl:
                                        (inventoryItem.imagePath.isNotEmpty)
                                            ? inventoryItem.imagePath.first
                                            : null,
                                    count: inventoryItem.quantity,
                                    name: inventoryItem.name,
                                    officeName: inventoryItem.officeLocation,
                                    roomName: inventoryItem.roomLocation,
                                  );
                                },
                              ),
                            ),
            ),
          ],
        ),
      ),
    );
  }
}
