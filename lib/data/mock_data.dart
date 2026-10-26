import '../models/models.dart';

class DemoAccounts {
  static const admin = AppUser(
    id: 'u-jana',
    name: 'Jana Kumaran',
    email: 'jana@labourpro.lk',
    phone: '0771234567',
    role: UserRole.admin,
    companyName: 'BuildO & LabourPro Engineering',
    avatarUrl: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150',
  );

  static const supervisor = AppUser(
    id: 'u-supervisor',
    name: 'K. Niroshan',
    email: 'niroshan@labourpro.lk',
    phone: '0772223344',
    role: UserRole.supervisor,
    companyName: 'BuildO Engineering',
    avatarUrl: 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=150',
  );

  static const labour = AppUser(
    id: 'u-labour',
    name: 'S. Thavarasa',
    email: 'thavarasa@labourpro.lk',
    phone: '0773334455',
    role: UserRole.labour,
    linkedId: 'lab-1',
    companyName: 'BuildO Engineering',
    avatarUrl: 'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=150',
  );

  static const supplier = AppUser(
    id: 'u-supplier',
    name: 'Nimal Fernando',
    email: 'supplier@labourpro.lk',
    phone: '0774445566',
    role: UserRole.supplier,
    linkedId: 'sup-1',
    companyName: 'Jaffna Building Supplies',
    avatarUrl: 'https://images.unsplash.com/photo-1519085360753-af0119f7cbe7?w=150',
  );

  static const foodSupplier = AppUser(
    id: 'u-food',
    name: 'Razaak Caterers',
    email: 'food@labourpro.lk',
    phone: '0775556677',
    role: UserRole.foodSupplier,
    linkedId: 'food-1',
    companyName: 'Northern Site Food Services',
    avatarUrl: 'https://images.unsplash.com/photo-1522075469751-3a6694fb2f61?w=150',
  );

  static const password = '123456';

  static const List<AppUser> all = [
    admin,
    supervisor,
    labour,
    supplier,
    foodSupplier,
  ];

  static AppUser accountFor(UserRole role) {
    switch (role) {
      case UserRole.admin:
        return admin;
      case UserRole.supervisor:
        return supervisor;
      case UserRole.labour:
        return labour;
      case UserRole.supplier:
        return supplier;
      case UserRole.foodSupplier:
        return foodSupplier;
    }
  }

  static AppUser? authenticate({
    required String email,
    required String password,
  }) {
    if (password != DemoAccounts.password) return null;
    final normalized = email.trim().toLowerCase();
    for (final user in all) {
      if (user.email == normalized) return user;
    }
    return null;
  }
}

class SeedData {
  static List<ConstructionSite> sites() => [
        ConstructionSite(
          id: 'site-jaffna-school',
          siteName: 'Jaffna School Project',
          projectName: 'Jaffna School Project',
          address: 'Chavakachcheri Road, Jaffna',
          clientName: 'Northern Education Department',
          startDate: DateTime(2026, 10, 20),
          expectedCompletion: DateTime(2027, 4, 20),
          status: SiteStatus.active,
          progress: 0.42,
          contractValue: 'LKR 89,500,000',
          costSpent: 'LKR 21.4M',
          margin: 18.0,
          labourCount: '22 / 40',
          description:
              'Three-storey modern secondary school building including 18 classrooms, science labs, and auditorium.',
          assignedLabourIds: const ['lab-1', 'lab-2', 'lab-3'],
          imageUrl:
              'https://images.unsplash.com/photo-1541888946425-d0fbb18615f3?w=500',
        ),
        ConstructionSite(
          id: 'site-ladies-hostel',
          siteName: 'Ladies Hostel Project',
          projectName: 'Ladies Hostel Project',
          address: 'University Road, Jaffna',
          clientName: 'University Grants Commission',
          startDate: DateTime(2026, 5, 10),
          expectedCompletion: DateTime(2027, 2, 28),
          status: SiteStatus.active,
          progress: 0.68,
          contractValue: 'LKR 45,000,000',
          costSpent: 'LKR 28.5M',
          margin: 22.0,
          labourCount: '18 / 25',
          description: '4-storey residential university hostel with dining hall.',
          assignedLabourIds: const ['lab-4', 'lab-5'],
          imageUrl:
              'https://images.unsplash.com/photo-1590381105924-c72589b9ef3f?w=500',
        ),
        ConstructionSite(
          id: 'site-factory',
          siteName: 'Factory Project',
          projectName: 'Factory Project',
          address: 'Industrial Zone, Atchuvely',
          clientName: 'Apex Industries Ltd',
          startDate: DateTime(2026, 8, 1),
          expectedCompletion: DateTime(2027, 8, 30),
          status: SiteStatus.active,
          progress: 0.25,
          contractValue: 'LKR 120,000,000',
          costSpent: 'LKR 31.0M',
          margin: 15.0,
          labourCount: '30 / 60',
          description: 'Pre-engineered steel building with heavy concrete flooring.',
          assignedLabourIds: const [],
          imageUrl:
              'https://images.unsplash.com/photo-1504307651254-35680f356dfd?w=500',
        ),
      ];

