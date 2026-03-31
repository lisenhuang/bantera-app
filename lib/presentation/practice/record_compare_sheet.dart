import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../../core/theme.dart';
import '../../domain/models/models.dart';

class RecordCompareSheet extends StatefulWidget {
  final Cue cue;

  const RecordCompareSheet({super.key, required this.cue});

  @override
  State<RecordCompareSheet> createState() => _RecordCompareSheetState();
}

class _RecordCompareSheetState extends State<RecordCompareSheet> {
  bool _isRecording = false;
  bool _hasResult = false;

  void _simulateRecording() {
    setState(() {
      _isRecording = true;
      _hasResult = false;
    });

    Future.delayed(const Duration(seconds: 3), () {
      setState(() {
        _isRecording = false;
        _hasResult = true;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: BanteraTheme.surfaceColorLight,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Record your version',
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: BanteraTheme.backgroundLight,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: Text(
                widget.cue.originalText,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontSize: 18),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 32),
            
            if (!_hasResult) ...[
              // Recording State
              GestureDetector(
                onTap: _isRecording ? () {} : _simulateRecording,
                child: Container(
                  height: 80,
                  width: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _isRecording ? Colors.redAccent.withOpacity(0.1) : BanteraTheme.primaryColor.withOpacity(0.1),
                    border: Border.all(color: _isRecording ? Colors.redAccent : BanteraTheme.primaryColor, width: 4),
                  ),
                  child: Center(
                    child: Icon(
                      _isRecording ? CupertinoIcons.stop_fill : CupertinoIcons.mic_solid,
                      color: _isRecording ? Colors.redAccent : BanteraTheme.primaryColor,
                      size: 32,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                _isRecording ? 'Listening...' : 'Tap to start recording',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 32),
            ] else ...[
              // Comparison State
              const Divider(),
              const SizedBox(height: 16),
              Text('Your transcribed attempt:', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.orange.withOpacity(0.2)),
                ),
                child: RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontSize: 18),
                    children: [
                      const TextSpan(text: "Hey mate, how's it going "),
                      TextSpan(
                        text: "to day?",
                        style: TextStyle(
                          color: Colors.orange[800],
                          fontWeight: FontWeight.bold,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                   Icon(Icons.info_outline, color: Colors.orange[800], size: 16),
                   const SizedBox(width: 4),
                   Text(
                     'Some words were recognised differently.',
                     style: TextStyle(color: Colors.orange[800], fontSize: 12, fontWeight: FontWeight.bold),
                   ),
                ],
              ),
              const SizedBox(height: 32),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      onPressed: () {
                        setState(() {
                          _hasResult = false;
                        });
                      },
                      child: const Text('Try Again'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text('Save Attempt'),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
