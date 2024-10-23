import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';

void showSnackbar(BuildContext context, String text) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(
      content: Text(text),
      behavior: SnackBarBehavior.floating,
    ));
}

Future<XFile?> pickImageFromGallery() async {
  final result = await ImagePicker().pickImage(source: ImageSource.gallery);
  return result;
}

Future<XFile?> pickImageFromCamera() async {
  final result = await ImagePicker().pickImage(source: ImageSource.camera);
  return result;
}

Future<XFile> resizeImage(XFile imageFile) async {
  List<int> imageBytes = (await FlutterImageCompress.compressWithFile(
      imageFile.path,
      minWidth: 1000,
      minHeight: 1000,
      quality: 90)) as List<int>;
  String fName = imageFile.name;

  Directory appDocDir = await getApplicationDocumentsDirectory();
  String appDocPath = appDocDir.path;
  String compressedImagePath = '$appDocPath/$fName.jpg';
  await File(compressedImagePath).writeAsBytes(imageBytes);
  return XFile(compressedImagePath);
}

List<String> indexName(String text) {
  List<String> searchList = [];

  // Split the text into words
  List<String> words = text.split(' ');

  // Generate incremental combinations for each word
  for (var word in words) {
    String temp = "";
    for (var char in word.split('')) {
      temp += char;
      searchList.add(temp);
    }
  }

  // Generate incremental combinations for the full text progressively
  for (var i = 0; i < words.length; i++) {
    String newTemp = words[0];
    for (var j = 0; j <= i; j++) {
      newTemp = words.sublist(0, j + 1).join(' ');
      if (j > 0) {
        for (var k = words[j].length; k > 0; k--) {
          searchList.add(newTemp);
          newTemp = newTemp.substring(0, newTemp.length - 1);
        }
      }
    }
  }

  return searchList.toSet().toList();
}

String formatDateTime(DateTime dateTime) {
  // Define the format
  final DateFormat formatter = DateFormat('dd/MM/yyyy');

  // Format the date
  final String formattedDate = formatter.format(dateTime);

  return formattedDate;
}

String formatDateTime2(DateTime dateTime) {
  // Define the format with dashes
  final DateFormat formatter = DateFormat('dd-MM-yyyy');

  // Format the date
  final String formattedDate = formatter.format(dateTime);

  return formattedDate;
}


TextEditingValue dateFormatFunction(
      TextEditingValue oldValue, TextEditingValue newValue) {
    String text = newValue.text;
    if (newValue.text.length == 2 && oldValue.text.length != 3) {
      text += '/';
    }
    if (newValue.text.length == 5 && oldValue.text.length != 6) {
      text += '/';
    }
    return TextEditingValue(text: text);
  }

  TextEditingValue priceFormatFunction(
      TextEditingValue oldValue, TextEditingValue newValue) {
    String text = newValue.text.replaceAll(',', '');

    if (text.isEmpty) {
      return newValue.copyWith(text: '');
    }

    // Check if the text can be parsed as an integer
    int value;
    try {
      value = int.parse(text);
    } catch (e) {
      // Perform validation if parsing fails
      final regex = RegExp(r'^(\d+)?(\.\d{0,2})?$');
      if (regex.hasMatch(text)) {
        // Return newValue if it contains a '.' with at most 2 digits after it
        return newValue;
      } else {
        // Return oldValue if validation fails
        return oldValue;
      }
    }

    // Format the value to a string with commas
    String formattedText = NumberFormat.decimalPattern().format(value);

    // Calculate the new selection offset
    int newOffset =
        formattedText.length - (oldValue.text.length - oldValue.selection.end);

    // Ensure the new offset is within the bounds of the formatted text
    newOffset = newOffset.clamp(0, formattedText.length);

    // Return the new TextEditingValue
    return TextEditingValue(
      text: formattedText,
      selection: TextSelection.collapsed(offset: newOffset),
    );
  }