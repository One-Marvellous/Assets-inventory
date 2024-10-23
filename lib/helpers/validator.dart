class Validator {
  static String? validateEmail(String? value) {
    const pattern = r"(?:[a-z0-9!#$%&'*+/=?^_`{|}~-]+(?:\.[a-z0-9!#$%&'"
        r'*+/=?^_`{|}~-]+)*|"(?:[\x01-\x08\x0b\x0c\x0e-\x1f\x21\x23-\x5b\x5d-'
        r'\x7f]|\\[\x01-\x09\x0b\x0c\x0e-\x7f])*")@(?:(?:[a-z0-9](?:[a-z0-9-]*'
        r'[a-z0-9])?\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?|\[(?:(?:(2(5[0-5]|[0-4]'
        r'[0-9])|1[0-9][0-9]|[1-9]?[0-9]))\.){3}(?:(2(5[0-5]|[0-4][0-9])|1[0-9]'
        r'[0-9]|[1-9]?[0-9])|[a-z0-9-]*[a-z0-9]:(?:[\x01-\x08\x0b\x0c\x0e-\x1f\'
        r'x21-\x5a\x53-\x7f]|\\[\x01-\x09\x0b\x0c\x0e-\x7f])+)\])';
    final regex = RegExp(pattern);

    if (value!.isEmpty) {
      return "Enter a valid email address";
    } else {
      return !regex.hasMatch(value) ? 'Enter a valid email address' : null;
    }
  }

  static String? validateItem(String? value, String itemName) {
    return value != null && value.isEmpty ? "Enter a valid $itemName" : null;
  }

  static String? validateWithMessage(String? value, String message) {
    return value != null && value.isEmpty ? message : null;
  }

  static String? validateQuantity(String? value, int? initialQuantity) {
    if (value!.isEmpty) {
      return "Enter a valid quantity";
    }
    try {
      var newvalue = int.parse(value);
      if (newvalue == 0) return "Quantity is zero can't perform action";
      if (initialQuantity != null) {
        return newvalue <= initialQuantity
            ? null
            : "Operation failed. $newvalue > $initialQuantity ";
      }
      return null;
    } catch (e) {
      return "Quantity must be an integer";
    }
  }

  static String? validateAddQuantity(String? value) {
    if (value!.isEmpty) {
      return "Enter a valid quantity";
    }
    try {
      var newValue = int.parse(value);
      if (newValue == 0) return "Quantity is zero can't perform action";
      return null;
    } catch (e) {
      return "Quantity must be an integer";
    }
  }

  static String? validateInteger(String? value, String name) {
    if (value!.isEmpty) {
      return "Enter a valid ${name.toLowerCase()}";
    }
    try {
      int.parse(value);
      return null;
    } catch (e) {
      return "$name must be an integer";
    }
  }

  static String? validateDouble(String? value, String name) {
    if (value!.isEmpty) {
      return "Enter a valid ${name.toLowerCase()}";
    }
    try {
      double.parse(value);
      return null;
    } catch (e) {
      return "$name must be have decimal";
    }
  }

  static String? validatePassword(String? value) {
    if (value?.isEmpty ?? true) {
      return "Please enter a valid password";
    }
    return null;
  }

  static String? validateName(String? value) {
    if (value!.isEmpty || value.length < 4) {
      return "Enter a valid name";
    }
    return null;
  }

  static String? validateCode(String? value, String code) {
    return value != code ? "You didn't enter the correct code" : null;
  }

  static String? validateDate(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a valid date';
    }

    // Regular expression for dd/mm/yyyy format
    final RegExp dateRegExp =
        RegExp(r'^(0[1-9]|[12][0-9]|3[01])/(0[1-9]|1[0-2])/([0-9]{4})$');

    if (!dateRegExp.hasMatch(value)) {
      return 'Enter date in dd/mm/yyyy format';
    }

    return null;
  }

  static String? validateEmptyDate(String? value) {
    if (value?.isEmpty ?? false) {
      return null;
    }
    final RegExp dateRegExp =
        RegExp(r'^(0[1-9]|[12][0-9]|3[01])/(0[1-9]|1[0-2])/([0-9]{4})$');

    if (!dateRegExp.hasMatch(value!)) {
      return 'Enter date in dd/mm/yyyy format';
    }
    return null;
  }
}
