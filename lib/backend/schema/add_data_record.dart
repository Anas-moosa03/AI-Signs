import 'dart:async';

import 'package:collection/collection.dart';

import '/backend/schema/util/firestore_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class AddDataRecord extends FirestoreRecord {
  AddDataRecord._(
    DocumentReference reference,
    Map<String, dynamic> data,
  ) : super(reference, data) {
    _initializeFields();
  }

  // "image" field.
  String? _image;
  String get image => _image ?? '';
  bool hasImage() => _image != null;

  // "meaning" field.
  String? _meaning;
  String get meaning => _meaning ?? '';
  bool hasMeaning() => _meaning != null;

  void _initializeFields() {
    _image = snapshotData['image'] as String?;
    _meaning = snapshotData['meaning'] as String?;
  }

  static CollectionReference get collection =>
      FirebaseFirestore.instance.collection('AddData');

  static Stream<AddDataRecord> getDocument(DocumentReference ref) =>
      ref.snapshots().map((s) => AddDataRecord.fromSnapshot(s));

  static Future<AddDataRecord> getDocumentOnce(DocumentReference ref) =>
      ref.get().then((s) => AddDataRecord.fromSnapshot(s));

  static AddDataRecord fromSnapshot(DocumentSnapshot snapshot) =>
      AddDataRecord._(
        snapshot.reference,
        mapFromFirestore(snapshot.data() as Map<String, dynamic>),
      );

  static AddDataRecord getDocumentFromData(
    Map<String, dynamic> data,
    DocumentReference reference,
  ) =>
      AddDataRecord._(reference, mapFromFirestore(data));

  @override
  String toString() =>
      'AddDataRecord(reference: ${reference.path}, data: $snapshotData)';

  @override
  int get hashCode => reference.path.hashCode;

  @override
  bool operator ==(other) =>
      other is AddDataRecord &&
      reference.path.hashCode == other.reference.path.hashCode;
}

Map<String, dynamic> createAddDataRecordData({
  String? image,
  String? meaning,
}) {
  final firestoreData = mapToFirestore(
    <String, dynamic>{
      'image': image,
      'meaning': meaning,
    }.withoutNulls,
  );

  return firestoreData;
}

class AddDataRecordDocumentEquality implements Equality<AddDataRecord> {
  const AddDataRecordDocumentEquality();

  @override
  bool equals(AddDataRecord? e1, AddDataRecord? e2) {
    return e1?.image == e2?.image && e1?.meaning == e2?.meaning;
  }

  @override
  int hash(AddDataRecord? e) =>
      const ListEquality().hash([e?.image, e?.meaning]);

  @override
  bool isValidKey(Object? o) => o is AddDataRecord;
}
