import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/mock_data.dart';
import '../../models/models.dart';
import '../../providers/app_data_provider.dart';
import '../../providers/auth_provider.dart';

class RoleAuthScreen extends StatefulWidget {
  final UserRole selectedRole;

  const RoleAuthScreen({
    super.key,
    required this.selectedRole,
  });

  @override
  State<RoleAuthScreen> createState() => _RoleAuthScreenState();
}

class _RoleAuthScreenState extends State<RoleAuthScreen> {
  bool _isSignUp = false;
  int _currentStep = 0; // 0 = Basic Account, 1 = Role Details

  // Sign In Controllers
  final _signInIdentifierCtrl = TextEditingController();
  final _signInPasswordCtrl = TextEditingController();
  bool _signInObscure = true;
  String? _signInError;

  // Step 1: Basic Controllers
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController(text: '123456');
  bool _signUpObscure = true;
  String? _signUpError;

  // Step 2: Labour Details
  String _labourTrade = 'Mason';
  String _labourExperience = '3-5 years';
  double _labourDailyWage = 3500;
  final List<String> _labourSkills = ['Bricklaying', 'Plastering'];
  final _emergencyPhoneCtrl = TextEditingController();

  // Step 2: Supplier Details
  final _supplierShopNameCtrl = TextEditingController();
  final _supplierShopAddressCtrl = TextEditingController();
  String _supplierYearsInBusiness = '5-10 years';
  final List<String> _supplierMaterials = [
    'Cement',
    'Sand',
    'Steel Rebars',
    'Hollow Blocks'
  ];

  // Step 2: Supervisor Details
  String _supervisorExperience = '3-5 years';
  String _supervisorQualification = 'HNDE / NDT Civil';
  String _supervisorSpecialization = 'Structural & Concrete';
  bool _isSafetyCertified = true;

  // Step 2: Admin Details
  final _adminCompanyNameCtrl = TextEditingController();
  final _adminOfficeAddressCtrl = TextEditingController();
  String _adminCidaGrade = 'C3';
  final _adminRegNoCtrl = TextEditingController();

  final List<String> _availableLabourRoles = [
    'Mason',
    'Carpenter',
    'Steel Fixer',
    'Electrician',
    'Plumber',
    'Painter',
    'Helper',
    'Welder',
    'Tiler',
    'Scaffolder',
  ];

  final List<String> _availableLabourSkills = [
    'Bricklaying',
    'Plastering',
    'Scaffolding',
    'Concrete Pouring',
    'Tiling',
    'Roofing',
    'Steel Binding',
    'Electrical Wiring',
    'Pipe Fitting',
    'Waterproofing',
    'Painting',
  ];

  final List<String> _availableMaterials = [
    'Cement',
    'Sand',
    'Metal / Gravel',
    'Steel Rebars',
    'Red Bricks',
    'Hollow Blocks',
    'Paint & Primer',
    'PVC Pipes',
    'Electrical Cables',
    'Roofing Sheets',
    'Plywood & Timber',
  ];

  @override
  void initState() {
    super.initState();
    _fillDemoSignIn(widget.selectedRole);
  }

  void _fillDemoSignIn(UserRole role) {
    final demo = DemoAccounts.accountFor(role);
    _signInIdentifierCtrl.text = demo.email;
    _signInPasswordCtrl.text = DemoAccounts.password;
  }

  @override
  void dispose() {
    _signInIdentifierCtrl.dispose();
    _signInPasswordCtrl.dispose();
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _emailCtrl.dispose();
    _addressCtrl.dispose();
    _passwordCtrl.dispose();
    _emergencyPhoneCtrl.dispose();
    _supplierShopNameCtrl.dispose();
    _supplierShopAddressCtrl.dispose();
    _adminCompanyNameCtrl.dispose();
    _adminOfficeAddressCtrl.dispose();
    _adminRegNoCtrl.dispose();
    super.dispose();
  }

  Color get _roleAccent {
    switch (widget.selectedRole) {
      case UserRole.labour:
        return const Color(0xFFEA580C);
      case UserRole.supervisor:
        return const Color(0xFF2563EB);
      case UserRole.supplier:
      case UserRole.foodSupplier:
        return const Color(0xFF0D9488);
      case UserRole.admin:
        return const Color(0xFF0F172A);
    }
  }

