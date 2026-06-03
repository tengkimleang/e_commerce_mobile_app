import 'dart:async';

import 'package:dio/dio.dart';
import 'package:e_commerce_mobile_app/core/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:e_commerce_mobile_app/l10n/generated/app_localizations.dart';

/// Screen that guides the user through linking their Telegram account as an
/// OTP fallback channel.
///
/// Flow:
///   1. App calls `/auth/telegram/link-request` → backend returns a
///      short-lived one-time [code] and the bot's [botUsername].
///   2. User opens Telegram, finds the bot, and sends the code as a message.
///   3. This screen polls `/auth/telegram/link-status` every 3 seconds.
///   4. When the backend confirms the link, the screen shows success and pops
///      with `true`. On timeout (5 min) it pops with `false`.
class TelegramLinkView extends StatefulWidget {
  const TelegramLinkView({super.key});

  @override
  State<TelegramLinkView> createState() => _TelegramLinkViewState();
}

class _TelegramLinkViewState extends State<TelegramLinkView> {
  static const _pollInterval = Duration(seconds: 3);
  static const _timeoutSeconds = 300; // 5 minutes
  static const _accent = Color(0xFFEC407A);

  final AuthService _authService = AuthService();

  bool _isLoading = true;
  bool _isLinked = false;
  bool _isTimedOut = false;
  String _code = '';
  String _botUsername = '';
  String _errorMessage = '';

  Timer? _pollTimer;
  int _elapsedSeconds = 0;

  @override
  void initState() {
    super.initState();
    _requestCode();
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    super.dispose();
  }

  Future<void> _requestCode() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final result = await _authService.requestTelegramLinkCode();
      if (!mounted) return;

      final errorCode = (result['errorCode'] ?? '').toString().trim();
      final success = result['success'] == true;

      if (errorCode.isNotEmpty || !success) {
        final isAuthError =
            errorCode == 'AUTH401' ||
            errorCode == 'HTTP401' ||
            errorCode == 'UNAUTHORIZED';
        final msg = isAuthError
            ? 'Your session has expired. Please log in again.'
            : (result['errorMsg'] ?? '').toString().trim();
        setState(() {
          _isLoading = false;
          _errorMessage = msg.isEmpty
              ? 'Failed to request linking code. Please try again.'
              : msg;
        });
        return;
      }

      final data = result['data'] is Map
          ? Map<String, dynamic>.from(result['data'] as Map)
          : result;

      final code = (data['code'] ?? result['code'] ?? '').toString().trim();
      final botUsername = (data['botUsername'] ?? result['botUsername'] ?? '')
          .toString()
          .trim();

      if (code.isEmpty) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Server returned an empty code. Please try again.';
        });
        return;
      }

      setState(() {
        _isLoading = false;
        _code = code;
        _botUsername = botUsername;
        _elapsedSeconds = 0;
        _isTimedOut = false;
      });

      _startPolling();
    } on DioException catch (e) {
      if (!mounted) return;
      final isNetwork =
          e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout;
      setState(() {
        _isLoading = false;
        _errorMessage = isNetwork
            ? 'No internet connection. Please check your network.'
            : 'Unable to reach the server. Please try again.';
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  void _startPolling() {
    _pollTimer?.cancel();
    _pollTimer = Timer.periodic(_pollInterval, (_) async {
      if (!mounted) return;
      _elapsedSeconds += _pollInterval.inSeconds;

      if (_elapsedSeconds >= _timeoutSeconds) {
        _pollTimer?.cancel();
        if (mounted) setState(() => _isTimedOut = true);
        return;
      }

      try {
        final result = await _authService.checkTelegramLinkStatus();
        if (!mounted) return;
        final linked = result['linked'] == true;
        if (linked) {
          _pollTimer?.cancel();
          setState(() => _isLinked = true);
        }
      } catch (_) {
        // Swallow polling errors silently; the timer will retry.
      }
    });
  }

  Future<void> _openTelegram() async {
    final username = _botUsername.replaceFirst('@', '');
    if (username.isEmpty) return;
    final uri = Uri.parse('https://t.me/ChipmongSMSbot');
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not open Telegram. Please try manually.'),
          ),
        );
      }
    }
  }

  void _copyCode() {
    Clipboard.setData(ClipboardData(text: _code));
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Code copied to clipboard')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.chevron_left, size: 28, color: Colors.black87),
          onPressed: () => Navigator.of(context).pop(false),
        ),
        title: const Text(
          'Link Telegram',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: _buildBody(),
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: _accent));
    }

    if (_errorMessage.isNotEmpty) {
      return _ErrorState(message: _errorMessage, onRetry: _requestCode);
    }

    if (_isLinked) {
      return _SuccessState(onDone: () => Navigator.of(context).pop(true));
    }

    if (_isTimedOut) {
      return _TimeoutState(onRetry: _requestCode);
    }

    return _LinkingInstructions(
      code: _code,
      botUsername: _botUsername,
      onOpenTelegram: _openTelegram,
      onCopyCode: _copyCode,
    );
  }
}

