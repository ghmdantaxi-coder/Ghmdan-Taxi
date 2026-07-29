import 'package:flutter/material.dart';

void main() {
  runApp(const GhmdanTaxiApp());
}

class GhmdanTaxiApp extends StatefulWidget {
  const GhmdanTaxiApp({super.key});

  @override
  State<GhmdanTaxiApp> createState() => _GhmdanTaxiAppState();
}

class _GhmdanTaxiAppState extends State<GhmdanTaxiApp> {
  bool isDarkMode = false;

  void toggleTheme(bool value) {
    setState(() {
      isDarkMode = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'غمدان تاكسي - سرعة وأمان',
      debugShowCheckedModeBanner: false,
      themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
      theme: ThemeData(
        primarySwatch: Colors.amber,
        brightness: Brightness.light,
        scaffoldBackgroundColor: const Color(0xFFFAFAFA),
        fontFamily: 'Roboto',
      ),
      darkTheme: ThemeData(
        primarySwatch: Colors.amber,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF121212),
      ),
      home: DriverMainShell(
        isDarkMode: isDarkMode,
        onThemeChanged: toggleTheme,
      ),
    );
  }
}

class DriverMainShell extends StatefulWidget {
  final bool isDarkMode;
  final ValueChanged<bool> onThemeChanged;

  const DriverMainShell({
    super.key,
    required this.isDarkMode,
    required this.onThemeChanged,
  });

  @override
  State<DriverMainShell> createState() => _DriverMainShellState();
}

class _DriverMainShellState extends State<DriverMainShell> {
  int _currentIndex = 0;
  bool isOnline = true;
  bool isNetworkConnected = true; 
  int pendingOfflineTrips = 2; 
  bool destinationFilterActive = false;
  
  String selectedCurrency = 'الريال اليمني (YER)';

