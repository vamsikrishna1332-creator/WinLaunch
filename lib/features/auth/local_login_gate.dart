import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:fluent_ui/fluent_ui.dart';
import '../../core/database/database_helper.dart';

/// Single-device workspace lock. This is NOT a Microsoft/ChatGPT login.
/// Existing LaunchDesk data remains in the existing local SQLite workspace.
class LocalLoginGate extends StatefulWidget {
  final Widget Function(String userName, VoidCallback signOut) builder;
  const LocalLoginGate({super.key, required this.builder});

  @override
  State<LocalLoginGate> createState() => _LocalLoginGateState();
}

class _LocalLoginGateState extends State<LocalLoginGate> {
  final _name = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  bool _loading = true;
  bool _busy = false;
  bool _registered = false;
  String? _signedIn;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final db = await DatabaseHelper.instance.database;
      await db.execute('CREATE TABLE IF NOT EXISTS local_workspace_lock ('
          'id INTEGER PRIMARY KEY CHECK(id = 1), '
          'display_name TEXT NOT NULL, salt TEXT NOT NULL, verifier TEXT NOT NULL)');
      final records = await db.query('local_workspace_lock', limit: 1);
      if (!mounted) return;
      setState(() {
        _registered = records.isNotEmpty;
        if (_registered) _name.text = records.first['display_name'] as String;
        _loading = false;
      });
    } catch (e) {
      if (mounted) setState(() { _loading = false; _error = 'Could not load local account: $e'; });
    }
  }

  Future<void> _submit() async {
    if (_busy) return;
    final pass = _password.text;
    if (pass.isEmpty) { setState(() => _error = 'Enter your password.'); return; }
    if (!_registered && (pass.length < 8 || pass != _confirm.text || _name.text.trim().isEmpty)) {
      setState(() => _error = 'Enter a name and matching password of at least 8 characters.');
      return;
    }
    setState(() { _busy = true; _error = null; });
    try {
      final db = await DatabaseHelper.instance.database;
      if (!_registered) {
        final rng = Random.secure();
        final salt = base64Encode(List<int>.generate(16, (_) => rng.nextInt(256)));
        final verifier = await compute(_pbkdf2Verifier, [pass, salt]);
        await db.insert('local_workspace_lock', {
          'id': 1, 'display_name': _name.text.trim(),
          'salt': salt, 'verifier': verifier,
        });
        if (!mounted) return;
        setState(() { _registered = true; _signedIn = _name.text.trim(); });
      } else {
        final rows = await db.query('local_workspace_lock', limit: 1);
        if (rows.isEmpty) throw StateError('Local account not found.');
        final expected = rows.first['verifier'] as String;
        final actual = await compute(
          _pbkdf2Verifier, [pass, rows.first['salt'] as String]);
        if (!_constantTimeEquals(actual, expected)) {
          if (mounted) setState(() => _error = 'Incorrect password.');
          return;
        }
        if (mounted) setState(() => _signedIn = rows.first['display_name'] as String);
      }
    } catch (e) {
      if (mounted) setState(() => _error = 'Unable to sign in: $e');
    } finally {
      _password.clear(); _confirm.clear();
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  void dispose() {
    _name.dispose(); _password.dispose(); _confirm.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_signedIn != null) {
      return widget.builder(_signedIn!, () => setState(() => _signedIn = null));
    }
    return Container(
      color: const Color(0xFF091522),
      alignment: Alignment.center,
      child: SizedBox(
        width: 420,
        child: Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: const Color(0xFF111F2E),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFF2B3551)),
          ),
          child: _loading
              ? const Center(child: ProgressRing())
              : Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Icon(FluentIcons.lock, size: 30,
                        color: Color(0xFF8C75FF)),
                    const SizedBox(height: 14),
                    const Text('LaunchDesk', style: TextStyle(
                        fontSize: 29, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 7),
                    Text(_registered ? 'Unlock your local workspace'
                        : 'Create your local workspace login',
                        style: const TextStyle(color: Color(0xFFA8B4CB))),
                    const SizedBox(height: 26),
                    if (!_registered) ...[
                      const Text('Display name'),
                      const SizedBox(height: 6),
                      TextBox(controller: _name, placeholder: 'Your name'),
                      const SizedBox(height: 14),
                    ] else ...[
                      Text(_name.text, style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 14),
                    ],
                    const Text('Password'),
                    const SizedBox(height: 6),
                    PasswordBox(
                      controller: _password,
                      placeholder: 'Local workspace password',
                      onSubmitted: (_) => _submit(),
                    ),
                    if (!_registered) ...[
                      const SizedBox(height: 14),
                      const Text('Confirm password'),
                      const SizedBox(height: 6),
                      PasswordBox(controller: _confirm,
                          placeholder: 'Repeat password'),
                    ],
                    if (_error != null) ...[
                      const SizedBox(height: 13),
                      Text(_error!, style: const TextStyle(color: Color(0xFFFF8787))),
                    ],
                    const SizedBox(height: 22),
                    FilledButton(
                      onPressed: _busy ? null : _submit,
                      child: Text(_busy ? 'Checking...' :
                          _registered ? 'Unlock LaunchDesk' : 'Create account'),
                    ),
                    const SizedBox(height: 15),
                    const Text(
                      'Local-device login only. No cloud account or password '
                      'recovery is provided; keep a safe backup of your data.',
                      style: TextStyle(fontSize: 11, color: Color(0xFF8999B1)),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

// PBKDF2-HMAC-SHA256, single 256-bit block, 120000 iterations.
// Runs on a worker isolate using compute so it does not freeze the UI.
String _pbkdf2Verifier(List<String> args) {
  final mac = Hmac(sha256, utf8.encode(args[0]));
  final salt = base64Decode(args[1]);
  var last = mac.convert([...salt, 0, 0, 0, 1]).bytes;
  final result = List<int>.from(last);
  for (var round = 1; round < 120000; round++) {
    last = mac.convert(last).bytes;
    for (var i = 0; i < result.length; i++) {
      result[i] ^= last[i];
    }
  }
  return base64Encode(result);
}

bool _constantTimeEquals(String a, String b) {
  final aa = utf8.encode(a);
  final bb = utf8.encode(b);
  var different = aa.length ^ bb.length;
  for (var i = 0; i < aa.length; i++) {
    different |= aa[i] ^ bb[i % bb.length];
  }
  return different == 0;
}
