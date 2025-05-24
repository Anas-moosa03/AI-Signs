import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import 'password_change_widget.dart' show PasswordChangeWidget;
import 'package:flutter/material.dart';

class PasswordChangeModel extends FlutterFlowModel<PasswordChangeWidget> {
  ///  State fields for stateful widgets in this page.

  // State field(s) for emailAddress widget.
  FocusNode? emailAddressFocusNode;
  TextEditingController? emailAddressTextController;
  String? Function(BuildContext, String?)? emailAddressTextControllerValidator;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {
    emailAddressFocusNode?.dispose();
    emailAddressTextController?.dispose();
  }
}