  static List<ProjectLogbookEntry> logbookEntries() => [
        ProjectLogbookEntry(
          id: 'log-001',
          projectId: 'site-jaffna-school',
          date: DateTime(2026, 10, 9, 10, 35),
          authorName: 'S. Thavarasa',
          authorRole: 'Consultant',
          authorAvatar:
              'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=150',
          category: LogbookCategory.designChange,
          title: 'Second Floor Toilet Window Size Change',
          description:
              "Second floor toilet window size to be changed from 4' × 3' to 5' × 3' as discussed. Please update the architectural drawing and coordinate with structural team.",
          photoUrls: const [
            'https://images.unsplash.com/photo-1503387762-592deb58ef4e?w=400',
            'https://images.unsplash.com/photo-1513694203232-719a280e022f?w=400',
            'https://images.unsplash.com/photo-1581094794329-c8112a89af12?w=400',
          ],
          attachments: const [
            LogbookAttachment(
              name: 'Drawing Rev.03.pdf',
              size: '2.4 MB',
              extension: 'pdf',
            ),
            LogbookAttachment(
              name: 'Window sample.jpg',
              size: '1.8 MB',
              extension: 'jpg',
            ),
            LogbookAttachment(
              name: 'Site photo 1.jpg',
              size: '2.1 MB',
              extension: 'jpg',
            ),
          ],
          linkedItems: const ['Drawing Revision AR-02 Rev.03'],
          isAcknowledged: true,
          acknowledgedBy: 'Jana Kumaran (Owner)',
          acknowledgedAt: DateTime(2026, 10, 10, 8, 45),
          comments: [
            LogbookComment(
              id: 'c1',
              authorName: 'Jana Kumaran',
              authorRole: 'Owner',
              text: 'Aluminium supplier has confirmed the revised dimensions. Fabrication underway.',
              timestamp: DateTime(2026, 10, 9, 11, 20),
            ),
            LogbookComment(
              id: 'c2',
              authorName: 'K. Niroshan',
              authorRole: 'Site Engineer',
              text: 'Lintel height adjusted accordingly on site today.',
              timestamp: DateTime(2026, 10, 9, 14, 05),
            ),
            LogbookComment(
              id: 'c3',
              authorName: 'S. Thavarasa',
              authorRole: 'Consultant',
              text: 'Thanks for the prompt coordination.',
              timestamp: DateTime(2026, 10, 10, 8, 30),
            ),
          ],
        ),
        ProjectLogbookEntry(
          id: 'log-002',
          projectId: 'site-jaffna-school',
          date: DateTime(2026, 10, 10, 8, 45),
          authorName: 'Jana Kumaran',
          authorRole: 'Owner',
          authorAvatar:
              'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150',
          category: LogbookCategory.costVariation,
          title: 'Window Size Variation Cost Approval',
          description:
              'Window size change approved. Additional aluminium cost can be proceeded. Linked to: Log #024.',
          linkedItems: const ['Log #024'],
          isAcknowledged: true,
          acknowledgedBy: 'K. Niroshan (Site Engineer)',
          acknowledgedAt: DateTime(2026, 10, 10, 9, 15),
          comments: [
            LogbookComment(
              id: 'c4',
              authorName: 'K. Niroshan',
              authorRole: 'Site Engineer',
              text: 'Cost variance of LKR 85,000 recorded in project ledger.',
              timestamp: DateTime(2026, 10, 10, 9, 20),
            ),
          ],
        ),
        ProjectLogbookEntry(
          id: 'log-003',
          projectId: 'site-jaffna-school',
          date: DateTime(2026, 10, 12, 14, 20),
          authorName: 'K. Niroshan',
          authorRole: 'Site Engineer',
          authorAvatar:
              'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=150',
          category: LogbookCategory.siteObservation,
          title: 'North Boundary Wall Excavation Check',
          description:
              'North boundary wall excavation completed. Soil condition good. Ready for lean concrete blinding layer tomorrow morning.',
          photoUrls: const [
            'https://images.unsplash.com/photo-1541888946425-d0fbb18615f3?w=400',
            'https://images.unsplash.com/photo-1581094794329-c8112a89af12?w=400',
          ],
          isAcknowledged: false,
          comments: [
            LogbookComment(
              id: 'c5',
              authorName: 'Jana Kumaran',
              authorRole: 'Owner',
              text: 'Ensure cement and sand bags are positioned near north boundary.',
              timestamp: DateTime(2026, 10, 12, 15, 10),
            ),
            LogbookComment(
              id: 'c6',
              authorName: 'K. Niroshan',
              authorRole: 'Site Engineer',
              text: 'Arranged 30 bags cement and 1 cube sand.',
              timestamp: DateTime(2026, 10, 12, 15, 30),
            ),
          ],
        ),
        ProjectLogbookEntry(
          id: 'log-004',
          projectId: 'site-jaffna-school',
          date: DateTime(2026, 10, 14, 9, 0),
          authorName: 'Mr. Rajendran',
          authorRole: 'Client',
          authorAvatar:
              'https://images.unsplash.com/photo-1522075469751-3a6694fb2f61?w=150',
          category: LogbookCategory.clientRequest,
          title: 'Additional Wash Area Near Ground Floor Canteen',
          description:
              'Requested to add extra wash area near kitchen and ground floor canteen. To provide cost estimate and plumbing schematic before Friday.',
          comments: [],
        ),
      ];

