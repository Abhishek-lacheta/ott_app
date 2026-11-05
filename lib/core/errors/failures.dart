import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  final String message;
  final int? statusCode;

  const Failure(this.message, [this.statusCode]);

  @override
  List<Object?> get props => [message, statusCode];
}

class ServerFailure extends Failure {
  const ServerFailure([
    super.message = 'An unexpected server error occurred.',
    super.statusCode,
  ]);
}

class NetworkFailure extends Failure {
  const NetworkFailure([
    super.message =
        'No internet connection. Please check your network and try again.',
  ]);
}

class CacheFailure extends Failure {
  const CacheFailure([super.message = 'Failed to load or save cached data.']);
}

class PlaybackFailure extends Failure {
  const PlaybackFailure([
    super.message = 'Failed to initialize or play video.',
  ]);
}
