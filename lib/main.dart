
import 'package:flutter/material.dart';

// MODEL
class Item {
  Item(
    this.name, {
    this.note = '',
    this.category = 'Food',
  });

  // Name is no longer final because it can be edited.
  String name;
  String note;
  String category;

  bool bought = false;
  int quantity = 1;
}

void main() {
  runApp(const ShoppingApp());
}

// MAIN APPLICATION
class ShoppingApp extends StatelessWidget {
  const ShoppingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(colorSchemeSeed: Colors.purple),
      home: const HomeScreen(title: 'My grocery List'),
    );
  }
}

// HOME SCREEN
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.title});

  final String title;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<Item> items = [
    Item('Milk'),
    Item('Bread'),
    Item('Rice'),
    Item('Tiramisu'),
  ];

  final controller = TextEditingController();

  // PART 5: Current filter
  String filter = 'All';

  // Show a SnackBar without queuing old messages
  void showMessage(String message) {
    final messenger = ScaffoldMessenger.of(context);

    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  // PART 3: Add new items or increase existing quantities
  void addItem() {
    final text = controller.text.trim();

    if (text.isEmpty) {
      showMessage('Type an item first');
      return;
    }

    final matches = items.where(
      (item) =>
          item.name.trim().toLowerCase() ==
          text.toLowerCase(),
    );

    if (matches.isNotEmpty) {
      final existingItem = matches.first;

      setState(() {
        existingItem.quantity++;
      });

      showMessage(
        '${existingItem.name} is already on the list: '
        'now ×${existingItem.quantity}',
      );

      controller.clear();
      return;
    }

    setState(() {
      items.add(Item(text));
    });

    controller.clear();
  }

  // PART 4: Delete an item with Undo
  void deleteItem(Item item) {
    final originalIndex = items.indexOf(item);

    if (originalIndex == -1) return;

    setState(() {
      items.remove(item);
    });

    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();

    messenger.showSnackBar(
      SnackBar(
        content: Text('${item.name} removed'),
        duration: const Duration(seconds: 5),
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () {
            if (items.contains(item)) return;

            setState(() {
              final position =
                  originalIndex.clamp(0, items.length);

              items.insert(position, item);
            });
          },
        ),
      ),
    );
  }

  // Mark item as bought or not bought
  void toggleBought(Item item) {
    setState(() {
      item.bought = !item.bought;
    });
  }

  // PART 2: Increase quantity
  void increaseQuantity(Item item) {
    setState(() {
      item.quantity++;
    });
  }

  // PART 2: Decrease quantity
  void decreaseQuantity(Item item) {
    if (item.quantity > 1) {
      setState(() {
        item.quantity--;
      });
    }
  }

  // Clear bought items
  void clearBoughtItems() {
    setState(() {
      items.removeWhere((item) => item.bought);
    });
  }

  // PART 5: Filter shopping items
  List<Item> getShownItems() {
    if (filter == 'To buy') {
      return items.where((item) => !item.bought).toList();
    }

    if (filter == 'Bought') {
      return items.where((item) => item.bought).toList();
    }

    // All: Unbought items first, bought items last
    return [
      ...items.where((item) => !item.bought),
      ...items.where((item) => item.bought),
    ];
  }

  // PART 6: Open the Item Details screen
  Future<void> openDetails(Item item) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DetailsScreen(
          item: item,
          items: items,
        ),
      ),
    );

    // Update the shopping list after returning
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final itemsLeft =
        items.where((item) => !item.bought).length;

    final shown = getShownItems();

    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.title} ($itemsLeft left)'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_sweep),
            tooltip: 'Clear bought items',
            onPressed: clearBoughtItems,
          ),
        ],
      ),

      body: Column(
        children: [
          // Item input
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: controller,
                    onSubmitted: (_) => addItem(),
                    decoration: const InputDecoration(
                      hintText: 'Enter an item',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                FilledButton(
                  onPressed: addItem,
                  child: const Text('Add'),
                ),
              ],
            ),
          ),

          // PART 5: Filters
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
            ),
            child: Wrap(
              spacing: 10,
              children: [
                ChoiceChip(
                  label: const Text('All'),
                  selected: filter == 'All',
                  onSelected: (_) {
                    setState(() {
                      filter = 'All';
                    });
                  },
                ),
                ChoiceChip(
                  label: const Text('To buy'),
                  selected: filter == 'To buy',
                  onSelected: (_) {
                    setState(() {
                      filter = 'To buy';
                    });
                  },
                ),
                ChoiceChip(
                  label: const Text('Bought'),
                  selected: filter == 'Bought',
                  onSelected: (_) {
                    setState(() {
                      filter = 'Bought';
                    });
                  },
                ),
              ],
            ),
          ),

          // Shopping list
          Expanded(
            child: items.isEmpty
                ? const Center(
                    child: Text(
                      'Your list is empty',
                      style: TextStyle(fontSize: 20),
                    ),
                  )
                : shown.isEmpty
                    ? const Center(
                        child: Text(
                          'Nothing here',
                          style: TextStyle(fontSize: 20),
                        ),
                      )
                    : ListView.builder(
                        itemCount: shown.length,
                        itemBuilder: (context, index) {
                          final item = shown[index];

                          return ListTile(
                            // Tap to mark as bought
                            onTap: () => toggleBought(item),

                            // PART 6: Long-press for details
                            onLongPress: () => openDetails(item),

                            leading: Icon(
                              item.bought
                                  ? Icons.check_circle
                                  : Icons.shopping_basket,
                              color: item.bought
                                  ? Colors.green
                                  : null,
                            ),

                            title: Text(
                              item.name,
                              style: TextStyle(
                                decoration: item.bought
                                    ? TextDecoration.lineThrough
                                    : TextDecoration.none,
                              ),
                            ),

                            // PART 6: Category and note
                            subtitle: Text(
                              item.note.isEmpty
                                  ? item.category
                                  : '${item.category} · ${item.note}',
                            ),

                            // Quantity and delete controls
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.remove),
                                  tooltip: 'Decrease quantity',
                                  onPressed: () {
                                    decreaseQuantity(item);
                                  },
                                ),
                                Text(
                                  '${item.quantity}',
                                  style: const TextStyle(
                                    fontSize: 16,
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.add),
                                  tooltip: 'Increase quantity',
                                  onPressed: () {
                                    increaseQuantity(item);
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete),
                                  tooltip: 'Delete item',
                                  onPressed: () {
                                    deleteItem(item);
                                  },
                                ),
                              ],
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}

