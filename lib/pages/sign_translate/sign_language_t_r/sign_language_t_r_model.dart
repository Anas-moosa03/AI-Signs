import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import 'sign_language_t_r_widget.dart' show SignLanguageTRWidget;
import 'package:flutter/material.dart';

class SignLanguageTRModel extends FlutterFlowModel<SignLanguageTRWidget> {
  ///  State fields for stateful widgets in this page.

  // State field(s) for TextField widget.
  FocusNode? textFieldFocusNode;
  TextEditingController? textController;
  String? Function(BuildContext, String?)? textControllerValidator;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {
    textFieldFocusNode?.dispose();
    textController?.dispose();
  }
}
