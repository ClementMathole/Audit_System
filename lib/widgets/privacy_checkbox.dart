// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import '../views/auth/privacy_policy_screen.dart';

class PrivacyPolicyCheckbox extends StatefulWidget {
  final ValueChanged<bool>? onChanged;
  final bool initialValue;

  const PrivacyPolicyCheckbox({
    // Name: PrivacyPolicyCheckbox
    // Purpose: Constructor for PrivacyPolicyCheckbox
    // Parameters:
    //   - Key? key: The widget key
    //   - ValueChanged<bool>? onChanged: Callback when the checkbox state changes
    //   - bool initialValue: The initial value of the checkbox
    super.key,
    this.onChanged,
    this.initialValue = false,
  });

  @override
  State<PrivacyPolicyCheckbox> createState() => _PrivacyPolicyCheckboxState();
}

class _PrivacyPolicyCheckboxState extends State<PrivacyPolicyCheckbox>
    with SingleTickerProviderStateMixin {
  late bool _accepted;
  late AnimationController _animController;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    // Name: initState
    // Purpose: Initialize the state and animation controllers
    // Parameters: None
    // Returns: None
    super.initState();
    _accepted = widget.initialValue;

    _animController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 200),
    );
    _scaleAnim = Tween<double>(
      begin: 1.0,
      end: 1.06,
    ).animate(CurvedAnimation(parent: _animController, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    // Name: dispose
    // Purpose: Clean up the animation controller
    // Parameters: None
    // Returns: None
    _animController.dispose();
    super.dispose();
  }

  void _toggleAccepted() {
    // Name: _toggleAccepted
    // Purpose: Toggle the accepted terms state
    // Parameters: None
    // Returns: None
    setState(() {
      // Purpose: Update the accepted terms state
      _accepted = !_accepted;
    });
    widget.onChanged?.call(_accepted);
    if (_accepted) {
      // Purpose: Trigger the animation when accepted
      _animController.forward().then((_) => _animController.reverse());
    }
  }

  void _openPolicy() {
    // Name: _openPolicy
    // Purpose: Navigate to the Privacy Policy screen
    // Parameters: None
    // Returns: None
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => PrivacyPolicyScreen()));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: _toggleAccepted,
          child: ScaleTransition(
            scale: _scaleAnim,
            child: Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.blue, width: 2),
                borderRadius: BorderRadius.circular(6),
                color:
                    _accepted
                        ? Colors.blue.withOpacity(0.1)
                        : Colors.transparent,
              ),
              child:
                  _accepted
                      ? Icon(
                        Icons.check,
                        size: 18,
                        color: theme.colorScheme.primary,
                      )
                      : SizedBox.shrink(),
            ),
          ),
        ),
        SizedBox(width: 12),
        Expanded(
          child: GestureDetector(
            onTap: _toggleAccepted,
            child: RichText(
              text: TextSpan(
                style: theme.textTheme.bodyMedium?.copyWith(height: 1.3),
                children: [
                  TextSpan(text: 'I agree to the '),
                  TextSpan(
                    text: 'Privacy Policy',
                    style: TextStyle(
                      decoration: TextDecoration.underline,
                      fontWeight: FontWeight.w600,
                      color: Colors.blue,
                    ),
                    recognizer: TapGestureRecognizer()..onTap = _openPolicy,
                  ),
                  TextSpan(text: ' and '),
                  TextSpan(
                    text: 'Terms of Service',
                    style: TextStyle(
                      decoration: TextDecoration.underline,
                      fontWeight: FontWeight.w600,
                      color: Colors.blue,
                    ),
                    recognizer:
                        TapGestureRecognizer()..onTap = () => _openPolicy(),
                  ),
                  TextSpan(text: '.'),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
