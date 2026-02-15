import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart' as picker;
import 'package:permission_handler/permission_handler.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/user_service.dart';
import '../services/locale_service.dart';

/// Assistance IA en chat — images, reconnaissance vocale, renvoi vers agent
class AiChatSupportScreen extends StatefulWidget {
  const AiChatSupportScreen({super.key});

  @override
  State<AiChatSupportScreen> createState() => _AiChatSupportScreenState();
}

class _AiChatSupportScreenState extends State<AiChatSupportScreen> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();
  final List<_ChatMessage> _messages = [];
  bool _loading = false;
  bool _agentRequested = false;
  bool _isListening = false;
  final SpeechToText _speech = SpeechToText();

  String get _localeCode => LocaleService.instance.locale.code;

  @override
  void initState() {
    super.initState();
    _messages.add(_ChatMessage(
      text: "Bonjour ! Je suis l'assistant IA Yadeli. Comment puis-je vous aider ?",
      isUser: false,
      time: DateTime.now(),
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _sendMessage({String? textOverride, List<int>? imageBytes}) async {
    final text = textOverride ?? _controller.text.trim();
    if (text.isEmpty && imageBytes == null) return;
    if (textOverride == null) _controller.clear();
    setState(() {
      _messages.add(_ChatMessage(text: text, isUser: true, time: DateTime.now(), imageBytes: imageBytes));
      _loading = true;
    });
    _scrollToBottom();

    await Future.delayed(const Duration(milliseconds: 800));

    final response = _getAiResponse(text, hasImage: imageBytes != null);

    if (!mounted) return;
    setState(() {
      _messages.add(_ChatMessage(text: response, isUser: false, time: DateTime.now()));
      _loading = false;
    });
    _scrollToBottom();
  }

  Future<void> _addImage() async {
    try {
      final ip = picker.ImagePicker();
      final xFile = await ip.pickImage(source: picker.ImageSource.gallery, maxWidth: 600);
      if (xFile != null && mounted) {
        final bytes = await xFile.readAsBytes();
        await _sendMessage(textOverride: "[Image jointe]", imageBytes: bytes);
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Erreur image: $e"), backgroundColor: Colors.red, behavior: SnackBarBehavior.floating));
    }
  }

  Future<void> _startListening() async {
    if (_isListening) return;
    if (!mounted) return;

    // Demander la permission micro sur Android/iOS
    if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
      final status = await Permission.microphone.request();
      if (!status.isGranted) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Autorisation micro refusée. Activez-la dans les paramètres pour utiliser la reconnaissance vocale."),
              backgroundColor: Colors.orange,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
        return;
      }
    }

    final available = await _speech.initialize();
    if (!mounted) return;
    if (!available) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Reconnaissance vocale non disponible sur ce périphérique. Tapez votre message."),
          backgroundColor: Colors.orange,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => _isListening = true);
    final localeId = _localeCode == 'fr' ? 'fr_FR' : _localeCode == 'en' ? 'en_US' : 'fr_FR';
    await _speech.listen(
      onResult: (r) {
        if (mounted) {
          final text = r.recognizedWords;
          if (text.isNotEmpty) {
            _controller.text = text;
            setState(() {});
          }
        }
      },
      localeId: localeId,
      listenFor: const Duration(seconds: 30),
      pauseFor: const Duration(seconds: 5),
    );
  }

  Future<void> _stopListening() async {
    await _speech.stop();
    if (mounted) setState(() => _isListening = false);
  }

  String _getAiResponse(String userInput, {bool hasImage = false}) {
    final lower = userInput.toLowerCase();
    if (lower.contains('agent') || lower.contains('humain') || lower.contains('réel') || lower.contains('parler') || lower.contains('support')) {
      return "Je peux vous mettre en contact avec un agent Yadeli. Souhaitez-vous être appelé, contacté par email/SMS ou via WhatsApp ? Dites-moi votre préférence.";
    }
    if (lower.contains('annuler') || lower.contains('annulation')) {
      return "Pour annuler une course : allez dans Historique > sélectionnez le trajet > Modifier/Annuler. Si la course est déjà en cours ou confirmée, l'annulation n'est pas possible sans signaler un problème. Des frais peuvent s'appliquer en cas d'annulation sans motif.";
    }
    if (lower.contains('paiement') || lower.contains('payer')) {
      return "Yadeli accepte : Cash, Airtel Money, MTN MoMo à la livraison ou au terme de la course.";
    }
    if (hasImage) {
      return "J'ai bien reçu votre image. Pour une analyse détaillée, contactez un agent via le bouton en haut à droite. Je peux vous aider pour : annulation, paiement, livraison, pourboire, facture.";
    }
    if (lower.contains('livraison') || lower.contains('pharmacie') || lower.contains('alimentaire')) {
      return "Nous proposons : Pharmacie, Alimentaire, Boutique, Cosmétique, Marché et Livraison colis. Choisissez le service dans l'application.";
    }
    if (lower.contains('pourboire')) {
      return "Vous pouvez ajouter un pourboire au chauffeur/livreur après la course, dans les détails du trajet.";
    }
    if (lower.contains('facture') || lower.contains('récap')) {
      return "Dans l'historique des trajets, ouvrez un trajet et cliquez sur 'Envoyer récap' ou 'Voir facture' pour recevoir le récapitulatif par mail/SMS.";
    }
    return "Je n'ai pas compris. Tapez 'agent' pour parler à un conseiller, ou posez une question sur : annulation, paiement, livraison, pourboire, facture.";
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(_scrollController.position.maxScrollExtent, duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
      }
    });
  }

  Future<void> _requestAgent() async {
    setState(() => _agentRequested = true);
    final languages = await UserService.getUserLanguages();
    final langStr = languages.isNotEmpty ? languages.join(', ') : 'FR';

    showModalBottomSheet(
      context: context,
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text("Contacter un agent (langue(s): $langStr)", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green[700])),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.phone, color: Colors.green),
                title: const Text("Appel"),
                onTap: () async {
                  Navigator.pop(context);
                  await launchUrl(Uri.parse('tel:+242064442211'), mode: LaunchMode.externalApplication);
                },
              ),
              ListTile(
                leading: const Icon(Icons.email, color: Colors.green),
                title: const Text("Email"),
                onTap: () async {
                  Navigator.pop(context);
                  await launchUrl(Uri.parse('mailto:support@yadeli.cg'), mode: LaunchMode.externalApplication);
                },
              ),
              ListTile(
                leading: const Icon(Icons.chat, color: Colors.green),
                title: const Text("WhatsApp"),
                onTap: () async {
                  Navigator.pop(context);
                  await launchUrl(Uri.parse('https://wa.me/242064442211'), mode: LaunchMode.externalApplication);
                },
              ),
              ListTile(
                leading: const Icon(Icons.sms, color: Colors.green),
                title: const Text("SMS"),
                onTap: () async {
                  Navigator.pop(context);
                  await launchUrl(Uri.parse('sms:+242064442211'), mode: LaunchMode.externalApplication);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Assistance IA"),
        backgroundColor: Colors.green[700],
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: _requestAgent,
            tooltip: "Parler à un agent",
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length + (_loading ? 1 : 0),
              itemBuilder: (context, i) {
                if (i == _messages.length) {
                  return const Padding(
                    padding: EdgeInsets.all(16),
                    child: Row(children: [CircularProgressIndicator(strokeWidth: 2), SizedBox(width: 12), Text("Réflexion...")]),
                  );
                }
                final m = _messages[i];
                return Align(
                  alignment: m.isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: m.isUser ? Colors.green[100] : Colors.grey[200],
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (m.imageBytes != null) ...[
                          ClipRRect(borderRadius: BorderRadius.circular(8), child: Image.memory(Uint8List.fromList(m.imageBytes!), width: 120, height: 90, fit: BoxFit.cover)),
                          const SizedBox(height: 8),
                        ],
                        Text(m.text, style: const TextStyle(fontSize: 15)),
                        const SizedBox(height: 4),
                        Text("${m.time.hour.toString().padLeft(2, '0')}:${m.time.minute.toString().padLeft(2, '0')}", style: TextStyle(fontSize: 11, color: Colors.grey[600])),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                IconButton(onPressed: _loading ? null : _addImage, icon: const Icon(Icons.image_outlined), tooltip: "Insérer une image"),
                if (!kIsWeb) IconButton(
                  onPressed: _loading ? null : (_isListening ? _stopListening : _startListening),
                  icon: Icon(_isListening ? Icons.mic : Icons.mic_none),
                  tooltip: _isListening ? "Arrêter" : "Parler",
                  color: _isListening ? Colors.red : null,
                ),
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: "Votre question... (ou parlez)",
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(24)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filled(
                  onPressed: _loading ? null : () => _sendMessage(),
                  icon: const Icon(Icons.send),
                  style: IconButton.styleFrom(backgroundColor: Colors.green[700]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ChatMessage {
  final String text;
  final bool isUser;
  final DateTime time;
  final List<int>? imageBytes;
  _ChatMessage({required this.text, required this.isUser, required this.time, this.imageBytes});
}
