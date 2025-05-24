import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import 'password_recovery_widget.dart' show PasswordRecoveryWidget;
import 'package:flutter/material.dart';

class PasswordRecoveryModel extends FlutterFlowModel<PasswordRecoveryWidget> {
  ///  State fields for stateful widgets in this page.

  // State field(s) for emailaddressRecovery widget.
  FocusNode? emailaddressRecoveryFocusNode;
  TextEditingController? emailaddressRecoveryTextController;
  String? Function(BuildContext, String?)?
      emailaddressRecoveryTextControllerValidator;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {
    emailaddressRecoveryFocusNode?.dispose();
    emailaddressRecoveryTextController?.dispose();
  }
}
