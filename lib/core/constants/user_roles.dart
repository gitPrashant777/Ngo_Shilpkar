class UserRole {
  static const String superAdmin = 'SUPER_ADMIN';
  static const String admin = 'ADMIN';
  static const String field = 'FIELD';
  static const String coordinator = 'COORDINATOR';
  static const String beneficiary = 'BENEFICIARY';
  static const String employee = 'EMPLOYEE';

  static const String districtCoordinator = 'DISTRICT_COORDINATOR';
  static const String talukaCoordinator = 'TALUKA_COORDINATOR';
  static const String villageCoordinator = 'VILLAGE_COORDINATOR';

  static const List<String> coordinatorRoles = [
    coordinator,
    districtCoordinator,
    talukaCoordinator,
    villageCoordinator,
  ];

  static const List<String> employeeFacingRoles = [
    field,
    employee,
    ...coordinatorRoles,
  ];

  static bool isCoordinatorRole(String? role) =>
      coordinatorRoles.contains(role);

  static bool isEmployeeRole(String? role) =>
      employeeFacingRoles.contains(role);

  static String displayName(String role) {
    switch (role) {
      case field:
        return 'Field Employee';
      case coordinator:
        return 'Coordinator';
      case districtCoordinator:
        return 'District Coordinator';
      case talukaCoordinator:
        return 'Taluka Coordinator';
      case villageCoordinator:
        return 'Village Coordinator';
      case superAdmin:
        return 'Super Admin';
      case admin:
        return 'Admin';
      case beneficiary:
        return 'Beneficiary';
      case employee:
        return 'Employee';
      default:
        return role
            .toLowerCase()
            .split('_')
            .where((part) => part.isNotEmpty)
            .map((part) => '${part[0].toUpperCase()}${part.substring(1)}')
            .join(' ');
    }
  }
}
