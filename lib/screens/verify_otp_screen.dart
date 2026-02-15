import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'auth_screen.dart';
import 'map_order_screen.dart';
import '../services/user_service.dart';
import '../widgets/congo_flag.dart';

/// Formatter qui gère le collage d'un code OTP complet dans une case.
class _OtpPasteFormatter extends TextInputFormatter {
  final int index;
  final int length;
  final List<TextEditingController> controllers;
  final List<FocusNode> focusNodes;
  final VoidCallback? onComplete;

  _OtpPasteFormatter(this.index, this.length, this.controllers, this.focusNodes, this.onComplete);

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = newValue.text.replaceAll(RegExp(r'\D'), '');
    if (digits.length > 1) {
      for (int i = 0; i < length && i < digits.length; i++) {
        if (i != index) controllers[i].text = digits[i];
      }
      final myDigit = index < digits.length ? digits[index] : '';
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (digits.length >= length) {
          focusNodes[length - 1].requestFocus();
          onComplete?.call();
        } else {
          focusNodes[digits.length.clamp(0, length - 1)].requestFocus();
        }
      });
      return TextEditingValue(
        text: myDigit,
        selection: TextSelection.collapsed(offset: myDigit.length),
      );
    }
    if (newValue.text.length <= 1 && RegExp(r'^\d*$').hasMatch(newValue.text)) {
      return newValue;
    }
    return oldValue;
  }
}

/// Écran de saisie du code OTP envoyé par email ou SMS après inscription
class VerifyOtpScreen extends StatefulWidget {
  final String email;
  final String? phone;
  final String name;
  final String validPhone;
  final String selectedGender;
  final List<String> selectedLanguages;

  const VerifyOtpScreen({
    super.key,
    required this.email,
    this.phone,
    this.name = 'Utilisateur Yadeli',
    this.validPhone = '+242 06 444 22 11',
    this.selectedGender = 'homme',
    this.selectedLanguages = const ['FR'],
  });

  @override
  State<VerifyOtpScreen> createState() => _VerifyOtpScreenState();
}

class _VerifyOtpScreenState extends State<VerifyOtpScreen> {
  static const int _otpLength = 8;
  static const int _otpExpirySeconds = 120;
  static const int _resendCooldownSeconds = 30;
  late final List<TextEditingController> _controllers = List.generate(_otpLength, (_) => TextEditingController());
  late final List<FocusNode> _focusNodes = List.generate(_otpLength, (_) => FocusNode());
  bool _isLoading = false;
  bool _usePhone = false;
  int _secondsRemaining = _otpExpirySeconds;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer({bool isResend = false}) {
    _secondsRemaining = isResend ? _resendCooldownSeconds : _otpExpirySeconds;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        setState(() => _secondsRemaining--);
      } else {
        timer.cancel();
        _timer = null;
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (final c in _controllers) c.dispose();
    for (final f in _focusNodes) f.dispose();
    super.dispose();
  }

  String get _code => _controllers.map((c) => c.text).join();

