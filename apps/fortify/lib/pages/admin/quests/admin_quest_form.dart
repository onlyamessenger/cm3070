import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:fortify/widgets/admin/admin_dropdown_field.dart';
import 'package:fortify/widgets/admin/admin_form_actions.dart';
import 'package:fortify/widgets/admin/admin_form_field.dart';

class AdminQuestForm extends StatefulWidget {
  final Quest? quest;
  final bool isLoading;
  final void Function(Quest) onSave;

  /// External startNodeId - managed by the tree widget, not this form.
  final String startNodeId;

  const AdminQuestForm({super.key, this.quest, required this.isLoading, required this.onSave, this.startNodeId = ''});

  @override
  AdminQuestFormState createState() => AdminQuestFormState();
}

class AdminQuestFormState extends State<AdminQuestForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _totalDaysController;
  late final TextEditingController _regionController;

  Difficulty _difficulty = Difficulty.beginner;
  DisasterType _disasterType = DisasterType.flood;
  ContentSource _source = ContentSource.human;
  bool _isPublished = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.quest?.title ?? '');
    _descriptionController = TextEditingController(text: widget.quest?.description ?? '');
    _totalDaysController = TextEditingController(text: widget.quest?.totalDays.toString() ?? '');
    _regionController = TextEditingController(text: widget.quest?.region ?? '');
    _difficulty = widget.quest?.difficulty ?? Difficulty.beginner;
    _disasterType = widget.quest?.disasterType ?? DisasterType.flood;
    _source = widget.quest?.source ?? ContentSource.human;
    _isPublished = widget.quest?.isPublished ?? false;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _totalDaysController.dispose();
    _regionController.dispose();
    super.dispose();
  }

  /// Validates the form and returns the built Quest, or null if validation fails.
  /// Uses the externally-provided startNodeId (managed by the tree widget).
  Quest? validateAndBuild(String startNodeId) {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return null;
    }

    final int? totalDays = int.tryParse(_totalDaysController.text.trim());
    if (totalDays == null) {
      return null;
    }

    final DateTime now = DateTime.now();
    final String? region = _regionController.text.trim().isEmpty ? null : _regionController.text.trim();

    return Quest(
      id: widget.quest?.id ?? '',
      created: widget.quest?.created ?? now,
      updated: now,
      createdBy: widget.quest?.createdBy ?? '',
      updatedBy: '',
      isDeleted: widget.quest?.isDeleted ?? false,
      source: _source,
      isPublished: _isPublished,
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      totalDays: totalDays,
      startNodeId: startNodeId,
      difficulty: _difficulty,
      disasterType: _disasterType,
      region: region,
    );
  }

  void _handleSave() {
    final Quest? quest = validateAndBuild(widget.startNodeId);
    if (quest != null) {
      widget.onSave(quest);
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
          AdminFormField(
            label: 'Total Days',
            controller: _totalDaysController,
            keyboardType: TextInputType.number,
            validator: (String? value) {
              if (value == null || value.trim().isEmpty) {
                return 'Total days is required';
              }
              final int? parsed = int.tryParse(value.trim());
              if (parsed == null || parsed <= 0) {
                return 'Total days must be greater than 0';
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
          AdminFormField(label: 'Region (optional)', controller: _regionController),
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
}
