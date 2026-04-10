import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../theme/app_colors.dart';
import '../providers/settings_provider.dart';
import '../models/tts_engine.dart';
import '../models/voice_info.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(28, 16, 28, 12),
            child: Text(
              'Settings',
              style: GoogleFonts.outfit(
                fontSize: 28,
                fontWeight: FontWeight.w800,
                color: AppColors.onSurface,
                letterSpacing: -0.5,
              ),
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              children: [
                _buildEngineSection(context),
                const SizedBox(height: 24),
                _buildVoiceSection(context),
                const SizedBox(height: 24),
                _buildPlaybackSection(context),
                const SizedBox(height: 24),
                _buildApiConfigSection(context),
                const SizedBox(height: 100), // 为底部导航留白
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.primary),
          const SizedBox(width: 8),
          Text(
            title,
            style: GoogleFonts.outfit(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCard({required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.outlineVariant.withOpacity(0.4)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: child,
    );
  }

  Widget _buildEngineSection(BuildContext context) {
    final settings = context.watch<SettingsProvider>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('TTS Engine', Icons.rocket_launch_rounded),
        _buildCard(
          child: Column(
            children: TtsEngineId.values.map((id) {
              final engine = TtsEngineRegistry.findById(id)!;
              final isSelected = settings.selectedEngineId == id;

              return InkWell(
                onTap: () => settings.setEngine(id),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: id == TtsEngineId.values.last
                            ? Colors.transparent
                            : AppColors.outlineVariant.withOpacity(0.3),
                      ),
                    ),
                    color: isSelected ? AppColors.primary.withOpacity(0.05) : null,
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: isSelected 
                              ? AppColors.primary 
                              : AppColors.surfaceContainerLow,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.mic_rounded,
                          color: isSelected ? Colors.white : AppColors.onSurfaceVariant,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              engine.name,
                              style: GoogleFonts.outfit(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: isSelected ? AppColors.primary : AppColors.onSurface,
                              ),
                            ),
                            if (!engine.isFree)
                              Text(
                                'Requires API Key',
                                style: GoogleFonts.inter(
                                  fontSize: 11,
                                  color: AppColors.tertiary,
                                ),
                              ),
                          ],
                        ),
                      ),
                      if (isSelected)
                        const Icon(Icons.check_circle_rounded, color: AppColors.primary, size: 22),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildVoiceSection(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    final engineId = settings.selectedEngineId;
    final engineName = settings.selectedEngine.name;
    final voices = settings.getDefaultVoices(engineId);
    final selectedVoiceId = settings.getSelectedVoiceId(engineId) ?? voices.first.voiceId;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Voice Selection ($engineName)', Icons.record_voice_over_rounded),
        _buildCard(
          child: Column(
            children: voices.map((voice) {
              final isSelected = selectedVoiceId == voice.voiceId;

              return InkWell(
                onTap: () => settings.setSelectedVoice(engineId, voice.voiceId),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: voice == voices.last
                            ? Colors.transparent
                            : AppColors.outlineVariant.withOpacity(0.3),
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 16,
                        backgroundColor: isSelected 
                            ? AppColors.primaryContainer 
                            : AppColors.surfaceContainerHigh,
                        child: Text(
                          voice.name.substring(0, 1),
                          style: GoogleFonts.outfit(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: isSelected ? AppColors.primary : AppColors.onSurfaceVariant,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          voice.name,
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                            color: isSelected ? AppColors.primary : AppColors.onSurface,
                          ),
                        ),
                      ),
                      if (isSelected)
                        const Icon(Icons.check_rounded, color: AppColors.primary, size: 20),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildPlaybackSection(BuildContext context) {
    final settings = context.watch<SettingsProvider>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Playback', Icons.speed_rounded),
        _buildCard(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Speed', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.onSurface)),
                    Text('${settings.speed.toStringAsFixed(1)}x', style: GoogleFonts.inter(fontSize: 14, color: AppColors.primary, fontWeight: FontWeight.bold)),
                  ],
                ),
                SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    activeTrackColor: AppColors.primary,
                    inactiveTrackColor: AppColors.primaryContainer,
                    thumbColor: AppColors.secondary,
                    overlayColor: AppColors.primary.withOpacity(0.1),
                    trackHeight: 4,
                  ),
                  child: Slider(
                    value: settings.speed,
                    min: 0.5,
                    max: 2.0,
                    divisions: 15,
                    onChanged: (val) => settings.setSpeed(val),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildApiConfigSection(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    final engine = settings.selectedEngine;
    
    // Always show Backend URL
    final List<Widget> children = [];
    
    children.add(
      _ApiFieldItem(
        label: 'Backend Base URL',
        initialValue: settings.backendUrl,
        onSave: (val) => settings.setBackendUrl(val),
      )
    );

    if (!engine.isFree && engine.configFields.isNotEmpty) {
      for (final field in engine.configFields) {
        children.add(Divider(height: 1, color: AppColors.outlineVariant.withOpacity(0.3)));
        children.add(
          _ApiFieldItem(
            label: field.label,
            initialValue: settings.getCredential(engine.id, field.key),
            onSave: (val) => settings.setCredential(engine.id, field.key, val),
            isObscured: field.isSecret,
          )
        );
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Configuration', Icons.api_rounded),
        _buildCard(
          child: Column(
            children: children,
          ),
        ),
      ],
    );
  }
}

class _ApiFieldItem extends StatefulWidget {
  final String label;
  final String initialValue;
  final ValueChanged<String> onSave;
  final bool isObscured;

  const _ApiFieldItem({
    required this.label,
    required this.initialValue,
    required this.onSave,
    this.isObscured = false,
  });

  @override
  State<_ApiFieldItem> createState() => _ApiFieldItemState();
}

class _ApiFieldItemState extends State<_ApiFieldItem> {
  late TextEditingController _controller;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
  }

  @override
  void didUpdateWidget(covariant _ApiFieldItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialValue != widget.initialValue && !_isEditing) {
      _controller.text = widget.initialValue;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.label,
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 44,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _isEditing ? AppColors.primary : Colors.transparent,
                    ),
                  ),
                  child: TextField(
                    controller: _controller,
                    obscureText: widget.isObscured && !_isEditing,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Enter ${widget.label}',
                      hintStyle: GoogleFonts.inter(color: AppColors.outline),
                    ),
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: AppColors.onSurface,
                    ),
                    onChanged: (_) => setState(() => _isEditing = true),
                  ),
                ),
              ),
              if (_isEditing) ...[
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.check_circle_rounded, color: AppColors.primary),
                  onPressed: () {
                    widget.onSave(_controller.text);
                    setState(() => _isEditing = false);
                    FocusScope.of(context).unfocus();
                  },
                ),
              ]
            ],
          ),
        ],
      ),
    );
  }
}
