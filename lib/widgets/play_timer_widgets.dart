import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math';
import '../services/play_timer_service.dart';

/// Timer display widget for the home screen
class PlayTimerDisplay extends StatefulWidget {
  const PlayTimerDisplay({super.key});

  @override
  State<PlayTimerDisplay> createState() => _PlayTimerDisplayState();
}

class _PlayTimerDisplayState extends State<PlayTimerDisplay> {
  final PlayTimerService _timerService = PlayTimerService();

  @override
  void initState() {
    super.initState();
    _timerService.addListener(_onTimerChange);
  }

  @override
  void dispose() {
    _timerService.removeListener(_onTimerChange);
    super.dispose();
  }

  void _onTimerChange() {
    setState(() {});
  }

  void _showTimerSettings() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const PlayTimerSettingsDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_timerService.isTimerEnabled) {
      return GestureDetector(
        onTap: _showTimerSettings,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.grey.shade400),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.timer_off, color: Colors.grey.shade600, size: 20),
              const SizedBox(width: 6),
              Text(
                'Timer OFF',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Timer is enabled - show countdown
    final progress = _timerService.progress;
    final isLow = _timerService.remainingSeconds < 300; // Less than 5 minutes

    return GestureDetector(
      onTap: _showTimerSettings,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isLow ? Colors.red.shade50 : Colors.blue.shade50,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isLow ? Colors.red : Colors.blue,
            width: 2,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 22,
              height: 22,
              child: Stack(
                children: [
                  CircularProgressIndicator(
                    value: progress,
                    strokeWidth: 3,
                    backgroundColor: Colors.grey.shade300,
                    valueColor: AlwaysStoppedAnimation(
                      isLow ? Colors.red : Colors.blue,
                    ),
                  ),
                  Center(
                    child: Icon(
                      Icons.timer,
                      size: 12,
                      color: isLow ? Colors.red : Colors.blue,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text(
              _timerService.remainingTimeFormatted,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: isLow ? Colors.red : Colors.blue.shade700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Timer settings dialog with parental gate
class PlayTimerSettingsDialog extends StatefulWidget {
  const PlayTimerSettingsDialog({super.key});

  @override
  State<PlayTimerSettingsDialog> createState() => _PlayTimerSettingsDialogState();
}

class _PlayTimerSettingsDialogState extends State<PlayTimerSettingsDialog> {
  bool _verified = false;
  late int _num1;
  late int _num2;
  late int _correctAnswer;
  final _answerController = TextEditingController();
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _generateNewProblem();
  }

  void _generateNewProblem() {
    final random = Random();
    _num1 = random.nextInt(10) + 10;
    _num2 = random.nextInt(10) + 5;
    _correctAnswer = _num1 + _num2;
    _answerController.clear();
    _errorMessage = null;
  }

  void _checkAnswer() {
    final answer = int.tryParse(_answerController.text);
    if (answer == _correctAnswer) {
      setState(() => _verified = true);
    } else {
      setState(() {
        _errorMessage = 'Incorrect. Try again!';
        _generateNewProblem();
      });
    }
  }

  @override
  void dispose() {
    _answerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_verified) {
      return _buildParentalGate();
    }
    return _buildTimerSettings();
  }

  Widget _buildParentalGate() {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.purple.shade50,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.timer, color: Colors.purple, size: 36),
          ),
          const SizedBox(height: 10),
          const Text(
            'Parent Verification',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Solve to access timer settings:',
            style: TextStyle(color: Colors.grey, fontSize: 13),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.purple.shade50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '$_num1 + $_num2 = ?',
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Colors.purple,
              ),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _answerController,
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: InputDecoration(
              hintText: 'Answer',
              filled: true,
              fillColor: Colors.grey.shade100,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
            onSubmitted: (_) => _checkAnswer(),
          ),
          if (_errorMessage != null) ...[
            const SizedBox(height: 10),
            Text(_errorMessage!, style: const TextStyle(color: Colors.red)),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _checkAnswer,
          style: ElevatedButton.styleFrom(backgroundColor: Colors.purple),
          child: const Text('Verify', style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }

  Widget _buildTimerSettings() {
    final timerService = PlayTimerService();

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.purple.shade50,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.timer, color: Colors.purple, size: 28),
          ),
          const SizedBox(width: 12),
          const Text('Play Timer', style: TextStyle(fontSize: 20)),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (timerService.isTimerEnabled) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: timerService.remainingSeconds < 300
                    ? Colors.red.shade50
                    : Colors.green.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Text(
                    timerService.remainingTimeFormatted,
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: timerService.remainingSeconds < 300
                          ? Colors.red
                          : Colors.green.shade700,
                    ),
                  ),
                  const Text('remaining', style: TextStyle(color: Colors.grey)),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Text('Add more time:', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildBonusButton('+5', 5, timerService),
                _buildBonusButton('+15', 15, timerService),
                _buildBonusButton('+30', 30, timerService),
              ],
            ),
            const SizedBox(height: 16),
          ],
          const Text('Set new time limit:', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _buildTimeLimitButton('15 min', 15, timerService),
              _buildTimeLimitButton('30 min', 30, timerService),
              _buildTimeLimitButton('45 min', 45, timerService),
              _buildTimeLimitButton('60 min', 60, timerService),
              _buildTimeLimitButton('90 min', 90, timerService),
            ],
          ),
        ],
      ),
      actions: [
        if (timerService.isTimerEnabled)
          TextButton(
            onPressed: () async {
              await timerService.disableTimer();
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text('Disable Timer', style: TextStyle(color: Colors.red)),
          ),
        ElevatedButton(
          onPressed: () => Navigator.pop(context),
          style: ElevatedButton.styleFrom(backgroundColor: Colors.purple),
          child: const Text('Done', style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }

  Widget _buildBonusButton(String label, int minutes, PlayTimerService service) {
    return ElevatedButton(
      onPressed: () async {
        await service.addBonusTime(minutes);
        setState(() {});
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blue,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
      child: Text(label, style: const TextStyle(color: Colors.white)),
    );
  }

  Widget _buildTimeLimitButton(String label, int minutes, PlayTimerService service) {
    final isSelected = service.timeLimitMinutes == minutes && service.isTimerEnabled;

    return ElevatedButton(
      onPressed: () async {
        await service.enableTimer(minutes);
        setState(() {});
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Timer set to $minutes minutes'),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 2),
            ),
          );
        }
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: isSelected ? Colors.purple : Colors.grey.shade200,
        foregroundColor: isSelected ? Colors.white : Colors.black87,
      ),
      child: Text(label),
    );
  }
}

