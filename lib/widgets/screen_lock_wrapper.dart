import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math';
import '../services/screen_lock_service.dart';

class ScreenLockWrapper extends StatefulWidget {
  final Widget child;

  const ScreenLockWrapper({super.key, required this.child});

  @override
  State<ScreenLockWrapper> createState() => _ScreenLockWrapperState();
}

class _ScreenLockWrapperState extends State<ScreenLockWrapper>
    with WidgetsBindingObserver {
  final ScreenLockService _lockService = ScreenLockService();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _lockService.addListener(_onLockChange);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _lockService.removeListener(_onLockChange);
    super.dispose();
  }

  void _onLockChange() {
    setState(() {});
  }

  @override
  Future<bool> didPopRoute() async {
    // Intercept back button when lock is enabled
    if (_lockService.isLockEnabled) {
      _showExitDialog();
      return true; // Prevent default back behavior
    }
    return false;
  }

  void _showExitDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const ParentalGateDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_lockService.isLockEnabled,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop && _lockService.isLockEnabled) {
          _showExitDialog();
        }
      },
      child: widget.child,
    );
  }
}

/// Parental gate dialog that requires solving a math problem to exit
class ParentalGateDialog extends StatefulWidget {
  const ParentalGateDialog({super.key});

  @override
  State<ParentalGateDialog> createState() => _ParentalGateDialogState();
}

class _ParentalGateDialogState extends State<ParentalGateDialog> {
  late int _num1;
  late int _num2;
  late int _correctAnswer;
  final _answerController = TextEditingController();
  String? _errorMessage;
  int _attempts = 0;

  @override
  void initState() {
    super.initState();
    _generateNewProblem();
  }

  void _generateNewProblem() {
    final random = Random();
    _num1 = random.nextInt(10) + 10; // 10-19
    _num2 = random.nextInt(10) + 5;  // 5-14
    _correctAnswer = _num1 + _num2;
    _answerController.clear();
    _errorMessage = null;
  }

  void _checkAnswer() {
    final answer = int.tryParse(_answerController.text);
    if (answer == _correctAnswer) {
      Navigator.pop(context, true); // Allow exit
    } else {
      setState(() {
        _attempts++;
        _errorMessage = 'Incorrect. Try again!';
        if (_attempts >= 3) {
          _generateNewProblem();
          _attempts = 0;
          _errorMessage = 'New problem generated. Try again!';
        }
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
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: Colors.white,
      title: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.lock, color: Colors.blue, size: 40),
          ),
          const SizedBox(height: 12),
          const Text(
            'Parental Gate',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.indigo,
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Solve this math problem to exit:',
            style: TextStyle(fontSize: 14, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            decoration: BoxDecoration(
              color: Colors.indigo.shade50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '$_num1 + $_num2 = ?',
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.indigo,
              ),
            ),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _answerController,
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: InputDecoration(
              hintText: 'Enter answer',
              hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 18),
              filled: true,
              fillColor: Colors.grey.shade100,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 16),
            ),
            onSubmitted: (_) => _checkAnswer(),
          ),
          if (_errorMessage != null) ...[
            const SizedBox(height: 12),
            Text(
              _errorMessage!,
              style: const TextStyle(color: Colors.red, fontSize: 14),
            ),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text(
            'Stay in App',
            style: TextStyle(color: Colors.grey.shade600),
          ),
        ),
        ElevatedButton(
          onPressed: _checkAnswer,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.indigo,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child: const Text('Submit', style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }
}

/// Lock toggle button widget to use in settings/home screen
class ScreenLockToggle extends StatefulWidget {
  const ScreenLockToggle({super.key});

  @override
  State<ScreenLockToggle> createState() => _ScreenLockToggleState();
}

class _ScreenLockToggleState extends State<ScreenLockToggle> {
  final ScreenLockService _lockService = ScreenLockService();

  @override
  void initState() {
    super.initState();
    _lockService.addListener(_onLockChange);
  }

  @override
  void dispose() {
    _lockService.removeListener(_onLockChange);
    super.dispose();
  }

  void _onLockChange() {
    setState(() {});
  }

  Future<void> _toggleLock() async {
    if (_lockService.isLockEnabled) {
      // Show parental gate to disable
      final result = await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (_) => const ParentalGateDialog(),
      );
      if (result == true) {
        await _lockService.setLockEnabled(false);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Screen Lock disabled'),
              backgroundColor: Colors.orange,
              duration: Duration(seconds: 2),
            ),
          );
        }
      }
    } else {
      // Enable directly
      await _lockService.setLockEnabled(true);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Screen Lock enabled - Kids cannot exit the app'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEnabled = _lockService.isLockEnabled;

    return GestureDetector(
      onTap: _toggleLock,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isEnabled ? Colors.green.shade100 : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(25),
          border: Border.all(
            color: isEnabled ? Colors.green : Colors.grey.shade400,
            width: 2,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isEnabled ? Icons.lock : Icons.lock_open,
              color: isEnabled ? Colors.green.shade700 : Colors.grey.shade600,
              size: 22,
            ),
            const SizedBox(width: 8),
            Text(
              isEnabled ? 'Lock ON' : 'Lock OFF',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: isEnabled ? Colors.green.shade700 : Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
