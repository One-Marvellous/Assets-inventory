class MenuItem {
  final String text;

  const MenuItem(this.text);
}

class MenuItems {
  static const List<MenuItem> items = [editItem, itemHistory, deleteItem];
  static const itemHistory = MenuItem("Item History");
  static const editItem = MenuItem("Edit Item");
  static const deleteItem = MenuItem("Delete Item");
  static const updateInventory = MenuItem("Update Inventory");
  static const downloadReport = MenuItem("Download Report");
  static const List<MenuItem> maintenanceItems = [
    updateInventory,
    downloadReport
  ];
}
