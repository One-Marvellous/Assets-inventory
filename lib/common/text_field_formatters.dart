// void _formatPrice() {
//   final text = priceController.text;
//   priceController.value = priceController.value.copyWith(
//     text: _formatNumber(text.replaceAll(',', '')),
//     selection: TextSelection.collapsed(
//         offset: _formatNumber(text.replaceAll(',', '')).length),
//   );
// }

// String _formatNumber(String s) {
//   if (s.isNotEmpty) {
//     return NumberFormat.decimalPattern().format(int.parse(s));
//   } else {
//     return s;
//   }
// }

// void _formatDate(TextEditingController controller) {
//   String text = controller.text.replaceAll(RegExp(r'[^\d]'), '');

//   if (text.length > 8) {
//     text = text.substring(0, 8);
//   }

//   String formattedText = _formatDateString(text);

//   controller.value = controller.value.copyWith(
//     text: formattedText,
//     selection: TextSelection.collapsed(offset: formattedText.length),
//   );
// }
