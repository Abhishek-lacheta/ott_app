import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';

abstract class NetworkInfo {
  Future<bool> get isConnected;
  Stream<bool> get onConnectivityChanged;
}

class NetworkInfoImpl implements NetworkInfo {
  final Connectivity _connectivity;

  NetworkInfoImpl({Connectivity? connectivity})
    : _connectivity = connectivity ?? Connectivity();

  @override
  Future<bool> get isConnected async {
    try {
      final results = await _connectivity.checkConnectivity();
      return _hasActiveConnection(results);
    } catch (_) {
      return false;
    }
  }

  @override
  Stream<bool> get onConnectivityChanged {
    return _connectivity.onConnectivityChanged.map(_hasActiveConnection);
  }

  bool _hasActiveConnection(List<ConnectivityResult> results) {
    if (results.isEmpty) return false;
    return results.any(
      (result) =>
          result != ConnectivityResult.none &&
          result != ConnectivityResult.other,
    );
  }
}
