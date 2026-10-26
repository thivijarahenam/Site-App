import 'package:flutter/foundation.dart';

import '../data/mock_data.dart';
import '../models/models.dart';

class AppDataProvider extends ChangeNotifier {
  AppDataProvider() {
    _sites = SeedData.sites();
    _labours = SeedData.labours();
    _suppliers = SeedData.suppliers();
    _requests = SeedData.materialRequests();
    _notifications = SeedData.notifications();
    _logbookEntries = SeedData.logbookEntries();
    _recentActivities = SeedData.recentActivities();
    _todayTasks = SeedData.todayTasks();
    _pendingApprovals = SeedData.pendingApprovals();
    _teamMembers = SeedData.teamMembers();
    _rentals = SeedData.rentals();
    _foodOrders = SeedData.foodOrders();
  }

  late List<ConstructionSite> _sites;
  late List<LabourProfile> _labours;
  late List<SupplierProfile> _suppliers;
  late List<MaterialRequest> _requests;
  late List<AppNotification> _notifications;
  late List<ProjectLogbookEntry> _logbookEntries;
  late List<ActivityItem> _recentActivities;
  late List<TaskItem> _todayTasks;
  late List<ApprovalItem> _pendingApprovals;
  late List<TeamMember> _teamMembers;
  late List<EquipmentRental> _rentals;
  late List<FoodSupplyOrder> _foodOrders;

  List<ConstructionSite> get sites => List.unmodifiable(_sites);
  List<LabourProfile> get labours => List.unmodifiable(_labours);
  List<SupplierProfile> get suppliers => List.unmodifiable(_suppliers);
  List<MaterialRequest> get requests => List.unmodifiable(_requests);
  List<AppNotification> get notifications => List.unmodifiable(_notifications);
  List<ProjectLogbookEntry> get logbookEntries => List.unmodifiable(_logbookEntries);
  List<ActivityItem> get recentActivities => List.unmodifiable(_recentActivities);
  List<TaskItem> get todayTasks => List.unmodifiable(_todayTasks);
  List<ApprovalItem> get pendingApprovals => List.unmodifiable(_pendingApprovals);
  List<TeamMember> get teamMembers => List.unmodifiable(_teamMembers);
  List<EquipmentRental> get rentals => List.unmodifiable(_rentals);
  List<FoodSupplyOrder> get foodOrders => List.unmodifiable(_foodOrders);

  ConstructionSite? siteById(String id) {
    try {
      return _sites.firstWhere((s) => s.id == id);
    } catch (_) {
      return null;
    }
  }

  LabourProfile? labourById(String id) {
    try {
      return _labours.firstWhere((l) => l.id == id);
    } catch (_) {
      return null;
    }
  }

  SupplierProfile? supplierById(String id) {
    try {
      return _suppliers.firstWhere((s) => s.id == id);
    } catch (_) {
      return null;
    }
  }

  int get activeSites =>
      _sites.where((s) => s.status == SiteStatus.active).length;

  int get activeLabours =>
      _labours.where((l) => l.status == LabourStatus.active).length;

  int get pendingRequests => _requests
      .where((r) =>
          r.status == MaterialRequestStatus.pending ||
          r.status == MaterialRequestStatus.awaitingResponse)
      .length;

  int get pendingResponses => _requests
      .where((r) => r.status == MaterialRequestStatus.responseReceived)
      .length;

  int get completedRequests => _requests
      .where((r) =>
          r.status == MaterialRequestStatus.completed ||
          r.status == MaterialRequestStatus.approved)
      .length;

