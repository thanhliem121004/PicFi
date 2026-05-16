import 'dart:async';
import 'package:app_links/app_links.dart';

enum DeepLinkType { expense, profile, friends, unknown }

class DeepLinkResult {
  final DeepLinkType type;
  final String? id;

  const DeepLinkResult({required this.type, this.id});
}

class DeepLinkService {
  DeepLinkService._();
  static final DeepLinkService _instance = DeepLinkService._();
  static DeepLinkService get instance => _instance;

  final AppLinks _appLinks = AppLinks();
  final StreamController<DeepLinkResult> _linkController =
      StreamController<DeepLinkResult>.broadcast();

  Stream<DeepLinkResult> get linkStream => _linkController.stream;
  StreamSubscription? _sub;

  Future<void> init() async {
    _sub = _appLinks.uriLinkStream.listen(_handleUri);

    final initialUri = await _appLinks.getInitialLink();
    if (initialUri != null) {
      _handleUri(initialUri);
    }
  }

  void _handleUri(Uri uri) {
    final result = parseUri(uri);
    if (result.type != DeepLinkType.unknown) {
      _linkController.add(result);
    }
  }

  static DeepLinkResult parseUri(Uri uri) {
    final segments = uri.pathSegments;
    final host = uri.host;

    if (host == 'expense' || (segments.isNotEmpty && segments.first == 'expense')) {
      final id = segments.length > 1 ? segments[1] : null;
      return DeepLinkResult(type: DeepLinkType.expense, id: id);
    }

    if (host == 'profile' || (segments.isNotEmpty && segments.first == 'profile')) {
      final userId = segments.length > 1 ? segments[1] : null;
      return DeepLinkResult(type: DeepLinkType.profile, id: userId);
    }

    if (host == 'friends' || (segments.isNotEmpty && segments.first == 'friends')) {
      return const DeepLinkResult(type: DeepLinkType.friends);
    }

    return const DeepLinkResult(type: DeepLinkType.unknown);
  }

  void dispose() {
    _sub?.cancel();
    _linkController.close();
  }
}
