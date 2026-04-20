import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:provider/provider.dart';
import '../../../../core/api/api_client.dart';
import '../../../../core/api/api_endpoints.dart';
import '../../../../core/constants/user_roles.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import 'about_us_management_screen.dart';

class AboutUsScreen extends StatefulWidget {
  const AboutUsScreen({super.key});

  @override
  State<AboutUsScreen> createState() => _AboutUsScreenState();
}

class _AboutUsScreenState extends State<AboutUsScreen> {
  late Future<_AboutPageData?> _aboutFuture;

  @override
  void initState() {
    super.initState();
    _aboutFuture = _fetchAboutContent();
  }

  Future<_AboutPageData?> _fetchAboutContent() async {
    try {
      final client = ApiClient();
      final response = await client.dio.get(
        ApiEndpoints.cmsPage('about'),
        options: Options(extra: {'skipAuth': true}),
      );
      final raw = response.data;
      if (raw is! Map<String, dynamic>) return null;
      final data = raw['data'];
      if (data is! Map<String, dynamic>) return null;
      final impactRaw = data['impact'];
      final contactRaw = data['contact'] is Map<String, dynamic>
          ? data['contact'] as Map<String, dynamic>
          : (data['contactUs'] is Map<String, dynamic>
              ? data['contactUs'] as Map<String, dynamic>
              : null);
      return _AboutPageData(
        title: data['title']?.toString(),
        content: data['content']?.toString(),
        impact: impactRaw is Map<String, dynamic>
            ? _ImpactStats(
                beneficiaries: _safeInt(impactRaw['beneficiaries']),
                payouts: _safeInt(impactRaw['payouts']),
                applications: _safeInt(impactRaw['applications']),
                missionsCompleted: _safeInt(impactRaw['missionsCompleted']),
              )
            : null,
        contactAddress: contactRaw?['address']?.toString(),
        contactEmail: contactRaw?['email']?.toString(),
        contactWebsite: contactRaw?['website']?.toString(),
        contactPhone: contactRaw?['phone']?.toString(),
      );
    } catch (_) {
      return null;
    }
  }

