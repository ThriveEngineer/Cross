import 'package:posthog_flutter/posthog_flutter.dart';

class PosthogService {
  PosthogService._();
  static final PosthogService instance = PosthogService._();

  static const String _apiKey = String.fromEnvironment('POSTHOG_API_KEY');
  static const String _host = String.fromEnvironment('POSTHOG_HOST', defaultValue: 'https://eu.i.posthog.com');

  late final Posthog _posthog;

  Future<void> initialize() async {
    final config = PostHogConfig(_apiKey)
      ..host = _host
      ..captureApplicationLifecycleEvents = true
      ..debug = false;

    await Posthog().setup(config);
    _posthog = Posthog();
  }

  void capture(String eventName, {Map<String, Object>? properties}) {
    _posthog.capture(eventName: eventName, properties: properties);
  }

  void screen(String screenName, {Map<String, Object>? properties}) {
    _posthog.screen(screenName: screenName, properties: properties);
  }

  void identify(String userId, {Map<String, Object>? properties}) {
    _posthog.identify(userId: userId, userProperties: properties);
  }

  void reset() {
    _posthog.reset();
  }
}
