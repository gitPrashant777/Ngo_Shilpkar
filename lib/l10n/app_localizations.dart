import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_mr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('mr'),
  ];

  /// App name
  ///
  /// In en, this message translates to:
  /// **'Shilpkar Foundation'**
  String get appName;

  /// Language toggle label
  ///
  /// In en, this message translates to:
  /// **'English | मराठी'**
  String get languageToggle;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @marathi.
  ///
  /// In en, this message translates to:
  /// **'मराठी'**
  String get marathi;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// No description provided for @required.
  ///
  /// In en, this message translates to:
  /// **'Required'**
  String get required;

  /// No description provided for @continue_btn.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continue_btn;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// No description provided for @loginFailed.
  ///
  /// In en, this message translates to:
  /// **'Login failed'**
  String get loginFailed;

  /// No description provided for @errorOccurred.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong'**
  String get errorOccurred;

  /// No description provided for @notAvailable.
  ///
  /// In en, this message translates to:
  /// **'N/A'**
  String get notAvailable;

  /// No description provided for @viewAll.
  ///
  /// In en, this message translates to:
  /// **'View All'**
  String get viewAll;

  /// No description provided for @viewList.
  ///
  /// In en, this message translates to:
  /// **'View List'**
  String get viewList;

  /// No description provided for @chatNow.
  ///
  /// In en, this message translates to:
  /// **'Chat Now'**
  String get chatNow;

  /// No description provided for @create.
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get create;

  /// No description provided for @joinNow.
  ///
  /// In en, this message translates to:
  /// **'Join Now'**
  String get joinNow;

  /// No description provided for @exploreProducts.
  ///
  /// In en, this message translates to:
  /// **'Explore Products'**
  String get exploreProducts;

  /// No description provided for @donate.
  ///
  /// In en, this message translates to:
  /// **'Donate'**
  String get donate;

  /// No description provided for @free.
  ///
  /// In en, this message translates to:
  /// **'FREE'**
  String get free;

  /// No description provided for @ourVision.
  ///
  /// In en, this message translates to:
  /// **'Our Vision'**
  String get ourVision;

  /// No description provided for @ourWork.
  ///
  /// In en, this message translates to:
  /// **'Our Work'**
  String get ourWork;

  /// No description provided for @ourImpact.
  ///
  /// In en, this message translates to:
  /// **'Our Impact'**
  String get ourImpact;

  /// No description provided for @whyWeExist.
  ///
  /// In en, this message translates to:
  /// **'Why we Exist'**
  String get whyWeExist;

  /// No description provided for @whatWeDo.
  ///
  /// In en, this message translates to:
  /// **'What we do on the ground'**
  String get whatWeDo;

  /// No description provided for @livesTouched.
  ///
  /// In en, this message translates to:
  /// **'Lives touched & villages reached'**
  String get livesTouched;

  /// No description provided for @shilpkarFoundation.
  ///
  /// In en, this message translates to:
  /// **'Shilpkar Foundation'**
  String get shilpkarFoundation;

  /// No description provided for @shilpkarMaharashtra.
  ///
  /// In en, this message translates to:
  /// **'Shilpkar Foundations - Maharashtra'**
  String get shilpkarMaharashtra;

  /// No description provided for @welcomeTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome to Shilpkar Foundation'**
  String get welcomeTitle;

  /// No description provided for @welcomeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Empowering communities with purpose driven actions'**
  String get welcomeSubtitle;

  /// No description provided for @loginAsEmployee.
  ///
  /// In en, this message translates to:
  /// **'Login as Coordinator'**
  String get loginAsEmployee;

  /// No description provided for @loginAsEmployeeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'for coordinators'**
  String get loginAsEmployeeSubtitle;

  /// No description provided for @loginAsBeneficiary.
  ///
  /// In en, this message translates to:
  /// **'Login as Beneficiary'**
  String get loginAsBeneficiary;

  /// No description provided for @loginAsBeneficiarySubtitle.
  ///
  /// In en, this message translates to:
  /// **'for farmers, women, workers, students & citizens'**
  String get loginAsBeneficiarySubtitle;

  /// No description provided for @loginAsAdmin.
  ///
  /// In en, this message translates to:
  /// **'Login as Admin'**
  String get loginAsAdmin;

  /// No description provided for @loginAsAdminSubtitle.
  ///
  /// In en, this message translates to:
  /// **'for admins and super-admin'**
  String get loginAsAdminSubtitle;

  /// No description provided for @applyForJob.
  ///
  /// In en, this message translates to:
  /// **'Apply for a Job'**
  String get applyForJob;

  /// No description provided for @applyForJobSubtitle.
  ///
  /// In en, this message translates to:
  /// **'View open positions and apply with your qualifications'**
  String get applyForJobSubtitle;

  /// No description provided for @joinUsSocialMission.
  ///
  /// In en, this message translates to:
  /// **'Join Us on our social mission'**
  String get joinUsSocialMission;

  /// No description provided for @bePartOfChange.
  ///
  /// In en, this message translates to:
  /// **'Be a part of beautiful change'**
  String get bePartOfChange;

  /// No description provided for @purposeDrivenProducts.
  ///
  /// In en, this message translates to:
  /// **'Purpose Driven Products'**
  String get purposeDrivenProducts;

  /// No description provided for @everyProductCreatesImpact.
  ///
  /// In en, this message translates to:
  /// **'Every product you support creates impact'**
  String get everyProductCreatesImpact;

  /// No description provided for @donateSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Your support help us reach more communities'**
  String get donateSubtitle;

  /// No description provided for @ourVisionSection.
  ///
  /// In en, this message translates to:
  /// **'Our Vision • Our Work • Our Impact'**
  String get ourVisionSection;

  /// No description provided for @governmentNgoSchemes.
  ///
  /// In en, this message translates to:
  /// **'Government & NGO Schemes'**
  String get governmentNgoSchemes;

  /// No description provided for @schemesAvailableForYou.
  ///
  /// In en, this message translates to:
  /// **'Schemes Available for You'**
  String get schemesAvailableForYou;

  /// No description provided for @loginToViewSchemes.
  ///
  /// In en, this message translates to:
  /// **'Login as Beneficiary to view and apply for government & NGO schemes available in your area.'**
  String get loginToViewSchemes;

  /// No description provided for @loginToSeeAllSchemes.
  ///
  /// In en, this message translates to:
  /// **'Login as Beneficiary to see all {count} schemes & apply'**
  String loginToSeeAllSchemes(int count);

  /// No description provided for @loginToApplySchemes.
  ///
  /// In en, this message translates to:
  /// **'Login as Beneficiary to apply for these schemes'**
  String get loginToApplySchemes;

  /// No description provided for @loginAsEmployeeFull.
  ///
  /// In en, this message translates to:
  /// **'Login As Coordinator'**
  String get loginAsEmployeeFull;

  /// No description provided for @selectRoleToContinue.
  ///
  /// In en, this message translates to:
  /// **'Select your job role to continue'**
  String get selectRoleToContinue;

  /// No description provided for @selectYourRole.
  ///
  /// In en, this message translates to:
  /// **'Select Your Role'**
  String get selectYourRole;

  /// No description provided for @fieldWork.
  ///
  /// In en, this message translates to:
  /// **'Field work'**
  String get fieldWork;

  /// No description provided for @fieldWorkSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Works at ground/village level'**
  String get fieldWorkSubtitle;

  /// No description provided for @coordinator.
  ///
  /// In en, this message translates to:
  /// **'Co-ordinator'**
  String get coordinator;

  /// No description provided for @coordinatorSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Coordinates the working of office and ground team'**
  String get coordinatorSubtitle;

  /// No description provided for @employeeAccessOnly.
  ///
  /// In en, this message translates to:
  /// **'Coordinator Access Only'**
  String get employeeAccessOnly;

  /// No description provided for @employeeId.
  ///
  /// In en, this message translates to:
  /// **'Coordinator ID'**
  String get employeeId;

  /// No description provided for @enterEmployeeId.
  ///
  /// In en, this message translates to:
  /// **'Coordinator ID'**
  String get enterEmployeeId;

  /// No description provided for @useEmployeeIdNote.
  ///
  /// In en, this message translates to:
  /// **'Use Coordinator ID and Password Created by the Admin Panel'**
  String get useEmployeeIdNote;

  /// No description provided for @loginAsBeneficiaryFull.
  ///
  /// In en, this message translates to:
  /// **'Login As Beneficiary'**
  String get loginAsBeneficiaryFull;

  /// No description provided for @selectCategoryToContinue.
  ///
  /// In en, this message translates to:
  /// **'Select your category and continue'**
  String get selectCategoryToContinue;

  /// No description provided for @selectYourCategory.
  ///
  /// In en, this message translates to:
  /// **'Select Your Category'**
  String get selectYourCategory;

  /// No description provided for @beneficiaryAccessOnly.
  ///
  /// In en, this message translates to:
  /// **'Beneficiary Access Only'**
  String get beneficiaryAccessOnly;

  /// No description provided for @beneficiaryId.
  ///
  /// In en, this message translates to:
  /// **'Beneficiary ID'**
  String get beneficiaryId;

  /// No description provided for @enterId.
  ///
  /// In en, this message translates to:
  /// **'Enter ID'**
  String get enterId;

  /// No description provided for @useBeneficiaryIdNote.
  ///
  /// In en, this message translates to:
  /// **'Use ID and Password Created by the Admin Panel'**
  String get useBeneficiaryIdNote;

  /// No description provided for @farmer.
  ///
  /// In en, this message translates to:
  /// **'Farmer'**
  String get farmer;

  /// No description provided for @farmerSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Works in a farm'**
  String get farmerSubtitle;

  /// No description provided for @student.
  ///
  /// In en, this message translates to:
  /// **'Student'**
  String get student;

  /// No description provided for @studentSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Studying in a higher institution'**
  String get studentSubtitle;

  /// No description provided for @women.
  ///
  /// In en, this message translates to:
  /// **'Women'**
  String get women;

  /// No description provided for @womenSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Housewife or daily wage workers'**
  String get womenSubtitle;

  /// No description provided for @worker.
  ///
  /// In en, this message translates to:
  /// **'Worker'**
  String get worker;

  /// No description provided for @workerSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Daily wage workers or labours'**
  String get workerSubtitle;

  /// No description provided for @citizen.
  ///
  /// In en, this message translates to:
  /// **'Citizen'**
  String get citizen;

  /// No description provided for @citizenSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Citizens of Latur'**
  String get citizenSubtitle;

  /// No description provided for @loginTitle.
  ///
  /// In en, this message translates to:
  /// **'Login as {role}'**
  String loginTitle(String role);

  /// No description provided for @usernameEmail.
  ///
  /// In en, this message translates to:
  /// **'Username / Email'**
  String get usernameEmail;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @enterPassword.
  ///
  /// In en, this message translates to:
  /// **'Enter Password'**
  String get enterPassword;

  /// No description provided for @enterIdHint.
  ///
  /// In en, this message translates to:
  /// **'Enter ID'**
  String get enterIdHint;

  /// No description provided for @shilpkarEmployee.
  ///
  /// In en, this message translates to:
  /// **'Shilpkar Coordinator'**
  String get shilpkarEmployee;

  /// No description provided for @attendance.
  ///
  /// In en, this message translates to:
  /// **'Attendance'**
  String get attendance;

  /// No description provided for @attendancePunchInOut.
  ///
  /// In en, this message translates to:
  /// **'Punch in and Punch Out time of coordinators'**
  String get attendancePunchInOut;

  /// No description provided for @connectWithAdmin.
  ///
  /// In en, this message translates to:
  /// **'Connect with Admin'**
  String get connectWithAdmin;

  /// No description provided for @resolveQueries.
  ///
  /// In en, this message translates to:
  /// **'Resolve queries'**
  String get resolveQueries;

  /// No description provided for @announcements.
  ///
  /// In en, this message translates to:
  /// **'Announcements'**
  String get announcements;

  /// No description provided for @systemMessages.
  ///
  /// In en, this message translates to:
  /// **'System messages'**
  String get systemMessages;

  /// No description provided for @attendanceViewAll.
  ///
  /// In en, this message translates to:
  /// **'View all logs'**
  String get attendanceViewAll;

  /// No description provided for @welcomeShilpkar.
  ///
  /// In en, this message translates to:
  /// **'Welcome to Shilpkar Foundation'**
  String get welcomeShilpkar;

  /// No description provided for @empoweringCommunities.
  ///
  /// In en, this message translates to:
  /// **'Empowering communities with purpose driven actions'**
  String get empoweringCommunities;

  /// No description provided for @whatWeDoBrief.
  ///
  /// In en, this message translates to:
  /// **'what we do'**
  String get whatWeDoBrief;

  /// No description provided for @villageReached.
  ///
  /// In en, this message translates to:
  /// **'village reached'**
  String get villageReached;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @welcomeGuest.
  ///
  /// In en, this message translates to:
  /// **'Welcome, Guest!'**
  String get welcomeGuest;

  /// No description provided for @pleaseLoginManageProfile.
  ///
  /// In en, this message translates to:
  /// **'Please login to manage your profile and applications.'**
  String get pleaseLoginManageProfile;

  /// No description provided for @editProfile.
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get editProfile;

  /// No description provided for @basicDetails.
  ///
  /// In en, this message translates to:
  /// **'Basic Details'**
  String get basicDetails;

  /// No description provided for @locationDetails.
  ///
  /// In en, this message translates to:
  /// **'Location Details'**
  String get locationDetails;

  /// No description provided for @bankingDetails.
  ///
  /// In en, this message translates to:
  /// **'Banking details'**
  String get bankingDetails;

  /// No description provided for @username.
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get username;

  /// No description provided for @phoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Phone Number'**
  String get phoneNumber;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @dateOfBirth.
  ///
  /// In en, this message translates to:
  /// **'Date Of Birth'**
  String get dateOfBirth;

  /// No description provided for @state.
  ///
  /// In en, this message translates to:
  /// **'State'**
  String get state;

  /// No description provided for @district.
  ///
  /// In en, this message translates to:
  /// **'District'**
  String get district;

  /// No description provided for @taluka.
  ///
  /// In en, this message translates to:
  /// **'Taluka'**
  String get taluka;

  /// No description provided for @village.
  ///
  /// In en, this message translates to:
  /// **'Village'**
  String get village;

  /// No description provided for @address.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get address;

  /// No description provided for @accountNumber.
  ///
  /// In en, this message translates to:
  /// **'Account Number'**
  String get accountNumber;

  /// No description provided for @accountHolderName.
  ///
  /// In en, this message translates to:
  /// **'Account Holder\'s Name'**
  String get accountHolderName;

  /// No description provided for @ifscCode.
  ///
  /// In en, this message translates to:
  /// **'IFSC Code'**
  String get ifscCode;

  /// No description provided for @accountType.
  ///
  /// In en, this message translates to:
  /// **'Account Type'**
  String get accountType;

  /// No description provided for @upiId.
  ///
  /// In en, this message translates to:
  /// **'UPI ID'**
  String get upiId;

  /// No description provided for @deleteAccount.
  ///
  /// In en, this message translates to:
  /// **'Delete Account'**
  String get deleteAccount;

  /// No description provided for @deleteAccountConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete your account? This action cannot be undone.'**
  String get deleteAccountConfirm;

  /// No description provided for @accountDeletionSubmitted.
  ///
  /// In en, this message translates to:
  /// **'Account deletion request submitted.'**
  String get accountDeletionSubmitted;

  /// No description provided for @broadcastMessage.
  ///
  /// In en, this message translates to:
  /// **'📢 System Broadcast: {message}'**
  String broadcastMessage(String message);

  /// No description provided for @schemes.
  ///
  /// In en, this message translates to:
  /// **'Schemes'**
  String get schemes;

  /// No description provided for @jobs.
  ///
  /// In en, this message translates to:
  /// **'Jobs'**
  String get jobs;

  /// No description provided for @chat.
  ///
  /// In en, this message translates to:
  /// **'Chat'**
  String get chat;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @apply.
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get apply;

  /// No description provided for @applyScheme.
  ///
  /// In en, this message translates to:
  /// **'Apply for Scheme'**
  String get applyScheme;

  /// No description provided for @status.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get status;

  /// No description provided for @paid.
  ///
  /// In en, this message translates to:
  /// **'PAID'**
  String get paid;

  /// No description provided for @amount.
  ///
  /// In en, this message translates to:
  /// **'Amount: ₹{amt}'**
  String amount(String amt);

  /// No description provided for @date.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get date;

  /// No description provided for @location.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get location;

  /// No description provided for @punchIn.
  ///
  /// In en, this message translates to:
  /// **'Punch In'**
  String get punchIn;

  /// No description provided for @punchOut.
  ///
  /// In en, this message translates to:
  /// **'Punch Out'**
  String get punchOut;

  /// No description provided for @attendanceRecords.
  ///
  /// In en, this message translates to:
  /// **'Attendance Records'**
  String get attendanceRecords;

  /// No description provided for @noAttendanceFound.
  ///
  /// In en, this message translates to:
  /// **'No attendance records found.'**
  String get noAttendanceFound;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @overrideBtn.
  ///
  /// In en, this message translates to:
  /// **'Override'**
  String get overrideBtn;

  /// No description provided for @timeSincePunchIn.
  ///
  /// In en, this message translates to:
  /// **'Time since punch in'**
  String get timeSincePunchIn;

  /// No description provided for @attendanceCompleted.
  ///
  /// In en, this message translates to:
  /// **'Attendance Completed'**
  String get attendanceCompleted;

  /// No description provided for @totalHoursLabel.
  ///
  /// In en, this message translates to:
  /// **'Total Hours: {hours}'**
  String totalHoursLabel(String hours);

  /// No description provided for @gettingLocation.
  ///
  /// In en, this message translates to:
  /// **'Getting Location...'**
  String get gettingLocation;

  /// No description provided for @locationPermissionRequired.
  ///
  /// In en, this message translates to:
  /// **'Location permission required for attendance.'**
  String get locationPermissionRequired;

  /// No description provided for @viewFullHistory.
  ///
  /// In en, this message translates to:
  /// **'View Full Attendance History'**
  String get viewFullHistory;

  /// No description provided for @viewAllRecords.
  ///
  /// In en, this message translates to:
  /// **'View All Records'**
  String get viewAllRecords;

  /// No description provided for @punchInSuccess.
  ///
  /// In en, this message translates to:
  /// **'✅ Punch In Successful'**
  String get punchInSuccess;

  /// No description provided for @punchOutSuccess.
  ///
  /// In en, this message translates to:
  /// **'✅ Punch Out Successful'**
  String get punchOutSuccess;

  /// No description provided for @noRecord.
  ///
  /// In en, this message translates to:
  /// **'NO RECORD'**
  String get noRecord;

  /// No description provided for @markAllRead.
  ///
  /// In en, this message translates to:
  /// **'Mark All Read'**
  String get markAllRead;

  /// No description provided for @noNotificationsFound.
  ///
  /// In en, this message translates to:
  /// **'No notifications found.'**
  String get noNotificationsFound;

  /// No description provided for @yesterday.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get yesterday;

  /// No description provided for @applicationsFor.
  ///
  /// In en, this message translates to:
  /// **'Applications - {schemeName}'**
  String applicationsFor(String schemeName);

  /// No description provided for @noApplicationsFound.
  ///
  /// In en, this message translates to:
  /// **'No applications found for this job'**
  String get noApplicationsFound;

  /// No description provided for @resume.
  ///
  /// In en, this message translates to:
  /// **'Resume'**
  String get resume;

  /// No description provided for @photo.
  ///
  /// In en, this message translates to:
  /// **'Photo'**
  String get photo;

  /// No description provided for @accept.
  ///
  /// In en, this message translates to:
  /// **'Accept'**
  String get accept;

  /// No description provided for @reject.
  ///
  /// In en, this message translates to:
  /// **'Reject'**
  String get reject;

  /// No description provided for @couldNotOpenLink.
  ///
  /// In en, this message translates to:
  /// **'Could not open link'**
  String get couldNotOpenLink;

  /// No description provided for @acceptApplication.
  ///
  /// In en, this message translates to:
  /// **'Accept Application?'**
  String get acceptApplication;

  /// No description provided for @rejectApplication.
  ///
  /// In en, this message translates to:
  /// **'Reject Application?'**
  String get rejectApplication;

  /// No description provided for @confirmAccept.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to accept this application?'**
  String get confirmAccept;

  /// No description provided for @confirmReject.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to reject this application?'**
  String get confirmReject;

  /// No description provided for @applicationStatusUpdated.
  ///
  /// In en, this message translates to:
  /// **'Application {status}'**
  String applicationStatusUpdated(String status);

  /// No description provided for @applicationIdMissing.
  ///
  /// In en, this message translates to:
  /// **'Application ID is missing'**
  String get applicationIdMissing;

  /// No description provided for @createBeneficiary.
  ///
  /// In en, this message translates to:
  /// **'Create Beneficiary'**
  String get createBeneficiary;

  /// No description provided for @registrationForm.
  ///
  /// In en, this message translates to:
  /// **'Registration Form'**
  String get registrationForm;

  /// No description provided for @completeAllSections.
  ///
  /// In en, this message translates to:
  /// **'Complete all sections to create the account.'**
  String get completeAllSections;

  /// No description provided for @personalInformation.
  ///
  /// In en, this message translates to:
  /// **'Personal Information'**
  String get personalInformation;

  /// No description provided for @bankInformation.
  ///
  /// In en, this message translates to:
  /// **'Bank Information'**
  String get bankInformation;

  /// No description provided for @otherInformation.
  ///
  /// In en, this message translates to:
  /// **'Other Information'**
  String get otherInformation;

  /// No description provided for @firstName.
  ///
  /// In en, this message translates to:
  /// **'First Name'**
  String get firstName;

  /// No description provided for @lastName.
  ///
  /// In en, this message translates to:
  /// **'Last Name'**
  String get lastName;

  /// No description provided for @mobile.
  ///
  /// In en, this message translates to:
  /// **'Mobile'**
  String get mobile;

  /// No description provided for @emailField.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get emailField;

  /// No description provided for @accountNumberField.
  ///
  /// In en, this message translates to:
  /// **'Account Number'**
  String get accountNumberField;

  /// No description provided for @accountHolderField.
  ///
  /// In en, this message translates to:
  /// **'Account Holder*'**
  String get accountHolderField;

  /// No description provided for @ifscField.
  ///
  /// In en, this message translates to:
  /// **'IFSC*'**
  String get ifscField;

  /// No description provided for @accountTypeField.
  ///
  /// In en, this message translates to:
  /// **'Account Type'**
  String get accountTypeField;

  /// No description provided for @categoryField.
  ///
  /// In en, this message translates to:
  /// **'Category*'**
  String get categoryField;

  /// No description provided for @createBeneficiaryBtn.
  ///
  /// In en, this message translates to:
  /// **'CREATE BENEFICIARY'**
  String get createBeneficiaryBtn;

  /// No description provided for @completeRequiredFields.
  ///
  /// In en, this message translates to:
  /// **'Please complete all required fields'**
  String get completeRequiredFields;

  /// No description provided for @tenDigitsRequired.
  ///
  /// In en, this message translates to:
  /// **'10 digits required'**
  String get tenDigitsRequired;

  /// No description provided for @invalidEmail.
  ///
  /// In en, this message translates to:
  /// **'Invalid email'**
  String get invalidEmail;

  /// No description provided for @tooShort.
  ///
  /// In en, this message translates to:
  /// **'Too short'**
  String get tooShort;

  /// No description provided for @elevenCharsRequired.
  ///
  /// In en, this message translates to:
  /// **'11 characters required'**
  String get elevenCharsRequired;

  /// No description provided for @chatWith.
  ///
  /// In en, this message translates to:
  /// **'Chat with {name}'**
  String chatWith(String name);

  /// No description provided for @typeMessage.
  ///
  /// In en, this message translates to:
  /// **'Type a message...'**
  String get typeMessage;

  /// No description provided for @send.
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get send;

  /// No description provided for @noMessages.
  ///
  /// In en, this message translates to:
  /// **'No messages yet. Say hello!'**
  String get noMessages;

  /// No description provided for @requestChat.
  ///
  /// In en, this message translates to:
  /// **'Request Chat with Admin'**
  String get requestChat;

  /// No description provided for @noChatSessions.
  ///
  /// In en, this message translates to:
  /// **'No chat sessions yet.'**
  String get noChatSessions;

  /// No description provided for @connectToAdmin.
  ///
  /// In en, this message translates to:
  /// **'Connect to Admin'**
  String get connectToAdmin;

  /// No description provided for @adminChat.
  ///
  /// In en, this message translates to:
  /// **'Admin Chat'**
  String get adminChat;

  /// No description provided for @selectEmployee.
  ///
  /// In en, this message translates to:
  /// **'Select Employee'**
  String get selectEmployee;

  /// No description provided for @reason.
  ///
  /// In en, this message translates to:
  /// **'Reason for chat'**
  String get reason;

  /// No description provided for @submitRequest.
  ///
  /// In en, this message translates to:
  /// **'Submit Request'**
  String get submitRequest;

  /// No description provided for @chatRequested.
  ///
  /// In en, this message translates to:
  /// **'Chat request submitted!'**
  String get chatRequested;

  /// No description provided for @myApplications.
  ///
  /// In en, this message translates to:
  /// **'My Applications'**
  String get myApplications;

  /// No description provided for @noApplicationsYet.
  ///
  /// In en, this message translates to:
  /// **'No applications found.'**
  String get noApplicationsYet;

  /// No description provided for @appliedOn.
  ///
  /// In en, this message translates to:
  /// **'Applied on: {date}'**
  String appliedOn(String date);

  /// No description provided for @shilpkarSuperAdmin.
  ///
  /// In en, this message translates to:
  /// **'Shilpkar Super Admin'**
  String get shilpkarSuperAdmin;

  /// No description provided for @shilpkarAdmin.
  ///
  /// In en, this message translates to:
  /// **'Shilpkar Admin'**
  String get shilpkarAdmin;

  /// No description provided for @adminDashboard.
  ///
  /// In en, this message translates to:
  /// **'Admin Dashboard'**
  String get adminDashboard;

  /// No description provided for @adminDashboardSub.
  ///
  /// In en, this message translates to:
  /// **'Monitor foundation pillars and field operations'**
  String get adminDashboardSub;

  /// No description provided for @ourVisionWork.
  ///
  /// In en, this message translates to:
  /// **'Our Vision • Our Work • Our Impact'**
  String get ourVisionWork;

  /// No description provided for @manage.
  ///
  /// In en, this message translates to:
  /// **'Manage'**
  String get manage;

  /// No description provided for @see.
  ///
  /// In en, this message translates to:
  /// **'See'**
  String get see;

  /// No description provided for @explore.
  ///
  /// In en, this message translates to:
  /// **'Explore'**
  String get explore;

  /// No description provided for @createNow.
  ///
  /// In en, this message translates to:
  /// **'Create Now'**
  String get createNow;

  /// No description provided for @makeOthersAdmin.
  ///
  /// In en, this message translates to:
  /// **'Make Others Admin'**
  String get makeOthersAdmin;

  /// No description provided for @makeOthersAdminSub.
  ///
  /// In en, this message translates to:
  /// **'Add people in this good cause'**
  String get makeOthersAdminSub;

  /// No description provided for @makeAdmin.
  ///
  /// In en, this message translates to:
  /// **'Make Admin'**
  String get makeAdmin;

  /// No description provided for @makeEmployee.
  ///
  /// In en, this message translates to:
  /// **'Make Employee'**
  String get makeEmployee;

  /// No description provided for @makeEmployeeSub.
  ///
  /// In en, this message translates to:
  /// **'Add people in this good cause'**
  String get makeEmployeeSub;

  /// No description provided for @makeBeneficiary.
  ///
  /// In en, this message translates to:
  /// **'Make Beneficiary'**
  String get makeBeneficiary;

  /// No description provided for @makeBeneficiarySub.
  ///
  /// In en, this message translates to:
  /// **'Add new beneficiary'**
  String get makeBeneficiarySub;

  /// No description provided for @createEmployee.
  ///
  /// In en, this message translates to:
  /// **'Create Employee'**
  String get createEmployee;

  /// No description provided for @createEmployeeSub.
  ///
  /// In en, this message translates to:
  /// **'Onboard new staff & coordinators'**
  String get createEmployeeSub;

  /// No description provided for @paymentFixture.
  ///
  /// In en, this message translates to:
  /// **'Payment Fixture'**
  String get paymentFixture;

  /// No description provided for @paymentFixtureSub.
  ///
  /// In en, this message translates to:
  /// **'Fix payments for beneficiaries'**
  String get paymentFixtureSub;

  /// No description provided for @paymentHistory.
  ///
  /// In en, this message translates to:
  /// **'Payment History'**
  String get paymentHistory;

  /// No description provided for @paymentHistorySub.
  ///
  /// In en, this message translates to:
  /// **'Check payment history'**
  String get paymentHistorySub;

  /// No description provided for @manageSchemes.
  ///
  /// In en, this message translates to:
  /// **'Manage Schemes'**
  String get manageSchemes;

  /// No description provided for @manageSchemeSub.
  ///
  /// In en, this message translates to:
  /// **'Create, publish and archive schemes'**
  String get manageSchemeSub;

  /// No description provided for @manageJobsSub.
  ///
  /// In en, this message translates to:
  /// **'Edit & Create jobs'**
  String get manageJobsSub;

  /// No description provided for @manageJobs.
  ///
  /// In en, this message translates to:
  /// **'Manage Jobs'**
  String get manageJobs;

  /// No description provided for @ecommerceManagement.
  ///
  /// In en, this message translates to:
  /// **'Ecommerce Management'**
  String get ecommerceManagement;

  /// No description provided for @quickAccess.
  ///
  /// In en, this message translates to:
  /// **'Quick Access'**
  String get quickAccess;

  /// No description provided for @products.
  ///
  /// In en, this message translates to:
  /// **'Products'**
  String get products;

  /// No description provided for @manageInventory.
  ///
  /// In en, this message translates to:
  /// **'Manage inventory'**
  String get manageInventory;

  /// No description provided for @categories.
  ///
  /// In en, this message translates to:
  /// **'Categories'**
  String get categories;

  /// No description provided for @manageCategories.
  ///
  /// In en, this message translates to:
  /// **'Manage categories'**
  String get manageCategories;

  /// No description provided for @exploreProductsSub.
  ///
  /// In en, this message translates to:
  /// **'View the public store'**
  String get exploreProductsSub;

  /// No description provided for @jobRequests.
  ///
  /// In en, this message translates to:
  /// **'Job Requests'**
  String get jobRequests;

  /// No description provided for @jobRequestsSub.
  ///
  /// In en, this message translates to:
  /// **'Check details of people who applied for jobs'**
  String get jobRequestsSub;

  /// No description provided for @jobRequestsAdminSub.
  ///
  /// In en, this message translates to:
  /// **'People who applied for jobs'**
  String get jobRequestsAdminSub;

  /// No description provided for @chatRequests.
  ///
  /// In en, this message translates to:
  /// **'Chat Requests'**
  String get chatRequests;

  /// No description provided for @chatRequestsSub.
  ///
  /// In en, this message translates to:
  /// **'Manage help requests'**
  String get chatRequestsSub;

  /// No description provided for @systemBroadcasts.
  ///
  /// In en, this message translates to:
  /// **'System Broadcasts'**
  String get systemBroadcasts;

  /// No description provided for @systemBroadcastsSub.
  ///
  /// In en, this message translates to:
  /// **'Send announcements'**
  String get systemBroadcastsSub;

  /// No description provided for @onboardingConfig.
  ///
  /// In en, this message translates to:
  /// **'Onboarding Config'**
  String get onboardingConfig;

  /// No description provided for @onboardingConfigSub.
  ///
  /// In en, this message translates to:
  /// **'Contribution & waiver management'**
  String get onboardingConfigSub;

  /// No description provided for @manageOrders.
  ///
  /// In en, this message translates to:
  /// **'Manage Orders'**
  String get manageOrders;

  /// No description provided for @manageOrdersSub.
  ///
  /// In en, this message translates to:
  /// **'Track & update orders'**
  String get manageOrdersSub;

  /// No description provided for @refundRequests.
  ///
  /// In en, this message translates to:
  /// **'Refund Requests'**
  String get refundRequests;

  /// No description provided for @refundRequestsSub.
  ///
  /// In en, this message translates to:
  /// **'Approve or reject returns'**
  String get refundRequestsSub;

  /// No description provided for @attendanceSub.
  ///
  /// In en, this message translates to:
  /// **'View employee attendance'**
  String get attendanceSub;

  /// No description provided for @applyForAJob.
  ///
  /// In en, this message translates to:
  /// **'Apply for a Job'**
  String get applyForAJob;

  /// No description provided for @applyForAJobSub.
  ///
  /// In en, this message translates to:
  /// **'View open positions and apply with your qualifications'**
  String get applyForAJobSub;

  /// No description provided for @myJobApplications.
  ///
  /// In en, this message translates to:
  /// **'My Job Applications'**
  String get myJobApplications;

  /// No description provided for @myJobApplicationsSub.
  ///
  /// In en, this message translates to:
  /// **'Track your applied benefits'**
  String get myJobApplicationsSub;

  /// No description provided for @viewApplications.
  ///
  /// In en, this message translates to:
  /// **'View Applications'**
  String get viewApplications;

  /// No description provided for @productsSub.
  ///
  /// In en, this message translates to:
  /// **'Explore purpose driven products'**
  String get productsSub;

  /// No description provided for @announcementsSub.
  ///
  /// In en, this message translates to:
  /// **'View important system messages'**
  String get announcementsSub;

  /// No description provided for @myOrders.
  ///
  /// In en, this message translates to:
  /// **'My Orders'**
  String get myOrders;

  /// No description provided for @myOrdersSub.
  ///
  /// In en, this message translates to:
  /// **'Track your purchases and refund requests'**
  String get myOrdersSub;

  /// No description provided for @connectWithAdminSub.
  ///
  /// In en, this message translates to:
  /// **'Connect to resolve queries'**
  String get connectWithAdminSub;

  /// No description provided for @filterJobs.
  ///
  /// In en, this message translates to:
  /// **'Filter Jobs'**
  String get filterJobs;

  /// No description provided for @city.
  ///
  /// In en, this message translates to:
  /// **'City*'**
  String get city;

  /// No description provided for @category.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get category;

  /// No description provided for @clear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get clear;

  /// No description provided for @noJobsFound.
  ///
  /// In en, this message translates to:
  /// **'No jobs found'**
  String get noJobsFound;

  /// No description provided for @unpaid.
  ///
  /// In en, this message translates to:
  /// **'Unpaid'**
  String get unpaid;

  /// No description provided for @viewDetails.
  ///
  /// In en, this message translates to:
  /// **'View Details'**
  String get viewDetails;

  /// No description provided for @totalApps.
  ///
  /// In en, this message translates to:
  /// **'Total Apps'**
  String get totalApps;

  /// No description provided for @paymentsLabel.
  ///
  /// In en, this message translates to:
  /// **'Payments'**
  String get paymentsLabel;

  /// No description provided for @active.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get active;

  /// No description provided for @completed.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get completed;

  /// No description provided for @recentUnpaidApplications.
  ///
  /// In en, this message translates to:
  /// **'Recent Unpaid Applications'**
  String get recentUnpaidApplications;

  /// No description provided for @noPendingPayouts.
  ///
  /// In en, this message translates to:
  /// **'No pending payouts found.'**
  String get noPendingPayouts;

  /// No description provided for @totalPayoutsDisbursed.
  ///
  /// In en, this message translates to:
  /// **'Total Payouts Disbursed'**
  String get totalPayoutsDisbursed;

  /// No description provided for @transactions.
  ///
  /// In en, this message translates to:
  /// **'{count} transactions'**
  String transactions(int count);

  /// No description provided for @schemeStats.
  ///
  /// In en, this message translates to:
  /// **'{name} Stats'**
  String schemeStats(String name);

  /// No description provided for @statusLabel.
  ///
  /// In en, this message translates to:
  /// **'Status: {status}'**
  String statusLabel(String status);

  /// No description provided for @selectAdminLevel.
  ///
  /// In en, this message translates to:
  /// **'Select your administration level'**
  String get selectAdminLevel;

  /// No description provided for @selectAdminType.
  ///
  /// In en, this message translates to:
  /// **'Select Admin Type'**
  String get selectAdminType;

  /// No description provided for @superAdmin.
  ///
  /// In en, this message translates to:
  /// **'Super Admin'**
  String get superAdmin;

  /// No description provided for @fullSystemAccess.
  ///
  /// In en, this message translates to:
  /// **'Full system access & user management'**
  String get fullSystemAccess;

  /// No description provided for @adminLabel.
  ///
  /// In en, this message translates to:
  /// **'Admin'**
  String get adminLabel;

  /// No description provided for @manageJobsSchemesB.
  ///
  /// In en, this message translates to:
  /// **'Manage jobs, schemes, and beneficiaries'**
  String get manageJobsSchemesB;

  /// No description provided for @adminPanelAccess.
  ///
  /// In en, this message translates to:
  /// **'Admin Panel Access'**
  String get adminPanelAccess;

  /// No description provided for @authorizedOnly.
  ///
  /// In en, this message translates to:
  /// **'Authorized Personnel Only'**
  String get authorizedOnly;

  /// No description provided for @emailAddress.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get emailAddress;

  /// No description provided for @adminIdLabel.
  ///
  /// In en, this message translates to:
  /// **'Admin ID'**
  String get adminIdLabel;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot Password?'**
  String get forgotPassword;

  /// No description provided for @adminDetails.
  ///
  /// In en, this message translates to:
  /// **'Admin Details'**
  String get adminDetails;

  /// No description provided for @firstNameStar.
  ///
  /// In en, this message translates to:
  /// **'First Name*'**
  String get firstNameStar;

  /// No description provided for @lastNameStar.
  ///
  /// In en, this message translates to:
  /// **'Last Name*'**
  String get lastNameStar;

  /// No description provided for @mobileStar.
  ///
  /// In en, this message translates to:
  /// **'Mobile*'**
  String get mobileStar;

  /// No description provided for @emailStar.
  ///
  /// In en, this message translates to:
  /// **'Email*'**
  String get emailStar;

  /// No description provided for @dobStar.
  ///
  /// In en, this message translates to:
  /// **'DOB*'**
  String get dobStar;

  /// No description provided for @firstNameRequired.
  ///
  /// In en, this message translates to:
  /// **'First name required'**
  String get firstNameRequired;

  /// No description provided for @lastNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Last name required'**
  String get lastNameRequired;

  /// No description provided for @mobileRequired.
  ///
  /// In en, this message translates to:
  /// **'Mobile required'**
  String get mobileRequired;

  /// No description provided for @mobileMustBe10.
  ///
  /// In en, this message translates to:
  /// **'Mobile must be 10 digits'**
  String get mobileMustBe10;

  /// No description provided for @emailRequired.
  ///
  /// In en, this message translates to:
  /// **'Email required'**
  String get emailRequired;

  /// No description provided for @enterValidEmail.
  ///
  /// In en, this message translates to:
  /// **'Enter valid email'**
  String get enterValidEmail;

  /// No description provided for @dobRequired.
  ///
  /// In en, this message translates to:
  /// **'DOB required'**
  String get dobRequired;

  /// No description provided for @errorCreatingAdmin.
  ///
  /// In en, this message translates to:
  /// **'Error creating admin'**
  String get errorCreatingAdmin;

  /// No description provided for @selectEmployeeRole.
  ///
  /// In en, this message translates to:
  /// **'Select Employee Role'**
  String get selectEmployeeRole;

  /// No description provided for @chooseEmployeeType.
  ///
  /// In en, this message translates to:
  /// **'Choose the type of employee to create'**
  String get chooseEmployeeType;

  /// No description provided for @fieldEmployeeLabel.
  ///
  /// In en, this message translates to:
  /// **'Field Employee'**
  String get fieldEmployeeLabel;

  /// No description provided for @worksOnGround.
  ///
  /// In en, this message translates to:
  /// **'Works on ground operations'**
  String get worksOnGround;

  /// No description provided for @coordinatorLabel.
  ///
  /// In en, this message translates to:
  /// **'Coordinator'**
  String get coordinatorLabel;

  /// No description provided for @managesFieldEmployees.
  ///
  /// In en, this message translates to:
  /// **'Manages field employees'**
  String get managesFieldEmployees;

  /// No description provided for @noSchemesAvailable.
  ///
  /// In en, this message translates to:
  /// **'No schemes available currently'**
  String get noSchemesAvailable;

  /// No description provided for @availableSchemesCount.
  ///
  /// In en, this message translates to:
  /// **'Available Schemes ({count})'**
  String availableSchemesCount(int count);

  /// No description provided for @moreSchemesAfterLogin.
  ///
  /// In en, this message translates to:
  /// **'+{count} more schemes available after login'**
  String moreSchemesAfterLogin(int count);

  /// No description provided for @unlockAllSchemes.
  ///
  /// In en, this message translates to:
  /// **'Unlock All Schemes'**
  String get unlockAllSchemes;

  /// No description provided for @loginBeneficiarySchemeDesc.
  ///
  /// In en, this message translates to:
  /// **'Login as a Beneficiary to view full scheme details, check eligibility, and apply directly from this screen.'**
  String get loginBeneficiarySchemeDesc;

  /// No description provided for @loginAsBeneficiaryBtn.
  ///
  /// In en, this message translates to:
  /// **'Login as Beneficiary'**
  String get loginAsBeneficiaryBtn;

  /// No description provided for @createRoleTitle.
  ///
  /// In en, this message translates to:
  /// **'Create {role}'**
  String createRoleTitle(String role);

  /// No description provided for @dateOfBirthStar.
  ///
  /// In en, this message translates to:
  /// **'Date of Birth*'**
  String get dateOfBirthStar;

  /// No description provided for @districtStar.
  ///
  /// In en, this message translates to:
  /// **'District*'**
  String get districtStar;

  /// No description provided for @talukaStar.
  ///
  /// In en, this message translates to:
  /// **'Taluka*'**
  String get talukaStar;

  /// No description provided for @villageStar.
  ///
  /// In en, this message translates to:
  /// **'Village*'**
  String get villageStar;

  /// No description provided for @accountNumberStar.
  ///
  /// In en, this message translates to:
  /// **'Account Number*'**
  String get accountNumberStar;

  /// No description provided for @accountHolderStar.
  ///
  /// In en, this message translates to:
  /// **'Account Holder*'**
  String get accountHolderStar;

  /// No description provided for @ifscStar.
  ///
  /// In en, this message translates to:
  /// **'IFSC*'**
  String get ifscStar;

  /// No description provided for @accountTypeStar.
  ///
  /// In en, this message translates to:
  /// **'Account Type*'**
  String get accountTypeStar;

  /// No description provided for @createEmployeeBtn.
  ///
  /// In en, this message translates to:
  /// **'CREATE EMPLOYEE'**
  String get createEmployeeBtn;

  /// No description provided for @pleaseCompleteFields.
  ///
  /// In en, this message translates to:
  /// **'Please complete all required fields'**
  String get pleaseCompleteFields;

  /// No description provided for @errorCreatingEmployee.
  ///
  /// In en, this message translates to:
  /// **'Error creating employee'**
  String get errorCreatingEmployee;

  /// No description provided for @adminCreatedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Admin Created Successfully'**
  String get adminCreatedSuccess;

  /// No description provided for @employeeCreatedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Employee Created Successfully'**
  String get employeeCreatedSuccess;

  /// No description provided for @credentialsForAdmin.
  ///
  /// In en, this message translates to:
  /// **'The credentials for the created admin are:'**
  String get credentialsForAdmin;

  /// No description provided for @credentialsForEmployee.
  ///
  /// In en, this message translates to:
  /// **'The credentials for the created employee are:'**
  String get credentialsForEmployee;

  /// No description provided for @usernameLabel.
  ///
  /// In en, this message translates to:
  /// **'Username: {value}'**
  String usernameLabel(String value);

  /// No description provided for @passwordLabel.
  ///
  /// In en, this message translates to:
  /// **'Password: {value}'**
  String passwordLabel(String value);

  /// No description provided for @copyAllCredentials.
  ///
  /// In en, this message translates to:
  /// **'Copy All Credentials'**
  String get copyAllCredentials;

  /// No description provided for @copiedToClipboard.
  ///
  /// In en, this message translates to:
  /// **'{label} copied to clipboard'**
  String copiedToClipboard(String label);

  /// No description provided for @credentialsCopied.
  ///
  /// In en, this message translates to:
  /// **'Credentials copied successfully'**
  String get credentialsCopied;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @usernameField.
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get usernameField;

  /// No description provided for @phoneNumberField.
  ///
  /// In en, this message translates to:
  /// **'Phone Number'**
  String get phoneNumberField;

  /// No description provided for @dateOfBirthField.
  ///
  /// In en, this message translates to:
  /// **'Date of Birth'**
  String get dateOfBirthField;

  /// No description provided for @stateField.
  ///
  /// In en, this message translates to:
  /// **'State'**
  String get stateField;

  /// No description provided for @districtField.
  ///
  /// In en, this message translates to:
  /// **'District'**
  String get districtField;

  /// No description provided for @talukaField.
  ///
  /// In en, this message translates to:
  /// **'Taluka'**
  String get talukaField;

  /// No description provided for @villageField.
  ///
  /// In en, this message translates to:
  /// **'Village'**
  String get villageField;

  /// No description provided for @addressField.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get addressField;

  /// No description provided for @accountHolderNameField.
  ///
  /// In en, this message translates to:
  /// **'Account Holder\'s Name'**
  String get accountHolderNameField;

  /// No description provided for @ifscCodeField.
  ///
  /// In en, this message translates to:
  /// **'IFSC Code'**
  String get ifscCodeField;

  /// No description provided for @upiIdField.
  ///
  /// In en, this message translates to:
  /// **'UPI ID'**
  String get upiIdField;

  /// No description provided for @schemeManagement.
  ///
  /// In en, this message translates to:
  /// **'Scheme Management'**
  String get schemeManagement;

  /// No description provided for @createNewScheme.
  ///
  /// In en, this message translates to:
  /// **'Create New Scheme'**
  String get createNewScheme;

  /// No description provided for @editScheme.
  ///
  /// In en, this message translates to:
  /// **'Edit Scheme'**
  String get editScheme;

  /// No description provided for @schemeName.
  ///
  /// In en, this message translates to:
  /// **'Scheme Name'**
  String get schemeName;

  /// No description provided for @description.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get description;

  /// No description provided for @benefitsCommaSep.
  ///
  /// In en, this message translates to:
  /// **'Benefits (comma separated)'**
  String get benefitsCommaSep;

  /// No description provided for @schemeType.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get schemeType;

  /// No description provided for @priceInr.
  ///
  /// In en, this message translates to:
  /// **'Price (₹)'**
  String get priceInr;

  /// No description provided for @financial.
  ///
  /// In en, this message translates to:
  /// **'Financial'**
  String get financial;

  /// No description provided for @payoutMode.
  ///
  /// In en, this message translates to:
  /// **'Payout Mode'**
  String get payoutMode;

  /// No description provided for @createScheme.
  ///
  /// In en, this message translates to:
  /// **'Create Scheme'**
  String get createScheme;

  /// No description provided for @saveChanges.
  ///
  /// In en, this message translates to:
  /// **'Save Changes'**
  String get saveChanges;

  /// No description provided for @cancelEditing.
  ///
  /// In en, this message translates to:
  /// **'Cancel Editing'**
  String get cancelEditing;

  /// No description provided for @noSchemesFound.
  ///
  /// In en, this message translates to:
  /// **'No Schemes Found.'**
  String get noSchemesFound;

  /// No description provided for @endOfResults.
  ///
  /// In en, this message translates to:
  /// **'End of results.'**
  String get endOfResults;

  /// No description provided for @schemeCreatedDrafted.
  ///
  /// In en, this message translates to:
  /// **'Scheme Created & Auto-Drafted'**
  String get schemeCreatedDrafted;

  /// No description provided for @schemeUpdated.
  ///
  /// In en, this message translates to:
  /// **'Scheme Updated'**
  String get schemeUpdated;

  /// No description provided for @failedToCreate.
  ///
  /// In en, this message translates to:
  /// **'Failed to create'**
  String get failedToCreate;

  /// No description provided for @failedToDelete.
  ///
  /// In en, this message translates to:
  /// **'Failed to delete'**
  String get failedToDelete;

  /// No description provided for @deleteScheme.
  ///
  /// In en, this message translates to:
  /// **'Delete Scheme?'**
  String get deleteScheme;

  /// No description provided for @deleteSchemeConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this scheme? This will archive or soft delete it from the system.'**
  String get deleteSchemeConfirm;

  /// No description provided for @schemeDeleted.
  ///
  /// In en, this message translates to:
  /// **'Scheme Deleted'**
  String get schemeDeleted;

  /// No description provided for @publish.
  ///
  /// In en, this message translates to:
  /// **'Publish'**
  String get publish;

  /// No description provided for @archive.
  ///
  /// In en, this message translates to:
  /// **'Archive'**
  String get archive;

  /// No description provided for @republish.
  ///
  /// In en, this message translates to:
  /// **'Republish'**
  String get republish;

  /// No description provided for @viewDashboard.
  ///
  /// In en, this message translates to:
  /// **'View Dashboard'**
  String get viewDashboard;

  /// No description provided for @productInventory.
  ///
  /// In en, this message translates to:
  /// **'Product Inventory'**
  String get productInventory;

  /// No description provided for @deleteProduct.
  ///
  /// In en, this message translates to:
  /// **'Delete Product?'**
  String get deleteProduct;

  /// No description provided for @deleteProductConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete \'{name}\'? This action is permanent.'**
  String deleteProductConfirm(String name);

  /// No description provided for @productRemoved.
  ///
  /// In en, this message translates to:
  /// **'Product removed'**
  String get productRemoved;

  /// No description provided for @inventoryEmpty.
  ///
  /// In en, this message translates to:
  /// **'Inventory is empty. Add your first product!'**
  String get inventoryEmpty;

  /// No description provided for @newProduct.
  ///
  /// In en, this message translates to:
  /// **'New Product'**
  String get newProduct;

  /// No description provided for @categoriesTitle.
  ///
  /// In en, this message translates to:
  /// **'Categories'**
  String get categoriesTitle;

  /// No description provided for @editCategory.
  ///
  /// In en, this message translates to:
  /// **'Edit Category'**
  String get editCategory;

  /// No description provided for @newCategory.
  ///
  /// In en, this message translates to:
  /// **'New Category'**
  String get newCategory;

  /// No description provided for @categoryName.
  ///
  /// In en, this message translates to:
  /// **'Category Name'**
  String get categoryName;

  /// No description provided for @categoryNameHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Electronics'**
  String get categoryNameHint;

  /// No description provided for @update.
  ///
  /// In en, this message translates to:
  /// **'Update'**
  String get update;

  /// No description provided for @keepIt.
  ///
  /// In en, this message translates to:
  /// **'Keep it'**
  String get keepIt;

  /// No description provided for @categoryUpdated.
  ///
  /// In en, this message translates to:
  /// **'Category updated'**
  String get categoryUpdated;

  /// No description provided for @categoryCreated.
  ///
  /// In en, this message translates to:
  /// **'Category created'**
  String get categoryCreated;

  /// No description provided for @categoryDeleted.
  ///
  /// In en, this message translates to:
  /// **'Category deleted'**
  String get categoryDeleted;

  /// No description provided for @deleteCategoryConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete \'{name}\'? This will affect all products linked to this category.'**
  String deleteCategoryConfirm(String name);

  /// No description provided for @noCategoriesFound.
  ///
  /// In en, this message translates to:
  /// **'No categories found'**
  String get noCategoriesFound;

  /// No description provided for @addCategory.
  ///
  /// In en, this message translates to:
  /// **'Add Category'**
  String get addCategory;

  /// No description provided for @tryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try Again'**
  String get tryAgain;

  /// No description provided for @orderManagement.
  ///
  /// In en, this message translates to:
  /// **'Order Management'**
  String get orderManagement;

  /// No description provided for @updateOrderStatus.
  ///
  /// In en, this message translates to:
  /// **'Update Order Status'**
  String get updateOrderStatus;

  /// No description provided for @applyChanges.
  ///
  /// In en, this message translates to:
  /// **'Apply Changes'**
  String get applyChanges;

  /// No description provided for @markedAsDelivered.
  ///
  /// In en, this message translates to:
  /// **'Marked as Delivered'**
  String get markedAsDelivered;

  /// No description provided for @deliveredAt.
  ///
  /// In en, this message translates to:
  /// **'Delivered At'**
  String get deliveredAt;

  /// No description provided for @refundWindowExpires.
  ///
  /// In en, this message translates to:
  /// **'Refund Window Expires'**
  String get refundWindowExpires;

  /// No description provided for @customerCanRequestRefund.
  ///
  /// In en, this message translates to:
  /// **'Customer can request refund/replacement within 7 days.'**
  String get customerCanRequestRefund;

  /// No description provided for @gotIt.
  ///
  /// In en, this message translates to:
  /// **'Got it'**
  String get gotIt;

  /// No description provided for @manageStatus.
  ///
  /// In en, this message translates to:
  /// **'Manage Status'**
  String get manageStatus;

  /// No description provided for @noOrdersYet.
  ///
  /// In en, this message translates to:
  /// **'No orders yet'**
  String get noOrdersYet;

  /// No description provided for @returnRequests.
  ///
  /// In en, this message translates to:
  /// **'Return Requests'**
  String get returnRequests;

  /// No description provided for @customerReason.
  ///
  /// In en, this message translates to:
  /// **'Customer Reason'**
  String get customerReason;

  /// No description provided for @adminRemark.
  ///
  /// In en, this message translates to:
  /// **'Admin Remark'**
  String get adminRemark;

  /// No description provided for @noReturnRequests.
  ///
  /// In en, this message translates to:
  /// **'No return requests'**
  String get noReturnRequests;

  /// No description provided for @approve.
  ///
  /// In en, this message translates to:
  /// **'Approve'**
  String get approve;

  /// No description provided for @retryRefundProcessing.
  ///
  /// In en, this message translates to:
  /// **'Retry Refund Processing'**
  String get retryRefundProcessing;

  /// No description provided for @rejectReturnRequest.
  ///
  /// In en, this message translates to:
  /// **'Reject Return Request'**
  String get rejectReturnRequest;

  /// No description provided for @provideReasonForRejection.
  ///
  /// In en, this message translates to:
  /// **'Provide a reason for rejection.'**
  String get provideReasonForRejection;

  /// No description provided for @adminRemarkRequired.
  ///
  /// In en, this message translates to:
  /// **'Admin Remark *'**
  String get adminRemarkRequired;

  /// No description provided for @adminRemarkHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Item not eligible for return per policy'**
  String get adminRemarkHint;

  /// No description provided for @remarkRequired.
  ///
  /// In en, this message translates to:
  /// **'A remark is required to reject.'**
  String get remarkRequired;

  /// No description provided for @requestApproved.
  ///
  /// In en, this message translates to:
  /// **'Request approved. Refund/Replacement processing initiated.'**
  String get requestApproved;

  /// No description provided for @requestRejected.
  ///
  /// In en, this message translates to:
  /// **'Request rejected.'**
  String get requestRejected;

  /// No description provided for @refundRetryInitiated.
  ///
  /// In en, this message translates to:
  /// **'Refund retry initiated.'**
  String get refundRetryInitiated;

  /// No description provided for @chatSupport.
  ///
  /// In en, this message translates to:
  /// **'Chat Support'**
  String get chatSupport;

  /// No description provided for @activeChats.
  ///
  /// In en, this message translates to:
  /// **'Active Chats'**
  String get activeChats;

  /// No description provided for @requests.
  ///
  /// In en, this message translates to:
  /// **'Requests'**
  String get requests;

  /// No description provided for @noActiveChats.
  ///
  /// In en, this message translates to:
  /// **'No active chats'**
  String get noActiveChats;

  /// No description provided for @noRequestsFound.
  ///
  /// In en, this message translates to:
  /// **'No requests found'**
  String get noRequestsFound;

  /// No description provided for @newRequest.
  ///
  /// In en, this message translates to:
  /// **'New Request'**
  String get newRequest;

  /// No description provided for @openChat.
  ///
  /// In en, this message translates to:
  /// **'Open Chat'**
  String get openChat;

  /// No description provided for @youSentThisRequest.
  ///
  /// In en, this message translates to:
  /// **'You sent this request'**
  String get youSentThisRequest;

  /// No description provided for @with_.
  ///
  /// In en, this message translates to:
  /// **'With: {name} • {status}'**
  String with_(String name, String status);

  /// No description provided for @createdOn.
  ///
  /// In en, this message translates to:
  /// **'Created on: {date}'**
  String createdOn(String date);

  /// No description provided for @from_.
  ///
  /// In en, this message translates to:
  /// **'From: {name} ({role})'**
  String from_(String name, String role);

  /// No description provided for @customerAccount.
  ///
  /// In en, this message translates to:
  /// **'Customer Account'**
  String get customerAccount;

  /// No description provided for @register.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get register;

  /// No description provided for @loginToContinue.
  ///
  /// In en, this message translates to:
  /// **'Login to continue'**
  String get loginToContinue;

  /// No description provided for @createCustomerAccount.
  ///
  /// In en, this message translates to:
  /// **'Create a customer account'**
  String get createCustomerAccount;

  /// No description provided for @fullName.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get fullName;

  /// No description provided for @pleaseEnterEmail.
  ///
  /// In en, this message translates to:
  /// **'Please enter email'**
  String get pleaseEnterEmail;

  /// No description provided for @pleaseEnterValidEmail.
  ///
  /// In en, this message translates to:
  /// **'Please enter valid email'**
  String get pleaseEnterValidEmail;

  /// No description provided for @pleaseEnterPassword.
  ///
  /// In en, this message translates to:
  /// **'Please enter password'**
  String get pleaseEnterPassword;

  /// No description provided for @validEmailRequired.
  ///
  /// In en, this message translates to:
  /// **'Valid email required'**
  String get validEmailRequired;

  /// No description provided for @minSixChars.
  ///
  /// In en, this message translates to:
  /// **'Min 6 characters required'**
  String get minSixChars;

  /// No description provided for @successProceeding.
  ///
  /// In en, this message translates to:
  /// **'Success! Proceeding...'**
  String get successProceeding;

  /// No description provided for @actionFailed.
  ///
  /// In en, this message translates to:
  /// **'Action failed'**
  String get actionFailed;

  /// No description provided for @myProfileAndOrders.
  ///
  /// In en, this message translates to:
  /// **'My Profile & Orders'**
  String get myProfileAndOrders;

  /// No description provided for @loggedOut.
  ///
  /// In en, this message translates to:
  /// **'Logged out'**
  String get loggedOut;

  /// No description provided for @notLoggedIn.
  ///
  /// In en, this message translates to:
  /// **'Not Logged In'**
  String get notLoggedIn;

  /// No description provided for @loginToViewProfile.
  ///
  /// In en, this message translates to:
  /// **'Login or create an account to view your profile and track your orders.'**
  String get loginToViewProfile;

  /// No description provided for @loginRegister.
  ///
  /// In en, this message translates to:
  /// **'Login / Register'**
  String get loginRegister;

  /// No description provided for @viewFullOrderHistory.
  ///
  /// In en, this message translates to:
  /// **'View Full Order History'**
  String get viewFullOrderHistory;

  /// No description provided for @noOrdersYetCustomer.
  ///
  /// In en, this message translates to:
  /// **'No orders yet'**
  String get noOrdersYetCustomer;

  /// No description provided for @requestReturnRefund.
  ///
  /// In en, this message translates to:
  /// **'Request Return/Refund'**
  String get requestReturnRefund;

  /// No description provided for @refund.
  ///
  /// In en, this message translates to:
  /// **'Refund'**
  String get refund;

  /// No description provided for @replacement.
  ///
  /// In en, this message translates to:
  /// **'Replacement'**
  String get replacement;

  /// No description provided for @reasonForReturn.
  ///
  /// In en, this message translates to:
  /// **'Reason for return'**
  String get reasonForReturn;

  /// No description provided for @submit.
  ///
  /// In en, this message translates to:
  /// **'Submit'**
  String get submit;

  /// No description provided for @cancelOrder.
  ///
  /// In en, this message translates to:
  /// **'CANCEL ORDER'**
  String get cancelOrder;

  /// No description provided for @requestRefund.
  ///
  /// In en, this message translates to:
  /// **'REQUEST REFUND'**
  String get requestRefund;

  /// No description provided for @cancelOrderTitle.
  ///
  /// In en, this message translates to:
  /// **'Cancel Order?'**
  String get cancelOrderTitle;

  /// No description provided for @cancelOrderConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to cancel this order?'**
  String get cancelOrderConfirm;

  /// No description provided for @yesCancelIt.
  ///
  /// In en, this message translates to:
  /// **'Yes, Cancel'**
  String get yesCancelIt;

  /// No description provided for @returnRequestSubmitted.
  ///
  /// In en, this message translates to:
  /// **'Return request submitted successfully'**
  String get returnRequestSubmitted;

  /// No description provided for @orderCancelledSuccess.
  ///
  /// In en, this message translates to:
  /// **'Order cancelled successfully'**
  String get orderCancelledSuccess;

  /// No description provided for @quantity.
  ///
  /// In en, this message translates to:
  /// **'Quantity: {qty}'**
  String quantity(String qty);

  /// No description provided for @paymentStatus.
  ///
  /// In en, this message translates to:
  /// **'Payment Status'**
  String get paymentStatus;

  /// No description provided for @addProduct.
  ///
  /// In en, this message translates to:
  /// **'Add Product'**
  String get addProduct;

  /// No description provided for @editProduct.
  ///
  /// In en, this message translates to:
  /// **'Edit Product'**
  String get editProduct;

  /// No description provided for @updateProduct.
  ///
  /// In en, this message translates to:
  /// **'Update Product'**
  String get updateProduct;

  /// No description provided for @createProduct.
  ///
  /// In en, this message translates to:
  /// **'Create Product'**
  String get createProduct;

  /// No description provided for @selectCategory.
  ///
  /// In en, this message translates to:
  /// **'Select a category'**
  String get selectCategory;

  /// No description provided for @productName.
  ///
  /// In en, this message translates to:
  /// **'Product Name'**
  String get productName;

  /// No description provided for @price.
  ///
  /// In en, this message translates to:
  /// **'Price'**
  String get price;

  /// No description provided for @isFeatured.
  ///
  /// In en, this message translates to:
  /// **'Is Featured?'**
  String get isFeatured;

  /// No description provided for @isActive.
  ///
  /// In en, this message translates to:
  /// **'Is Active?'**
  String get isActive;

  /// No description provided for @productImages.
  ///
  /// In en, this message translates to:
  /// **'Product Images'**
  String get productImages;

  /// No description provided for @addImages.
  ///
  /// In en, this message translates to:
  /// **'Add Images'**
  String get addImages;

  /// No description provided for @noImagesSelected.
  ///
  /// In en, this message translates to:
  /// **'No images selected'**
  String get noImagesSelected;

  /// No description provided for @pleaseSelectCategory.
  ///
  /// In en, this message translates to:
  /// **'Please select a category'**
  String get pleaseSelectCategory;

  /// No description provided for @pleaseUploadImage.
  ///
  /// In en, this message translates to:
  /// **'Please upload at least one image'**
  String get pleaseUploadImage;

  /// No description provided for @enterProductName.
  ///
  /// In en, this message translates to:
  /// **'Enter product name'**
  String get enterProductName;

  /// No description provided for @enterPrice.
  ///
  /// In en, this message translates to:
  /// **'Enter price'**
  String get enterPrice;

  /// No description provided for @enterValidNumber.
  ///
  /// In en, this message translates to:
  /// **'Enter valid number'**
  String get enterValidNumber;

  /// No description provided for @productUpdated.
  ///
  /// In en, this message translates to:
  /// **'Product Updated'**
  String get productUpdated;

  /// No description provided for @productCreated.
  ///
  /// In en, this message translates to:
  /// **'Product Created'**
  String get productCreated;

  /// No description provided for @imagesUploaded.
  ///
  /// In en, this message translates to:
  /// **'{count} images uploaded successfully!'**
  String imagesUploaded(int count);

  /// No description provided for @uploadFailed.
  ///
  /// In en, this message translates to:
  /// **'Upload failed'**
  String get uploadFailed;

  /// No description provided for @jobManagement.
  ///
  /// In en, this message translates to:
  /// **'Job Management'**
  String get jobManagement;

  /// No description provided for @postNewJob.
  ///
  /// In en, this message translates to:
  /// **'POST NEW JOB'**
  String get postNewJob;

  /// No description provided for @postANewJob.
  ///
  /// In en, this message translates to:
  /// **'Post a New Job'**
  String get postANewJob;

  /// No description provided for @noActiveJobPostings.
  ///
  /// In en, this message translates to:
  /// **'No active job postings'**
  String get noActiveJobPostings;

  /// No description provided for @refreshList.
  ///
  /// In en, this message translates to:
  /// **'Refresh List'**
  String get refreshList;

  /// No description provided for @applications.
  ///
  /// In en, this message translates to:
  /// **'Applications'**
  String get applications;

  /// No description provided for @closeListing.
  ///
  /// In en, this message translates to:
  /// **'Close Listing'**
  String get closeListing;

  /// No description provided for @openListing.
  ///
  /// In en, this message translates to:
  /// **'Open Listing'**
  String get openListing;

  /// No description provided for @jobCreatedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Job Created Successfully!'**
  String get jobCreatedSuccess;

  /// No description provided for @postJobOpportunity.
  ///
  /// In en, this message translates to:
  /// **'POST JOB OPPORTUNITY'**
  String get postJobOpportunity;

  /// No description provided for @basicInformation.
  ///
  /// In en, this message translates to:
  /// **'Basic Information'**
  String get basicInformation;

  /// No description provided for @jobSpecifications.
  ///
  /// In en, this message translates to:
  /// **'Job Specifications'**
  String get jobSpecifications;

  /// No description provided for @requirementsAndDetails.
  ///
  /// In en, this message translates to:
  /// **'Requirements & Details'**
  String get requirementsAndDetails;

  /// No description provided for @jobTitle.
  ///
  /// In en, this message translates to:
  /// **'Job Title*'**
  String get jobTitle;

  /// No description provided for @organization.
  ///
  /// In en, this message translates to:
  /// **'Organization*'**
  String get organization;

  /// No description provided for @jobCategory.
  ///
  /// In en, this message translates to:
  /// **'Job Category*'**
  String get jobCategory;

  /// No description provided for @duration.
  ///
  /// In en, this message translates to:
  /// **'Duration*'**
  String get duration;

  /// No description provided for @durationHint.
  ///
  /// In en, this message translates to:
  /// **'e.g., 6 months'**
  String get durationHint;

  /// No description provided for @stipend.
  ///
  /// In en, this message translates to:
  /// **'Stipend*'**
  String get stipend;

  /// No description provided for @stipendHint.
  ///
  /// In en, this message translates to:
  /// **'e.g., 8000'**
  String get stipendHint;

  /// No description provided for @requiredSkills.
  ///
  /// In en, this message translates to:
  /// **'Required Skills*'**
  String get requiredSkills;

  /// No description provided for @skillsHint.
  ///
  /// In en, this message translates to:
  /// **'HTML, CSS, Flutter (comma separated)'**
  String get skillsHint;

  /// No description provided for @jobDescription.
  ///
  /// In en, this message translates to:
  /// **'Description*'**
  String get jobDescription;

  /// No description provided for @navHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// No description provided for @navJobs.
  ///
  /// In en, this message translates to:
  /// **'Jobs'**
  String get navJobs;

  /// No description provided for @navSchemes.
  ///
  /// In en, this message translates to:
  /// **'Schemes'**
  String get navSchemes;

  /// No description provided for @navProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get navProfile;

  /// No description provided for @navChat.
  ///
  /// In en, this message translates to:
  /// **'Chat'**
  String get navChat;

  /// No description provided for @navDashboard.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get navDashboard;

  /// No description provided for @navAttendance.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get navAttendance;

  /// No description provided for @applicationSubmittedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Application Submitted Successfully!'**
  String get applicationSubmittedSuccess;

  /// No description provided for @addBank.
  ///
  /// In en, this message translates to:
  /// **'Add Bank'**
  String get addBank;

  /// No description provided for @areYouSureApplyScheme.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to apply for this scheme?'**
  String get areYouSureApplyScheme;

  /// No description provided for @unexpectedError.
  ///
  /// In en, this message translates to:
  /// **'Unexpected error'**
  String get unexpectedError;

  /// No description provided for @video.
  ///
  /// In en, this message translates to:
  /// **'Video'**
  String get video;

  /// No description provided for @updateStatus.
  ///
  /// In en, this message translates to:
  /// **'Update'**
  String get updateStatus;

  /// No description provided for @failedToLoadSchemes.
  ///
  /// In en, this message translates to:
  /// **'Failed to load schemes'**
  String get failedToLoadSchemes;

  /// No description provided for @createFirstScheme.
  ///
  /// In en, this message translates to:
  /// **'Create First Scheme'**
  String get createFirstScheme;

  /// No description provided for @addScheme.
  ///
  /// In en, this message translates to:
  /// **'Add Scheme'**
  String get addScheme;

  /// No description provided for @myApplicationsCount.
  ///
  /// In en, this message translates to:
  /// **'My Applications ({count})'**
  String myApplicationsCount(int count);

  /// No description provided for @applied.
  ///
  /// In en, this message translates to:
  /// **'APPLIED'**
  String get applied;

  /// No description provided for @appliedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'✅ Applied successfully!'**
  String get appliedSuccessfully;

  /// No description provided for @loginRequired.
  ///
  /// In en, this message translates to:
  /// **'Login Required'**
  String get loginRequired;

  /// No description provided for @loginRequiredDesc.
  ///
  /// In en, this message translates to:
  /// **'Please login as a Beneficiary to apply for schemes.'**
  String get loginRequiredDesc;

  /// No description provided for @withdrawApplicationQ.
  ///
  /// In en, this message translates to:
  /// **'Withdraw Application?'**
  String get withdrawApplicationQ;

  /// No description provided for @areYouSureWithdrawScheme.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to withdraw this scheme application?'**
  String get areYouSureWithdrawScheme;

  /// No description provided for @withdraw.
  ///
  /// In en, this message translates to:
  /// **'Withdraw'**
  String get withdraw;

  /// No description provided for @applicationWithdrawn.
  ///
  /// In en, this message translates to:
  /// **'✅ Application withdrawn'**
  String get applicationWithdrawn;

  /// No description provided for @beneficiaryRole.
  ///
  /// In en, this message translates to:
  /// **'Beneficiary'**
  String get beneficiaryRole;

  /// No description provided for @userRole.
  ///
  /// In en, this message translates to:
  /// **'User'**
  String get userRole;

  /// No description provided for @helpUsUnderstandIssue.
  ///
  /// In en, this message translates to:
  /// **'Help Us Understand Your Issue'**
  String get helpUsUnderstandIssue;

  /// No description provided for @topicSubject.
  ///
  /// In en, this message translates to:
  /// **'Topic / Subject'**
  String get topicSubject;

  /// No description provided for @topicHint.
  ///
  /// In en, this message translates to:
  /// **'E.g., Issue with document upload'**
  String get topicHint;

  /// No description provided for @pleaseEnterTopic.
  ///
  /// In en, this message translates to:
  /// **'Please enter a topic'**
  String get pleaseEnterTopic;

  /// No description provided for @requestSentSuccess.
  ///
  /// In en, this message translates to:
  /// **'Request Sent Successfully!'**
  String get requestSentSuccess;

  /// No description provided for @supportAgentRole.
  ///
  /// In en, this message translates to:
  /// **'Support Agent'**
  String get supportAgentRole;

  /// No description provided for @manageBroadcasts.
  ///
  /// In en, this message translates to:
  /// **'Manage Broadcasts'**
  String get manageBroadcasts;

  /// No description provided for @newBroadcastMessage.
  ///
  /// In en, this message translates to:
  /// **'New Broadcast Message'**
  String get newBroadcastMessage;

  /// No description provided for @enterMessageHere.
  ///
  /// In en, this message translates to:
  /// **'Enter your message here...'**
  String get enterMessageHere;

  /// No description provided for @broadcastSentSuccess.
  ///
  /// In en, this message translates to:
  /// **'Broadcast sent successfully!'**
  String get broadcastSentSuccess;

  /// No description provided for @noBroadcastsFound.
  ///
  /// In en, this message translates to:
  /// **'No broadcasts found'**
  String get noBroadcastsFound;

  /// No description provided for @sentBy.
  ///
  /// In en, this message translates to:
  /// **'Sent by: {name}'**
  String sentBy(String name);

  /// No description provided for @editBroadcast.
  ///
  /// In en, this message translates to:
  /// **'Edit Broadcast'**
  String get editBroadcast;

  /// No description provided for @deleteBroadcast.
  ///
  /// In en, this message translates to:
  /// **'Delete Broadcast'**
  String get deleteBroadcast;

  /// No description provided for @deleteBroadcastPrompt.
  ///
  /// In en, this message translates to:
  /// **'Delete Broadcast?'**
  String get deleteBroadcastPrompt;

  /// No description provided for @cannotBeUndone.
  ///
  /// In en, this message translates to:
  /// **'This action cannot be undone.'**
  String get cannotBeUndone;

  /// No description provided for @broadcastUpdated.
  ///
  /// In en, this message translates to:
  /// **'Broadcast updated!'**
  String get broadcastUpdated;

  /// No description provided for @broadcastDeleted.
  ///
  /// In en, this message translates to:
  /// **'Broadcast deleted!'**
  String get broadcastDeleted;

  /// No description provided for @sendBroadcast.
  ///
  /// In en, this message translates to:
  /// **'Send Broadcast'**
  String get sendBroadcast;

  /// No description provided for @enterMessageAllUsers.
  ///
  /// In en, this message translates to:
  /// **'Enter message for all users...'**
  String get enterMessageAllUsers;

  /// No description provided for @noBroadcastsYet.
  ///
  /// In en, this message translates to:
  /// **'No broadcasts yet'**
  String get noBroadcastsYet;

  /// No description provided for @noApplications.
  ///
  /// In en, this message translates to:
  /// **'No Applications'**
  String get noApplications;

  /// No description provided for @categoryLabel.
  ///
  /// In en, this message translates to:
  /// **'Category: {category}'**
  String categoryLabel(String category);

  /// No description provided for @approveBtn.
  ///
  /// In en, this message translates to:
  /// **'Approve'**
  String get approveBtn;

  /// No description provided for @rejectBtn.
  ///
  /// In en, this message translates to:
  /// **'Reject'**
  String get rejectBtn;

  /// No description provided for @governmentSchemes.
  ///
  /// In en, this message translates to:
  /// **'Government Schemes'**
  String get governmentSchemes;

  /// No description provided for @availableSchemes.
  ///
  /// In en, this message translates to:
  /// **'Available Schemes'**
  String get availableSchemes;

  /// No description provided for @myApplicationsTab.
  ///
  /// In en, this message translates to:
  /// **'My Applications'**
  String get myApplicationsTab;

  /// No description provided for @failedToLoadSchemesError.
  ///
  /// In en, this message translates to:
  /// **'Failed to load schemes:\n{error}'**
  String failedToLoadSchemesError(String error);

  /// No description provided for @noSchemesAvailableAtMoment.
  ///
  /// In en, this message translates to:
  /// **'No schemes available at the moment.'**
  String get noSchemesAvailableAtMoment;

  /// No description provided for @benefitsLabel.
  ///
  /// In en, this message translates to:
  /// **'Benefits:'**
  String get benefitsLabel;

  /// No description provided for @applyNowBtn.
  ///
  /// In en, this message translates to:
  /// **'Apply Now'**
  String get applyNowBtn;

  /// No description provided for @confirmApplicationBtn.
  ///
  /// In en, this message translates to:
  /// **'Confirm Application'**
  String get confirmApplicationBtn;

  /// No description provided for @schemeTermsPrompt.
  ///
  /// In en, this message translates to:
  /// **'Do you want to submit an application for \'{schemeName}\'?\n\nBy applying, you agree to the scheme\'s terms and conditions.'**
  String schemeTermsPrompt(String schemeName);

  /// No description provided for @schemeTermsPaidNote.
  ///
  /// In en, this message translates to:
  /// **'\n\nNote: You will need to pay ₹{price} after applying to complete the process.'**
  String schemeTermsPaidNote(String price);

  /// No description provided for @appliedPleasePay.
  ///
  /// In en, this message translates to:
  /// **'Applied! Please complete the payment.'**
  String get appliedPleasePay;

  /// No description provided for @failedToApply.
  ///
  /// In en, this message translates to:
  /// **'Failed to apply'**
  String get failedToApply;

  /// No description provided for @saveBtn.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get saveBtn;

  /// No description provided for @cancelBtn.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancelBtn;

  /// No description provided for @deleteBtn.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get deleteBtn;

  /// No description provided for @sendBtn.
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get sendBtn;

  /// No description provided for @byName.
  ///
  /// In en, this message translates to:
  /// **'By: {name}'**
  String byName(String name);

  /// No description provided for @jobApplication.
  ///
  /// In en, this message translates to:
  /// **'Job Application'**
  String get jobApplication;

  /// No description provided for @educationExperience.
  ///
  /// In en, this message translates to:
  /// **'Education & Experience'**
  String get educationExperience;

  /// No description provided for @mobileNumber.
  ///
  /// In en, this message translates to:
  /// **'Mobile Number'**
  String get mobileNumber;

  /// No description provided for @stateLbl.
  ///
  /// In en, this message translates to:
  /// **'State'**
  String get stateLbl;

  /// No description provided for @talukaOrTq.
  ///
  /// In en, this message translates to:
  /// **'Taluka/TQ'**
  String get talukaOrTq;

  /// No description provided for @highestQualification.
  ///
  /// In en, this message translates to:
  /// **'Highest Qualification'**
  String get highestQualification;

  /// No description provided for @experienceLevel.
  ///
  /// In en, this message translates to:
  /// **'Experience Level'**
  String get experienceLevel;

  /// No description provided for @jobType.
  ///
  /// In en, this message translates to:
  /// **'Job Type'**
  String get jobType;

  /// No description provided for @selectHint.
  ///
  /// In en, this message translates to:
  /// **'Select'**
  String get selectHint;

  /// No description provided for @availabilityWillingness.
  ///
  /// In en, this message translates to:
  /// **'Availability & Willingness*'**
  String get availabilityWillingness;

  /// No description provided for @willingFieldLocations.
  ///
  /// In en, this message translates to:
  /// **'Willing to work in field locations'**
  String get willingFieldLocations;

  /// No description provided for @comfortableWithCommunities.
  ///
  /// In en, this message translates to:
  /// **'Comfortable working with communities'**
  String get comfortableWithCommunities;

  /// No description provided for @willingTravelDistrict.
  ///
  /// In en, this message translates to:
  /// **'Willing to travel within district'**
  String get willingTravelDistrict;

  /// No description provided for @uploadResume.
  ///
  /// In en, this message translates to:
  /// **'Upload Resume'**
  String get uploadResume;

  /// No description provided for @uploadPhoto.
  ///
  /// In en, this message translates to:
  /// **'Upload Photo'**
  String get uploadPhoto;

  /// No description provided for @noFileChosen.
  ///
  /// In en, this message translates to:
  /// **'No file chosen'**
  String get noFileChosen;

  /// No description provided for @openCameraBtn.
  ///
  /// In en, this message translates to:
  /// **'Open Camera'**
  String get openCameraBtn;

  /// No description provided for @openCameraForLivePhoto.
  ///
  /// In en, this message translates to:
  /// **'Open Camera for Live Photo'**
  String get openCameraForLivePhoto;

  /// No description provided for @pdfOnlyMax5Mb.
  ///
  /// In en, this message translates to:
  /// **'PDF only • Max 5 MB'**
  String get pdfOnlyMax5Mb;

  /// No description provided for @livePhotoOnlyMax2Mb.
  ///
  /// In en, this message translates to:
  /// **'Live photo only • Max 2 MB'**
  String get livePhotoOnlyMax2Mb;

  /// No description provided for @continueBtn.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueBtn;

  /// No description provided for @submitApplication.
  ///
  /// In en, this message translates to:
  /// **'Submit Application'**
  String get submitApplication;

  /// No description provided for @loggedInAs.
  ///
  /// In en, this message translates to:
  /// **'Logged in as {name}'**
  String loggedInAs(String name);

  /// No description provided for @requiredField.
  ///
  /// In en, this message translates to:
  /// **'Required field'**
  String get requiredField;

  /// No description provided for @qual10thSSC.
  ///
  /// In en, this message translates to:
  /// **'10th / SSC'**
  String get qual10thSSC;

  /// No description provided for @qual12thHSC.
  ///
  /// In en, this message translates to:
  /// **'12th / HSC'**
  String get qual12thHSC;

  /// No description provided for @qualDiploma.
  ///
  /// In en, this message translates to:
  /// **'Diploma'**
  String get qualDiploma;

  /// No description provided for @qualGraduate.
  ///
  /// In en, this message translates to:
  /// **'Graduate (BA/BSc/BCom)'**
  String get qualGraduate;

  /// No description provided for @qualPostGraduate.
  ///
  /// In en, this message translates to:
  /// **'Post Graduate'**
  String get qualPostGraduate;

  /// No description provided for @qualOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get qualOther;

  /// No description provided for @expFresher.
  ///
  /// In en, this message translates to:
  /// **'Fresher (0 years)'**
  String get expFresher;

  /// No description provided for @exp1To2Years.
  ///
  /// In en, this message translates to:
  /// **'1 – 2 years'**
  String get exp1To2Years;

  /// No description provided for @exp3To5Years.
  ///
  /// In en, this message translates to:
  /// **'3 – 5 years'**
  String get exp3To5Years;

  /// No description provided for @exp5PlusYears.
  ///
  /// In en, this message translates to:
  /// **'5 + years'**
  String get exp5PlusYears;

  /// No description provided for @jobTypeFullTime.
  ///
  /// In en, this message translates to:
  /// **'Full Time'**
  String get jobTypeFullTime;

  /// No description provided for @jobTypePartTime.
  ///
  /// In en, this message translates to:
  /// **'Part Time'**
  String get jobTypePartTime;

  /// No description provided for @jobTypeContract.
  ///
  /// In en, this message translates to:
  /// **'Contract'**
  String get jobTypeContract;

  /// No description provided for @jobTypeVolunteer.
  ///
  /// In en, this message translates to:
  /// **'Volunteer'**
  String get jobTypeVolunteer;

  /// No description provided for @resumeTooLarge.
  ///
  /// In en, this message translates to:
  /// **'Resume too large ({size}). Max allowed is 5 MB.'**
  String resumeTooLarge(String size);

  /// No description provided for @photoTooLarge.
  ///
  /// In en, this message translates to:
  /// **'Photo too large ({size}). Max allowed is 2 MB.'**
  String photoTooLarge(String size);

  /// No description provided for @photoCaptured.
  ///
  /// In en, this message translates to:
  /// **'Photo captured'**
  String get photoCaptured;

  /// No description provided for @jobDescriptionLabel.
  ///
  /// In en, this message translates to:
  /// **'Job Description'**
  String get jobDescriptionLabel;

  /// No description provided for @requiredSkillsLabel.
  ///
  /// In en, this message translates to:
  /// **'Required Skills'**
  String get requiredSkillsLabel;

  /// No description provided for @unpaidLabel.
  ///
  /// In en, this message translates to:
  /// **'Unpaid'**
  String get unpaidLabel;

  /// No description provided for @generalCategory.
  ///
  /// In en, this message translates to:
  /// **'General'**
  String get generalCategory;

  /// No description provided for @jobClosedBtn.
  ///
  /// In en, this message translates to:
  /// **'Job Closed'**
  String get jobClosedBtn;

  /// No description provided for @viewApplicationsBtn.
  ///
  /// In en, this message translates to:
  /// **'View Applications'**
  String get viewApplicationsBtn;

  /// No description provided for @notEligibleToApply.
  ///
  /// In en, this message translates to:
  /// **'Not Eligible to Apply'**
  String get notEligibleToApply;

  /// No description provided for @loginRequiredJob.
  ///
  /// In en, this message translates to:
  /// **'Login Required'**
  String get loginRequiredJob;

  /// No description provided for @loginRequiredJobDesc.
  ///
  /// In en, this message translates to:
  /// **'Please login to apply for this job.'**
  String get loginRequiredJobDesc;

  /// No description provided for @loginAsBeneficiaryJob.
  ///
  /// In en, this message translates to:
  /// **'Login as Beneficiary'**
  String get loginAsBeneficiaryJob;

  /// No description provided for @naLabel.
  ///
  /// In en, this message translates to:
  /// **'N/A'**
  String get naLabel;

  /// No description provided for @schemesSoon.
  ///
  /// In en, this message translates to:
  /// **'Schemes coming soon'**
  String get schemesSoon;

  /// No description provided for @profileSoon.
  ///
  /// In en, this message translates to:
  /// **'Profile coming soon'**
  String get profileSoon;

  /// No description provided for @page.
  ///
  /// In en, this message translates to:
  /// **'Page'**
  String get page;

  /// No description provided for @ofText.
  ///
  /// In en, this message translates to:
  /// **'of'**
  String get ofText;

  /// No description provided for @totalSchemes.
  ///
  /// In en, this message translates to:
  /// **'Total Schemes'**
  String get totalSchemes;

  /// No description provided for @userManagement.
  ///
  /// In en, this message translates to:
  /// **'User Management'**
  String get userManagement;

  /// No description provided for @operationsFinance.
  ///
  /// In en, this message translates to:
  /// **'Operations & Finance'**
  String get operationsFinance;

  /// No description provided for @programsAttendance.
  ///
  /// In en, this message translates to:
  /// **'Programs & Attendance'**
  String get programsAttendance;

  /// No description provided for @communication.
  ///
  /// In en, this message translates to:
  /// **'Communication'**
  String get communication;

  /// No description provided for @viewEmployees.
  ///
  /// In en, this message translates to:
  /// **'View Employees'**
  String get viewEmployees;

  /// No description provided for @viewCoordinators.
  ///
  /// In en, this message translates to:
  /// **'View Coordinators'**
  String get viewCoordinators;

  /// No description provided for @viewBeneficiaries.
  ///
  /// In en, this message translates to:
  /// **'View Beneficiaries'**
  String get viewBeneficiaries;

  /// No description provided for @browseByTalukaAndChat.
  ///
  /// In en, this message translates to:
  /// **'Browse by taluka & chat'**
  String get browseByTalukaAndChat;

  /// No description provided for @paymentsLogistics.
  ///
  /// In en, this message translates to:
  /// **'Payments & Logistics'**
  String get paymentsLogistics;

  /// No description provided for @manualPayment.
  ///
  /// In en, this message translates to:
  /// **'Manual Payment'**
  String get manualPayment;

  /// No description provided for @manualPaymentSub.
  ///
  /// In en, this message translates to:
  /// **'Record cash payments for users'**
  String get manualPaymentSub;

  /// No description provided for @manualPaymentRecord.
  ///
  /// In en, this message translates to:
  /// **'Record'**
  String get manualPaymentRecord;

  /// No description provided for @employeeRequests.
  ///
  /// In en, this message translates to:
  /// **'Employee Requests'**
  String get employeeRequests;

  /// No description provided for @employeeRequestsSub.
  ///
  /// In en, this message translates to:
  /// **'Approve/reject payment requests'**
  String get employeeRequestsSub;

  /// No description provided for @employeeRequestsReview.
  ///
  /// In en, this message translates to:
  /// **'Review'**
  String get employeeRequestsReview;

  /// No description provided for @createParcel.
  ///
  /// In en, this message translates to:
  /// **'Create Parcel'**
  String get createParcel;

  /// No description provided for @createParcelSub.
  ///
  /// In en, this message translates to:
  /// **'Submit parcel for tracking'**
  String get createParcelSub;

  /// No description provided for @createParcelSubmit.
  ///
  /// In en, this message translates to:
  /// **'Submit'**
  String get createParcelSubmit;

  /// No description provided for @pendingPayments.
  ///
  /// In en, this message translates to:
  /// **'Pending Payments'**
  String get pendingPayments;

  /// No description provided for @pendingPaymentsSub.
  ///
  /// In en, this message translates to:
  /// **'Unpaid beneficiary accounts'**
  String get pendingPaymentsSub;

  /// No description provided for @analyticsAndMore.
  ///
  /// In en, this message translates to:
  /// **'Analytics & More'**
  String get analyticsAndMore;

  /// No description provided for @foundationDashboard.
  ///
  /// In en, this message translates to:
  /// **'Foundation Dashboard'**
  String get foundationDashboard;

  /// No description provided for @foundationDashboardSub.
  ///
  /// In en, this message translates to:
  /// **'Dynamic progress & analytics'**
  String get foundationDashboardSub;

  /// No description provided for @transactionsLabel.
  ///
  /// In en, this message translates to:
  /// **'Transactions'**
  String get transactionsLabel;

  /// No description provided for @transactionsSub.
  ///
  /// In en, this message translates to:
  /// **'Contributions, refunds & benefits'**
  String get transactionsSub;

  /// No description provided for @aboutFoundation.
  ///
  /// In en, this message translates to:
  /// **'About Foundation'**
  String get aboutFoundation;

  /// No description provided for @aboutFoundationSub.
  ///
  /// In en, this message translates to:
  /// **'Foundation info for all users'**
  String get aboutFoundationSub;

  /// No description provided for @noStaffFound.
  ///
  /// In en, this message translates to:
  /// **'No staff found'**
  String get noStaffFound;

  /// No description provided for @viewProfile.
  ///
  /// In en, this message translates to:
  /// **'View Profile'**
  String get viewProfile;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'mr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'mr':
      return AppLocalizationsMr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
