// ignore_for_file: avoid_print
import 'package:connectivity_plus/connectivity_plus.dart';

/// Network information service for checking connectivity status
abstract class NetworkInfo {
  /// Check if device is currently connected to network
  Future<bool> get isConnected;

  /// Stream of connectivity status changes
  Stream<bool> get onConnectivityChanged;
}

/// Implementation of NetworkInfo using connectivity_plus package
class NetworkInfoImpl implements NetworkInfo {
  NetworkInfoImpl(this.connectivity);

  final Connectivity connectivity;

  @override
  Future<bool> get isConnected async {
    try {
      final results = await connectivity.checkConnectivity();
      print('🌐 NetworkInfo: Connectivity check results: $results');

      // Check if there's at least one active connection (WiFi or Mobile)
      final hasConnection = results.any((result) =>
          result == ConnectivityResult.mobile ||
          result == ConnectivityResult.wifi);

      print('🌐 NetworkInfo: Has connection = $hasConnection');
      return hasConnection;
    } catch (e) {
      print('🔴 NetworkInfo: Error checking connectivity: $e');
      // On error, assume we're offline
      return false;
    }
  }

  @override
  Stream<bool> get onConnectivityChanged =>
      connectivity.onConnectivityChanged.map(
        (results) {
          print('🌐 NetworkInfo: Connectivity changed: $results');
          final hasConnection = results.any((result) =>
              result == ConnectivityResult.mobile ||
              result == ConnectivityResult.wifi);
          print('🌐 NetworkInfo: New connection status = $hasConnection');
          return hasConnection;
        },
      );
}
