import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math';
import '../services/billing_service.dart';

class PremiumScreen extends StatefulWidget {
  const PremiumScreen({super.key});

  @override
  State<PremiumScreen> createState() => _PremiumScreenState();
}

class _PremiumScreenState extends State<PremiumScreen> {
  final BillingService _billingService = BillingService();

  @override
  void initState() {
    super.initState();
    _billingService.addListener(_onBillingUpdate);

    // Set up callbacks
    _billingService.onPurchaseSuccess = _onPurchaseSuccess;
    _billingService.onPurchaseError = _onPurchaseError;
  }

  @override
  void dispose() {
    _billingService.removeListener(_onBillingUpdate);
    _billingService.onPurchaseSuccess = null;
    _billingService.onPurchaseError = null;
    super.dispose();
  }

  void _onBillingUpdate() {
    if (mounted) {
      setState(() {});
    }
  }

  void _onPurchaseSuccess() {
    if (mounted) {
      _showSuccessDialog();
    }
  }

  void _onPurchaseError(String error) {
    if (mounted) {
      _showErrorDialog(error);
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.error_outline, color: Colors.red, size: 30),
            SizedBox(width: 10),
            Text('Purchase Failed'),
          ],
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _showParentalGate();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            child: const Text('Try Again', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check_circle, color: Colors.green, size: 60),
            ),
            const SizedBox(height: 16),
            const Text('Purchase Successful!'),
          ],
        ),
        content: const Text(
          'Premium games are now unlocked!\nEnjoy learning with your little one!',
          textAlign: TextAlign.center,
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context); // Close dialog
                Navigator.pop(context); // Go back to home
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: const Text(
                'Start Playing!',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showParentalGate() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const ParentalGateDialog(),
    ).then((verified) {
      if (verified == true) {
        _billingService.purchasePremium();
      }
    });
  }

  void _restorePurchases() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const ParentalGateDialog(),
    ).then((verified) {
      if (verified == true) {
        _billingService.restorePurchases();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFFFD700), Color(0xFFFF8C00)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back, color: Colors.white, size: 30),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.star,
                        size: 100,
                        color: Colors.white,
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Unlock Premium Games!',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Get access to 12 amazing educational games',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white.withOpacity(0.9),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 30),

                      // Google Play badge
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.play_arrow, color: Colors.white, size: 28),
                            const SizedBox(width: 8),
                            const Text(
                              'Google Play Purchase',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 30),
                      _FeatureItem(
                        icon: Icons.spellcheck,
                        title: 'Spelling Game',
                        description: 'Learn to spell words letter by letter',
                      ),
                      _FeatureItem(
                        icon: Icons.calculate,
                        title: 'Math Game',
                        description: 'Fun addition and subtraction practice',
                      ),
                      _FeatureItem(
                        icon: Icons.extension,
                        title: 'Puzzle Game',
                        description: 'Arrange pieces to complete pictures',
                      ),
                      _FeatureItem(
                        icon: Icons.record_voice_over,
                        title: 'Phonics Game',
                        description: 'Learn letter sounds and pronunciation',
                      ),
                      _FeatureItem(
                        icon: Icons.visibility,
                        title: 'Hide & Seek',
                        description: 'Find hidden animals behind objects',
                      ),
                      _FeatureItem(
                        icon: Icons.route,
                        title: 'Maze Fun',
                        description: 'Navigate through fun mazes',
                      ),
                      _FeatureItem(
                        icon: Icons.timeline,
                        title: 'Connect the Dots',
                        description: 'Connect dots to reveal pictures',
                      ),
                      _FeatureItem(
                        icon: Icons.compare,
                        title: 'Find Differences',
                        description: 'Spot the differences between pictures',
                      ),
                      _FeatureItem(
                        icon: Icons.gesture,
                        title: 'Draw Lines',
                        description: 'Practice drawing different line types',
                      ),
                      _FeatureItem(
                        icon: Icons.child_care,
                        title: 'Potty Training',
                        description: 'Fun potty training encouragement',
                      ),
                      _FeatureItem(
                        icon: Icons.category,
                        title: 'Organizing Game',
                        description: 'Sort and organize objects into groups',
                      ),
                      _FeatureItem(
                        icon: Icons.brush,
                        title: 'Coloring Game',
                        description: 'Color fun sketches and pictures',
                      ),
                      const SizedBox(height: 40),
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 10,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            const Text(
                              'Premium Bundle',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.orange,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _billingService.displayPrice,
                              style: const TextStyle(
                                fontSize: 42,
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                              ),
                            ),
                            const Text(
                              'One-time purchase \u2022 Lifetime access',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 20),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: _billingService.purchasePending ? null : _showParentalGate,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.orange,
                                  disabledBackgroundColor: Colors.orange.withOpacity(0.5),
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                ),
                                child: _billingService.purchasePending
                                    ? const SizedBox(
                                        height: 24,
                                        width: 24,
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : const Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(Icons.lock_open, color: Colors.white),
                                          SizedBox(width: 8),
                                          Text(
                                            'Unlock Now',
                                            style: TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ],
                                      ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            TextButton(
                              onPressed: _billingService.purchasePending ? null : _restorePurchases,
                              child: const Text(
                                'Restore Previous Purchase',
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Secure payment badge
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.security, color: Colors.white.withOpacity(0.8), size: 18),
                          const SizedBox(width: 6),
                          Text(
                            'Secure Payment via Google Play',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.8),
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FeatureItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const _FeatureItem({
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Icon(icon, color: Colors.white, size: 30),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Dialog with parental verification before purchase
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

  @override
  void initState() {
    super.initState();
    _generateNewProblem();
  }

  void _generateNewProblem() {
    final random = Random();
    _num1 = random.nextInt(15) + 10; // 10-24
    _num2 = random.nextInt(10) + 5;  // 5-14
    _correctAnswer = _num1 + _num2;
    _answerController.clear();
    _errorMessage = null;
  }

  void _checkAnswer() {
    final answer = int.tryParse(_answerController.text);
    if (answer == _correctAnswer) {
      Navigator.pop(context, true);
    } else {
      setState(() {
        _errorMessage = 'Incorrect! Try again.';
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
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
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
            'Solve to continue:',
            style: TextStyle(color: Colors.grey, fontSize: 13),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.orange.shade50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '$_num1 + $_num2 = ?',
              style: const TextStyle(
                fontSize: 28,
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
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: InputDecoration(
              hintText: 'Answer',
              hintStyle: TextStyle(color: Colors.grey.shade400),
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
}
