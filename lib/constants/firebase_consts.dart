/// Firebase collection names and constants

class FirebaseConsts {
  // Collections
  static const String usersCollection = 'users';
  static const String disputesCollection = 'disputes';
  static const String documentsCollection = 'documents';
  static const String notificationsCollection = 'notifications';
  static const String auditLogsCollection = 'audit_logs';
  static const String systemLogsCollection = 'system_logs';

  // Storage
  static const String documentsFolder = 'dispute_documents';
  static const String profilePictureFolder = 'profile_pictures';

  // Firebase config
  static const String firebaseProjectId = 'land-disputes-system';

  // Auth
  static const String authProvider = 'password';
  static const int sessionTimeout = 3600000; // 1 hour

  // Default values
  static const int defaultPageSize = 20;
  static const String defaultOrderBy = 'createdAt';
  static const String defaultOrderDirection = 'desc';
}