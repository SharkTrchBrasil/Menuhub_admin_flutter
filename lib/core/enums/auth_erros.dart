import 'package:easy_localization/easy_localization.dart';

enum SignInError {
  invalidCredentials,
  inactiveAccount,
  emailNotVerified,
  noStoresAvailable,
  notLoggedIn,
  networkError,
  serverError,
  unauthorized,
  sessionExpired,
  unknown,
}


enum StoreCreationError {
  creationFailed,
  connectionFailed,
  unknown;

  String get message {
    switch (this) {
      case StoreCreationError.creationFailed:
        return 'Falha ao criar a loja';
      case StoreCreationError.connectionFailed:
        return 'Falha ao conectar com a loja';
      case StoreCreationError.unknown:
        return 'Erro desconhecido';
    }
  }
}

enum CodeError { unknown, userNotFound, alreadyVerified, invalidCode }

enum ResendError { unknown, userNotFound, resendError }


enum SignUpError {
  userAlreadyExists,
  emailAlreadyExists, // Alias para userAlreadyExists
  invalidData,
  weakPassword,
  networkError,
  serverError, // ✅ ADICIONADO
  emailNotSent,
  unknown;

  String get message {
    switch (this) {
      case SignUpError.userAlreadyExists:
      case SignUpError.emailAlreadyExists:
        return 'user_already_exists'.tr();
      case SignUpError.invalidData:
        return 'invalid_data'.tr();
      case SignUpError.weakPassword:
        return 'weak_password'.tr();
      case SignUpError.networkError:
        return 'network_error'.tr();
      case SignUpError.serverError: // ✅ ADICIONADO
        return 'server_error'.tr();
      case SignUpError.emailNotSent:
        return 'verification_email_not_sent'.tr();
      case SignUpError.unknown:
        return 'failed_to_create_account'.tr();
    }
  }
}