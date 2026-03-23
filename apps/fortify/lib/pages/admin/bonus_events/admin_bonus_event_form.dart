import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:fortify/config/theme/admin_colors.dart';
import 'package:fortify/widgets/admin/admin_dropdown_field.dart';
import 'package:fortify/widgets/admin/admin_form_actions.dart';
import 'package:fortify/widgets/admin/admin_form_field.dart';

class AdminBonusEventForm extends StatefulWidget {
  final BonusEvent? bonusEvent;
  final bool isLoading;
  final void Function(BonusEvent) onSave;

  const AdminBonusEventForm({super.key, this.bonusEvent, required this.isLoading, required this.onSave});

  @override
  State<AdminBonusEventForm> createState() => _AdminBonusEventFormState();
}

class _AdminBonusEventFormState extends State<AdminBonusEventForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _multiplierController;
  late final TextEditingController _startsAtController;
  late final TextEditingController _endsAtController;

  bool _isActive = false;
  DateTime? _startsAt;
  DateTime? _endsAt;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.bonusEvent?.title ?? '');
    _descriptionController = TextEditingController(text: widget.bonusEvent?.description ?? '');
    _multiplierController = TextEditingController(text: widget.bonusEvent?.multiplier.toString() ?? '');
    _startsAt = widget.bonusEvent?.startsAt;
    _endsAt = widget.bonusEvent?.endsAt;
    _startsAtController = TextEditingController(text: _startsAt != null ? _formatDate(_startsAt!) : '');
    _endsAtController = TextEditingController(text: _endsAt != null ? _formatDate(_endsAt!) : '');
    _isActive = widget.bonusEvent?.isActive ?? false;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _multiplierController.dispose();
    _startsAtController.dispose();
    _endsAtController.dispose();
    super.dispose();
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  Future<void> _pickDate(TextEditingController controller, DateTime? current, void Function(DateTime) onPicked) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: current ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: Theme.of(context).copyWith(colorScheme: const ColorScheme.dark(primary: AdminColors.primary)),
          child: child!,
        );
      },
    );
    if (picked != null) {
      onPicked(picked);
      controller.text = _formatDate(picked);
    }
  }

  void _handleSave() {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    final double? multiplier = double.tryParse(_multiplierController.text.trim());
    if (multiplier == null || _startsAt == null || _endsAt == null) {
      return;
    }

    final DateTime now = DateTime.now();

    final BonusEvent saved = BonusEvent(
      id: widget.bonusEvent?.id ?? '',
      created: widget.bonusEvent?.created ?? now,
      updated: now,
      createdBy: widget.bonusEvent?.createdBy ?? '',
      updatedBy: '',
      isDeleted: widget.bonusEvent?.isDeleted ?? false,
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      multiplier: multiplier,
      startsAt: _startsAt!,
      endsAt: _endsAt!,
      isActive: _isActive,
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
            label: 'Multiplier',
            controller: _multiplierController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            validator: (String? value) {
              if (value == null || value.trim().isEmpty) {
                return 'Multiplier is required';
              }
              final double? parsed = double.tryParse(value.trim());
              if (parsed == null || parsed <= 0) {
                return 'Multiplier must be greater than 0';
              }
              return null;
            },
          ),
          AdminFormField(
            label: 'Starts At',
            controller: _startsAtController,
            readOnly: true,
            onTap: () => _pickDate(_startsAtController, _startsAt, (DateTime d) => setState(() => _startsAt = d)),
            validator: (String? value) {
              if (value == null || value.trim().isEmpty) {
                return 'Start date is required';
              }
              return null;
            },
          ),
          AdminFormField(
            label: 'Ends At',
            controller: _endsAtController,
            readOnly: true,
            onTap: () => _pickDate(_endsAtController, _endsAt, (DateTime d) => setState(() => _endsAt = d)),
            validator: (String? value) {
              if (value == null || value.trim().isEmpty) {
                return 'End date is required';
              }
              return null;
            },
          ),
          AdminDropdownField<bool>(
            label: 'Active',
            value: _isActive,
            items: const <bool>[true, false],
            displayName: (bool item) => item ? 'Active' : 'Inactive',
            onChanged: (bool? value) {
              if (value != null) {
                setState(() => _isActive = value);
              }
            },
          ),
          AdminFormActions(isLoading: widget.isLoading, onSave: _handleSave),
        ],
      ),
    );
  }
}