// ── Sub-widgets ──────────────────────────────────────────────────────────────

class _LinkingInstructions extends StatelessWidget {
  const _LinkingInstructions({
    required this.code,
    required this.botUsername,
    required this.onOpenTelegram,
    required this.onCopyCode,
  });

  final String code;
  final String botUsername;
  final VoidCallback onOpenTelegram;
  final VoidCallback onCopyCode;

  @override
  Widget build(BuildContext context) {
    const accent = Color(0xFFEC407A);
    final displayBot = botUsername.isNotEmpty
        ? (botUsername.startsWith('@') ? botUsername : '@$botUsername')
        : 'the bot';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Center(
          child: Icon(Icons.send, size: 56, color: Color(0xFF0088CC)),
        ),
        const SizedBox(height: 20),
        const Text(
          'Set up Telegram backup',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 8),
        Text(
          'If SMS delivery fails, your OTP will be sent via Telegram instead.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 14, color: Colors.grey[600], height: 1.4),
        ),
        const SizedBox(height: 32),
        _StepTile(
          number: '1',
          text: 'Open Telegram and start a chat with $displayBot',
        ),
        const SizedBox(height: 16),
        _StepTile(
          number: '2',
          text: 'Send the code below as a message to the bot',
        ),
        const SizedBox(height: 24),
        // Code display card
        GestureDetector(
          onTap: onCopyCode,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F7FB),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFE0E0E0)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  code,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 6,
                    color: Color(0xFF1D1B22),
                  ),
                ),
                const SizedBox(width: 12),
                const Icon(Icons.copy_rounded, size: 20, color: Colors.grey),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        Center(
          child: Text(
            'Tap to copy',
            style: TextStyle(fontSize: 12, color: Colors.grey[500]),
          ),
        ),
        const SizedBox(height: 24),
        _StepTile(
          number: '3',
          text: 'Wait here — this screen will update automatically once linked',
        ),
        const Spacer(),
        SizedBox(
          height: 52,
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0088CC),
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            icon: const Icon(Icons.send),
            label: Text('Open $displayBot on Telegram'),
            onPressed: onOpenTelegram,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(color: accent, strokeWidth: 2),
            ),
            const SizedBox(width: 10),
            Text(
              'Waiting for confirmation…',
              style: TextStyle(fontSize: 13, color: Colors.grey[600]),
            ),
          ],
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}

class _StepTile extends StatelessWidget {
  const _StepTile({required this.number, required this.text});
  final String number;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: const BoxDecoration(
            color: Color(0xFFEC407A),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              number,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 13,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              text,
              style: const TextStyle(fontSize: 14, color: Color(0xFF1D1B22)),
            ),
          ),
        ),
      ],
    );
  }
}

class _SuccessState extends StatelessWidget {
  const _SuccessState({required this.onDone});
  final VoidCallback onDone;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Icon(
          Icons.check_circle_rounded,
          size: 72,
          color: Color(0xFF0D9A58),
        ),
        const SizedBox(height: 20),
        const Text(
          'Telegram Linked!',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 8),
        Text(
          'Your Telegram account is now set as the OTP fallback channel.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 14, color: Colors.grey[600], height: 1.4),
        ),
        const SizedBox(height: 40),
        SizedBox(
          height: 52,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEC407A),
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            onPressed: onDone,
            child: Text(
              AppLocalizations.of(context)!.done,
              style: TextStyle(fontSize: 16),
            ),
          ),
        ),
      ],
    );
  }
}

class _TimeoutState extends StatelessWidget {
  const _TimeoutState({required this.onRetry});
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Icon(Icons.timer_off_rounded, size: 64, color: Colors.orange),
        const SizedBox(height: 20),
        const Text(
          'Code Expired',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 8),
        Text(
          'The linking code expired. Request a new one and try again.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 14, color: Colors.grey[600], height: 1.4),
        ),
        const SizedBox(height: 40),
        SizedBox(
          height: 52,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEC407A),
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            onPressed: onRetry,
            child: const Text('Get New Code', style: TextStyle(fontSize: 16)),
          ),
        ),
      ],
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Icon(
          Icons.error_outline_rounded,
          size: 64,
          color: Color(0xFFEC407A),
        ),
        const SizedBox(height: 20),
        const Text(
          'Something Went Wrong',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 8),
        Text(
          message,
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 14, color: Colors.grey[600], height: 1.4),
        ),
        const SizedBox(height: 40),
        SizedBox(
          height: 52,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEC407A),
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            onPressed: onRetry,
            child: const Text('Try Again', style: TextStyle(fontSize: 16)),
          ),
        ),
      ],
    );
  }
}
