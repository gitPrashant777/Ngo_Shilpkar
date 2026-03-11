class ApiEndpoints {
  static const String baseUrl = "https://ngo-project-r7cc.onrender.com/api";

  // ── Auth ───────────────────────────────────────────────────────────────────
  static const String login = "/auth/login";
  static const String profileMe = "/profile/me";
  static const String forgotPassword = "/auth/superadmin-forgot-password";

  // ── Super Admin ────────────────────────────────────────────────────────────
  static const String createUser = "/onboarding/create-user";

  // ── Dashboard Analytics ────────────────────────────────────────────────────
  static const String dashboardOverview = "/dashboard/overview";
  static const String dashboardUserGrowth = "/dashboard/user-growth";
  static const String dashboardPaymentSummary = "/dashboard/payment-summary";

  // ── Status / View Tracking ─────────────────────────────────────────────────
  static String statusView(String id) => "/status/view/$id";
  static String statusViews(String id) => "/status/$id/views";

  // ── User Management (Paginated) ────────────────────────────────────────────
  static const String usersEmployees = "/users/employees";
  static const String usersCoordinators = "/users/coordinators";
  static const String usersBeneficiaries = "/users/beneficiaries";
  static String userDeactivate(String id) => "/users/$id/deactivate";

  // ── Terms & Conditions ─────────────────────────────────────────────────────
  static const String terms = "/terms";
  static const String termsAccept = "/terms/accept";

  // ── Manual Payments ────────────────────────────────────────────────────────
  static const String manualPayment = "/payments/manual";

  // ── Employee Payment Requests ──────────────────────────────────────────────
  static const String employeePaymentRequest = "/employee/payments/request";
  static const String adminEmployeePayments   = "/admin/employee-payments";        // GET – pending list
  static const String adminEmployeePaymentPay = "/admin/employee-payments/pay";    // POST – approve/reject

  // ── Parcels ────────────────────────────────────────────────────────────────
  static const String parcels = "/parcels";

  // ── CMS Pages ──────────────────────────────────────────────────────────────
  static String cmsPage(String slug) => "/pages/$slug";

  // ── Beneficiary Pending Payments ───────────────────────────────────────────
  static const String beneficiaryPendingPayments = "/beneficiaries/pending-payments";
}