import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../core/theme.dart';
import '../../domain/models/models.dart';

class ChatConversationScreen extends StatefulWidget {
  final ChatThread thread;
  final User partner;

  const ChatConversationScreen({super.key, required this.thread, required this.partner});

  @override
  State<ChatConversationScreen> createState() => _ChatConversationScreenState();
}

class _ChatConversationScreenState extends State<ChatConversationScreen> {
  bool _showTranslation = false;
  
  // Audio recording states
  late final AudioRecorder _audioRecorder;
  late final AudioPlayer _audioPlayer;
  bool _isRecording = false;
  bool _isPlaying = false;
  String? _currentlyPlayingPath;
  
  // Ephemeral in-memory only recordings to satisfy "don't save file persistently"
  final List<String> _localRecordings = [];

  @override
  void initState() {
    super.initState();
    _audioRecorder = AudioRecorder();
    _audioPlayer = AudioPlayer();
    
    _audioPlayer.onPlayerStateChanged.listen((state) {
      if (mounted) {
        setState(() {
          _isPlaying = state == PlayerState.playing;
          if (state == PlayerState.completed) {
            _currentlyPlayingPath = null;
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _audioRecorder.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _startRecording() async {
    try {
      if (await Permission.microphone.request().isGranted) {
        final dir = await getTemporaryDirectory();
        final path = '${dir.path}/bantera_ephemeral_${DateTime.now().millisecondsSinceEpoch}.m4a';
        
        await _audioRecorder.start(const RecordConfig(), path: path);
        setState(() => _isRecording = true);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Microphone permission required')),
          );
        }
      }
    } catch (e) {
      debugPrint('Error starting record: $e');
    }
  }

  Future<void> _stopRecording() async {
    try {
      final path = await _audioRecorder.stop();
      setState(() => _isRecording = false);
      
      if (path != null) {
        setState(() {
          _localRecordings.add(path);
        });
      }
    } catch (e) {
      debugPrint('Error stopping record: $e');
    }
  }

  Future<void> _playLocalAudio(String path) async {
    if (_isPlaying && _currentlyPlayingPath == path) {
      await _audioPlayer.pause();
    } else {
      await _audioPlayer.play(DeviceFileSource(path));
      setState(() {
        _currentlyPlayingPath = path;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(radius: 16, backgroundImage: NetworkImage(widget.partner.avatarUrl)),
            const SizedBox(width: 8),
            // Show group info if applicable
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.thread.isGroup ? 'Group Chat' : widget.partner.displayName, style: const TextStyle(fontSize: 16)),
                if (widget.thread.isGroup)
                  Text('${widget.thread.participants.length} members', style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 10)),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(icon: const Icon(Icons.info_outline), onPressed: () {}),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Render mock history
                _buildMessageBubble(context, widget.thread.lastMessage),
                
                // Render real local dynamic messages
                for (var path in _localRecordings)
                  _buildLocalRecordingBubble(context, path),
              ],
            ),
          ),
          SafeArea(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: Theme.of(context).colorScheme.surface,
              child: Row(
                children: [
                   IconButton(icon: Icon(Icons.add_circle, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5), size: 28), onPressed: () {}),
                   Expanded(
                     child: GestureDetector(
                       onLongPressStart: (_) => _startRecording(),
                       onLongPressEnd: (_) => _stopRecording(),
                       child: Container(
                         height: 44,
                         decoration: BoxDecoration(
                           color: _isRecording ? Colors.redAccent.withOpacity(0.1) : Theme.of(context).colorScheme.background,
                           borderRadius: BorderRadius.circular(22),
                           border: Border.all(color: _isRecording ? Colors.redAccent : Colors.transparent),
                         ),
                         alignment: Alignment.center,
                         child: Text(
                           _isRecording ? 'Recording... Release to send' : 'Hold to Record', 
                           style: TextStyle(
                             color: _isRecording ? Colors.redAccent : Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                             fontWeight: _isRecording ? FontWeight.bold : FontWeight.normal,
                           ),
                         ),
                       ),
                     ),
                   ),
                   IconButton(
                     icon: Icon(CupertinoIcons.mic_solid, color: _isRecording ? Colors.redAccent : Theme.of(context).colorScheme.primary, size: 28), 
                     onPressed: () {
                         ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Hold down to record!')));
                     },
                   ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocalRecordingBubble(BuildContext context, String path) {
    final isPresentPlaying = _isPlaying && _currentlyPlayingPath == path;

    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        margin: const EdgeInsets.only(bottom: 24, top: 8),
        width: MediaQuery.of(context).size.width * 0.75,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
            bottomRight: Radius.circular(4),
            bottomLeft: Radius.circular(20),
          ),
          border: Border.all(color: Theme.of(context).colorScheme.primary.withOpacity(0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.thread.isGroup)
              Padding(
                padding: const EdgeInsets.only(left: 12, top: 8),
                child: Text('You', style: TextStyle(color: Theme.of(context).colorScheme.primary, fontSize: 12, fontWeight: FontWeight.bold)),
              ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => _playLocalAudio(path),
                    child: CircleAvatar(
                       radius: 20,
                       backgroundColor: Theme.of(context).colorScheme.primary,
                       child: Icon(isPresentPlaying ? Icons.pause : Icons.play_arrow, color: Colors.white),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      height: 24,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Stack(
                         alignment: Alignment.centerLeft,
                         children: [
                           Container(width: 60, color: Theme.of(context).colorScheme.primary.withOpacity(0.7)),
                         ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Text(
                'Transcription processing...',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontStyle: FontStyle.italic),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageBubble(BuildContext context, ChatMessage message) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 24),
        width: MediaQuery.of(context).size.width * 0.75,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
            bottomRight: Radius.circular(20),
            bottomLeft: Radius.circular(4),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.thread.isGroup)
              Padding(
                padding: const EdgeInsets.only(left: 12, top: 8),
                child: Text(widget.partner.displayName, style: TextStyle(color: Theme.of(context).colorScheme.primary, fontSize: 12, fontWeight: FontWeight.bold)),
              ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  CircleAvatar(
                     radius: 20,
                     backgroundColor: Theme.of(context).colorScheme.primary,
                     child: const Icon(Icons.play_arrow, color: Colors.white),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      height: 24,
                      decoration: BoxDecoration(
                        color: Colors.grey[200] ?? Colors.grey,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Stack(
                         alignment: Alignment.centerLeft,
                         children: [
                           Container(width: 40, color: Theme.of(context).colorScheme.primary.withOpacity(0.3)),
                         ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text('0:12', style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   Text(
                     message.transcriptPreview,
                     style: Theme.of(context).textTheme.bodyLarge,
                   ),
                   if (_showTranslation) ...[
                     const SizedBox(height: 8),
                     Text(
                       message.translatedPreview,
                       style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.primary),
                     ),
                   ],
                   const SizedBox(height: 12),
                   Row(
                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                     children: [
                        Text('10:45 AM', style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 12)),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _showTranslation = !_showTranslation;
                            });
                          },
                          child: Icon(Icons.g_translate, color: _showTranslation ? Theme.of(context).colorScheme.primary : Colors.grey[400], size: 18),
                        ),
                     ],
                   ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