  List<AppNotification> notificationsFor(AppUser user) {
    return _notifications
        .where((n) =>
            n.targetRole == user.role &&
            (n.targetUserId == null || n.targetUserId == user.id))
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  List<MaterialRequest> requestsForSupplier(String supplierId) {
    return _requests.where((r) => r.assignedSupplierId == supplierId).toList();
  }

  List<ProjectLogbookEntry> logbookEntriesForProject(String projectId) {
    return _logbookEntries
        .where((e) => e.projectId == projectId)
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  void addLogbookEntry(ProjectLogbookEntry entry) {
    _logbookEntries = [entry, ..._logbookEntries];
    _recentActivities = [
      ActivityItem(
        id: 'act-${DateTime.now().millisecondsSinceEpoch}',
        title: '${entry.authorName} added: ${entry.title}',
        subtitle: 'Logbook • ${entry.category.label}',
        timeAgo: 'Just now',
        type: 'logbook',
      ),
      ..._recentActivities,
    ];
    notifyListeners();
  }

  void acknowledgeLogbookEntry(String entryId, String acknowledgedBy) {
    _logbookEntries = _logbookEntries.map((e) {
      if (e.id != entryId) return e;
      return e.copyWith(
        isAcknowledged: true,
        acknowledgedBy: acknowledgedBy,
        acknowledgedAt: DateTime.now(),
      );
    }).toList();
    notifyListeners();
  }

  void addLogbookComment(String entryId, LogbookComment comment) {
    _logbookEntries = _logbookEntries.map((e) {
      if (e.id != entryId) return e;
      return e.copyWith(
        comments: [...e.comments, comment],
      );
    }).toList();
    notifyListeners();
  }

  void toggleTask(String taskId) {
    _todayTasks = _todayTasks.map((t) {
      if (t.id != taskId) return t;
      return TaskItem(
        id: t.id,
        title: t.title,
        projectName: t.projectName,
        dueDate: t.dueDate,
        isCompleted: !t.isCompleted,
      );
    }).toList();
    notifyListeners();
  }

  void addFoodOrder(FoodSupplyOrder order) {
    _foodOrders = [order, ..._foodOrders];
    notifyListeners();
  }

  void addEquipmentRental(EquipmentRental rental) {
    _rentals = [rental, ..._rentals];
    notifyListeners();
  }

  void upsertSite(ConstructionSite site) {
    final index = _sites.indexWhere((s) => s.id == site.id);
    if (index >= 0) {
      _sites[index] = site;
    } else {
      _sites = [..._sites, site];
    }
    notifyListeners();
  }

  void upsertLabour(LabourProfile labour) {
    final index = _labours.indexWhere((l) => l.id == labour.id);
    if (index >= 0) {
      _labours[index] = labour;
    } else {
      _labours = [..._labours, labour];
    }

    _sites = _sites.map((site) {
      final ids = [...site.assignedLabourIds]..remove(labour.id);
      if (labour.currentSiteId == site.id) {
        ids.add(labour.id);
      }
      return site.copyWith(assignedLabourIds: ids);
    }).toList();

    notifyListeners();
  }

  void upsertSupplier(SupplierProfile supplier) {
    final index = _suppliers.indexWhere((s) => s.id == supplier.id);
    if (index >= 0) {
      _suppliers[index] = supplier;
    } else {
      _suppliers = [..._suppliers, supplier];
    }
    notifyListeners();
  }

  void addMaterialRequest(MaterialRequest request) {
    _requests = [request, ..._requests];
    _notifications = [
      AppNotification(
        id: 'n-${DateTime.now().millisecondsSinceEpoch}',
        targetRole: UserRole.supplier,
        targetUserId: request.assignedSupplierId == 'sup-1' ? 'u-supplier' : null,
        title: 'New material request',
        body:
            'Admin requested ${request.requiredQuantity} ${request.unit} of ${request.materialName}.',
        createdAt: DateTime.now(),
      ),
      ..._notifications,
    ];
    notifyListeners();
  }

  void submitSupplierResponse({
    required String requestId,
    required SupplierResponse response,
  }) {
    _requests = _requests.map((r) {
      if (r.id != requestId) return r;
      return r.copyWith(
        status: MaterialRequestStatus.responseReceived,
        response: response,
      );
    }).toList();

    _notifications = [
      AppNotification(
        id: 'n-${DateTime.now().millisecondsSinceEpoch}',
        targetRole: UserRole.admin,
        title: 'New supplier response',
        body: 'Supplier submitted details for ${response.materialName}.',
        createdAt: DateTime.now(),
      ),
      ..._notifications,
    ];
    notifyListeners();
  }

  void updateRequestStatus(String requestId, MaterialRequestStatus status) {
    _requests = _requests.map((r) {
      if (r.id != requestId) return r;
      return r.copyWith(status: status);
    }).toList();

    final request = _requests.firstWhere((r) => r.id == requestId);
    _notifications = [
      AppNotification(
        id: 'n-${DateTime.now().millisecondsSinceEpoch}',
        targetRole: UserRole.supplier,
        targetUserId:
            request.assignedSupplierId == 'sup-1' ? 'u-supplier' : null,
        title: 'Request status changed',
        body: '${request.materialName} is now ${status.name}.',
        createdAt: DateTime.now(),
      ),
      ..._notifications,
    ];
    notifyListeners();
  }

  void markNotificationRead(String id) {
    _notifications = _notifications
        .map((n) => n.id == id ? n.copyWith(isRead: true) : n)
        .toList();
    notifyListeners();
  }
}
