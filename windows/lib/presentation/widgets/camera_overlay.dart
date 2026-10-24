import 'package:flutter/material.dart';
import '../../data/models/exercise_log.dart';
import '../../core/localization/app_localizations.dart';

class CameraOverlay extends StatelessWidget {
  final double accuracy;
  final int repCount;
  final String phase;
  final List<FormWarning> warnings;
  final Duration? holdDuration;
  final VoidCallback onToggleLandmarks;
  final VoidCallback onToggleRecording;
  final VoidCallback onCompleteWorkout;
  final bool showLandmarks;
  final bool isRecording;
  
  const CameraOverlay({
    super.key,
    required this.accuracy,
    required this.repCount,
    required this.phase,
    required this.warnings,
    this.holdDuration,
    required this.onToggleLandmarks,
    required this.onToggleRecording,
    required this.onCompleteWorkout,
    required this.showLandmarks,
    required this.isRecording,
  });
  
  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Column(
      children: [
        // Top Bar
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withOpacity(0.8),
                Colors.transparent,
              ],
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Phase Indicator
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: _getPhaseColor().withOpacity(0.7),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  phase.toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
              
              // Hold Duration (for static exercises)
              if (holdDuration != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    _formatDuration(holdDuration!),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
            ],
          ),
        ),
        
        const Spacer(),
        
        // Bottom Controls
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
              colors: [
                Colors.black.withOpacity(0.9),
                Colors.transparent,
              ],
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              // Landmarks Toggle
              _buildControlButton(
                icon: Icons.account_tree,
                label: l10n.t('camera.overlay.skeleton'),
                isActive: showLandmarks,
                onPressed: onToggleLandmarks,
                isPremium: true,
              ),
              
              // Recording Toggle
              _buildControlButton(
                icon: isRecording ? Icons.stop : Icons.videocam,
                label: isRecording
                    ? l10n.t('camera.overlay.stop')
                    : l10n.t('camera.overlay.record'),
                isActive: isRecording,
                onPressed: onToggleRecording,
                isPremium: true,
              ),
              
              // Complete Workout
              _buildControlButton(
                icon: Icons.check_circle,
                label: l10n.t('camera.overlay.complete'),
                isActive: false,
                onPressed: onCompleteWorkout,
                isPremium: false,
              ),
            ],
          ),
        ),
      ],
    );
  }
  
  Widget _buildControlButton({
    required IconData icon,
    required String label,
    required bool isActive,
    required VoidCallback onPressed,
    required bool isPremium,
  }) {
    return Column(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: isActive ? Colors.blue : Colors.white.withOpacity(0.2),
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.transparent,
              width: 2,
            ),
          ),
          child: IconButton(
            icon: Icon(icon, color: isActive ? Colors.white : Colors.grey[300]),
            onPressed: onPressed,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: isPremium ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }
  
  Color _getPhaseColor() {
    switch (phase.toLowerCase()) {
      case 'up':
        return Colors.green;
      case 'down':
        return Colors.orange;
      case 'hold':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }
  
  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes.toString().padLeft(2, '0');
    final seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }
}
