import 'package:flutter/material.dart';

/// Wraps a tab child to keep it alive when the user switches tabs.
///
/// Without this, TabBarView disposes off-screen children and their
/// form state (TextEditingController values) is lost.
class AdminKeepAliveTab extends StatefulWidget {
  final Widget child;

  const AdminKeepAliveTab({super.key, required this.child});

  @override
  State<AdminKeepAliveTab> createState() => _AdminKeepAliveTabState();
}

class _AdminKeepAliveTabState extends State<AdminKeepAliveTab> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return widget.child;
  }
}
