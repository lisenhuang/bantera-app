import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../../domain/models/models.dart';
import 'record_compare_sheet.dart';

enum SubtitleState { hidden, original, translated }

class PracticePlayerScreen extends StatefulWidget {
  final MediaItem mediaItem;

  const PracticePlayerScreen({super.key, required this.mediaItem});

  @override
  State<PracticePlayerScreen> createState() => _PracticePlayerScreenState();
}

class _PracticePlayerScreenState extends State<PracticePlayerScreen> {
  int _currentCueIndex = 0;
  SubtitleState _subtitleState = SubtitleState.hidden;
  bool _isPlaying = false;

  void _nextCue() {
    if (_currentCueIndex < widget.mediaItem.cues.length - 1) {
      setState(() {
        _currentCueIndex++;
        _subtitleState = SubtitleState.hidden;
      });
    }
  }

  void _prevCue() {
    if (_currentCueIndex > 0) {
      setState(() {
        _currentCueIndex--;
        _subtitleState = SubtitleState.hidden;
      });
    }
  }

  void _togglePlay() {
    setState(() {
      _isPlaying = !_isPlaying;
    });
  }

  void _cycleSubtitleState() {
    setState(() {
      if (_subtitleState == SubtitleState.hidden) {
        _subtitleState = SubtitleState.original;
      } else if (_subtitleState == SubtitleState.original) {
        _subtitleState = SubtitleState.translated;
      } else {
        _subtitleState = SubtitleState.hidden;
      }
    });
  }

  void _openCompareSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => RecordCompareSheet(cue: widget.mediaItem.cues[_currentCueIndex]),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.mediaItem.cues.isEmpty) return const Scaffold(body: Center(child: Text('No cues')));

    final cue = widget.mediaItem.cues[_currentCueIndex];
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.background,
      appBar: AppBar(
        title: Text('${_currentCueIndex + 1} / ${widget.mediaItem.cues.length}'),
        centerTitle: true,
        actions: [
          IconButton(icon: const Icon(CupertinoIcons.settings), onPressed: () {}),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Media info bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Row(
                children: [
                   CircleAvatar(radius: 12, backgroundImage: NetworkImage(widget.mediaItem.creator.avatarUrl)),
                   const SizedBox(width: 8),
                   Expanded(
                     child: Text(
                       widget.mediaItem.title, 
                       style: Theme.of(context).textTheme.titleMedium?.copyWith(fontSize: 14),
                       maxLines: 1,
                       overflow: TextOverflow.ellipsis,
                     ),
                   ),
                ],
              ),
            ),
            
            Expanded(
              child: GestureDetector(
                onTap: _togglePlay,
                child: Container(
                  width: double.infinity,
                  margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: colorScheme.surface,
                    borderRadius: BorderRadius.circular(32),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Subtitle Display area Custom Polished
                      Expanded(
                        child: Center(
                          child: _buildSubtitleContent(cue, colorScheme),
                        ),
                      ),
                      
                      // Mock Waveform
                      Container(
                        height: 48,
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: colorScheme.background,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: List.generate(30, (index) {
                            return Expanded(
                              child: Container(
                                margin: const EdgeInsets.symmetric(horizontal: 1.5),
                                height: (index % 4 + 1) * 8.0,
                                decoration: BoxDecoration(
                                  color: index % 3 == 0 ? colorScheme.primary : colorScheme.onSurface.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                            );
                          }),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            
            // Subtitle Toggle Actions
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  OutlinedButton.icon(
                     style: OutlinedButton.styleFrom(
                       padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                     ),
                     onPressed: _cycleSubtitleState,
                     icon: Icon(_subtitleState == SubtitleState.hidden ? CupertinoIcons.eye : CupertinoIcons.textformat),
                     label: Text(
                       _subtitleState == SubtitleState.hidden ? 'Reveal' : 'Translate',
                       style: const TextStyle(fontWeight: FontWeight.bold),
                     ),
                  ),
                ],
              ),
            ),

            // Controls Timeline
            Container(
              padding: const EdgeInsets.only(top: 16, bottom: 24, left: 32, right: 32),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        iconSize: 36,
                        icon: const Icon(CupertinoIcons.backward_fill),
                        color: _currentCueIndex > 0 ? colorScheme.onSurface : colorScheme.onSurface.withOpacity(0.2),
                        onPressed: _prevCue,
                      ),
                      const SizedBox(width: 24),
                      IconButton(
                        iconSize: 72,
                        icon: Icon(_isPlaying ? CupertinoIcons.pause_circle_fill : CupertinoIcons.play_circle_fill),
                        color: colorScheme.primary,
                        onPressed: _togglePlay,
                      ),
                      const SizedBox(width: 24),
                      IconButton(
                        iconSize: 36,
                        icon: const Icon(CupertinoIcons.forward_fill),
                        color: _currentCueIndex < widget.mediaItem.cues.length - 1 ? colorScheme.onSurface : colorScheme.onSurface.withOpacity(0.2),
                        onPressed: _nextCue,
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildActionBtn(CupertinoIcons.bookmark, 'Note', () {}, colorScheme),
                      _buildActionBtn(CupertinoIcons.mic_solid, 'Compare', _openCompareSheet, colorScheme, isHighlight: true),
                      _buildActionBtn(CupertinoIcons.reply, 'Replay', () {}, colorScheme),
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

  Widget _buildSubtitleContent(Cue cue, ColorScheme colorScheme) {
    if (_subtitleState == SubtitleState.hidden) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
           Icon(CupertinoIcons.ear, size: 64, color: colorScheme.primary.withOpacity(0.4)),
           const SizedBox(height: 16),
           Text(
             'Listen carefully...', 
             style: Theme.of(context).textTheme.titleLarge?.copyWith(color: colorScheme.primary.withOpacity(0.6)),
           ),
        ],
      );
    } else if (_subtitleState == SubtitleState.original) {
      return Text(
        cue.originalText,
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 32, height: 1.3),
      );
    } else {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            cue.originalText,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 28, height: 1.3),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              cue.translatedText,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: colorScheme.primary,
                  ),
            ),
          ),
        ],
      );
    }
  }

  Widget _buildActionBtn(IconData icon, String label, VoidCallback onTap, ColorScheme colorScheme, {bool isHighlight = false}) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: isHighlight ? colorScheme.primary : colorScheme.surface,
            foregroundColor: isHighlight ? colorScheme.onPrimary : colorScheme.primary,
            child: Icon(icon, size: 28),
          ),
          const SizedBox(height: 8),
          Text(label, style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: isHighlight ? FontWeight.bold : FontWeight.w600,
            color: isHighlight ? colorScheme.primary : colorScheme.onSurface.withOpacity(0.6),
          )),
        ],
      ),
    );
  }
}