  static List<ActivityItem> recentActivities() => const [
        ActivityItem(
          id: 'act-1',
          title: 'S. Thavarasa marked attendance',
          subtitle: 'Jaffna School Project • 08:05 AM',
          timeAgo: '2 min ago',
          type: 'attendance',
        ),
        ActivityItem(
          id: 'act-2',
          title: 'Cement delivery received (50 bags)',
          subtitle: 'Jaffna School Project • 08:30 AM',
          timeAgo: '15 min ago',
          type: 'delivery',
        ),
        ActivityItem(
          id: 'act-3',
          title: 'Site photos added by Engineer',
          subtitle: 'Ladies Hostel Project • 09:10 AM',
          timeAgo: '45 min ago',
          type: 'photo',
        ),
        ActivityItem(
          id: 'act-4',
          title: 'Sub Contractor quotation submitted',
          subtitle: 'Factory Project • 10:20 AM',
          timeAgo: '1 hour ago',
          type: 'quote',
        ),
      ];

  static List<TaskItem> todayTasks() => const [
        TaskItem(
          id: 't1',
          title: 'Column block work',
          projectName: 'Jaffna School Project',
          dueDate: '15 Oct',
          isCompleted: false,
        ),
        TaskItem(
          id: 't2',
          title: 'Plastering inspection',
          projectName: 'Ladies Hostel Project',
          dueDate: '16 Oct',
          isCompleted: false,
        ),
        TaskItem(
          id: 't3',
          title: 'Material order (sand)',
          projectName: 'Factory Project',
          dueDate: '17 Oct',
          isCompleted: true,
        ),
      ];