// PART 6: SECOND SCREEN — ITEM DETAILS
class DetailsScreen extends StatefulWidget {
  const DetailsScreen({
    super.key,
    required this.item,
    required this.items,
  });

  final Item item;
  final List<Item> items;

  @override
  State<DetailsScreen> createState() => _DetailsScreenState();
}

class _DetailsScreenState extends State<DetailsScreen> {
  final nameController = TextEditingController();
  final noteController = TextEditingController();

  String category = 'Food';

  // Fill text fields when the screen opens
  @override
  void initState() {
    super.initState();

    nameController.text = widget.item.name;
    noteController.text = widget.item.note;
    category = widget.item.category;
  }

  // Save updated item information
  void saveDetails() {
    final newName = nameController.text.trim();
    final newNote = noteController.text.trim();

    // Reject empty names
    if (newName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Item name cannot be empty'),
        ),
      );
      return;
    }

    // Prevent duplicate item names
    final duplicate = widget.items.any(
      (item) =>
          !identical(item, widget.item) &&
          item.name.trim().toLowerCase() ==
              newName.toLowerCase(),
    );

    if (duplicate) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('An item with this name already exists'),
        ),
      );
      return;
    }

    // Apply changes only when Save is pressed
    widget.item.name = newName;
    widget.item.note = newNote;
    widget.item.category = category;

    Navigator.pop(context);
  }

  @override
  void dispose() {
    nameController.dispose();
    noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Item details'),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Item name',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                hintText: 'Enter item name',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 24),

            const Text(
              'Note',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            TextField(
              controller: noteController,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'Example: the 1 litre bottle',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 24),

            const Text(
              'Category',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 12),

            Wrap(
              spacing: 10,
              children: [
                ChoiceChip(
                  label: const Text('Food'),
                  selected: category == 'Food',
                  onSelected: (_) {
                    setState(() {
                      category = 'Food';
                    });
                  },
                ),
                ChoiceChip(
                  label: const Text('Drinks'),
                  selected: category == 'Drinks',
                  onSelected: (_) {
                    setState(() {
                      category = 'Drinks';
                    });
                  },
                ),
                ChoiceChip(
                  label: const Text('Home'),
                  selected: category == 'Home',
                  onSelected: (_) {
                    setState(() {
                      category = 'Home';
                    });
                  },
                ),
              ],
            ),

            const SizedBox(height: 32),

            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: saveDetails,
                child: const Text('Save'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