  Future<void> _verify() async {
    final code = _code;
    if (code.length != _otpLength) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Entrez les $_otpLength chiffres du code"), backgroundColor: Colors.orange, behavior: SnackBarBehavior.floating),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final supabase = Supabase.instance.client;
      if (_usePhone && widget.phone != null && widget.phone!.isNotEmpty) {
        await supabase.auth.verifyOTP(phone: widget.validPhone, token: code, type: OtpType.signup);
      } else {
        await supabase.auth.verifyOTP(email: widget.email, token: code, type: OtpType.signup);
      }
      await UserService.saveUser(
        name: widget.name,
        phone: widget.validPhone,
        gender: widget.selectedGender,
        email: widget.email,
        languages: widget.selectedLanguages,
      );
      if (mounted) {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const MapOrderScreen()));
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Compte vérifié ! Bienvenue sur Yadeli."), backgroundColor: Colors.green, behavior: SnackBarBehavior.floating),
        );
      }
    } on AuthException catch (e) {
      if (mounted) {
        final msg = e.message.toLowerCase();
        final hint = (msg.contains('expired') || msg.contains('expiré') || msg.contains('invalid'))
            ? ' Cliquez sur « Renvoyer le code » pour en obtenir un nouveau.'
            : '';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${e.message}$hint'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Erreur: ${e.toString().split('\n').first}"), backgroundColor: Colors.red, behavior: SnackBarBehavior.floating),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _resendCode() async {
    setState(() => _isLoading = true);
    try {
      final supabase = Supabase.instance.client;
      if (_usePhone && widget.phone != null && widget.phone!.isNotEmpty) {
        await supabase.auth.resend(phone: widget.validPhone, type: OtpType.signup);
      } else {
        await supabase.auth.resend(email: widget.email, type: OtpType.signup);
      }
      if (mounted) {
        _startTimer(isResend: true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Nouveau code envoyé à ${_usePhone ? widget.validPhone : widget.email}"), backgroundColor: Colors.green, behavior: SnackBarBehavior.floating),
        );
      }
    } on AuthException catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message), backgroundColor: Colors.red, behavior: SnackBarBehavior.floating));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final target = _usePhone && widget.phone != null && widget.phone!.isNotEmpty ? widget.validPhone : widget.email;
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const SizedBox(height: 40),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.local_taxi, size: 50, color: Colors.green),
                  const SizedBox(width: 12),
                  CongoFlag(width: 40, height: 28),
                ],
              ),
              const SizedBox(height: 24),
              Text("Vérification", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.green[800])),
              const SizedBox(height: 12),
              Text(
                "Entrez le code à $_otpLength chiffres envoyé à\n$target",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 15, color: Colors.grey[700]),
              ),
              // Option SMS : affichée si numéro fourni (nécessite config Supabase Phone Auth)
              if (widget.phone != null && widget.phone!.isNotEmpty && widget.validPhone != '+242 06 444 22 11') ...[
                const SizedBox(height: 12),
                TextButton.icon(
                  onPressed: _isLoading ? null : () => setState(() => _usePhone = !_usePhone),
                  icon: Icon(Icons.swap_horiz, size: 18, color: Colors.green[700]),
                  label: Text(_usePhone ? "Utiliser l'email" : "Utiliser le SMS", style: TextStyle(color: Colors.green[700])),
                ),
              ],
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: _secondsRemaining > 0 ? Colors.orange[50] : Colors.green[50],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _secondsRemaining > 0 ? Icons.timer_outlined : Icons.check_circle_outline,
                      size: 22,
                      color: _secondsRemaining > 0 ? Colors.orange[700] : Colors.green[700],
                    ),
                    const SizedBox(width: 10),
                    Text(
                      _secondsRemaining > 0
                          ? "Code expire dans : ${(_secondsRemaining ~/ 60).toString().padLeft(2, '0')}:${(_secondsRemaining % 60).toString().padLeft(2, '0')}"
                          : "Code expiré. Cliquez sur « Renvoyer » pour un nouveau code.",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: _secondsRemaining > 0 ? Colors.orange[800] : Colors.green[800],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              LayoutBuilder(
                builder: (context, constraints) {
                  final availableWidth = constraints.maxWidth.isFinite ? constraints.maxWidth : MediaQuery.of(context).size.width - 48;
                  final gap = 8.0;
                  final boxSize = ((availableWidth - 3 * gap) / 4).clamp(42.0, 52.0);
                  return Wrap(
                    alignment: WrapAlignment.center,
                    spacing: gap,
                    runSpacing: gap,
                    children: List.generate(_otpLength, (i) {
                      return SizedBox(
                        width: boxSize,
                        height: 56,
                        child: TextField(
                          controller: _controllers[i],
                          focusNode: _focusNodes[i],
                          keyboardType: TextInputType.number,
                          textAlign: TextAlign.center,
                          maxLength: 1,
                          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.green[900]),
                          decoration: InputDecoration(
                            counterText: '',
                            filled: true,
                            fillColor: Colors.grey[50],
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.green[700]!, width: 2)),
                          ),
                          inputFormatters: [
                            _OtpPasteFormatter(i, _otpLength, _controllers, _focusNodes, () {
                              if (_code.length == _otpLength) _verify();
                            }),
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          onChanged: (v) {
                            if (v.isNotEmpty && i < _otpLength - 1) _focusNodes[i + 1].requestFocus();
                            if (v.isEmpty && i > 0) _focusNodes[i - 1].requestFocus();
                            if (_code.length == _otpLength) _verify();
                          },
                        ),
                      );
                    }),
                  );
                },
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _verify,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green[700],
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text("Vérifier", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                ),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: (_isLoading || _secondsRemaining > 0) ? null : _resendCode,
                child: Text(
                  _secondsRemaining > 0 ? "Renvoyer le code (${_secondsRemaining}s)" : "Renvoyer le code",
                  style: TextStyle(color: _secondsRemaining > 0 ? Colors.grey : Colors.green[700]),
                ),
              ),
              const SizedBox(height: 24),
              TextButton(
                onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const AuthScreen())),
                child: const Text("Retour à l'inscription"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
