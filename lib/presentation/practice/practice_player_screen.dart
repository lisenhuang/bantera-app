import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../../core/theme.dart';
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

    return Scaffold(
      backgroundColor: BanteraTheme.backgroundLight,
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
                  Text(widget.mediaItem.title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontSize: 14)),
                ],
              ),
            ),
            
            Expanded(
              child: GestureDetector(
                onTap: _togglePlay,
                child: Container(
                  width: double.infinity,
                  margin: const EdgeInsets.all(20),
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: BanteraTheme.surfaceColorLight,
                    borderRadius: BorderRadius.circular(24),
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
                      // Subtitle Display area
                      if (_subtitleState == SubtitleState.hidden)
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(CupertinoIcons.eye_slash_fill, size: 48, color: Colors.grey[300]),
                            const SizedBox(height: 16),
                            Text('Listen carefully...', style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.grey[400])),
                          ],
                        )
                      else if (_subtitleState == SubtitleState.original)
                        Text(
                          cue.originalText,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 28),
                        )
                      else
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              cue.originalText,
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 24),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              cue.translatedText,
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                    color: BanteraTheme.primaryColor,
                                  ),
                            ),
                          ],
                        ),

                      const Spacer(),
                      
                      // Mock Waveform
                      Container(
                        height: 40,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: BanteraTheme.backgroundLight,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: List.generate(40, (index) {
                            return Container(
                              margin: const EdgeInsets.symmetric(horizontal: 1),
                              width: 3,
                              height: (index % 5 + 1) * 6.0,
                              color: index % 3 == 0 ? BanteraTheme.primaryColor : Colors.grey[300],
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
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  OutlinedButton.icon(
                    onPressed: _cycleSubtitleState,
                    icon: Icon(_subtitleState == SubtitleState.hidden ? CupertinoIcons.eye : CupertinoIcons.textformat),
                    label: Text(_subtitleState == SubtitleState.hidden ? 'Reveal' : 'Translate'),
                  ),
                ],
              ),
            ),

            // Controls Timeline
            Container(
              padding: const EdgeInsets.only(top: 24, bottom: 16, left: 32, right: 32),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      IconButton(
                        iconSize: 32,
                        icon: const Icon(CupertinoIcons.backward_fill),
                        color: _currentCueIndex > 0 ? BanteraTheme.textPrimaryLight : Colors.grey[300],
                        onPressed: _prevCue,
                      ),
                      IconButton(
                        iconSize: 64,
                        icon: Icon(_isPlaying ? CupertinoIcons.pause_circle_fill : CupertinoIcons.play_circle_fill),
                        color: BanteraTheme.primaryColor,
                        onPressed: _togglePlay,
                      ),
                      IconButton(
                        iconSize: 32,
                        icon: const Icon(CupertinoIcons.forward_fill),
                        color: _currentCueIndex < widget.mediaItem.cues.length - 1 ? BanteraTheme.textPrimaryLight : Colors.grey[300],
                        onPressed: _nextCue,
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildActionBtn(CupertinoIcons.bookmark, 'Note', () {}),
                      _buildActionBtn(CupertinoIcons.mic_solid, 'Compare', _openCompareSheet, isHighlight: true),
                      _buildActionBtn(CupertinoIcons.reply, 'Replay', () {}),
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

  Widget _buildActionBtn(IconData icon, String label, VoidCallback onTap, {bool isHighlight = false}) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: isHighlight ? BanteraTheme.primaryColor : Colors.white,
            foregroundColor: isHighlight ? Colors.white : BanteraTheme.primaryColor,
            child: Icon(icon, size: 28),
          ),
          const SizedBox(height: 8),
          Text(label, style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: isHighlight ? FontWeight.bold : FontWeight.w500,
            color: isHighlight ? BanteraTheme.primaryColor : BanteraTheme.textSecondaryLight,
          )),
        ],
      ),
    );
  }
}
