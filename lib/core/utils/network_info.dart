import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Network connectivity checker
abstract class NetworkInfo {
  /// Check if device has internet connection
  Future<bool> get isConnected;

  /// Stream of connectivity changes
  Stream<bool> get onConnectivityChanged;
}

/// Implementation using connectivity_plus
class NetworkInfoImpl implements NetworkInfo {
  final Connectivity _connectivity;
  StreamController<bool>? _connectivityController;

  NetworkInfoImpl({Connectivity? connectivity})
      : _connectivity = connectivity ?? Connectivity();

  @override
  Future<bool> get isConnected async {
    final result = await _connectivity.checkConnectivity();
    return _isConnected(result);
  }

  @override
  Stream<bool> get onConnectivityChanged {
    _connectivityController ??= StreamController<bool>.broadcast();

    _connectivity.onConnectivityChanged.listen((results) {
      _connectivityController?.add(_isConnected(results));
    });

    return _connectivityController!.stream;
  }

  bool _isConnected(List<ConnectivityResult> results) {
    return results.any((result) =>
        result == ConnectivityResult.wifi ||
        result == ConnectivityResult.mobile ||
        result == ConnectivityResult.ethernet);
  }

  void dispose() {
    _connectivityController?.close();
  }
}

/// Provider for network info
final networkInfoProvider = Provider<NetworkInfo>((ref) {
  final networkInfo = NetworkInfoImpl();
  ref.onDispose(() => networkInfo.dispose());
  return networkInfo;
});

/// Provider for current connectivity status
final isConnectedProvider = FutureProvider<bool>((ref) async {
  final networkInfo = ref.watch(networkInfoProvider);
  return networkInfo.isConnected;
});

/// Provider for connectivity stream
final connectivityStreamProvider = StreamProvider<bool>((ref) {
  final networkInfo = ref.watch(networkInfoProvider);
  return networkInfo.onConnectivityChanged;
});
