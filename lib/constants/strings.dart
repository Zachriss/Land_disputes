/// App text, labels, and string constants

class AppStrings {
  // App info
  static const String appName = 'Land Disputes Management System';
  static const String appVersion = '1.0.0';

  // Authentication
  static const String login = 'Login';
  static const String register = 'Register';
  static const String logout = 'Logout';
  static const String email = 'Email';
  static const String password = 'Password';
  static const String confirmPassword = 'Confirm Password';
  static const String fullName = 'Full Name';
  static const String phoneNumber = 'Phone Number';
  static const String role = 'Role';
  static const String forgotPassword = 'Forgot Password?';
  static const String dontHaveAccount = "Don't have an account?";
  static const String alreadyHaveAccount = 'Already have an account?';
  static const String registerNow = 'Register Now';
  static const String loginNow = 'Login Now';
  static const String signInError = 'Invalid email or password';
  static const String passwordMismatch = 'Passwords do not match';
  static const String registrationSuccess = 'Registration successful';
  static const String loginSuccess = 'Login successful';

  // Roles
  static const String roleCitizen = 'citizen';
  static const String roleOfficer = 'officer';
  static const String roleMediator = 'mediator';
  static const String roleAdmin = 'admin';

  // Navigation
  static const String dashboard = 'Dashboard';
  static const String myCases = 'My Cases';
  static const String reportDispute = 'Report Dispute';
  static const String allDisputes = 'All Disputes';
  static const String updateStatus = 'Update Status';
  static const String assignedCases = 'Assigned Cases';
  static const String manageUsers = 'Manage Users';
  static const String backup = 'Backup';

  // Disputes
  static const String disputes = 'Disputes';
  static const String disputeTitle = 'Dispute Title';
  static const String disputeDescription = 'Description';
  static const String disputeLocation = 'Location';
  static const String disputeType = 'Dispute Type';
  static const String status = 'Status';
  static const String date = 'Date';
  static const String priority = 'Priority';
  static const String assignedTo = 'Assigned To';
  static const String noDisputes = 'No disputes found';
  static const String submitDispute = 'Submit Dispute';
  static const String updateDispute = 'Update Dispute';
  static const String disputeSubmitted = 'Dispute submitted successfully';
  static const String disputeUpdated = 'Dispute updated successfully';

  // Status
  static const String statusPending = 'Pending';
  static const String statusInProgress = 'In Progress';
  static const String statusResolved = 'Resolved';
  static const String statusRejected = 'Rejected';
  static const String statusOnHold = 'On Hold';
  static const String statusClosed = 'Closed';

  // Priority
  static const String priorityLow = 'Low';
  static const String priorityMedium = 'Medium';
  static const String priorityHigh = 'High';
  static const String priorityUrgent = 'Urgent';

  // Dispute types
  static const String typeBoundary = 'Boundary Dispute';
  static const String typeOwnership = 'Ownership Dispute';
  static const String typeInheritance = 'Inheritance Dispute';
  static const String typeLease = 'Lease Dispute';
  static const String typeOther = 'Other';

  // Documents
  static const String documents = 'Documents';
  static const String uploadDocument = 'Upload Document';
  static const String documentType = 'Document Type';
  static const String noDocuments = 'No documents uploaded';
  static const String uploadSuccess = 'Document uploaded successfully';
  static const String uploadError = 'Failed to upload document';

  // Users
  static const String users = 'Users';
  static const String addUser = 'Add User';
  static const String editUser = 'Edit User';
  static const String deleteUser = 'Delete User';
  static const String userDeleted = 'User deleted successfully';
  static const String userUpdated = 'User updated successfully';

  // Actions
  static const String save = 'Save';
  static const String cancel = 'Cancel';
  static const String delete = 'Delete';
  static const String edit = 'Edit';
  static const String view = 'View';
  static const String assign = 'Assign';
  static const String submit = 'Submit';
  static const String search = 'Search';
  static const String filter = 'Filter';
  static const String refresh = 'Refresh';
  static const String back = 'Back';
  static const String next = 'Next';

  // Messages
  static const String loading = 'Loading...';
  static const String processing = 'Processing...';
  static const String noData = 'No data available';
  static const String noResults = 'No results found';
  static const String error = 'Error';
  static const String success = 'Success';
  static const String warning = 'Warning';
  static const String info = 'Info';
  static const String confirmDelete = 'Are you sure you want to delete this?';
  static const String confirmLogout = 'Are you sure you want to logout?';

  // Backup
  static const String backupData = 'Backup Data';
  static const String restoreData = 'Restore Data';
  static const String backupSuccess = 'Backup completed successfully';
  static const String restoreSuccess = 'Data restored successfully';
  static const String backupError = 'Failed to backup data';
  static const String restoreError = 'Failed to restore data';

  // Profile
  static const String profile = 'Profile';
  static const String settings = 'Settings';
  static const String editProfile = 'Edit Profile';
  static const String updateProfile = 'Update Profile';
}