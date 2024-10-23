import 'package:assets_inventory_app_ghum/common/models/items_model.dart';
import 'package:assets_inventory_app_ghum/features/inventory/screens/show_search_inventory.dart';
import 'package:assets_inventory_app_ghum/features/inventory/widgets/search_items.dart';
import 'package:assets_inventory_app_ghum/services/controller/item_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SearchInventoryDelegate extends SearchDelegate {
  final WidgetRef ref;
  final Map<String, List<ItemModel>> _cachedResults = {}; // Cache map

  SearchInventoryDelegate(this.ref);

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
          onPressed: () {
            query = '';
          },
          icon: const Icon(Icons.close))
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
        onPressed: () => Navigator.pop(context),
        icon: const Icon(Icons.navigate_before));
  }

  @override
  Widget buildResults(BuildContext context) {
    if (query.isEmpty) {
      return const Center(child: Text('Type to search for an inventory.'));
    }

    // Check if the query is already in the cache
    if (_cachedResults.containsKey(query)) {
      final cachedData = _cachedResults[query]!;
      return _buildSuggestionsList(cachedData);
    }

    // Check if any cached item contains the query in its searchList
    for (var cachedData in _cachedResults.values) {
      final matchingItems = cachedData
          .where((item) => item.searchList
              .any((searchTerm) => searchTerm.contains(query.toLowerCase())))
          .toList();

      if (matchingItems.isNotEmpty) {
        return _buildSuggestionsList(matchingItems);
      }
    }

    return StreamBuilder<List<ItemModel>>(
      stream: ref
          .watch(itemControllerProvider.notifier)
          .getItemByName(query.toLowerCase().trim()),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return const Center(child: Text('An Unexpected error occurred'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No results found.'));
        } else {
          final data = snapshot.data!;
          _cachedResults[query] = data; // Cache the results
          return _buildSuggestionsList(data);
        }
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    if (query.isEmpty) {
      return const Center(child: Text('Type to search for an inventory.'));
    }

    // Check if the query is already in the cache
    if (_cachedResults.containsKey(query)) {
      final cachedData = _cachedResults[query]!;
      return _buildSuggestionsList(cachedData);
    }

    // Check if any cached item contains the query in its searchList
    for (var cachedData in _cachedResults.values) {
      final matchingItems = cachedData
          .where((item) => item.searchList
              .any((searchTerm) => searchTerm.contains(query.toLowerCase())))
          .toList();

      if (matchingItems.isNotEmpty) {
        return _buildSuggestionsList(matchingItems);
      }
    }

    return StreamBuilder<List<ItemModel>>(
      stream: ref
          .watch(itemControllerProvider.notifier)
          .getItemByName(query.toLowerCase().trim()),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return const Center(child: Text('An Unexpected error occurred'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No results found.'));
        } else {
          final data = snapshot.data!;
          _cachedResults[query] = data; // Cache the results
          return _buildSuggestionsList(data);
        }
      },
    );
  }

  Widget _buildSuggestionsList(List<ItemModel> data) {
    return ListView.builder(
      itemCount: data.length,
      itemBuilder: (context, index) {
        ItemModel inventoryItem = data[index];
        return SearchInventoryItem(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ShowSearchInventory(
                inventory: inventoryItem,
              ),
            ),
          ),
          imageUrl: (inventoryItem.imagePath.isNotEmpty)
              ? inventoryItem.imagePath.first
              : null,
          count: inventoryItem.quantity,
          name: inventoryItem.name,
          officeName: inventoryItem.officeLocation,
          roomName: inventoryItem.roomLocation,
        );
      },
    );
  }
}
