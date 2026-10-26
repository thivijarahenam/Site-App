enum UserRole {
  admin,
  supervisor,
  labour,
  supplier,
  foodSupplier,
}

extension UserRoleX on UserRole {
  String get label {
    switch (this) {
      case UserRole.admin:
        return 'Owner / Contractor';
      case UserRole.supervisor:
        return 'Site Supervisor';
      case UserRole.labour:
        return 'Labour';
      case UserRole.supplier:
        return 'Material Supplier';
      case UserRole.foodSupplier:
        return 'Food Supplier';
    }
  }

  String get shortLabel {
    switch (this) {
      case UserRole.admin:
        return 'Owner';
      case UserRole.supervisor:
        return 'Supervisor';
      case UserRole.labour:
        return 'Labour';
      case UserRole.supplier:
        return 'Materials';
      case UserRole.foodSupplier:
        return 'Food';
    }
  }
}
