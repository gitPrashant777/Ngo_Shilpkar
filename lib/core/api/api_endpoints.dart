class ApiEndpoints {
  static const String baseUrl =  "https://ngo-project-r7cc.onrender.com/api";

  // ── Auth ───────────────────────────────────────────────────────────────────static const String login = "/auth/login";
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
  static const String usersCommunity = "/users/community";
  static String userCommunityProfile(String id) => "/users/$id/profile";
  static String userStartChat(String id) => "/users/$id/start-chat";
  static const String userDeletionRequest = "/users/request-deletion";
  static const String userDeletionRequests = "/users/deletion-requests";
  static const String userDeactivatedHistory = "/users/deactivated-history";
  static String userApproveDeletion(String id) => "/users/$id/approve-deletion";
  static const String userCategories = "/users/categories";
  static String userVerify(String id) => "/users/$id/verify";
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
  static const String beneficiariesOffline = "/beneficiaries/offline";
  static const String beneficiariesOnlineInitiate = "/beneficiaries/online-initiate";
  static const String beneficiariesOnlineVerify = "/beneficiaries/online-verify";
  static const String beneficiariesOnlineResendOtp =
      "/beneficiaries/online-resend-otp";
  static const String beneficiariesCashRequest = "/beneficiaries/cash-request";
  static const String beneficiariesCashRequests = "/beneficiaries/cash-requests";
  static String beneficiariesCashApprove(String id) =>
      "/beneficiaries/cash-requests/$id/approve";

  // Admin CMS
  static const String adminAboutPage = "/admin/pages/about";
  static const String adminEmergencySiren =
      "/admin/pages/settings/emergency-siren";
}
