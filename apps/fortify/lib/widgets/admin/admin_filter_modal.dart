import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:fortify/config/theme/admin_colors.dart';
import 'package:fortify/widgets/admin/admin_button.dart';

class FilterField {
  final String key;
  final String label;
  final List<FilterOption> options;
  const FilterField({required this.key, required this.label, required this.options});
}

class FilterOption {
  final String label;
  final dynamic value;
  const FilterOption({required this.label, required this.value});
}

class AdminFilterModal extends StatefulWidget {
  final List<FilterField> fields;
  final Map<String, dynamic> currentFilters;

  const AdminFilterModal({super.key, required this.fields, required this.currentFilters});

  static Future<Map<String, dynamic>?> show(
    BuildContext context, {
    required List<FilterField> fields,
    required Map<String, dynamic> currentFilters,
  }) {
    final bool isDesktop = MediaQuery.of(context).size.width >= 768;
    if (isDesktop) {
      return showDialog<Map<String, dynamic>>(
        context: context,
        builder: (BuildContext context) => BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Dialog(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: AdminFilterModal(fields: fields, currentFilters: currentFilters),
            ),
          ),
        ),
      );
    } else {
      return showModalBottomSheet<Map<String, dynamic>>(
        context: context,
        backgroundColor: AdminColors.surfaceContainer,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
        builder: (BuildContext context) => AdminFilterModal(fields: fields, currentFilters: currentFilters),
      );
    }
  }

  @override
  State<AdminFilterModal> createState() => _AdminFilterModalState();
}

class _AdminFilterModalState extends State<AdminFilterModal> {
  late Map<String, dynamic> _filters;

  @override
  void initState() {
    super.initState();
    _filters = Map<String, dynamic>.from(widget.currentFilters);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Text(
            'Filters',
            style: TextStyle(color: AdminColors.onSurface, fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 16),
          ...widget.fields.map((FilterField field) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: DropdownButtonFormField<dynamic>(
                initialValue: _filters[field.key],
                decoration: InputDecoration(labelText: field.label),
                dropdownColor: AdminColors.surfaceContainerHigh,
                items: <DropdownMenuItem<dynamic>>[
                  const DropdownMenuItem<dynamic>(value: null, child: Text('All')),
                  ...field.options.map((FilterOption opt) {
                    return DropdownMenuItem<dynamic>(value: opt.value, child: Text(opt.label));
                  }),
                ],
                onChanged: (dynamic value) => setState(() => _filters[field.key] = value),
              ),
            );
          }),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              AdminButton(
                label: 'Clear',
                isPrimary: false,
                onPressed: () => Navigator.of(context).pop(<String, dynamic>{}),
              ),
              const SizedBox(width: 12),
              AdminButton(label: 'Apply', onPressed: () => Navigator.of(context).pop(_filters)),
            ],
          ),
        ],
      ),
    );
  }
}
