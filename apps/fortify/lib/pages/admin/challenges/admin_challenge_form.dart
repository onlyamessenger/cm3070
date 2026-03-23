import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:fortify/config/theme/admin_colors.dart';
import 'package:fortify/widgets/admin/admin_dropdown_field.dart';
import 'package:fortify/widgets/admin/admin_form_actions.dart';
import 'package:fortify/widgets/admin/admin_form_field.dart';

class AdminChallengeForm extends StatefulWidget {
  final Challenge? challenge;
  final bool isLoading;
  final void Function(Challenge) onSave;

  const AdminChallengeForm({super.key, this.challenge, required this.isLoading, required this.onSave});

  @override
  AdminChallengeFormState createState() => AdminChallengeFormState();
}

class AdminChallengeFormState extends State<AdminChallengeForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _xpRewardController;
  late final TextEditingController _questIdController;

  ChallengeType _type = ChallengeType.quiz;
  Difficulty _difficulty = Difficulty.beginner;
  DisasterType _disasterType = DisasterType.flood;
  ContentSource _source = ContentSource.human;
  bool _isPublished = false;
  ReadinessSectionType? _unlocksSectionType;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.challenge?.title ?? '');
    _descriptionController = TextEditingController(text: widget.challenge?.description ?? '');
    _xpRewardController = TextEditingController(text: widget.challenge?.xpReward.toString() ?? '');
    _questIdController = TextEditingController(text: widget.challenge?.questId ?? '');
    _type = widget.challenge?.type ?? ChallengeType.quiz;
    _difficulty = widget.challenge?.difficulty ?? Difficulty.beginner;
    _disasterType = widget.challenge?.disasterType ?? DisasterType.flood;
    _source = widget.challenge?.source ?? ContentSource.human;
    _isPublished = widget.challenge?.isPublished ?? false;
    _unlocksSectionType = widget.challenge?.unlocksSectionType != null
        ? ReadinessSectionType.fromString(widget.challenge!.unlocksSectionType!)
        : null;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _xpRewardController.dispose();
    _questIdController.dispose();
    super.dispose();
  }

  /// Validates the form and returns the built Challenge, or null if validation fails.
  Challenge? validateAndBuild() {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return null;
    }

    final int? xpReward = int.tryParse(_xpRewardController.text.trim());
    if (xpReward == null) {
      return null;
    }

    final DateTime now = DateTime.now();
    final String? questId = _questIdController.text.trim().isEmpty ? null : _questIdController.text.trim();

    return Challenge(
      id: widget.challenge?.id ?? '',
      created: widget.challenge?.created ?? now,
      updated: now,
      createdBy: widget.challenge?.createdBy ?? '',
      updatedBy: '',
      isDeleted: widget.challenge?.isDeleted ?? false,
      source: _source,
      isPublished: _isPublished,
      type: _type,
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      xpReward: xpReward,
      difficulty: _difficulty,
      disasterType: _disasterType,
      questId: questId,
      unlocksSectionType: _unlocksSectionType?.name,
    );
  }

  void _handleSave() {
    final Challenge? challenge = validateAndBuild();
    if (challenge != null) {
      widget.onSave(challenge);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          AdminFormField(
            label: 'Title',
            controller: _titleController,
            validator: (String? value) {
              if (value == null || value.trim().isEmpty) {
                return 'Title is required';
              }
              return null;
            },
          ),
          AdminFormField(
            label: 'Description',
            controller: _descriptionController,
            maxLines: 3,
            validator: (String? value) {
              if (value == null || value.trim().isEmpty) {
                return 'Description is required';
              }
              return null;
            },
          ),
          AdminDropdownField<ChallengeType>(
            label: 'Type',
            value: _type,
            items: ChallengeType.values,
            displayName: (ChallengeType item) => item.displayName,
            onChanged: (ChallengeType? value) {
              if (value != null) {
                setState(() => _type = value);
              }
            },
          ),
          AdminFormField(
            label: 'XP Reward',
            controller: _xpRewardController,
            keyboardType: TextInputType.number,
            validator: (String? value) {
              if (value == null || value.trim().isEmpty) {
                return 'XP Reward is required';
              }
              final int? parsed = int.tryParse(value.trim());
              if (parsed == null || parsed < 0) {
                return 'XP Reward must be 0 or greater';
              }
              return null;
            },
          ),
          AdminDropdownField<Difficulty>(
            label: 'Difficulty',
            value: _difficulty,
            items: Difficulty.values,
            displayName: (Difficulty item) => item.displayName,
            onChanged: (Difficulty? value) {
              if (value != null) {
                setState(() => _difficulty = value);
              }
            },
          ),
          AdminDropdownField<DisasterType>(
            label: 'Disaster Type',
            value: _disasterType,
            items: DisasterType.values,
            displayName: (DisasterType item) => item.displayName,
            onChanged: (DisasterType? value) {
              if (value != null) {
                setState(() => _disasterType = value);
              }
            },
          ),
          AdminFormField(label: 'Quest ID (optional)', controller: _questIdController),
          _buildUnlocksSectionTypeDropdown(),
          AdminDropdownField<ContentSource>(
            label: 'Source',
            value: _source,
            items: ContentSource.values,
            displayName: (ContentSource item) => item.displayName,
            onChanged: (ContentSource? value) {
              if (value != null) {
                setState(() => _source = value);
              }
            },
          ),
          AdminDropdownField<bool>(
            label: 'Published',
            value: _isPublished,
            items: const <bool>[true, false],
            displayName: (bool item) => item ? 'Published' : 'Draft',
            onChanged: (bool? value) {
              if (value != null) {
                setState(() => _isPublished = value);
              }
            },
          ),
          AdminFormActions(isLoading: widget.isLoading, onSave: _handleSave),
        ],
      ),
    );
  }

  Widget _buildUnlocksSectionTypeDropdown() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: DropdownButtonFormField<ReadinessSectionType?>(
        initialValue: _unlocksSectionType,
        items: <DropdownMenuItem<ReadinessSectionType?>>[
          const DropdownMenuItem<ReadinessSectionType?>(value: null, child: Text('None')),
          ...ReadinessSectionType.values.map(
            (ReadinessSectionType type) =>
                DropdownMenuItem<ReadinessSectionType?>(value: type, child: Text(type.displayName)),
          ),
        ],
        onChanged: (ReadinessSectionType? value) {
          setState(() => _unlocksSectionType = value);
        },
        decoration: const InputDecoration(labelText: 'Unlocks Section Type (optional)'),
        dropdownColor: AdminColors.surfaceContainerHigh,
        style: const TextStyle(color: AdminColors.onSurface),
      ),
    );
  }
}