  static List<ApprovalItem> pendingApprovals() => const [
        ApprovalItem(
          id: 'a1',
          title: 'Sub Contractor RFQ',
          count: 2,
          category: 'subContractor',
        ),
        ApprovalItem(
          id: 'a2',
          title: 'Material Quotations',
          count: 3,
          category: 'materials',
        ),
        ApprovalItem(
          id: 'a3',
          title: 'Leave Requests',
          count: 1,
          category: 'leave',
        ),
        ApprovalItem(
          id: 'a4',
          title: 'Payment Approvals',
          count: 4,
          category: 'payments',
        ),
      ];

  static List<TeamMember> teamMembers() => const [
        TeamMember(
          id: 'tm-1',
          name: 'Supervisor',
          role: 'Supervisor',
          onSiteCount: 8,
          avatarUrl:
              'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150',
        ),
        TeamMember(
          id: 'tm-2',
          name: 'Engineer',
          role: 'Engineer',
          onSiteCount: 3,
          avatarUrl:
              'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=150',
        ),
        TeamMember(
          id: 'tm-3',
          name: 'Technical Officer',
          role: 'Technical Officer',
          onSiteCount: 2,
          avatarUrl:
              'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=150',
        ),
        TeamMember(
          id: 'tm-4',
          name: 'Employees',
          role: 'Employees',
          onSiteCount: 22,
          avatarUrl:
              'https://images.unsplash.com/photo-1519085360753-af0119f7cbe7?w=150',
        ),
      ];

  static List<EquipmentRental> rentals() => const [
        EquipmentRental(
          id: 'rent-1',
          name: 'CAT 320 Hydraulic Excavator',
          category: 'Excavator',
          dailyRate: 35000,
          availableStock: 2,
          onRentalCount: 4,
        ),
        EquipmentRental(
          id: 'rent-2',
          name: 'Concrete Mixer 500L',
          category: 'Mixer',
          dailyRate: 8500,
          availableStock: 5,
          onRentalCount: 3,
        ),
        EquipmentRental(
          id: 'rent-3',
          name: 'Heavy Duty Steel Scaffolding (100 sets)',
          category: 'Scaffolding',
          dailyRate: 15000,
          availableStock: 12,
          onRentalCount: 18,
        ),
        EquipmentRental(
          id: 'rent-4',
          name: 'Telescopic Props / Acrow Jacks (50 pcs)',
          category: 'Jacks',
          dailyRate: 6000,
          availableStock: 40,
          onRentalCount: 60,
        ),
      ];

  static List<FoodSupplyOrder> foodOrders() => [
        FoodSupplyOrder(
          id: 'food-ord-1',
          siteId: 'site-jaffna-school',
          siteName: 'Jaffna School Project',
          mealType: 'Lunch',
          portions: 24,
          deliveryDate: DateTime(2026, 10, 15),
          deliveryTime: '12:30 PM',
          status: 'Preparing',
          totalCost: 12000,
        ),
        FoodSupplyOrder(
          id: 'food-ord-2',
          siteId: 'site-ladies-hostel',
          siteName: 'Ladies Hostel Project',
          mealType: 'Tea & Snacks',
          portions: 18,
          deliveryDate: DateTime(2026, 10, 15),
          deliveryTime: '03:45 PM',
          status: 'Pending',
          totalCost: 5400,
        ),
      ];