  int? _safeInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }

  String _formatCount(int? value) {
    if (value == null) return "-";
    return value.toString();
  }

  @override
  Widget build(BuildContext context) {
    final role = context.read<AuthProvider>().role;
    final canEdit = role == UserRole.superAdmin || role == UserRole.admin;
    return FutureBuilder<_AboutPageData?>(
      future: _aboutFuture,
      builder: (context, snapshot) {
        final data = snapshot.data;
        final isLoading = snapshot.connectionState == ConnectionState.waiting;
        final showNotice = !isLoading && data == null;
        final aboutTitle = data?.title?.trim();
        final aboutContent = data?.content?.trim();

        return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA),
      body: CustomScrollView(
        slivers: [
          // ── Collapsing header with Frame2 image ───────────────────────────
          SliverAppBar(
            expandedHeight: 220,
            pinned: true,
            backgroundColor: const Color(0xFF1E3A6B),
            foregroundColor: Colors.white,
            actions: [
              if (canEdit)
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.white),
                  onPressed: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const AboutUsManagementScreen(),
                      ),
                    );
                    if (!mounted) return;
                    setState(() {
                      _aboutFuture = _fetchAboutContent();
                    });
                  },
                ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              centerTitle: true,
              title: const Text(
                'आमच्याबद्दल  •  About Us',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(
                    'assets/Images/Frame2.png',
                    fit: BoxFit.cover,
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFF1E3A6B).withValues(alpha: 0.85),
                          const Color(0xFF1E3A6B).withValues(alpha: 0.3),
                        ],
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (isLoading)
                      const Padding(
                        padding: EdgeInsets.only(bottom: 12),
                        child: LinearProgressIndicator(minHeight: 3),
                      ),
                    if (showNotice) _buildNoticeCard(),
                  // ── Logo + Name + Cert Badge ───────────────────────────────
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.06),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                      child: Column(
                        children: [
                            Row(
                            children: [
                              Image.asset('assets/Images/logoSk.png', height: 64),
                            const SizedBox(width: 14),
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'शिल्पकार फाऊंडेशन',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: Color(0xFF1E3A6B),
                                    ),
                                  ),
                                  Text(
                                    'Shilpakar Foundation',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      fontSize: 13,
                                      color: Color(0xFF2E6DA4),
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    'लातूर  •  Latur, Maharashtra',
                                    style: TextStyle(
                                        color: Colors.grey, fontSize: 12),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),

                        // Orange cert badge
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                              vertical: 10, horizontal: 16),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE8730A),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.verified_rounded,
                                  color: Colors.white, size: 18),
                              SizedBox(width: 8),
                              Flexible(
                                child: Text(
                                  'नोंदणी क्रमांक / Reg. No: F-0028565 (LTR)',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                    letterSpacing: 0.3,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // ── About / आमच्याबद्दल ───────────────────────────────────
                  _buildLiveImpactCard(data?.impact),
                  const SizedBox(height: 16),
                  _buildBilingualSection(
                    icon: Icons.info_outline,
                    color: const Color(0xFF1E3A6B),
                    marathiTitle: 'आमच्याबद्दल',
                      englishTitle: (aboutTitle != null && aboutTitle.isNotEmpty)
                          ? aboutTitle
                          : 'About Us',
                    marathiContent: (aboutContent != null && aboutContent.isNotEmpty)
                        ? aboutContent
                        :
                        'शिल्पकार फाऊंडेशन लातूर , ता. जि.लातूर ही एक नोंदणीकृत सामाजिक संस्था असून , '
                        'नोंदणी क्रमांक लातूर F-0028565 (LTR) अन्वये नोंदणी प्रमाणपत्र मा.किटबद्ध असिस्टंट रजिस्ट्रार '
                        'ऑफ सोसायटी आयुक्त कार्यालय लातूर यांच्याकडून दि 2 मे 2025 ( सन 1860 चा अधिनियम 21 ) '
                        'अंतर्गत योग्यरित्या प्रमाणित करण्यात आली.\n\n'
                        'ही संस्था महाराष्ट्रातील ग्रामीण व शहरी भागातील सर्वसामान्य जनतेसाठी समर्पित आहे. '
                        'आम्ही समाजाच्या सर्व स्तरावरील लोकांसाठी शाश्वत विकास, सामाजिक न्याय, शिक्षण, आरोग्य, '
                        'रोजगार, कला, संस्कृती आणि युवकांच्या समृद्धीच्या दिशेने कार्यरत आहोत.',
                    englishContent: (aboutContent != null && aboutContent.isNotEmpty)
                        ? aboutContent
                        :
                        'Shilpakar Foundation Latur is a registered social organization. '
                        'The foundation was duly certified on 2nd May 2025 under the Act of 1860 (Section 21) '
                        'by the Assistant Registrar of Societies, Commissioner\'s Office, Latur, '
                        'with registration number F-0028565 (LTR).\n\n'
                        'This organization is dedicated to the common people of rural and urban areas of Maharashtra. '
                        'We work towards sustainable development, social justice, education, health, employment, '
                        'art, culture, and the prosperity of youth at all levels of society.',
                  ),

                  const SizedBox(height: 14),

                  // ── Objectives / उद्दिष्टे ────────────────────────────────
                  _buildBilingualSection(
                    icon: Icons.track_changes,
                    color: const Color(0xFF27AE60),
                    marathiTitle: 'उद्दिष्टे',
                    englishTitle: 'Objectives',
                    marathiContent:
                        'शिल्पकार फाऊंडेशनचा मुख्य उद्देश म्हणजे महाराष्ट्रात समतामूलक, आत्मनिर्भर आणि प्रगतशील '
                        'समाज घडवणे – जिथे शेतकरी, शेतमजूर, विद्यार्थी, आणि महिला विकासाच्या केंद्रस्थानी असतील.\n\n'
                        '• शेतकऱ्यांसाठी – नैसर्गिक शेती, योग्य बाजारपेठ, आधुनिक तंत्रज्ञान आणि नेतृत्त्व प्रशिक्षण.\n'
                        '• शेतमजुरांसाठी – सुरक्षित कामकाजाची जागा, किमान वेतनाची हमी आणि हक्कांबद्दल जागरूकता.\n'
                        '• विद्यार्थ्यांसाठी – मार्गदर्शन, डिजिटल शिक्षण, करिअर संधी आणि नेतृत्व विकास.\n'
                        '• महिलांसाठी – निर्णय घेण्याचा हक्क, उपजीविका निर्माण आणि नेतृत्व करण्याची संधी.',
                    englishContent:
                        'The main aim of Shilpakar Foundation is to build an equitable, self-reliant and progressive '
                        'society in Maharashtra – where farmers, laborers, students, and women are at the center of development.\n\n'
                        '• For Farmers – Natural farming, market access, modern technology and leadership training.\n'
                        '• For Laborers – Safe workplace, minimum wage guarantee, and awareness of their rights.\n'
                        '• For Students – Guidance, digital education, career opportunities and leadership development.\n'
                        '• For Women – Right to decision-making, livelihood creation and leadership opportunities.',
                  ),

                  const SizedBox(height: 14),

                  // ── Vision / ध्येय ────────────────────────────────────────
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF1E3A6B), Color(0xFF2E6DA4)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        // Bilingual title
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Text(
                                'ध्येय  •  Our Vision',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),

                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                                color: Colors.white.withValues(alpha: 0.2)),
                          ),
                          child: const Column(
                            children: [
                              Text(
                                'शहर असो वा गाव – प्रत्येक माणसात एक शिल्पकार आहे.\n'
                                'ज्याचं स्वप्न, त्याची गरज त्याची ताकद ओळखून आम्ही उभ आहोत\n'
                                'एक नवा समाज घडवण्यासाठी',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 13,
                                    height: 1.6,
                                    fontStyle: FontStyle.italic),
                                textAlign: TextAlign.center,
                              ),
                              SizedBox(height: 10),
                              Divider(color: Colors.white30),
                              SizedBox(height: 8),
                              Text(
                                'Whether a city or a village – there is a Shilpakar (craftsperson) in every person.\n'
                                'Recognizing their dreams, needs, and strength, we stand to build a new society.',
                                style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 12,
                                    height: 1.6,
                                    fontStyle: FontStyle.italic),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 14),

                        // Quote
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Column(
                            children: [
                              Text(
                                '"  शिल्पकार फाऊंडेशन हे केवळ मदतीचा नव्हे तर आत्मसन्मान आणि '
                                'स्वावलंबाचं केंद्र आहे. आम्ही काम करतो गावोगावी माणसामाणसांत विश्वास '
                                'रुजवण्यासाठी, विकास रुजवण्यासाठी आणि बदल घडवण्यासाठी  "',
                                style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 11,
                                    height: 1.6),
                                textAlign: TextAlign.center,
                              ),
                              SizedBox(height: 8),
                              Text(
                                '"  Shilpakar Foundation is not just a center of help, but of self-respect and '
                                'self-reliance. We work village by village, person by person — to instill trust, '
                                'nurture development, and create change.  "',
                                style: TextStyle(
                                    color: Colors.white54,
                                    fontSize: 11,
                                    height: 1.6),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 14),

                  // ── Impact Stats ──────────────────────────────────────────
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                          color: const Color(0xFFE8730A)
                              .withValues(alpha: 0.3)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.bar_chart_rounded,
                                color: Color(0xFFE8730A), size: 20),
                            SizedBox(width: 8),
                            Text(
                              'आमचे कार्य  •  Our Impact',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                                color: Color(0xFF1E3A6B),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        Row(
                          children: [
                            _buildStatItem('५०००+\n5000+', 'लाभार्थी\nBeneficiaries'),
                            _buildStatItem('२००+\n200+', 'कर्मचारी\nMembers'),
                            _buildStatItem('५०+\n50+', 'कार्यक्रम\nPrograms'),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 14),

                  // ── Key Programs / प्रमुख कार्यक्रम ──────────────────────
                  _buildBilingualSection(
                    icon: Icons.star_outline,
                    color: const Color(0xFFE8730A),
                    marathiTitle: 'प्रमुख कार्यक्रम',
                    englishTitle: 'Key Programs',
                    marathiContent:
                        '• समाज विकास – महिला सक्षमीकरण, बालकल्याण, वृद्ध कल्याण, दिव्यांग कल्याण, आर्थिक सक्षमीकरण, सामाजिक समरसता अभियान\n'
                        '• शिक्षण – मुलांसाठी मूलभूत शिक्षण, प्रौढ साक्षरता अभियान, डिजिटल साक्षरता, स्पर्धा परीक्षा मार्गदर्शन, पुस्तक वितरण / वाचनालय उपक्रम\n'
                        '• आरोग्य – आरोग्य तपासणी शिबिरे, महिलांसाठी आरोग्य जनजागृती, बालकांचे पोषण कार्यक्रम, रक्तदान शिबिर, योग/ध्यान कार्यक्रम\n'
                        '• पर्यावरण संवर्धन – वृक्ष लागवड मोहीम, प्लास्टिक मुक्त अभियान, जलसंचारण प्रकल्प, हरित ग्राम योजना',
                    englishContent:
                        '• Social Development – Women empowerment, child welfare, elderly care, disability welfare, economic empowerment, social harmony campaign\n'
                        '• Education – Basic education for children, adult literacy, digital literacy, competitive exam guidance, book distribution / library initiatives\n'
                        '• Health – Health check-up camps, women\'s health awareness, child nutrition programs, blood donation camps, yoga / meditation programs\n'
                        '• Environment Conservation – Tree plantation drive, plastic-free campaign, water conservation projects, Green Village Scheme',
                  ),

                  const SizedBox(height: 14),

                  // ── Contact / संपर्क करा ──────────────────────────────────
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.contact_phone_outlined,
                                color: Color(0xFF1E3A6B)),
                            SizedBox(width: 8),
                            Text(
                              'संपर्क करा  •  Contact Us',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                                color: Color(0xFF1E3A6B),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        if ((data?.contactAddress ?? '').trim().isNotEmpty)
                          _buildContactRow(
                            Icons.location_on_outlined,
                            data!.contactAddress!.trim(),
                          )
                        else
                          _buildContactRow(
                            Icons.location_on_outlined,
                            'लातूर, महाराष्ट्र, भारत - 413512\nLatur, Maharashtra, India - 413512',
                          ),
                        const SizedBox(height: 8),
                        _buildContactRow(
                          Icons.email_outlined,
                          data?.contactEmail ?? 'info@shilpkarfoundation.org',
                        ),
                        const SizedBox(height: 8),
                        _buildContactRow(
                          Icons.web_outlined,
                          data?.contactWebsite ?? 'www.shilpkarfoundation.org',
                        ),
                        if (data?.contactPhone != null) ...[
                          const SizedBox(height: 8),
                          _buildContactRow(
                            Icons.phone_outlined,
                            data!.contactPhone!,
                          ),
                        ],
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // ── Footer ────────────────────────────────────────────────
                  Center(
                    child: Text(
                      '© 2025 शिल्पकार फाऊंडेशन लातूर, महाराष्ट्र\n'
                      '© 2025 Shilpakar Foundation Latur, Maharashtra\n'
                      'सर्व हक्क राखीव  •  All Rights Reserved.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade500,
                        height: 1.7,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
          ],
        ),
      );
        },
      );
    }

  // ── Bilingual section card ───────────────────────────────────────────────────
  Widget _buildNoticeCard() {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF4E5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE8730A).withValues(alpha: 0.4)),
      ),
      child: const Row(
        children: [
          Icon(Icons.info_outline, color: Color(0xFFE8730A), size: 18),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              'Live impact data is temporarily unavailable.',
              style: TextStyle(fontSize: 12, color: Color(0xFF6B4E1E)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLiveImpactCard(_ImpactStats? impact) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF1E3A6B).withValues(alpha: 0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.insights, color: Color(0xFF1E3A6B), size: 18),
              SizedBox(width: 8),
              Text(
                'Live Impact',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: Color(0xFF1E3A6B),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (impact == null)
            const Text(
              'No live impact data yet.',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            )
          else
            Column(
              children: [
                Row(
                  children: [
                    _buildStatItem(
                      _formatCount(impact.beneficiaries),
                      'Beneficiaries',
                    ),
                    _buildStatItem(
                      _formatCount(impact.payouts),
                      'Payouts',
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _buildStatItem(
                      _formatCount(impact.applications),
                      'Applications',
                    ),
                    _buildStatItem(
                      _formatCount(impact.missionsCompleted),
                      'Missions Completed',
                    ),
                  ],
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildBilingualSection({
    required IconData icon,
    required Color color,
    required String marathiTitle,
    required String englishTitle,
    required String marathiContent,
    required String englishContent,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Bilingual title row
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 18),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      marathiTitle,
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: color),
                    ),
                    Text(
                      englishTitle,
                      style: TextStyle(
                          fontSize: 12,
                          color: color.withValues(alpha: 0.7)),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
              height: 2,
              width: 40,
              decoration: BoxDecoration(
                  color: color, borderRadius: BorderRadius.circular(1))),
          const SizedBox(height: 12),

          // Marathi content with left accent bar
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 3,
                margin: const EdgeInsets.only(right: 10, top: 2),
                color: color.withValues(alpha: 0.4),
                child: Text(marathiContent,
                    style: const TextStyle(fontSize: 0)),
              ),
              Expanded(
                child: Text(
                  marathiContent,
                  style: const TextStyle(
                      fontSize: 13, color: Colors.black87, height: 1.7),
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),
          Divider(color: Colors.grey.shade200, height: 1),
          const SizedBox(height: 10),

          // English content with left accent bar (lighter)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 3,
                margin: const EdgeInsets.only(right: 10, top: 2),
                color: color.withValues(alpha: 0.2),
                child: Text(englishContent,
                    style: const TextStyle(fontSize: 0)),
              ),
              Expanded(
                child: Text(
                  englishContent,
                  style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade700,
                      height: 1.7),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String value, String label) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              color: Color(0xFF1E3A6B),
              fontWeight: FontWeight.bold,
              fontSize: 16,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
                color: Colors.grey.shade600, fontSize: 11, height: 1.4),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildContactRow(IconData icon, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: Colors.grey.shade600),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style:
                const TextStyle(fontSize: 13, color: Colors.black87, height: 1.5),
          ),
        ),
      ],
    );
  }
}

class _AboutPageData {
  final String? title;
  final String? content;
  final _ImpactStats? impact;
  final String? contactAddress;
  final String? contactEmail;
  final String? contactWebsite;
  final String? contactPhone;

  const _AboutPageData({
    this.title,
    this.content,
    this.impact,
    this.contactAddress,
    this.contactEmail,
    this.contactWebsite,
    this.contactPhone,
  });
}

class _ImpactStats {
  final int? beneficiaries;
  final int? payouts;
  final int? applications;
  final int? missionsCompleted;

  const _ImpactStats({
    this.beneficiaries,
    this.payouts,
    this.applications,
    this.missionsCompleted,
  });
}
