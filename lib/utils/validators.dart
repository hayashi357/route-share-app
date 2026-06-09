import 'package:email_validator/email_validator.dart';

class Validators {
  static String? validateEmail(String? value) {
    if (value?.isEmpty ?? true) {
      return 'メールアドレスを入力してください';
    }
    if (!EmailValidator.validate(value!)) {
      return '有効なメールアドレスを入力してください';
    }
    return null;
  }

  static String? validatePassword(String? value) {
    if (value?.isEmpty ?? true) {
      return 'パスワードを入力してください';
    }
    if (value!.length < 6) {
      return 'パスワードは6文字以上で入力してください';
    }
    return null;
  }

  static String? validateConfirmPassword(
    String? value,
    String? passwordValue,
  ) {
    if (value?.isEmpty ?? true) {
      return 'パスワード確認を入力してください';
    }
    if (value != passwordValue) {
      return 'パスワードが一致しません';
    }
    return null;
  }

  static String? validateDisplayName(String? value) {
    if (value?.isEmpty ?? true) {
      return '表示名を入力してください';
    }
    if (value!.length < 2) {
      return '表示名は2文字以上で入力してください';
    }
    if (value.length > 50) {
      return '表示名は50文字以下で入力してください';
    }
    return null;
  }

  static String? validateBio(String? value) {
    if (value != null && value.length > 200) {
      return '自己紹介は200文字以下で入力してください';
    }
    return null;
  }

  static String? validateRouteTitle(String? value) {
    if (value?.isEmpty ?? true) {
      return 'ルートタイトルを入力してください';
    }
    if (value!.length > 100) {
      return 'ルートタイトルは100文字以下で入力してください';
    }
    return null;
  }
}
