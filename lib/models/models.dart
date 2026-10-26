import 'user_role.dart';

export 'user_role.dart';

enum SiteStatus { active, completed, onHold }

enum LabourStatus {
  active,
  onLeave,
  temporaryElsewhere,
  leftWithoutNotice,
  terminated,
}

enum CompanyStatus { active, inactive }

enum MaterialRequestStatus {
  pending,
  awaitingResponse,
  responseReceived,
  approved,
  rejected,
  completed,
}

enum AvailabilityStatus { available, partial, unavailable }

enum LogbookCategory {
  generalNote,
  designChange,
  siteInstruction,
  siteObservation,
  costVariation,
  clientRequest,
  inspectionQA,
  meetingNote,
  other,
}

extension LogbookCategoryX on LogbookCategory {
  String get label {
    switch (this) {
      case LogbookCategory.generalNote:
        return 'General Note';
      case LogbookCategory.designChange:
        return 'Design Change';
      case LogbookCategory.siteInstruction:
        return 'Site Instruction';
      case LogbookCategory.siteObservation:
        return 'Site Observation';
      case LogbookCategory.costVariation:
        return 'Cost / Variation';
      case LogbookCategory.clientRequest:
        return 'Client Request';
      case LogbookCategory.inspectionQA:
        return 'Inspection / QA';
      case LogbookCategory.meetingNote:
        return 'Meeting Note';
      case LogbookCategory.other:
        return 'Other';
    }
  }
}

class AppUser {
  final String id;
  final String name;
  final String email;
  final String phone;
  final UserRole role;
  final String? linkedId;
  final String? avatarUrl;
  final String companyName;
  final bool isProfileIncomplete;
  final String? address;
  final String? experience;
  final String? specialization;
  final int? yearsInBusiness;
  final List<String> skills;
  final double? dailyWage;
  final List<String> materialsSupplied;

  const AppUser({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.role,
    this.linkedId,
    this.avatarUrl,
    this.companyName = 'Ahenam Technologies',
    this.isProfileIncomplete = false,
    this.address,
    this.experience,
    this.specialization,
    this.yearsInBusiness,
    this.skills = const [],
    this.dailyWage,
    this.materialsSupplied = const [],
  });

  AppUser copyWith({
    String? name,
    String? email,
    String? phone,
    UserRole? role,
    String? linkedId,
    String? avatarUrl,
    String? companyName,
    bool? isProfileIncomplete,
    String? address,
    String? experience,
    String? specialization,
    int? yearsInBusiness,
    List<String>? skills,
    double? dailyWage,
    List<String>? materialsSupplied,
  }) {
    return AppUser(
      id: id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      linkedId: linkedId ?? this.linkedId,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      companyName: companyName ?? this.companyName,
      isProfileIncomplete: isProfileIncomplete ?? this.isProfileIncomplete,
      address: address ?? this.address,
      experience: experience ?? this.experience,
      specialization: specialization ?? this.specialization,
      yearsInBusiness: yearsInBusiness ?? this.yearsInBusiness,
      skills: skills ?? this.skills,
      dailyWage: dailyWage ?? this.dailyWage,
      materialsSupplied: materialsSupplied ?? this.materialsSupplied,
    );
  }
}

class ConstructionSite {
  final String id;
  final String siteName;
  final String projectName;
  final String address;
  final String clientName;
  final DateTime startDate;
  final DateTime expectedCompletion;
  final SiteStatus status;
  final String description;
  final double progress; // 0.0 to 1.0 (e.g. 0.42 for 42%)
  final String contractValue; // e.g. "LKR 89,500,000"
  final String costSpent; // e.g. "LKR 21.4M"
  final double margin; // e.g. 18.0 (%)
  final String labourCount; // e.g. "22 / 40"
  final String? imageUrl;
  final List<String> assignedLabourIds;
  final List<String> stages;
  final String supervisorName;
  final String supervisorPhone;

