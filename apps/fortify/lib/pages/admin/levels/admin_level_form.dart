import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:fortify/widgets/admin/admin_dropdown_field.dart';
import 'package:fortify/widgets/admin/admin_form_actions.dart';
import 'package:fortify/widgets/admin/admin_form_field.dart';

class AdminLevelForm extends StatefulWidget {
  final Level? level;
  final bool isLoading;
  final void Function(Level) onSave;

  const AdminLevelForm({super.key, this.level, required this.isLoading, required this.onSave});

  @override
  State<AdminLevelForm> createState() => _AdminLevelFormState();
}

class _AdminLevelFormState extends State<AdminLevelForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  late final TextEditingController _levelNumberController;
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _iconController;
  late final TextEditingController _xpThresholdController;

  ContentSource _source = ContentSource.human;
  bool _isPublished = false;

  @override
  void initState() {
    super.initState();
    _levelNumberController = TextEditingController(text: widget.level?.level.toString() ?? '');
    _titleController = TextEditingController(text: widget.level?.title ?? '');
    _descriptionController = TextEditingController(text: widget.level?.description ?? '');
    _iconController = TextEditingController(text: widget.level?.icon ?? '');
    _xpThresholdController = TextEditingController(text: widget.level?.xpThreshold.toString() ?? '');
    _source = widget.level?.source ?? ContentSource.human;
    _isPublished = widget.level?.isPublished ?? false;
  }

  @override
  void dispose() {
    _levelNumberController.dispose();
    _titleController.dispose();
    _descriptionController.dispose();
    _iconController.dispose();
    _xpThresholdController.dispose();
    super.dispose();
  }

  void _handleSave() {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    final int? levelNumber = int.tryParse(_levelNumberController.text.trim());
    final int? xpThreshold = int.tryParse(_xpThresholdController.text.trim());

    if (levelNumber == null || xpThreshold == null) {
      return;
    }

    final DateTime now = DateTime.now();

    final Level saved = Level(
      id: widget.level?.id ?? '',
      created: widget.level?.created ?? now,
      updated: now,
      createdBy: widget.level?.createdBy ?? '',
      updatedBy: '',
      isDeleted: widget.level?.isDeleted ?? false,
      source: _source,
      isPublished: _isPublished,
      level: levelNumber,
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      icon: _iconController.text.trim(),
      xpThreshold: xpThreshold,
    );

    widget.onSave(saved);
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          AdminFormField(
            label: 'Level Number',
            controller: _levelNumberController,
            keyboardType: TextInputType.number,
            validator: (String? value) {
              if (value == null || value.trim().isEmpty) {
                return 'Level number is required';
              }
              final int? parsed = int.tryParse(value.trim());
              if (parsed == null || parsed <= 0) {
                return 'Level number must be greater than 0';
              }
              return null;
            },
          ),
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
          AdminFormField(label: 'Description', controller: _descriptionController, maxLines: 3),
          AdminFormField(
            label: 'Icon',
            controller: _iconController,
            validator: (String? value) {
              if (value == null || value.trim().isEmpty) {
                return 'Icon is required';
              }
              return null;
            },
          ),
          AdminFormField(
            label: 'XP Threshold',
            controller: _xpThresholdController,
            keyboardType: TextInputType.number,
            validator: (String? value) {
              if (value == null || value.trim().isEmpty) {
                return 'XP Threshold is required';
              }
              final int? parsed = int.tryParse(value.trim());
              if (parsed == null || parsed < 0) {
                return 'XP Threshold must be 0 or greater';
              }
              return null;
            },
          ),
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