  final Map<String, double> balances = {
    'الريال اليمني (YER)': 45000.0,
    'الريال السعودي (SAR)': 350.0,
    'الدولار الأمريكي (USD)': 90.0,
  };

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('غمدان تاكسي | سرعة وأمان', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
          backgroundColor: Colors.amber,
          iconTheme: const IconThemeData(color: Colors.black),
          actions: [
            IconButton(
              icon: Icon(destinationFilterActive ? Icons.alt_route : Icons.alt_route_outlined),
              color: destinationFilterActive ? Colors.deepOrange : Colors.black,
              tooltip: 'طريق العودة',
              onPressed: _showDestinationFilterDialog,
            ),
            IconButton(
              icon: const Icon(Icons.notifications_none, color: Colors.black),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('لا توجد إشعارات جديدة حالياً')),
                );
              },
            ),
          ],
        ),

        drawer: Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              const UserAccountsDrawerHeader(
                decoration: BoxDecoration(color: Colors.amber),
                accountName: Text('أبو غمدان (الكابتن)', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black)),
                accountEmail: Text('رقم السائق: #10204 | باص نيسان', style: TextStyle(color: Colors.black87)),
                currentAccountPicture: CircleAvatar(
                  backgroundColor: Colors.black,
                  child: Icon(Icons.person, size: 40, color: Colors.amber),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.signal_cellular_connected_no_internet_4_bar, color: Colors.orange),
                title: const Text('حالة الاتصال والعمل بدون إنترنت'),
                subtitle: Text('رحلات معلقة للمزامنة: $pendingOfflineTrips'),
                onTap: () {
                  Navigator.pop(context);
                  _showOfflineStatusDialog();
                },
              ),
              ListTile(
                leading: const Icon(Icons.verified_user, color: Colors.amber),
                title: const Text('توثيق الحساب والوثائق (KYC)'),
                subtitle: const Text('الحالة: مفعّل ومتأكد'),
                onTap: () {
                  Navigator.pop(context);
                  _showKYCModal();
                },
              ),
              ListTile(
                leading: const Icon(Icons.speed, color: Colors.amber),
                title: const Text('عداد الشارع المباشر (Street Meter)'),
                onTap: () {
                  Navigator.pop(context);
                  _showStreetMeterDialog();
                },
              ),
              ListTile(
                leading: const Icon(Icons.account_balance_wallet, color: Colors.amber),
                title: const Text('المحفظة متعددة العملات'),
                onTap: () {
                  Navigator.pop(context);
                  setState(() => _currentIndex = 1);
                },
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.headset_mic, color: Colors.amber),
                title: const Text('الدعم الفني والخدمة'),
                onTap: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('خط الطوارئ والدعم الفني لشركة غمدان: 770000000')),
                  );
                },
              ),
              SwitchListTile(
                secondary: const Icon(Icons.dark_mode, color: Colors.amber),
                title: const Text('الوضع الداكن'),
                value: widget.isDarkMode,
                onChanged: widget.onThemeChanged,
              ),
            ],
          ),
        ),

        body: Column(
          children: [
            if (!isNetworkConnected)
              Container(
                color: Colors.orange.shade800,
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: const [
                        Icon(Icons.wifi_off, color: Colors.white, size: 18),
                        SizedBox(width: 8),
                        Text(
                          'وضع الأوفلاين مفعّل (الإنترنت منقطع)',
                          style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    InkWell(
                      onTap: () {
                        setState(() {
                          isNetworkConnected = true;
                          pendingOfflineTrips = 0;
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(backgroundColor: Colors.green, content: Text('تمت إعادة الاتصال ومزامنة البيانات مع السيرفر بنجاح!')),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4)),
                        child: const Text('مزامنة الآن', style: TextStyle(color: Colors.orange, fontSize: 11, fontWeight: FontWeight.bold)),
                      ),
                    )
                  ],
                ),
              ),

            Expanded(child: _buildSelectedTab()),
          ],
        ),

        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _currentIndex,
          selectedItemColor: Colors.amber.shade800,
          unselectedItemColor: Colors.grey,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.navigation), label: 'الرئيسية'),
            BottomNavigationBarItem(icon: Icon(Icons.account_balance_wallet), label: 'المحفظة'),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: 'الحساب'),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectedTab() {
    if (_currentIndex == 1) return _buildWalletScreen();
    if (_currentIndex == 2) return _buildProfileScreen();
    return _buildHomeScreen();
  }

  Widget _buildHomeScreen() {
    return Column(
      children: [
        Container(
          margin: const EdgeInsets.all(12),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: isOnline ? Colors.amber.shade50 : Colors.red.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: isOnline ? Colors.amber.shade700 : Colors.red),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                isOnline ? 'الحالة: متصل وجاهز للطلبات' : 'الحالة: غير متصل',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isOnline ? Colors.amber.shade900 : Colors.red.shade900,
                ),
              ),
              Switch(
                value: isOnline,
                activeColor: Colors.amber.shade800,
                onChanged: (val) {
                  setState(() => isOnline = val);
                },
              ),
            ],
          ),
        ),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0),
          child: Row(
            children: [
              Expanded(child: _buildQuickStatCard('أرباح اليوم', '18,500 $selectedCurrency', Icons.monetization_on)),
              const SizedBox(width: 8),
              Expanded(child: _buildQuickStatCard('الرحلات', '6 رحلات', Icons.directions_car)),
              const SizedBox(width: 8),
              Expanded(child: _buildQuickStatCard('التقييم', '4.9 ★', Icons.star)),
            ],
          ),
        ),

        const SizedBox(height: 12),

        Expanded(
          child: Stack(
            children: [
              Center(
                child: isOnline
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.local_taxi, size: 80, color: Colors.amber.shade700),
                          const SizedBox(height: 12),
                          const Text('انت في كل مكان - سرعة وأمان', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey)),
                          const SizedBox(height: 8),
                          const Text('...جاري البحث عن ركاب في منطقتك', style: TextStyle(fontSize: 13, color: Colors.grey)),
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.amber, foregroundColor: Colors.black, padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10)),
                            onPressed: _showTripRequestModal,
                            icon: const Icon(Icons.add_location_alt, color: Colors.black),
                            label: const Text('محاكاة استقبال طلب جديد', style: TextStyle(fontWeight: FontWeight.bold)),
                          ),
                          const SizedBox(height: 10),
                          OutlinedButton.icon(
                            onPressed: () {
                              setState(() => isNetworkConnected = !isNetworkConnected);
                            },
                            icon: const Icon(Icons.wifi_tethering_off),
                            label: Text(isNetworkConnected ? 'محاكاة انقطاع الإنترنت' : 'محاكاة عودة الإنترنت'),
                          )
                        ],
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(Icons.power_settings_new, size: 80, color: Colors.grey),
                          SizedBox(height: 12),
                          Text('أنت غير متصل حالياً', style: TextStyle(fontSize: 16, color: Colors.grey)),
                        ],
                      ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildWalletScreen() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('المحفظة متعددة العملات', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.amber, foregroundColor: Colors.black),
              onPressed: _showAddCurrencyDialog,
              icon: const Icon(Icons.add, color: Colors.black, size: 18),
              label: const Text('إضافة عملة', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
        const SizedBox(height: 12),

        ...balances.entries.map((entry) => _buildCurrencyBalanceCard(
              entry.key,
              '${entry.value.toStringAsFixed(2)}',
              _getColorForCurrency(entry.key),
            )),

        const SizedBox(height: 16),

        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.amber, foregroundColor: Colors.black, padding: const EdgeInsets.all(12)),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم تقديم طلب سحب الأرباح بنجاح')));
                },
                icon: const Icon(Icons.call_made, color: Colors.black),
                label: const Text('سحب أرباح', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(padding: const EdgeInsets.all(12)),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('شحن المحفظة عبر شبكات الصرافة المحلية')));
                },
                icon: const Icon(Icons.add_card),
                label: const Text('شحن المحفظة'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildProfileScreen() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Center(
          child: CircleAvatar(
            radius: 40,
            backgroundColor: Colors.amber,
            child: Icon(Icons.person, size: 50, color: Colors.black),
          ),
        ),
        const SizedBox(height: 8),
        const Center(child: Text('أبو غمدان', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
        const Center(child: Text('سائق معتمد - صنعاء / إب | باص نيسان', style: TextStyle(color: Colors.grey, fontSize: 12))),
        const Divider(height: 25),

        ListTile(
          leading: const Icon(Icons.attach_money),
          title: const Text('العملة الافتراضية للعرض'),
          trailing: DropdownButton<String>(
            value: selectedCurrency,
            onChanged: (val) {
              if (val != null) {
                setState(() => selectedCurrency = val);
              }
            },
            items: balances.keys.map((String currencyKey) {
              return DropdownMenuItem<String>(
                value: currencyKey,
                child: Text(currencyKey, style: const TextStyle(fontSize: 13)),
              );
            }).toList(),
          ),
        ),
        const ListTile(
          leading: Icon(Icons.directions_car),
          title: Text('بيانات السيارة'),
          subtitle: Text('نيسان موديل 2006 | لوحة: 12345/أ'),
        ),
        ListTile(
          leading: const Icon(Icons.security),
          title: const Text('توثيق الهوية (KYC)'),
          subtitle: const Text('رخصة القيادة والاستمارة: موثقة بنجاح'),
          trailing: const Icon(Icons.check_circle, color: Colors.green),
          onTap: _showKYCModal, // تم التصحيح هنا من onPressed إلى onTap
        ),
      ],
    );
  }

  Widget _buildQuickStatCard(String title, String value, IconData icon) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        child: Column(
          children: [
            Icon(icon, color: Colors.amber.shade800, size: 22),
            const SizedBox(height: 4),
            Text(title, style: const TextStyle(fontSize: 11, color: Colors.grey)),
            Text(value, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrencyBalanceCard(String title, String amount, Color color) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(backgroundColor: color.withOpacity(0.2), child: Icon(Icons.account_balance, color: color)),
        title: Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
        trailing: Text(amount, style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: color)),
      ),
    );
  }

  Color _getColorForCurrency(String name) {
    if (name.contains('اليمني')) return Colors.amber.shade800;
    if (name.contains('السعودي')) return Colors.blue;
    if (name.contains('الدولار')) return Colors.green;
    return Colors.teal; 
  }

  void _showAddCurrencyDialog() {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController balanceController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          title: const Text('إضافة عملة جديدة'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'اسم العملة (مثال: اليورو (EUR))', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: balanceController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'الرصيد الابتدائي', border: OutlineInputBorder()),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('إلغاء')),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.amber, foregroundColor: Colors.black),
              onPressed: () {
                if (nameController.text.isNotEmpty) {
                  setState(() {
                    balances[nameController.text] = double.tryParse(balanceController.text) ?? 0.0;
                    selectedCurrency = nameController.text;
                  });
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('تمت إضافة عملة "${nameController.text}" بنجاح')),
                  );
                }
              },
              child: const Text('إضافة وتفعيل', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  void _showTripRequestModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: Container(
          padding: const EdgeInsets.all(20),
          height: 380,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text('طلب رحلة جديدة من زبون!', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  Chip(label: Text('25 ثانية'), backgroundColor: Colors.amber),
                ],
              ),
              const Divider(),
              const ListTile(
                leading: Icon(Icons.my_location, color: Colors.blue),
                title: Text('نقطة الانطلاق: شارع الستين - صنعاء'),
                subtitle: Text('المسافة: 1.2 كم'),
              ),
              const ListTile(
                leading: Icon(Icons.location_on, color: Colors.red),
                title: Text('الوجهة: حدة - جولة الرويشان'),
              ),
              ListTile(
                leading: Icon(Icons.payments, color: Colors.amber.shade800),
                title: Text('الأجرة المتوقعة: 3,500 $selectedCurrency'),
              ),
              const Spacer(),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.amber, foregroundColor: Colors.black, padding: const EdgeInsets.all(12)),
                      onPressed: () {
                        Navigator.pop(ctx);
                        _showActiveRideDialog();
                      },
                      child: const Text('قبول الطلب', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(padding: const EdgeInsets.all(12)),
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text('رفض'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showActiveRideDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          title: const Text('الرحلة جارية حالياً...'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (!isNetworkConnected)
                Container(
                  padding: const EdgeInsets.all(8),
                  margin: const EdgeInsets.only(bottom: 10),
                  color: Colors.orange.shade100,
                  child: const Text('⚠️ وضع الأوفلاين: تسجل الرحلة محلياً وسترفع فور اتصال الإنترنت.', style: TextStyle(fontSize: 11, color: Colors.orange)),
                ),
              const Text('أدخل رمز أمان الراكب (OTP):'),
              const SizedBox(height: 10),
              const TextField(
                keyboardType: TextInputType.number,
                decoration: InputDecoration(border: OutlineInputBorder(), hintText: 'رمز التحقق (4 أرقام)'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(ctx);
                if (!isNetworkConnected) setState(() => pendingOfflineTrips++);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(isNetworkConnected ? 'تم إنهاء الرحلة بنجاح وإضافة الأرباح' : 'تم حفظ الرحلة محلياً لعدم وجود إنترنت')),
                );
              },
              child: Text('إنهاء الرحلة وتحصيل المبلغ', style: TextStyle(color: Colors.amber.shade900, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  void _showOfflineStatusDialog() {
    showDialog(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          title: const Text('وضع العمل بدون إنترنت'),
          content: Text('لديك حالياً ($pendingOfflineTrips) رحلات وحركات مالية مسجلة محلياً على الجوال.\n\nسيقوم التطبيق برفعها ومزامنتها تلقائياً مع السيرفر فور توافر شبكة الإنترنت.'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('حسناً')),
          ],
        ),
      ),
    );
  }

  void _showStreetMeterDialog() {
    showDialog(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          title: const Text('عداد الشارع الذكي للركاب'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('تتبع GPS مباشر لركاب الشارع العام'),
              const SizedBox(height: 10),
              const Text('المسافة المقطوعة: 4.5 كم | الوقت: 12 دقيقة'),
              const SizedBox(height: 10),
              Text('المبلغ المستحق: 2,500 $selectedCurrency', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.amber.shade900)),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('إغلاق العداد')),
          ],
        ),
      ),
    );
  }

  void _showKYCModal() {
    showDialog(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          title: const Text('توثيق الحساب والوثائق (KYC)'),
          content: const Text('رخصة القيادة: مأكدة\nاستمارة السيارة: مأكدة\nالهوية الشخصية: مأكدة\n\nالحالة العامة: حسابك موثق رسمياً لدى شركة غمدان.'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('حسناً')),
          ],
        ),
      ),
    );
  }

  void _showDestinationFilterDialog() {
    showDialog(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          title: const Text('تحديد طريق العودة'),
          content: const Text('فعّل هذا الخيار لتلقي الطلبات والرحلات التي تكون في نفس اتجاه عودتك فقط لتوفير الوقود والوقت.'),
          actions: [
            TextButton(
              onPressed: () {
                setState(() => destinationFilterActive = !destinationFilterActive);
                Navigator.pop(ctx);
              },
              child: Text(destinationFilterActive ? 'إلغاء التصفية' : 'تفعيل طريق العودة', style: const TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}