  IconData get _roleIcon {
    switch (widget.selectedRole) {
      case UserRole.labour:
        return Icons.handyman_rounded;
      case UserRole.supervisor:
        return Icons.assignment_ind_rounded;
      case UserRole.supplier:
      case UserRole.foodSupplier:
        return Icons.local_shipping_rounded;
      case UserRole.admin:
        return Icons.admin_panel_settings_rounded;
    }
  }

  void _handleSignIn() {
    setState(() => _signInError = null);
    final identifier = _signInIdentifierCtrl.text.trim();
    final password = _signInPasswordCtrl.text;

    if (identifier.isEmpty || password.isEmpty) {
      setState(() => _signInError = 'Please enter both phone/email and password.');
      return;
    }

    final auth = context.read<AuthProvider>();
    final error = auth.login(
      email: identifier,
      password: password,
      roleFilter: widget.selectedRole,
    );

    if (error == null) {
      Navigator.of(context).popUntil((route) => route.isFirst);
    } else {
      setState(() => _signInError = error);
    }
  }

  void _handleStep1Next() {
    setState(() => _signUpError = null);
    final name = _nameCtrl.text.trim();
    final phone = _phoneCtrl.text.trim();
    final email = _emailCtrl.text.trim();
    final address = _addressCtrl.text.trim();
    final password = _passwordCtrl.text;

    if (name.isEmpty) {
      setState(() => _signUpError = 'Please enter your full name.');
      return;
    }
    if (phone.isEmpty || phone.length < 9) {
      setState(() => _signUpError = 'Please enter a valid mobile phone number.');
      return;
    }
    if (widget.selectedRole != UserRole.labour && email.isEmpty) {
      setState(() => _signUpError = 'Please enter your email address.');
      return;
    }
    if (address.isEmpty) {
      setState(() => _signUpError = 'Please enter your residential/office address.');
      return;
    }
    if (password.length < 4) {
      setState(() => _signUpError = 'Password must be at least 4 characters.');
      return;
    }

    setState(() {
      _signUpError = null;
      _currentStep = 1;
    });
  }

