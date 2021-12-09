class InteractiveController {
  InteractiveController({
    required bool startPaused,
  }) : _isRunning = !startPaused;

  bool _isRunning;

  bool get isRunning => _isRunning;

  void resume() => _isRunning = true;

  void pause() => _isRunning = false;
}
