import 'package:flutter/foundation.dart';
import '../models/dispute_model.dart';
import '../services/dispute_service.dart';

class DisputeProvider extends ChangeNotifier {
  final DisputeService _disputeService = DisputeService();

  List<DisputeModel> _disputes = [];
  DisputeModel? _selectedDispute;
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  List<DisputeModel> get disputes => _disputes;
  DisputeModel? get selectedDispute => _selectedDispute;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Load all disputes - NO notifyListeners during loading phase to avoid setState during build
  Future<void> loadAllDisputes() async {
    _isLoading = true;
    _errorMessage = null;

    try {
      _disputes = await _disputeService.getAllDisputes();
      _isLoading = false;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
    }
  }

  // Load disputes by status
  Future<void> loadDisputesByStatus(DisputeStatus status) async {
    _isLoading = true;
    _errorMessage = null;

    try {
      _disputes = await _disputeService.getDisputesByStatus(status);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // Load disputes by user (for citizens)
  Future<void> loadDisputesByUser(String userId) async {
    _isLoading = true;
    _errorMessage = null;

    try {
      _disputes = await _disputeService.getDisputesByUser(userId);
      _isLoading = false;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
    }
  }

  // Load disputes assigned to officer
  Future<void> loadDisputesByOfficer(String officerId) async {
    _isLoading = true;
    _errorMessage = null;

    try {
      _disputes = await _disputeService.getDisputesByOfficer(officerId);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // Load disputes assigned to mediator
  Future<void> loadDisputesByMediator(String mediatorId) async {
    _isLoading = true;
    _errorMessage = null;

    try {
      _disputes = await _disputeService.getDisputesByMediator(mediatorId);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // Submit new dispute
  Future<bool> submitDispute(DisputeModel dispute) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      String? disputeId = await _disputeService.submitDispute(dispute);
      if (disputeId != null) {
        await loadAllDisputes(); // Refresh disputes
        _isLoading = false;
        notifyListeners();
        return true;
      }
      _errorMessage = 'Failed to submit dispute';
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Update dispute
  Future<bool> updateDispute(String disputeId, Map<String, dynamic> data) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _disputeService.updateDispute(disputeId, data);
      await loadAllDisputes(); // Refresh disputes
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Update dispute status
  Future<bool> updateDisputeStatus(String disputeId, DisputeStatus status) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _disputeService.updateDisputeStatus(disputeId, status);
      await loadAllDisputes(); // Refresh disputes
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Assign officer to dispute
  Future<bool> assignOfficer(String disputeId, String officerId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _disputeService.assignOfficer(disputeId, officerId);
      await loadAllDisputes(); // Refresh disputes
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Assign mediator to dispute
  Future<bool> assignMediator(String disputeId, String mediatorId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _disputeService.assignMediator(disputeId, mediatorId);
      await loadAllDisputes(); // Refresh disputes
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Delete dispute
  Future<bool> deleteDispute(String disputeId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _disputeService.deleteDispute(disputeId);
      _disputes.removeWhere((dispute) => dispute.id == disputeId);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Get dispute by ID
  Future<DisputeModel?> getDisputeById(String disputeId) async {
    _isLoading = true;

    try {
      _selectedDispute = await _disputeService.getDisputeById(disputeId);
      _isLoading = false;
      notifyListeners();
      return _selectedDispute;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }

  // Filter disputes by type
  List<DisputeModel> getDisputesByType(DisputeType type) {
    return _disputes.where((dispute) => dispute.disputeType == type).toList();
  }

  // Filter disputes by priority
  List<DisputeModel> getDisputesByPriority(DisputePriority priority) {
    return _disputes.where((dispute) => dispute.priority == priority).toList();
  }

  // Get disputes count by status
  Map<String, int> getDisputesByStatusCount() {
    Map<String, int> counts = {
      'pending': 0,
      'in_progress': 0,
      'resolved': 0,
      'rejected': 0,
      'on_hold': 0,
      'closed': 0,
    };
    
    for (var dispute in _disputes) {
      String status = dispute.status.toString().split('.').last;
      counts[status] = (counts[status] ?? 0) + 1;
    }
    
    return counts;
  }

  // Clear error
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // Clear selected dispute
  void clearSelectedDispute() {
    _selectedDispute = null;
    notifyListeners();
  }
}