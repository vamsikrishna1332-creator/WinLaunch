import 'package:fluent_ui/fluent_ui.dart';
import 'package:url_launcher/url_launcher.dart';

/// Opens the official ChatGPT sign-in in the user's default browser.
/// LaunchDesk never collects OpenAI passwords, cookies or tokens.
class ChatGptScreen extends StatefulWidget {
  const ChatGptScreen({super.key});

  @override
  State<ChatGptScreen> createState() => _ChatGptScreenState();
}

class _ChatGptScreenState extends State<ChatGptScreen> {
  String? _error;
  bool _opening = false;

  Future<void> _openChatGpt() async {
    setState(() {
      _opening = true;
      _error = null;
    });
    try {
      final opened = await launchUrl(
        Uri.parse('https://chatgpt.com/'),
        mode: LaunchMode.externalApplication,
      );
      if (!opened && mounted) {
        setState(() => _error = 'Could not open your default browser.');
      }
    } catch (error) {
      if (mounted) setState(() => _error = 'Browser launch failed: $error');
    } finally {
      if (mounted) setState(() => _opening = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldPage(
      header: const PageHeader(title: Text('ChatGPT')),
      content: Center(
        child: Container(
          width: 500,
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: const Color(0xFF111D2B),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFF26344B)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('ChatGPT', style: TextStyle(
                fontSize: 26, fontWeight: FontWeight.w700)),
              const SizedBox(height: 12),
              const Text(
                'Use your own ChatGPT account in the official website. '
                'LaunchDesk does not ask for your ChatGPT password or API key.',
              ),
              const SizedBox(height: 20),
              FilledButton(
                onPressed: _opening ? null : _openChatGpt,
                child: Text(_opening ? 'Opening...' : 'Open ChatGPT / Sign in'),
              ),
              if (_error != null) ...[
                const SizedBox(height: 12),
                Text(_error!, style: const TextStyle(color: Colors.red)),
              ],
              const SizedBox(height: 16),
              const Text(
                'Note: ChatGPT account login does not authorize native API '
                'chat inside third-party apps. This opens the official site.',
                style: TextStyle(fontSize: 12, color: Color(0xFF9DAEC6)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
