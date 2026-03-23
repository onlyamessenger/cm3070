import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:fortify/widgets/admin/admin_dropdown_field.dart';
import 'package:fortify/widgets/admin/admin_form_actions.dart';
import 'package:fortify/widgets/admin/admin_form_field.dart';

class AdminKitItemForm extends StatefulWidget {
  final KitItem? kitItem;
  final bool isLoading;
  final void Function(KitItem) onSave;

  const AdminKitItemForm({super.key, this.kitItem, required this.isLoading, required this.onSave});

  @override
  State<AdminKitItemForm> createState() => _AdminKitItemFormState();
}

class _AdminKitItemFormState extends State<AdminKitItemForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  late final TextEditingController _itemNameController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _sortOrderController;

  ContentSource _source = ContentSource.human;
  bool _isPublished = false;

  @override
  void initState() {
    super.initState();
    _itemNameController = TextEditingController(text: widget.kitItem?.itemName ?? '');
    _descriptionController = TextEditingController(text: widget.kitItem?.description ?? '');
    _sortOrderController = TextEditingController(text: widget.kitItem?.sortOrder.toString() ?? '');
    _source = widget.kitItem?.source ?? ContentSource.human;
    _isPublished = widget.kitItem?.isPublished ?? false;
  }

  @override
  void dispose() {
    _itemNameController.dispose();
    _descriptionController.dispose();
    _sortOrderController.dispose();
    super.dispose();
  }

  void _handleSave() {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    final int? sortOrder = int.tryParse(_sortOrderController.text.trim());
    if (sortOrder == null) {
      return;
    }

    final DateTime now = DateTime.now();

    final KitItem saved = KitItem(
      id: widget.kitItem?.id ?? '',
      created: widget.kitItem?.created ?? now,
      updated: now,
      createdBy: widget.kitItem?.createdBy ?? '',
      updatedBy: '',
      isDeleted: widget.kitItem?.isDeleted ?? false,
      source: _source,
      isPublished: _isPublished,
      userId: null,
      itemName: _itemNameController.text.trim(),
      description: _descriptionController.text.trim(),
      sortOrder: sortOrder,
      isChecked: false,
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
            label: 'Item Name',
            controller: _itemNameController,
            validator: (String? value) {
              if (value == null || value.trim().isEmpty) {
                return 'Item name is required';
              }
              return null;
            },
          ),
          AdminFormField(label: 'Description', controller: _descriptionController, maxLines: 3),
          AdminFormField(
            label: 'Sort Order',
            controller: _sortOrderController,
            keyboardType: TextInputType.number,
            validator: (String? value) {
              if (value == null || value.trim().isEmpty) {
                return 'Sort order is required';
              }
              final int? parsed = int.tryParse(value.trim());
              if (parsed == null || parsed < 0) {
                return 'Sort order must be 0 or greater';
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
