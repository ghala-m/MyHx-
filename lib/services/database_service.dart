import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/patient.dart'; // استيراد نموذج المريض

class DatabaseService {
  // الحصول على مرجع (reference) لمجموعة المرضى في Firestore
  final CollectionReference _patientsCollection = FirebaseFirestore.instance.collection('patients');

  // --- دالة لإضافة مريض جديد ---
  Future<void> addPatient(Patient patient) async {
    try {
      // استخدام id المريض كمعرف للمستند (document) في Firestore
      await _patientsCollection.doc(patient.id).set(patient.toJson());
    } catch (e) {
      // في تطبيق حقيقي، يجب معالجة الخطأ بشكل أفضل
      print('Error adding patient: $e');
      rethrow; // إعادة رمي الخطأ لمعالجته في الواجهة
    }
  }

  // --- دالة لجلب قائمة كل المرضى ---
  Future<List<Patient>> getPatients() async {
    try {
      final snapshot = await _patientsCollection.orderBy('createdAt', descending: true).get();
      
      // تحويل كل مستند (document) إلى كائن Patient
      return snapshot.docs.map((doc) {
        return Patient.fromJson(doc.data() as Map<String, dynamic>);
      }).toList();
    } catch (e) {
      print('Error getting patients: $e');
      return []; // إرجاع قائمة فارغة في حال حدوث خطأ
    }
  }

  // --- دالة لتحديث بيانات مريض (مثل حالته) ---
  Future<void> updatePatient(String patientId, Map<String, dynamic> dataToUpdate) async {
    try {
      await _patientsCollection.doc(patientId).update(dataToUpdate);
    } catch (e) {
      print('Error updating patient: $e');
      rethrow;
    }
  }

  // --- دالة لحذف مريض ---
  Future<void> deletePatient(String patientId) async {
    try {
      await _patientsCollection.doc(patientId).delete();
    } catch (e) {
      print('Error deleting patient: $e');
      rethrow;
    }
  }

  // يمكنك إضافة دوال أخرى هنا لاحقاً، مثل إضافة تقرير طبي
  // Future<void> addMedicalRecord(String patientId, Map<String, dynamic> record) async { ... }
}
