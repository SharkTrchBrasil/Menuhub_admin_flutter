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
  double _textFieldHeight = 48.0;
  final double _minTextFieldHeight = 48.0;
  final double _maxTextFieldHeight = 120.0;

  @override
  void initState() {
    super.initState();
    _textController.addListener(() {
      if (mounted) {
        setState(() {
          _canSend = _textController.text.trim().isNotEmpty;
          _updateTextFieldHeight();
        });
      }
    });

    _focusNode.addListener(() {
      if (_focusNode.hasFocus && _emojiShowing) {
        setState(() => _emojiShowing = false);
      }
    });
  }

  void _updateTextFieldHeight() {
    final textPainter = TextPainter(
      text: TextSpan(
        text: _textController.text,
        style: const TextStyle(fontSize: 16, height: 1.2),
      ),
      textDirection: TextDirection.ltr,
      maxLines: 5,
    )..layout(maxWidth: MediaQuery.of(context).size.width * 0.5 - 32); // Ajuste na largura máxima

    final desiredHeight = textPainter.size.height + 24;
    final newHeight = desiredHeight.clamp(_minTextFieldHeight, _maxTextFieldHeight);

    if (newHeight != _textFieldHeight) {
      setState(() => _textFieldHeight = newHeight);
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    _waveController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _toggleEmojiPicker() {
    if (!_emojiShowing) {
      FocusScope.of(context).unfocus();
    }
    setState(() => _emojiShowing = !_emojiShowing);
  }

  void _sendMessage() {
    if (_canSend) {
      context.read<ChatPanelCubit>().sendMessage(_textController.text.trim());
      _textController.clear();
      setState(() => _textFieldHeight = _minTextFieldHeight);

      // Mantém o foco no campo de texto após enviar
      _focusNode.requestFocus();
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
      setState(() => _textFieldHeight = _minTextFieldHeight);
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
    return Material(

      child: ListenableBuilder(
        listenable: _waveController,
        builder: (context, _) {
          final isRecording = _waveController.isRecording;
          return Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 12),
                color: Theme.of(context).canvasColor,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    IconButton(
                      icon: Icon(
                        _emojiShowing ? Icons.keyboard_alt_outlined : Icons.emoji_emotions_outlined,
                        color: Theme.of(context).iconTheme.color,
                      ),
                      onPressed: _toggleEmojiPicker,
                    ),
                    IconButton(
                      icon: const Icon(Icons.attach_file),
                      onPressed: isRecording ? null : _pickImage,
                    ),
                    // No arquivo chat_input_field.dart - ATUALIZE a parte do TextField:

                    Expanded(
                      child: isRecording
                          ? WaveformRecorder(
                        height: 48,
                        controller: _waveController,
                        onRecordingStopped: _onRecordingStopped,
                      )
                          : Container(
                        height: _textFieldHeight,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          border: Border.all(
                            width: 0.5,
                            color: Colors.grey,
                          ),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: TextField(
                          controller: _textController,
                          focusNode: _focusNode,
                          maxLines: null, // ✅ Permite múltiplas linhas
                          textInputAction: TextInputAction.newline,
                          decoration: const InputDecoration(
                            hintText: 'Digite sua mensagem...',
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(vertical: 12),
                            isDense: true, // ✅ Remove padding extra
                          ),
                          onSubmitted: (_) => _sendMessage(),
                        ),
                      ),
                    ),





                    const SizedBox(width: 8),
                    IconButton(
                      icon: _canSend
                          ? const Icon(Icons.send)
                          : Icon(
                        isRecording ? Icons.stop_circle : Icons.mic,
                        color: isRecording ? Colors.red.shade400 : null,
                      ),
                      onPressed: _canSend ? _sendMessage : _handleRecording,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ],
                ),
              ),
              Offstage(
                offstage: !_emojiShowing,
                child: SizedBox(
                  height: 250,
                  child: EmojiPicker(
                    textEditingController: _textController,
                    config: Config(
                      height: 250,
                      checkPlatformCompatibility: true,
                      emojiViewConfig: EmojiViewConfig(
                        emojiSizeMax: 28 * (foundation.defaultTargetPlatform == TargetPlatform.iOS ? 1.20 : 1.0),
                      ),
                      categoryViewConfig: const CategoryViewConfig(
                        indicatorColor: Colors.blue,
                        iconColorSelected: Colors.blue,
                      ),
                      bottomActionBarConfig: const BottomActionBarConfig(
                        enabled: false,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}