  static List<LabourProfile> labours() => [
        LabourProfile(
          id: 'lab-1',
          fullName: 'S. Thavarasa',
          nic: '198423456789',
          phone: '0773334455',
          address: 'No. 12, Temple Road, Nallur, Jaffna',
          jobRole: 'Mason / Bricklayer',
          skills: const ['Block Work', 'Plastering', 'Formwork'],
          experience: '8 Years',
          joiningDate: DateTime(2024, 2, 10),
          emergencyContact: '0779988776 (Wife)',
          currentSiteId: 'site-jaffna-school',
          status: LabourStatus.active,
          dailyWage: 3800.0,
          hasAttendedToday: true,
          avatarUrl: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150',
        ),
        LabourProfile(
          id: 'lab-2',
          fullName: 'V. Sivakumar',
          nic: '199145678901',
          phone: '0776655443',
          address: 'Kopay South, Jaffna',
          jobRole: 'Carpenter',
          skills: const ['Roof Timber', 'Centering', 'Door Frame'],
          experience: '6 Years',
          joiningDate: DateTime(2024, 4, 1),
          emergencyContact: '0771122334 (Brother)',
          currentSiteId: 'site-jaffna-school',
          status: LabourStatus.active,
          dailyWage: 3600.0,
          hasAttendedToday: true,
          avatarUrl: 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=150',
        ),
        LabourProfile(
          id: 'lab-3',
          fullName: 'M. Pathmanathan',
          nic: '198956789012',
          phone: '0774433221',
          address: 'Chavakachcheri, Jaffna',
          jobRole: 'Steel Fixer / Bar Bender',
          skills: const ['Rebar Cutting', 'Bending', 'Beam Mesh'],
          experience: '7 Years',
          joiningDate: DateTime(2024, 6, 15),
          emergencyContact: '0778877665 (Father)',
          currentSiteId: 'site-jaffna-school',
          status: LabourStatus.active,
          dailyWage: 3700.0,
          hasAttendedToday: false,
          avatarUrl: 'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=150',
        ),
        LabourProfile(
          id: 'lab-4',
          fullName: 'K. Selvaratnam',
          nic: '198734567890',
          phone: '0775551234',
          address: 'Station Road, Chunnakam, Jaffna',
          jobRole: 'Electrician',
          skills: const ['Conduit Wiring', 'DB Dressing', 'Earth Testing', 'Solar Setup'],
          experience: '9 Years',
          joiningDate: DateTime(2024, 7, 1),
          emergencyContact: '0772233445 (Wife)',
          currentSiteId: null, // Available for hire
          status: LabourStatus.active,
          dailyWage: 4000.0,
          hasAttendedToday: false,
          avatarUrl: 'https://images.unsplash.com/photo-1519085360753-af0119f7cbe7?w=150',
        ),
        LabourProfile(
          id: 'lab-5',
          fullName: 'R. Mayuran',
          nic: '199345678901',
          phone: '0776662345',
          address: 'Main Street, Manipay, Jaffna',
          jobRole: 'Plumber',
          skills: const ['PVC Piping', 'Pressure Testing', 'Sanitary Ware', 'Overhead Tank'],
          experience: '5 Years',
          joiningDate: DateTime(2024, 8, 12),
          emergencyContact: '0773344556 (Mother)',
          currentSiteId: null, // Available for hire
          status: LabourStatus.active,
          dailyWage: 3600.0,
          hasAttendedToday: false,
          avatarUrl: 'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?w=150',
        ),
        LabourProfile(
          id: 'lab-6',
          fullName: 'P. Anton',
          nic: '198556789012',
          phone: '0777773456',
          address: 'Beach Road, Gurunagar, Jaffna',
          jobRole: 'Painter & Finisher',
          skills: const ['Wall Putty', 'Emulsion Painting', 'Weather Shield', 'Texture Coat'],
          experience: '8 Years',
          joiningDate: DateTime(2024, 9, 5),
          emergencyContact: '0774455667 (Wife)',
          currentSiteId: 'site-ladies-hostel',
          status: LabourStatus.active,
          dailyWage: 3500.0,
          hasAttendedToday: true,
          avatarUrl: 'https://images.unsplash.com/photo-1522075469751-3a6694fb2f61?w=150',
        ),
        LabourProfile(
          id: 'lab-7',
          fullName: 'T. Kamal',
          nic: '199667890123',
          phone: '0778884567',
          address: 'KKS Road, Tellippalai, Jaffna',
          jobRole: 'Helper / General Labour',
          skills: const ['Concrete Mixing', 'Material Shifting', 'Curing', 'Site Cleaning'],
          experience: '3 Years',
          joiningDate: DateTime(2024, 10, 1),
          emergencyContact: '0775566778 (Father)',
          currentSiteId: null, // Available for hire
          status: LabourStatus.active,
          dailyWage: 2800.0,
          hasAttendedToday: false,
          avatarUrl: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=150',
        ),
      ];