  void _handleCreateAccount({required bool isSkipped}) {
    final auth = context.read<AuthProvider>();
    final data = context.read<AppDataProvider>();

    final name = _nameCtrl.text.trim();
    final phone = _phoneCtrl.text.trim();
    final email = _emailCtrl.text.trim().isNotEmpty
        ? _emailCtrl.text.trim()
        : '${phone.replaceAll(RegExp(r'\s+'), '')}@site.ahenam.lk';
    final address = _addressCtrl.text.trim();
    final password = _passwordCtrl.text;

    final userId = 'u-${DateTime.now().millisecondsSinceEpoch}';
    String? linkedId;
    String companyName = 'Ahenam Technologies';

    if (widget.selectedRole == UserRole.labour) {
      linkedId = 'lab-${DateTime.now().millisecondsSinceEpoch}';
      final labour = LabourProfile(
        id: linkedId,
        fullName: name,
        nic: 'NIC-${DateTime.now().millisecondsSinceEpoch % 100000}',
        phone: phone,
        address: address,
        jobRole: isSkipped ? 'Helper' : _labourTrade,
        skills: isSkipped ? ['General Site Work'] : _labourSkills,
        experience: isSkipped ? '1-2 years' : _labourExperience,
        joiningDate: DateTime.now(),
        emergencyContact: _emergencyPhoneCtrl.text.trim().isNotEmpty
            ? _emergencyPhoneCtrl.text.trim()
            : phone,
        status: LabourStatus.active,
        dailyWage: isSkipped ? 2500.0 : _labourDailyWage,
      );
      data.upsertLabour(labour);
    } else if (widget.selectedRole == UserRole.supplier) {
      linkedId = 'sup-${DateTime.now().millisecondsSinceEpoch}';
      companyName = _supplierShopNameCtrl.text.trim().isNotEmpty
          ? _supplierShopNameCtrl.text.trim()
          : '$name Building Materials';
      final supplier = SupplierProfile(
        id: linkedId,
        companyName: companyName,
        contactPerson: name,
        phone: phone,
        email: email,
        address: _supplierShopAddressCtrl.text.trim().isNotEmpty
            ? _supplierShopAddressCtrl.text.trim()
            : address,
        registrationDetails: 'Business Reg • Northern Province',
        materialsSupplied: isSkipped
            ? ['Cement', 'Sand', 'Metal']
            : _supplierMaterials,
        bankInfo: 'Commercial Bank - Verified Account',
        status: CompanyStatus.active,
      );
      data.upsertSupplier(supplier);
    } else if (widget.selectedRole == UserRole.admin) {
      if (_adminCompanyNameCtrl.text.trim().isNotEmpty) {
        companyName = _adminCompanyNameCtrl.text.trim();
      }
    }

    final newUser = AppUser(
      id: userId,
      name: name,
      email: email,
      phone: phone,
      role: widget.selectedRole,
      linkedId: linkedId,
      companyName: companyName,
      isProfileIncomplete: isSkipped,
      address: address,
      experience: widget.selectedRole == UserRole.labour
          ? _labourExperience
          : _supervisorExperience,
      specialization: _supervisorSpecialization,
      skills: _labourSkills,
      dailyWage: _labourDailyWage,
      materialsSupplied: _supplierMaterials,
    );

    auth.registerUser(user: newUser, password: password);
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    final roleName = widget.selectedRole.label;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Center(
          child: InkWell(
            onTap: () => Navigator.of(context).pop(),
            borderRadius: BorderRadius.circular(10),
            child: Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: const Icon(
                Icons.arrow_back_ios_new_rounded,
                size: 15,
                color: Color(0xFF0F172A),
              ),
            ),
          ),
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Icon(_roleIcon, size: 15, color: _roleAccent),
            ),
            const SizedBox(width: 8),
            Text(
              '$roleName Portal',
              style: const TextStyle(
                fontSize: 15.5,
                fontWeight: FontWeight.w700,
                color: Color(0xFF0F172A),
              ),
            ),
          ],
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              children: [
                // Top Segmented Toggle (Sign In | Create Account)
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: () => setState(() {
                            _isSignUp = false;
                            _currentStep = 0;
                          }),
                          borderRadius: BorderRadius.circular(11),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 150),
                            padding: const EdgeInsets.symmetric(vertical: 9),
                            decoration: BoxDecoration(
                              color: !_isSignUp ? Colors.white : Colors.transparent,
                              borderRadius: BorderRadius.circular(11),
                              boxShadow: !_isSignUp
                                  ? [
                                      BoxShadow(
                                        color: Colors.black.withValues(alpha: 0.04),
                                        blurRadius: 4,
                                        offset: const Offset(0, 1),
                                      ),
                                    ]
                                  : null,
                            ),
                            child: Text(
                              'Sign In',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: !_isSignUp
                                    ? FontWeight.w700
                                    : FontWeight.w600,
                                color: !_isSignUp
                                    ? const Color(0xFF0F172A)
                                    : const Color(0xFF64748B),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: InkWell(
                          onTap: () => setState(() => _isSignUp = true),
                          borderRadius: BorderRadius.circular(11),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 150),
                            padding: const EdgeInsets.symmetric(vertical: 9),
                            decoration: BoxDecoration(
                              color: _isSignUp ? Colors.white : Colors.transparent,
                              borderRadius: BorderRadius.circular(11),
                              boxShadow: _isSignUp
                                  ? [
                                      BoxShadow(
                                        color: Colors.black.withValues(alpha: 0.04),
                                        blurRadius: 4,
                                        offset: const Offset(0, 1),
                                      ),
                                    ]
                                  : null,
                            ),
                            child: Text(
                              'Create Account',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: _isSignUp
                                    ? FontWeight.w700
                                    : FontWeight.w600,
                                color: _isSignUp
                                    ? const Color(0xFF0F172A)
                                    : const Color(0xFF64748B),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 18),

                // Content View
                if (!_isSignUp) _buildSignInView() else _buildSignUpStepperView(),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ==========================================
  // SIGN IN VIEW
  // ==========================================
  Widget _buildSignInView() {
    final demoUser = DemoAccounts.accountFor(widget.selectedRole);

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Sign In as ${widget.selectedRole.label}',
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: Color(0xFF0F172A),
              letterSpacing: -0.2,
            ),
          ),
          const SizedBox(height: 3),
          const Text(
            'Enter your phone number or email to access your workspace',
            style: TextStyle(fontSize: 12.5, color: Color(0xFF64748B)),
          ),
          const SizedBox(height: 18),

          // Identifier
          TextField(
            controller: _signInIdentifierCtrl,
            decoration: _cleanInputDecoration(
              label: 'Phone Number or Email',
              hint: 'e.g. 077 123 4567 or email',
              icon: Icons.person_outline_rounded,
            ),
          ),
          const SizedBox(height: 14),

          // Password
          TextField(
            controller: _signInPasswordCtrl,
            obscureText: _signInObscure,
            decoration: _cleanInputDecoration(
              label: 'Password',
              icon: Icons.lock_outline_rounded,
              suffix: IconButton(
                icon: Icon(
                  _signInObscure
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  size: 20,
                  color: const Color(0xFF64748B),
                ),
                onPressed: () =>
                    setState(() => _signInObscure = !_signInObscure),
              ),
            ),
          ),

          if (_signInError != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFFEF2F2),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFFECACA)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.error_outline_rounded,
                      size: 16, color: Color(0xFFDC2626)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _signInError!,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFFDC2626),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 18),

          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0F172A),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 13),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              elevation: 0,
            ),
            onPressed: _handleSignIn,
            child: Text(
              'Sign In as ${widget.selectedRole.label}',
              style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700),
            ),
          ),

          const SizedBox(height: 18),
          const Divider(height: 1, color: Color(0xFFE2E8F0)),
          const SizedBox(height: 14),

          // Quick 1-Tap Demo Sign In
          InkWell(
            onTap: () {
              _fillDemoSignIn(widget.selectedRole);
              _handleSignIn();
            },
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 15,
                    backgroundImage: demoUser.avatarUrl != null
                        ? NetworkImage(demoUser.avatarUrl!)
                        : null,
                    backgroundColor: const Color(0xFFE2E8F0),
                    child: demoUser.avatarUrl == null
                        ? Text(
                            demoUser.name[0],
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF0F172A),
                            ),
                          )
                        : null,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: const [
                            Text(
                              'Instant 1-Tap Demo',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF0F172A),
                              ),
                            ),
                            SizedBox(width: 4),
                            Icon(Icons.bolt_rounded,
                                size: 13, color: Color(0xFFD97706)),
                          ],
                        ),
                        Text(
                          '${demoUser.name} (${demoUser.phone})',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF475569),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.chevron_right_rounded,
                    size: 18,
                    color: Color(0xFF64748B),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // SIGN UP STEPPER VIEW
  // ==========================================
  Widget _buildSignUpStepperView() {
    final step2Title = widget.selectedRole == UserRole.labour
        ? 'Trade & Skills'
        : widget.selectedRole == UserRole.supplier
            ? 'Shop & Goods'
            : widget.selectedRole == UserRole.supervisor
                ? 'Supervisory Profile'
                : 'Company Profile';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Sleek Minimalist Linear Progress Header
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _currentStep == 0
                        ? 'Step 1 of 2 • Basic Details'
                        : 'Step 2 of 2 • $step2Title',
                    style: const TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  Text(
                    _currentStep == 0 ? '50%' : '100%',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: Container(
                  height: 4,
                  color: const Color(0xFFF1F5F9),
                  child: Row(
                    children: [
                      Expanded(
                        flex: _currentStep == 0 ? 1 : 2,
                        child: Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFF0F172A),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                      if (_currentStep == 0)
                        const Expanded(flex: 1, child: SizedBox.shrink()),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        if (_currentStep == 0) _buildStep1Form() else _buildStep2Form(),
      ],
    );
  }

  // --- Step 1 Form (Basic Info) ---
  Widget _buildStep1Form() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Text(
                'Account Essentials',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF0F172A),
                  letterSpacing: -0.2,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  'Step 1 of 2',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF475569),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          TextField(
            controller: _nameCtrl,
            decoration: _cleanInputDecoration(
              label: 'Full Name *',
              hint: 'e.g. S. Thavarasa / Nimal Fernando',
              icon: Icons.badge_outlined,
            ),
          ),
          const SizedBox(height: 12),

          TextField(
            controller: _phoneCtrl,
            keyboardType: TextInputType.phone,
            decoration: _cleanInputDecoration(
              label: 'Mobile Phone Number *',
              hint: 'e.g. 077 123 4567',
              icon: Icons.phone_outlined,
            ),
          ),
          const SizedBox(height: 12),

          TextField(
            controller: _emailCtrl,
            keyboardType: TextInputType.emailAddress,
            decoration: _cleanInputDecoration(
              label: widget.selectedRole == UserRole.labour
                  ? 'Email (Optional)'
                  : 'Email Address *',
              hint: 'name@example.com',
              icon: Icons.email_outlined,
            ),
          ),
          const SizedBox(height: 12),

          TextField(
            controller: _addressCtrl,
            decoration: _cleanInputDecoration(
              label: 'Address / District *',
              hint: 'e.g. Jaffna, Chunnakam, Northern Province',
              icon: Icons.location_on_outlined,
            ),
          ),
          const SizedBox(height: 12),

          TextField(
            controller: _passwordCtrl,
            obscureText: _signUpObscure,
            decoration: _cleanInputDecoration(
              label: 'Password *',
              icon: Icons.lock_outline_rounded,
              suffix: IconButton(
                icon: Icon(
                  _signUpObscure
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  size: 20,
                  color: const Color(0xFF64748B),
                ),
                onPressed: () =>
                    setState(() => _signUpObscure = !_signUpObscure),
              ),
            ),
          ),

          if (_signUpError != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFFEF2F2),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFFECACA)),
              ),
              child: Text(
                _signUpError!,
                style: const TextStyle(
                  color: Color(0xFFDC2626),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],

          const SizedBox(height: 18),

          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0F172A),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 13),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              elevation: 0,
            ),
            onPressed: _handleStep1Next,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Text(
                  'Continue to Step 2',
                  style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700),
                ),
                SizedBox(width: 6),
                Icon(Icons.arrow_forward_rounded, size: 16),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- Step 2 Form (Role Specific Details with Skip Option) ---
  Widget _buildStep2Form() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Optional Step Banner (Minimalist & Clean)
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.info_outline_rounded,
                  color: Color(0xFF475569),
                  size: 18,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'Optional Step (Can be skipped)',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'You can skip this step and create your account right away. You can complete these details anytime from Profile Updates!',
                        style: TextStyle(
                          fontSize: 11.5,
                          color: Color(0xFF64748B),
                          height: 1.35,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Role-specific fields
          if (widget.selectedRole == UserRole.labour) ...[
            _buildLabourStep2Fields(),
          ] else if (widget.selectedRole == UserRole.supplier) ...[
            _buildSupplierStep2Fields(),
          ] else if (widget.selectedRole == UserRole.supervisor) ...[
            _buildSupervisorStep2Fields(),
          ] else ...[
            _buildAdminStep2Fields(),
          ],

          const SizedBox(height: 22),

          // TWO ACTION BUTTONS:
          // 1. Skip & Create Account
          // 2. Save & Create Profile
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF334155),
                    backgroundColor: Colors.white,
                    side: const BorderSide(color: Color(0xFFCBD5E1)),
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () => _handleCreateAccount(isSkipped: true),
                  child: const Text(
                    'Skip for Now',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0F172A),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  onPressed: () => _handleCreateAccount(isSkipped: false),
                  child: const Text(
                    'Save & Create Account',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          TextButton(
            onPressed: () => setState(() => _currentStep = 0),
            child: const Text(
              '← Back to Step 1',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Color(0xFF64748B),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- Step 2 Fields: Labour ---
  Widget _buildLabourStep2Fields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Trade Role / Primary Work',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: Color(0xFF0F172A),
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 7,
          runSpacing: 7,
          children: _availableLabourRoles.map((role) {
            final isSelected = _labourTrade == role;
            return ChoiceChip(
              label: Text(role),
              selected: isSelected,
              selectedColor: const Color(0xFF0F172A),
              backgroundColor: Colors.white,
              side: BorderSide(
                color: isSelected
                    ? const Color(0xFF0F172A)
                    : const Color(0xFFE2E8F0),
              ),
              labelStyle: TextStyle(
                fontSize: 11.5,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? Colors.white : const Color(0xFF334155),
              ),
              showCheckmark: false,
              onSelected: (val) {
                if (val) setState(() => _labourTrade = role);
              },
            );
          }).toList(),
        ),

        const SizedBox(height: 16),

        // Experience & Daily Wage Row
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Experience',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 6),
                  DropdownButtonFormField<String>(
                    initialValue: _labourExperience,
                    decoration: _cleanInputDecoration(
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 10),
                    ),
                    items: ['1-2 years', '3-5 years', '5-10 years', '10+ years']
                        .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                        .toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => _labourExperience = val);
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Daily Wage (LKR)',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 6),
                  TextFormField(
                    initialValue: _labourDailyWage.toStringAsFixed(0),
                    keyboardType: TextInputType.number,
                    decoration: _cleanInputDecoration(
                      prefixText: 'Rs. ',
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 10),
                    ),
                    onChanged: (val) {
                      final n = double.tryParse(val);
                      if (n != null) _labourDailyWage = n;
                    },
                  ),
                ],
              ),
            ),
          ],
        ),

        const SizedBox(height: 16),

        const Text(
          'Specific Skills Known',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: Color(0xFF0F172A),
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: _availableLabourSkills.map((skill) {
            final isSelected = _labourSkills.contains(skill);
            return FilterChip(
              label: Text(skill),
              selected: isSelected,
              selectedColor: const Color(0xFF0F172A),
              backgroundColor: Colors.white,
              side: BorderSide(
                color: isSelected
                    ? const Color(0xFF0F172A)
                    : const Color(0xFFE2E8F0),
              ),
              labelStyle: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? Colors.white : const Color(0xFF334155),
              ),
              showCheckmark: false,
              onSelected: (val) {
                setState(() {
                  if (val) {
                    _labourSkills.add(skill);
                  } else {
                    _labourSkills.remove(skill);
                  }
                });
              },
            );
          }).toList(),
        ),

        const SizedBox(height: 14),

        TextField(
          controller: _emergencyPhoneCtrl,
          keyboardType: TextInputType.phone,
          decoration: _cleanInputDecoration(
            label: 'Emergency Contact Person Phone',
            hint: 'e.g. 077 987 6543 (Family / Relative)',
            icon: Icons.contact_phone_outlined,
          ),
        ),
      ],
    );
  }

  // --- Step 2 Fields: Supplier ---
  Widget _buildSupplierStep2Fields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _supplierShopNameCtrl,
          decoration: _cleanInputDecoration(
            label: 'Company / Hardware Shop Name *',
            hint: 'e.g. Northern Build Hardware Ltd.',
            icon: Icons.storefront_outlined,
          ),
        ),
        const SizedBox(height: 12),

        TextField(
          controller: _supplierShopAddressCtrl,
          decoration: _cleanInputDecoration(
            label: 'Warehouse / Supply Yard Address',
            hint: 'e.g. KKS Road, Jaffna',
            icon: Icons.warehouse_outlined,
          ),
        ),
        const SizedBox(height: 12),

        DropdownButtonFormField<String>(
          initialValue: _supplierYearsInBusiness,
          decoration: _cleanInputDecoration(
            label: 'Years in Business',
            icon: Icons.history_rounded,
          ),
          items: ['1-2 years', '3-5 years', '5-10 years', '10+ years']
              .map((e) => DropdownMenuItem(value: e, child: Text(e)))
              .toList(),
          onChanged: (val) {
            if (val != null) setState(() => _supplierYearsInBusiness = val);
          },
        ),

        const SizedBox(height: 16),

        const Text(
          'Building Materials Supplied',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: Color(0xFF0F172A),
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: _availableMaterials.map((mat) {
            final isSelected = _supplierMaterials.contains(mat);
            return FilterChip(
              label: Text(mat),
              selected: isSelected,
              selectedColor: const Color(0xFF0F172A),
              backgroundColor: Colors.white,
              side: BorderSide(
                color: isSelected
                    ? const Color(0xFF0F172A)
                    : const Color(0xFFE2E8F0),
              ),
              labelStyle: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? Colors.white : const Color(0xFF334155),
              ),
              showCheckmark: false,
              onSelected: (val) {
                setState(() {
                  if (val) {
                    _supplierMaterials.add(mat);
                  } else {
                    _supplierMaterials.remove(mat);
                  }
                });
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  // --- Step 2 Fields: Supervisor ---
  Widget _buildSupervisorStep2Fields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DropdownButtonFormField<String>(
          initialValue: _supervisorExperience,
          decoration: _cleanInputDecoration(
            label: 'Supervisory Experience',
            icon: Icons.timer_outlined,
          ),
          items: ['1-2 years', '3-5 years', '6-10 years', '10+ years']
              .map((e) => DropdownMenuItem(value: e, child: Text(e)))
              .toList(),
          onChanged: (val) {
            if (val != null) setState(() => _supervisorExperience = val);
          },
        ),
        const SizedBox(height: 12),

        DropdownButtonFormField<String>(
          initialValue: _supervisorQualification,
          decoration: _cleanInputDecoration(
            label: 'Technical Qualification',
            icon: Icons.school_outlined,
          ),
          items: [
            'BSc Civil Engineering',
            'HNDE / NDT Civil',
            'NCT Civil Draftsmanship',
            'NVQ Level 4 / 5',
            'Site Experience (Practical)'
          ].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
          onChanged: (val) {
            if (val != null) setState(() => _supervisorQualification = val);
          },
        ),
        const SizedBox(height: 12),

        DropdownButtonFormField<String>(
          initialValue: _supervisorSpecialization,
          decoration: _cleanInputDecoration(
            label: 'Specialization Field',
            icon: Icons.category_outlined,
          ),
          items: [
            'Structural & Concrete',
            'Finishing & Interior',
            'Commercial Buildings',
            'Road & Earthworks',
            'General Civil Site'
          ].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
          onChanged: (val) {
            if (val != null) setState(() => _supervisorSpecialization = val);
          },
        ),
        const SizedBox(height: 14),

        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text(
            'Safety Officer Certified',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: Color(0xFF0F172A),
            ),
          ),
          subtitle: const Text(
            'Certified to enforce OSHA/site safety rules',
            style: TextStyle(fontSize: 11.5, color: Color(0xFF64748B)),
          ),
          value: _isSafetyCertified,
          activeThumbColor: const Color(0xFF0F172A),
          onChanged: (val) => setState(() => _isSafetyCertified = val),
        ),
      ],
    );
  }

  // --- Step 2 Fields: Admin ---
  Widget _buildAdminStep2Fields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _adminCompanyNameCtrl,
          decoration: _cleanInputDecoration(
            label: 'Construction Firm / Company Name *',
            hint: 'e.g. Jaffna Premier Builders (Pvt) Ltd',
            icon: Icons.business_outlined,
          ),
        ),
        const SizedBox(height: 12),

        TextField(
          controller: _adminOfficeAddressCtrl,
          decoration: _cleanInputDecoration(
            label: 'Head Office Address',
            hint: 'e.g. Main Street, Jaffna',
            icon: Icons.location_city_outlined,
          ),
        ),
        const SizedBox(height: 12),

        DropdownButtonFormField<String>(
          initialValue: _adminCidaGrade,
          decoration: _cleanInputDecoration(
            label: 'CIDA / ICTAD Grading',
            icon: Icons.verified_outlined,
          ),
          items: ['C1 (Major)', 'C2', 'C3', 'C4', 'C5', 'C6 - C9', 'Unregistered']
              .map((e) => DropdownMenuItem(value: e.split(' ').first, child: Text(e)))
              .toList(),
          onChanged: (val) {
            if (val != null) setState(() => _adminCidaGrade = val);
          },
        ),
        const SizedBox(height: 12),

        TextField(
          controller: _adminRegNoCtrl,
          decoration: _cleanInputDecoration(
            label: 'Business Registration No. (Optional)',
            hint: 'e.g. PV-123456',
            icon: Icons.description_outlined,
          ),
        ),
      ],
    );
  }

  InputDecoration _cleanInputDecoration({
    String? label,
    String? hint,
    IconData? icon,
    Widget? suffix,
    String? prefixText,
    EdgeInsetsGeometry? contentPadding,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixText: prefixText,
      prefixIcon: icon != null
          ? Icon(icon, size: 19, color: const Color(0xFF64748B))
          : null,
      suffixIcon: suffix,
      filled: true,
      fillColor: const Color(0xFFF8FAFC),
      contentPadding: contentPadding ??
          const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      labelStyle: const TextStyle(
        fontSize: 13,
        color: Color(0xFF64748B),
        fontWeight: FontWeight.w500,
      ),
      hintStyle: const TextStyle(
        fontSize: 12.5,
        color: Color(0xFF94A3B8),
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF0F172A), width: 1.4),
      ),
    );
  }
}
