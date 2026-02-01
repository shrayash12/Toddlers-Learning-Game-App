import 'package:flutter/material.dart';
import '../services/premium_service.dart';

class PremiumScreen extends StatefulWidget {
  const PremiumScreen({super.key});

  @override
  State<PremiumScreen> createState() => _PremiumScreenState();
}

class _PremiumScreenState extends State<PremiumScreen> {
  final PremiumService _premiumService = PremiumService();
  bool _wasPurchasing = false;
  bool _wasAlreadyPremium = false;

  @override
  void initState() {
    super.initState();
    _wasAlreadyPremium = _premiumService.isPremium;
    _premiumService.addListener(_onPremiumServiceUpdate);
  }

  @override
  void dispose() {
    _premiumService.removeListener(_onPremiumServiceUpdate);
    super.dispose();
  }

  void _onPremiumServiceUpdate() {
    if (mounted) {
      setState(() {});

      // Show error dialog if there's an error
      if (_premiumService.errorMessage != null) {
        _showErrorDialog(_premiumService.errorMessage!);
        _premiumService.clearError();
      }

      // Show success only if we were purchasing and now have premium
      if (_wasPurchasing &&
          !_premiumService.purchasePending &&
          _premiumService.isPremium &&
          !_wasAlreadyPremium) {
        _wasPurchasing = false;
        _showSuccessDialog();
      }

      // Track purchase state
      if (_premiumService.purchasePending) {
        _wasPurchasing = true;
      }
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
            Text('Error'),
          ],
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _handlePurchase();
            },
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green, size: 30),
            SizedBox(width: 10),
            Text('Success!'),
          ],
        ),
        content: const Text('Premium games are now unlocked! Enjoy learning!'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Go back to home
            },
            child: const Text('Start Playing!'),
          ),
        ],
      ),
    );
  }

  String _getPrice() {
    return _premiumService.priceString;
  }

  void _handlePurchase() async {
    if (_premiumService.purchasePending) return;

    await _premiumService.purchasePremium();
  }

  void _handleRestore() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(
        child: CircularProgressIndicator(color: Colors.white),
      ),
    );

    await _premiumService.restorePurchases();

    if (mounted) {
      Navigator.pop(context);

      final isPremium = _premiumService.isPremium;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isPremium
              ? 'Purchase restored successfully!'
              : 'No previous purchase found.',
          ),
          backgroundColor: isPremium ? Colors.green : Colors.orange,
        ),
      );

      if (isPremium) {
        Navigator.pop(context);
      }
    }
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
                      const SizedBox(height: 40),
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
                              _getPrice(),
                              style: const TextStyle(
                                fontSize: 36,
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                              ),
                            ),
                            const Text(
                              'One-time purchase',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 20),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: _premiumService.purchasePending ? null : _handlePurchase,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.orange,
                                  disabledBackgroundColor: Colors.orange.withOpacity(0.5),
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                ),
                                child: _premiumService.purchasePending
                                    ? const SizedBox(
                                        height: 24,
                                        width: 24,
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : const Text(
                                        'Unlock Now',
                                        style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      TextButton(
                        onPressed: _handleRestore,
                        child: const Text(
                          'Restore Purchase',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
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