/// Full screen overlay when timer expires
class TimerExpiredOverlay extends StatelessWidget {
  final VoidCallback onUnlock;

  const TimerExpiredOverlay({super.key, required this.onUnlock});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black87,
      child: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade100,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.bedtime,
                    size: 80,
                    color: Colors.orange,
                  ),
                ),
                const SizedBox(height: 32),
                const Text(
                  'Time\'s Up!',
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Playtime is over for now.\nAsk a parent to unlock more time!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 40),
                const Text(
                  '😴',
                  style: TextStyle(fontSize: 60),
                ),
                const SizedBox(height: 40),
                ElevatedButton.icon(
                  onPressed: onUnlock,
                  icon: const Icon(Icons.lock_open),
                  label: const Text('Parent Unlock'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                    textStyle: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Dialog to unlock after timer expires
class TimerUnlockDialog extends StatefulWidget {
  const TimerUnlockDialog({super.key});

  @override
  State<TimerUnlockDialog> createState() => _TimerUnlockDialogState();
}

class _TimerUnlockDialogState extends State<TimerUnlockDialog> {
  bool _verified = false;
  late int _num1;
  late int _num2;
  late int _correctAnswer;
  final _answerController = TextEditingController();
  String? _errorMessage;
  int _selectedMinutes = 30;

  @override
  void initState() {
    super.initState();
    _generateNewProblem();
  }

  void _generateNewProblem() {
    final random = Random();
    _num1 = random.nextInt(15) + 10;
    _num2 = random.nextInt(10) + 5;
    _correctAnswer = _num1 + _num2;
    _answerController.clear();
    _errorMessage = null;
  }

  void _checkAnswer() {
    final answer = int.tryParse(_answerController.text);
    if (answer == _correctAnswer) {
      setState(() => _verified = true);
    } else {
      setState(() {
        _errorMessage = 'Incorrect!';
        _generateNewProblem();
      });
    }
  }

  Future<void> _unlock() async {
    await PlayTimerService().unlockAndRestart(newLimitMinutes: _selectedMinutes);
    if (mounted) Navigator.pop(context, true);
  }

  Future<void> _disableTimer() async {
    await PlayTimerService().disableTimer();
    if (mounted) Navigator.pop(context, true);
  }

  @override
  void dispose() {
    _answerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_verified) {
      return AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: Colors.white,
        title: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.lock, color: Colors.orange, size: 36),
            ),
            const SizedBox(height: 10),
            const Text('Parent Unlock', style: TextStyle(fontSize: 20)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Solve to unlock:',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '$_num1 + $_num2 = ?',
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange,
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _answerController,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: InputDecoration(
                hintText: 'Answer',
                filled: true,
                fillColor: Colors.grey.shade100,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              onSubmitted: (_) => _checkAnswer(),
            ),
            if (_errorMessage != null) ...[
              const SizedBox(height: 10),
              Text(_errorMessage!, style: const TextStyle(color: Colors.red)),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: _checkAnswer,
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            child: const Text('Verify', style: TextStyle(color: Colors.white)),
          ),
        ],
      );
    }

    // Show time selection after verification
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Row(
        children: [
          Icon(Icons.timer, color: Colors.green, size: 28),
          SizedBox(width: 10),
          Text('Set New Time'),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Choose playtime:'),
          const SizedBox(height: 16),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            alignment: WrapAlignment.center,
            children: [15, 30, 45, 60, 90].map((mins) {
              final isSelected = _selectedMinutes == mins;
              return ChoiceChip(
                label: Text('$mins min'),
                selected: isSelected,
                onSelected: (_) => setState(() => _selectedMinutes = mins),
                selectedColor: Colors.green,
                labelStyle: TextStyle(
                  color: isSelected ? Colors.white : Colors.black87,
                  fontWeight: FontWeight.bold,
                ),
              );
            }).toList(),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: _disableTimer,
          child: const Text('Disable Timer', style: TextStyle(color: Colors.grey)),
        ),
        ElevatedButton(
          onPressed: _unlock,
          style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
          child: const Text('Start Timer', style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }
}