  const ConstructionSite({
    required this.id,
    required this.siteName,
    required this.projectName,
    required this.address,
    required this.clientName,
    required this.startDate,
    required this.expectedCompletion,
    required this.status,
    required this.description,
    this.progress = 0.42,
    this.contractValue = 'LKR 89,500,000',
    this.costSpent = 'LKR 21.4M',
    this.margin = 18.0,
    this.labourCount = '22 / 40',
    this.imageUrl,
    this.assignedLabourIds = const [],
    this.stages = const [
      'Site Preparation',
      'Foundation',
      'Structural Work',
      'Block Work',
      'Plastering',
      'Electrical & Plumbing',
      'Finishing & Handover',
    ],
    this.supervisorName = 'K. Niroshan',
    this.supervisorPhone = '0771234567',
  });

  ConstructionSite copyWith({
    String? siteName,
    String? projectName,
    String? address,
    String? clientName,
    DateTime? startDate,
    DateTime? expectedCompletion,
    SiteStatus? status,
    String? description,
    double? progress,
    String? contractValue,
    String? costSpent,
    double? margin,
    String? labourCount,
    String? imageUrl,
    List<String>? assignedLabourIds,
    List<String>? stages,
    String? supervisorName,
    String? supervisorPhone,
  }) {
    return ConstructionSite(
      id: id,
      siteName: siteName ?? this.siteName,
      projectName: projectName ?? this.projectName,
      address: address ?? this.address,
      clientName: clientName ?? this.clientName,
      startDate: startDate ?? this.startDate,
      expectedCompletion: expectedCompletion ?? this.expectedCompletion,
      status: status ?? this.status,
      description: description ?? this.description,
      progress: progress ?? this.progress,
      contractValue: contractValue ?? this.contractValue,
      costSpent: costSpent ?? this.costSpent,
      margin: margin ?? this.margin,
      labourCount: labourCount ?? this.labourCount,
      imageUrl: imageUrl ?? this.imageUrl,
      assignedLabourIds: assignedLabourIds ?? this.assignedLabourIds,
      stages: stages ?? this.stages,
      supervisorName: supervisorName ?? this.supervisorName,
      supervisorPhone: supervisorPhone ?? this.supervisorPhone,
    );
  }
}

class LogbookAttachment {
  final String name;
  final String size;
  final String extension; // pdf, jpg, png
  final String? url;

  const LogbookAttachment({
    required this.name,
    required this.size,
    required this.extension,
    this.url,
  });
}

class LogbookComment {
  final String id;
  final String authorName;
  final String authorRole;
  final String text;
  final DateTime timestamp;
  final String? avatarUrl;

  const LogbookComment({
    required this.id,
    required this.authorName,
    required this.authorRole,
    required this.text,
    required this.timestamp,
    this.avatarUrl,
  });
}

class ProjectLogbookEntry {
  final String id;
  final String projectId;
  final DateTime date;
  final String authorName;
  final String authorRole; // Consultant, Owner, Site Engineer, Client
  final String? authorAvatar;
  final LogbookCategory category;
  final String title;
  final String description;
  final List<String> photoUrls;
  final List<LogbookAttachment> attachments;
  final List<String> linkedItems;
  final bool isAcknowledged;
  final String? acknowledgedBy;
  final DateTime? acknowledgedAt;
  final List<LogbookComment> comments;

  const ProjectLogbookEntry({
    required this.id,
    required this.projectId,
    required this.date,
    required this.authorName,
    required this.authorRole,
    this.authorAvatar,
    required this.category,
    required this.title,
    required this.description,
    this.photoUrls = const [],
    this.attachments = const [],
    this.linkedItems = const [],
    this.isAcknowledged = false,
    this.acknowledgedBy,
    this.acknowledgedAt,
    this.comments = const [],
  });

  ProjectLogbookEntry copyWith({
    bool? isAcknowledged,
    String? acknowledgedBy,
    DateTime? acknowledgedAt,
    List<LogbookComment>? comments,
  }) {
    return ProjectLogbookEntry(
      id: id,
      projectId: projectId,
      date: date,
      authorName: authorName,
      authorRole: authorRole,
      authorAvatar: authorAvatar,
      category: category,
      title: title,
      description: description,
      photoUrls: photoUrls,
      attachments: attachments,
      linkedItems: linkedItems,
      isAcknowledged: isAcknowledged ?? this.isAcknowledged,
      acknowledgedBy: acknowledgedBy ?? this.acknowledgedBy,
      acknowledgedAt: acknowledgedAt ?? this.acknowledgedAt,
      comments: comments ?? this.comments,
    );
  }
}