  static List<SupplierProfile> suppliers() => [
        const SupplierProfile(
          id: 'sup-1',
          companyName: 'Jaffna Building Supplies Pvt Ltd',
          contactPerson: 'Nimal Fernando',
          phone: '0774445566',
          email: 'sales@jaffnasupplies.lk',
          address: 'Hospital Road, Jaffna',
          registrationDetails: 'PV-1029384',
          materialsSupplied: [
            'Cement',
            'Sand',
            'Metal / Aggregate',
            'Steel / Rebar',
            'Blocks',
          ],
          bankInfo: 'Commercial Bank - Jaffna Branch (8293049182)',
          status: CompanyStatus.active,
        ),
        const SupplierProfile(
          id: 'sup-2',
          companyName: 'Northern Timber & Hardware',
          contactPerson: 'K. Balakrishnan',
          phone: '0778899001',
          email: 'bala@northernhardware.lk',
          address: 'KKS Road, Chunnakam',
          registrationDetails: 'PV-2039485',
          materialsSupplied: [
            'Timber',
            'Plywood',
            'Hardware',
            'Plumbing',
            'Electrical',
          ],
          bankInfo: 'HNB Bank - Chunnakam (9028340192)',
          status: CompanyStatus.active,
        ),
      ];

  static List<MaterialRequest> materialRequests() => [
        MaterialRequest(
          id: 'mr-1',
          siteId: 'site-jaffna-school',
          materialName: 'Portland Cement (50kg)',
          category: 'Cement',
          requiredQuantity: 200,
          unit: 'Bags',
          requiredDate: DateTime(2026, 10, 22),
          description: 'Tokyo Super / Sanstha Grade 42.5N Cement for columns.',
          notes: 'Deliver to rear gate entrance.',
          requestDate: DateTime(2026, 10, 14),
          status: MaterialRequestStatus.responseReceived,
          assignedSupplierId: 'sup-1',
          response: SupplierResponse(
            id: 'resp-1',
            supplierId: 'sup-1',
            materialName: 'Portland Cement (Tokyo Super 50kg)',
            availableQuantity: 200,
            unitPrice: 2450.0,
            deliveryDate: DateTime(2026, 10, 21),
            availabilityStatus: AvailabilityStatus.available,
            notes: 'Price includes transport and unloading on site.',
            submittedAt: DateTime(2026, 10, 14, 11, 30),
          ),
        ),
        MaterialRequest(
          id: 'mr-2',
          siteId: 'site-jaffna-school',
          materialName: 'River Sand',
          category: 'Sand',
          requiredQuantity: 5,
          unit: 'Cubes',
          requiredDate: DateTime(2026, 10, 24),
          description: 'Washed river sand for brickwork plastering.',
          notes: 'Must be silt-free.',
          requestDate: DateTime(2026, 10, 14),
          status: MaterialRequestStatus.pending,
        ),
      ];

  static List<AppNotification> notifications() => [
        AppNotification(
          id: 'notif-1',
          targetRole: UserRole.admin,
          title: 'New Logbook Entry',
          body: 'Consultant S. Thavarasa added Design Change on Jaffna School Project.',
          createdAt: DateTime.now().subtract(const Duration(minutes: 10)),
          isRead: false,
        ),
        AppNotification(
          id: 'notif-2',
          targetRole: UserRole.admin,
          title: 'Quotation Received',
          body: 'Jaffna Building Supplies submitted quote for 200 Bags Cement.',
          createdAt: DateTime.now().subtract(const Duration(minutes: 45)),
          isRead: false,
        ),
        AppNotification(
          id: 'notif-3',
          targetRole: UserRole.admin,
          title: 'Attendance Alert',
          body: '22 / 24 assigned workers checked in at Jaffna School site.',
          createdAt: DateTime.now().subtract(const Duration(hours: 2)),
          isRead: false,
        ),
      ];
}
