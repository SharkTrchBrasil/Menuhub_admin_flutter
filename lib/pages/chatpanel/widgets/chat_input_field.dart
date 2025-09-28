// lib/features/chat/widgets/chat_input_field.dart

import 'dart:io';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/foundation.dart' as foundation;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:waveform_recorder/waveform_recorder.dart';

import '../cubit/chat_panel_cubit.dart';

class ChatInputField extends StatefulWidget {
  const ChatInputField({Key? key}) : super(key: key);

  @override
  _ChatInputFieldState createState() => _ChatInputFieldState();
}

class _ChatInputFieldState extends State<ChatInputField> {
  final _textController = TextEditingController();
  final _waveController = WaveformRecorderController();
  final _focusNode = FocusNode();

  bool _canSend = false;
  bool _emojiShowing = false;

  @override
  void initState() {
    super.initState();
    _textController.addListener(() {
      if (mounted) setState(() => _canSend = _textController.text.trim().isNotEmpty);
    });

    // Listener para esconder o emoji picker quando o teclado aparecer
    _focusNode.addListener(() {
      if (_focusNode.hasFocus && _emojiShowing) {
        setState(() => _emojiShowing = false);
      }
    });
  }

  @override
  void dispose() {
    _textController.dispose();
    _waveController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  /// Alterna a visibilidade do seletor de emoji, garantindo que o teclado
  /// seja escondido antes de mostrá-lo.
  void _toggleEmojiPicker() {
    if (!_emojiShowing) {
      FocusScope.of(context).unfocus(); // Esconde o teclado
    }
    setState(() => _emojiShowing = !_emojiShowing);
  }

  void _sendMessage() {
    if (_canSend) {
      context.read<ChatPanelCubit>().sendMessage(_textController.text.trim());
      _textController.clear();
    }
  }

  Future<void> _handleRecording() async {
    if (_waveController.isRecording) {
      await _waveController.stopRecording();
    } else {
      final status = await Permission.microphone.request();
      if (status.isGranted) {
        try {
          await _waveController.startRecording();
        } on PlatformException catch (e) {
          debugPrint('Erro ao iniciar gravação: $e');
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Nenhum dispositivo de gravação de áudio foi localizado.')),
            );
          }
        } catch (e) {
          debugPrint('Erro desconhecido ao iniciar gravação: $e');
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Permissão de microfone necessária.')),
          );
        }
      }
    }
  }

  void _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      context.read<ChatPanelCubit>().uploadAndSendMedia(
        File(pickedFile.path),
        'image',
        caption: _textController.text.trim(),
      );
      _textController.clear();
    }
  }

  void _onRecordingStopped() {
    final file = _waveController.file;
    if (file != null) {
      context.read<ChatPanelCubit>().uploadAndSendMedia(File(file.path), 'audio');
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _waveController,
      builder: (context, _) {
        final isRecording = _waveController.isRecording;
        return Column(
          children: [
            // --- Barra de Input Principal ---
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 12),
              color: Theme.of(context).canvasColor,
              child: Row(
                children: [
                  // ✅ Botão de Emoji
                  IconButton(
                    icon: Icon(
                      _emojiShowing ? Icons.keyboard_alt_outlined : Icons.emoji_emotions_outlined,
                      color: Theme.of(context).iconTheme.color,
                    ),
                    onPressed: _toggleEmojiPicker,
                  ),
                  IconButton(
                    icon: const Icon(Icons.attach_file),
                    onPressed: isRecording ? null : _pickImage, // Desativa durante gravação
                  ),
                  Expanded(
                    child: isRecording
                        ? WaveformRecorder(
                      height: 48,
                      controller: _waveController,
                      onRecordingStopped: _onRecordingStopped,
                    )
                        : TextField(
                      controller: _textController,
                      focusNode: _focusNode,
                      decoration: const InputDecoration(
                        hintText: 'Digite sua mensagem...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(20)),
                          borderSide: BorderSide(width: 0.5),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(20)),
                          borderSide: BorderSide(width: 0.5, color: Colors.grey),
                        ),
                        contentPadding: EdgeInsets.symmetric(horizontal: 16),
                      ),
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: _canSend
                        ? const Icon(Icons.send)
                        : Icon(isRecording ? Icons.stop_circle : Icons.mic,
                        color: isRecording ? Colors.red.shade400 : null),
                    onPressed: _canSend ? _sendMessage : _handleRecording,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ],
              ),
            ),
            // --- Seletor de Emoji (Controlado pela variável _emojiShowing) ---
            Offstage(
              offstage: !_emojiShowing,
              child: SizedBox(
                height: 250,
                child: EmojiPicker(
                  // ✅ Passa o controller diretamente para o picker
                  textEditingController: _textController,
                  config: Config(
                    height: 250,
                    checkPlatformCompatibility: true,
                    emojiViewConfig: EmojiViewConfig(
                      // Corrige bug de tamanho do emoji no iOS
                      emojiSizeMax: 28 * (foundation.defaultTargetPlatform == TargetPlatform.iOS ? 1.20 : 1.0),
                    ),
                    // Outras configurações para um visual mais limpo
                    categoryViewConfig: const CategoryViewConfig(
                      indicatorColor: Colors.blue,
                      iconColorSelected: Colors.blue,
                    ),
                    bottomActionBarConfig: const BottomActionBarConfig(
                      enabled: false, // Remove a barra inferior para um visual mais limpo
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}