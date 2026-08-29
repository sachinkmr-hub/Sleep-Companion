abstract class Failure {
  final String message;
  final dynamic error;

  const Failure(this.message, {this.error});

  @override
  String toString() => 'Failure(message: $message, error: $error)';
}

class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'Please check your internet connection.']) : super();
}

class AIFailure extends Failure {
  const AIFailure([super.message = 'Something went wrong with our AI companion. Please try again.']) : super();
}

class AudioFailure extends Failure {
  const AudioFailure([super.message = 'Failed to play audio.']) : super();
}

class StorageFailure extends Failure {
  const StorageFailure([super.message = 'Failed to save data.']) : super();
}

class PermissionFailure extends Failure {
  const PermissionFailure([super.message = 'Required permissions were not granted.']) : super();
}

class UnknownFailure extends Failure {
  const UnknownFailure([super.message = 'An unexpected error occurred.']) : super();
}
