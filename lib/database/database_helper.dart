import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/medical_profile.dart';
import '../models/ice_contact.dart';
import '../models/incident_log.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('rescusphere.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future _createDB(Database db, int version) async {
    const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    const textType = 'TEXT NOT NULL';
    const doubleType = 'REAL NOT NULL';

    await db.execute('''
CREATE TABLE medical_profile (
  id $idType,
  name $textType,
  bloodType $textType,
  allergies $textType,
  medicalConditions $textType
)
''');

    await db.execute('''
CREATE TABLE ice_contacts (
  id $idType,
  name $textType,
  relation $textType,
  phoneNumber $textType
)
''');

    await db.execute('''
CREATE TABLE incident_logs (
  id $idType,
  timestamp $textType,
  type $textType,
  status $textType,
  summary $textType,
  latitude $doubleType,
  longitude $doubleType
)
''');

    // Pre-populate Database with initial user template
    await db.insert('medical_profile', {
      'name': 'John Doe',
      'bloodType': 'O+',
      'allergies': 'Penicillin, Peanuts',
      'medicalConditions': 'Asthma',
    });

    await db.insert('ice_contacts', {
      'name': 'Jane Doe',
      'relation': 'Spouse',
      'phoneNumber': '+1-555-0192',
    });

    await db.insert('incident_logs', {
      'timestamp': DateTime.now().subtract(const Duration(days: 40)).toIso8601String(),
      'type': 'Medical',
      'status': 'Resolved',
      'summary': 'Severe asthma attack. Dispatched ambulance.',
      'latitude': 37.7749,
      'longitude': -122.4194,
    });

    await db.insert('incident_logs', {
      'timestamp': DateTime.now().subtract(const Duration(days: 12)).toIso8601String(),
      'type': 'Security',
      'status': 'Resolved',
      'summary': 'Suspicious activity reported outside residence.',
      'latitude': 37.7833,
      'longitude': -122.4167,
    });
  }

  // Medical Profile CRUD
  Future<MedicalProfile?> getMedicalProfile() async {
    final db = await instance.database;
    final maps = await db.query('medical_profile', limit: 1);
    if (maps.isNotEmpty) {
      return MedicalProfile.fromMap(maps.first);
    }
    return null;
  }

  Future<int> updateMedicalProfile(MedicalProfile profile) async {
    final db = await instance.database;
    final existing = await getMedicalProfile();
    if (existing != null && existing.id != null) {
      return await db.update(
        'medical_profile',
        profile.toMap(),
        where: 'id = ?',
        whereArgs: [existing.id],
      );
    } else {
      return await db.insert('medical_profile', profile.toMap());
    }
  }

  Future<int> resetMedicalProfile() async {
    final db = await instance.database;
    return await db.delete('medical_profile');
  }

  // ICE Contacts CRUD
  Future<List<IceContact>> getIceContacts() async {
    final db = await instance.database;
    final result = await db.query('ice_contacts');
    return result.map((json) => IceContact.fromMap(json)).toList();
  }

  Future<int> addIceContact(IceContact contact) async {
    final db = await instance.database;
    return await db.insert('ice_contacts', contact.toMap());
  }

  Future<int> deleteIceContact(int id) async {
    final db = await instance.database;
    return await db.delete(
      'ice_contacts',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Incident Logs CRUD
  Future<List<IncidentLog>> getIncidentLogs() async {
    final db = await instance.database;
    final result = await db.query('incident_logs', orderBy: 'timestamp DESC');
    return result.map((json) => IncidentLog.fromMap(json)).toList();
  }

  Future<int> addIncidentLog(IncidentLog log) async {
    final db = await instance.database;
    return await db.insert('incident_logs', log.toMap());
  }

  Future<int> updateIncidentStatus(int id, String newStatus) async {
    final db = await instance.database;
    return await db.update(
      'incident_logs',
      {'status': newStatus},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteIncidentLog(int id) async {
    final db = await instance.database;
    return await db.delete(
      'incident_logs',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> clearAllIncidentLogs() async {
    final db = await instance.database;
    return await db.delete('incident_logs');
  }
}