class ActivityItem {
  final String id;
  final String title;
  final String subtitle;
  final String timeAgo;
  final String type; // attendance, delivery, photo, quote, approval
  final String? projectId;

  const ActivityItem({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.timeAgo,
    required this.type,
    this.projectId,
  });
}

class TaskItem {
  final String id;
  final String title;
  final String projectName;
  final String dueDate; // e.g. "15 Oct"
  final bool isCompleted;

  const TaskItem({
    required this.id,
    required this.title,
    required this.projectName,
    required this.dueDate,
    this.isCompleted = false,
  });

  TaskItem copyWith({bool? isCompleted}) {
    return TaskItem(
      id: id,
      title: title,
      projectName: projectName,
      dueDate: dueDate,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}

class ApprovalItem {
  final String id;
  final String title;
  final int count;
  final String category; // subContractor, materials, leave, payments

  const ApprovalItem({
    required this.id,
    required this.title,
    required this.count,
    required this.category,
  });
}

class TeamMember {
  final String id;
  final String name;
  final String role; // Supervisor, Engineer, Technical Officer, Employee
  final int onSiteCount;
  final String? avatarUrl;
  final bool isOnSite;

  const TeamMember({
    required this.id,
    required this.name,
    required this.role,
    this.onSiteCount = 1,
    this.avatarUrl,
    this.isOnSite = true,
  });
}

class EquipmentRental {
  final String id;
  final String name;
  final String category; // Excavator, Mixer, Scaffolding, Jacks
  final double dailyRate;
  final int availableStock;
  final int onRentalCount;
  final String? imageUrl;

  const EquipmentRental({
    required this.id,
    required this.name,
    required this.category,
    required this.dailyRate,
    required this.availableStock,
    required this.onRentalCount,
    this.imageUrl,
  });
}

class FoodSupplyOrder {
  final String id;
  final String siteId;
  final String siteName;
  final String mealType; // Breakfast, Lunch, Tea, Dinner
  final int portions;
  final DateTime deliveryDate;
  final String deliveryTime;
  final String status; // Pending, Preparing, Out for Delivery, Delivered
  final double totalCost;

  const FoodSupplyOrder({
    required this.id,
    required this.siteId,
    required this.siteName,
    required this.mealType,
    required this.portions,
    required this.deliveryDate,
    required this.deliveryTime,
    required this.status,
    required this.totalCost,
  });
}

class LabourProfile {
  final String id;
  final String fullName;
  final String nic;
  final String phone;
  final String address;
  final String jobRole;
  final List<String> skills;
  final String experience;
  final DateTime joiningDate;
  final String emergencyContact;
  final String? currentSiteId;
  final LabourStatus status;
  final double dailyWage;
  final bool hasAttendedToday;
  final String? avatarUrl;

  const LabourProfile({
    required this.id,
    required this.fullName,
    required this.nic,
    required this.phone,
    required this.address,
    required this.jobRole,
    required this.skills,
    required this.experience,
    required this.joiningDate,
    required this.emergencyContact,
    this.currentSiteId,
    required this.status,
    this.dailyWage = 3500.0,
    this.hasAttendedToday = true,
    this.avatarUrl,
  });

  String get assignedLocation => address;

  LabourProfile copyWith({
    String? fullName,
    String? nic,
    String? phone,
    String? address,
    String? jobRole,
    List<String>? skills,
    String? experience,
    DateTime? joiningDate,
    String? emergencyContact,
    String? currentSiteId,
    bool clearSite = false,
    LabourStatus? status,
    double? dailyWage,
    bool? hasAttendedToday,
    String? avatarUrl,
  }) {
    return LabourProfile(
      id: id,
      fullName: fullName ?? this.fullName,
      nic: nic ?? this.nic,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      jobRole: jobRole ?? this.jobRole,
      skills: skills ?? this.skills,
      experience: experience ?? this.experience,
      joiningDate: joiningDate ?? this.joiningDate,
      emergencyContact: emergencyContact ?? this.emergencyContact,
      currentSiteId: clearSite ? null : (currentSiteId ?? this.currentSiteId),
      status: status ?? this.status,
      dailyWage: dailyWage ?? this.dailyWage,
      hasAttendedToday: hasAttendedToday ?? this.hasAttendedToday,
      avatarUrl: avatarUrl ?? this.avatarUrl,
    );
  }
}

class SupplierProfile {
  final String id;
  final String companyName;
  final String contactPerson;
  final String phone;
  final String email;
  final String address;
  final String registrationDetails;
  final List<String> materialsSupplied;
  final String bankInfo;
  final CompanyStatus status;

  const SupplierProfile({
    required this.id,
    required this.companyName,
    required this.contactPerson,
    required this.phone,
    required this.email,
    required this.address,
    required this.registrationDetails,
    required this.materialsSupplied,
    required this.bankInfo,
    required this.status,
  });

  SupplierProfile copyWith({
    String? id,
    String? companyName,
    String? contactPerson,
    String? phone,
    String? email,
    String? address,
    String? registrationDetails,
    List<String>? materialsSupplied,
    String? bankInfo,
    CompanyStatus? status,
  }) {
    return SupplierProfile(
      id: id ?? this.id,
      companyName: companyName ?? this.companyName,
      contactPerson: contactPerson ?? this.contactPerson,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      address: address ?? this.address,
      registrationDetails: registrationDetails ?? this.registrationDetails,
      materialsSupplied: materialsSupplied ?? this.materialsSupplied,
      bankInfo: bankInfo ?? this.bankInfo,
      status: status ?? this.status,
    );
  }
}

class SupplierResponse {
  final String id;
  final String supplierId;
  final String materialName;
  final double availableQuantity;
  final double unitPrice;
  final DateTime deliveryDate;
  final AvailabilityStatus availabilityStatus;
  final String notes;
  final DateTime submittedAt;

  const SupplierResponse({
    required this.id,
    required this.supplierId,
    required this.materialName,
    required this.availableQuantity,
    required this.unitPrice,
    required this.deliveryDate,
    required this.availabilityStatus,
    required this.notes,
    required this.submittedAt,
  });

  double get totalPrice => availableQuantity * unitPrice;
}

class MaterialRequest {
  final String id;
  final String siteId;
  final String materialName;
  final String category;
  final double requiredQuantity;
  final String unit;
  final DateTime requiredDate;
  final String description;
  final String notes;
  final DateTime requestDate;
  final MaterialRequestStatus status;
  final String? assignedSupplierId;
  final SupplierResponse? response;

  const MaterialRequest({
    required this.id,
    required this.siteId,
    required this.materialName,
    required this.category,
    required this.requiredQuantity,
    required this.unit,
    required this.requiredDate,
    required this.description,
    required this.notes,
    required this.requestDate,
    required this.status,
    this.assignedSupplierId,
    this.response,
  });

  MaterialRequest copyWith({
    MaterialRequestStatus? status,
    String? assignedSupplierId,
    SupplierResponse? response,
  }) {
    return MaterialRequest(
      id: id,
      siteId: siteId,
      materialName: materialName,
      category: category,
      requiredQuantity: requiredQuantity,
      unit: unit,
      requiredDate: requiredDate,
      description: description,
      notes: notes,
      requestDate: requestDate,
      status: status ?? this.status,
      assignedSupplierId: assignedSupplierId ?? this.assignedSupplierId,
      response: response ?? this.response,
    );
  }
}

class AppNotification {
  final String id;
  final UserRole targetRole;
  final String? targetUserId;
  final String title;
  final String body;
  final DateTime createdAt;
  final bool isRead;

  const AppNotification({
    required this.id,
    required this.targetRole,
    this.targetUserId,
    required this.title,
    required this.body,
    required this.createdAt,
    this.isRead = false,
  });

  AppNotification copyWith({bool? isRead}) {
    return AppNotification(
      id: id,
      targetRole: targetRole,
      targetUserId: targetUserId,
      title: title,
      body: body,
      createdAt: createdAt,
      isRead: isRead ?? this.isRead,
    );
  }
}
