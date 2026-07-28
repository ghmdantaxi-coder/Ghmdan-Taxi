import 'package:flutter/material.dart';

void main() {
  runApp(const GhmdanCaptainApp());
}

class GhmdanCaptainApp extends StatefulWidget {
  const GhmdanCaptainApp({super.key});

  @override
  State<GhmdanCaptainApp> createState() => _GhmdanCaptainAppState();
}

class _GhmdanCaptainAppState extends State<GhmdanCaptainApp> {
  bool isDarkMode = false;

  void toggleTheme(bool value) {
    setState(() {
      isDarkMode = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'كابتن غمدان',
      debugShowCheckedModeBanner: false,
      themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
      theme: ThemeData(
        primarySwatch: Colors.green,
        brightness: Brightness.light,
        scaffoldBackgroundColor: const Color(0xFFFAFAFA),
        fontFamily: 'Roboto',
      ),
      darkTheme: ThemeData(
        primarySwatch: Colors.green,
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
  bool isNetworkConnected = false; // شريط حالة شبكة الإنترنت (محاكاة ضعف الشبكة)
  int pendingOfflineTrips = 2; // عدد الرحلات المخزنة محلياً أثناء انقطاع الإنترنت
  bool destinationFilterActive = false;
  String selectedCurrency = 'ريال يمني (صنعاء)';

  final Map<String, double> balances = {
    'ريال يمني (صنعاء)': 45000.0,
    'ريال يمني (عدن)': 120000.0,
    'ريال سعودي (SAR)': 350.0,
    'دولار أمريكي (USD)': 90.0,
  };

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('كابتن غمدان', style: TextStyle(fontWeight: FontWeight.bold)),
          backgroundColor: Colors.green,
          actions: [
            IconButton(
              icon: Icon(destinationFilterActive ? Icons.alt_route : Icons.alt_route_outlined),
              color: destinationFilterActive ? Colors.yellowAccent : Colors.white,
              tooltip: 'طريق العودة',
              onPressed: _showDestinationFilterDialog,
            ),
            IconButton(
              icon: const Icon(Icons.notifications_none),
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
              UserAccountsDrawerHeader(
                decoration: const BoxDecoration(color: Colors.green),
                accountName: const Text('أبو غمدان (الكابتن)', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                accountEmail: const Text('رقم السائق: #10204 | باص نيسان'),
                currentAccountPicture: const CircleAvatar(
                  backgroundColor: Colors.white,
                  child: Icon(Icons.person, size: 40, color: Colors.green),
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
                leading: const Icon(Icons.verified_user, color: Colors.green),
                title: const Text('توثيق الحساب والوثائق (KYC)'),
                subtitle: const Text('الحالة: مفعّل ومتأكد'),
                onTap: () {
                  Navigator.pop(context);
                  _showKYCModal();
                },
              ),
              ListTile(
                leading: const Icon(Icons.speed, color: Colors.green),
                title: const Text('عداد الشارع المباشر (Street Meter)'),
                onTap: () {
                  Navigator.pop(context);
                  _showStreetMeterDialog();
                },
              ),
              ListTile(
                leading: const Icon(Icons.account_balance_wallet, color: Colors.green),
                title: const Text('المحفظة متعددة العملات'),
                onTap: () {
                  Navigator.pop(context);
                  setState(() => _currentIndex = 1);
                },
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.headset_mic, color: Colors.green),
                title: const Text('الدعم الفني والخدمة'),
                onTap: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('الاتصال بشركة غمدان: 770000000')),
                  );
                },
              ),
              SwitchListTile(
                secondary: const Icon(Icons.dark_mode, color: Colors.green),
                title: const Text('الوضع الداكن'),
                value: widget.isDarkMode,
                onChanged: widget.onThemeChanged,
              ),
            ],
          ),
        ),

        body: Column(
          children: [
            // شريط التنبيه عند ضعف أو انقطاع الإنترنت
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
                          'الوضع الخارجي مفعّل (الإنترنت ضعيف/منقطع)',
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
                          const SnackBar(backgroundColor: Colors.green, content: Text('تمت إعادة الاتصال ومزامنة البيانات محلياً مع السيرفر بنجاح!')),
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
          selectedItemColor: Colors.green,
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
            color: isOnline ? Colors.green.shade50 : Colors.red.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: isOnline ? Colors.green : Colors.red),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                isOnline ? 'متصل (جاهز للطلبات)' : 'غير متصل',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isOnline ? Colors.green.shade900 : Colors.red.shade900,
                ),
              ),
              Switch(
                value: isOnline,
                activeColor: Colors.green,
                onChanged: (val) {
                  setState(() => isOnline = val);
                },
              ),
            ],
          ),
        ),

        Padding(
          padding: const EdgeInsets.horizontal: 12.0),
          child: Row(
            children: [
              Expanded(child: _buildQuickStatCard('أرباح اليوم', '18,500 YER', Icons.monetization_on)),
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
                          const Icon(Icons.radar, size: 80, color: Colors.green),
                          const SizedBox(height: 12),
                          const Text('...جاري البحث عن رحلات قريبة', style: TextStyle(fontSize: 15, color: Colors.grey)),
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.green, padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10)),
                            onPressed: _showTripRequestModal,
                            icon: const Icon(Icons.add_location_alt, color: Colors.white),
                            label: const Text('محاكاة استقبال طلب جديد', style: TextStyle(color: Colors.white)),
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
                          Text('أنت غير متصل الآن', style: TextStyle(fontSize: 16, color: Colors.grey)),
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
        const Text('المحفظة والمالية', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),

        _buildCurrencyBalanceCard('ريال يمني (طبعة صنعاء)', '${balances['ريال يمني (صنعاء)']} YER', Colors.green),
        _buildCurrencyBalanceCard('ريال يمني (طبعة عدن)', '${balances['ريال يمني (عدن)']} YER', Colors.teal),
        _buildCurrencyBalanceCard('ريال سعودي (SAR)', '${balances['ريال سعودي (SAR)']} SAR', Colors.blue),
        _buildCurrencyBalanceCard('دولار أمريكي (USD)', '\$${balances['دولار أمريكي (USD)']}', Colors.indigo),

        const SizedBox(height: 16),

        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green, padding: const EdgeInsets.all(12)),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم إرسال طلب السحب الفوري لحسابك')));
                },
                icon: const Icon(Icons.call_made, color: Colors.white),
                label: const Text('طلب سحب أرباح', style: TextStyle(color: Colors.white)),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(padding: const EdgeInsets.all(12)),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('شحن المحفظة عن طريق الشبكات المحلية')));
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
            backgroundColor: Colors.green,
            child: Icon(Icons.person, size: 50, color: Colors.white),
          ),
        ),
        const SizedBox(height: 8),
        const Center(child: Text('أبو غمدان', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
        const Center(child: Text('السائق المعتمد - صنعاء / إب', style: TextStyle(color: Colors.grey))),
        const Divider(height: 25),

        ListTile(
          leading: const Icon(Icons.attach_money),
          title: const Text('العملة الافتراضية لعرض الأرباح'),
          trailing: DropdownButton<String>(
            value: selectedCurrency,
            onChanged: (val) {
              if (val != null) setState(() => selectedCurrency = val);
            },
            items: const [
              DropdownMenuItem(value: 'ريال يمني (صنعاء)', child: Text('صنعاء YER')),
              DropdownMenuItem(value: 'ريال يمني (عدن)', child: Text('عدن YER')),
              DropdownMenuItem(value: 'ريال سعودي (SAR)', child: Text('سعودي SAR')),
              DropdownMenuItem(value: 'دولار أمريكي (USD)', child: Text('دولار USD')),
            ],
          ),
        ),
        const ListTile(
          leading: Icon(Icons.directions_car),
          title: Text('بيانات المركبة'),
          subtitle: Text('باص نيسان 2006 | لوحة: 12345/أ'),
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
            Icon(icon, color: Colors.green, size: 22),
            const SizedBox(height: 4),
            Text(title, style: const TextStyle(fontSize: 11, color: Colors.grey)),
            Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
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
        title: Text(title, style: const TextStyle(fontSize: 13)),
        trailing: Text(amount, style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: color)),
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
                  Text('طلب رحلة جديدة!', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green)),
                  Chip(label: Text('25 ثانية'), backgroundColor: Colors.amber),
                ],
              ),
              const Divider(),
              const ListTile(
                leading: Icon(Icons.my_location, color: Colors.blue),
                title: Text('نقطة الالتقاء: شارع الستين - صنعاء'),
                subtitle: Text('المسافة: 1.2 كم (3 دقائق)'),
              ),
              const ListTile(
                leading: Icon(Icons.location_on, color: Colors.red),
                title: Text('الوجهة: حدة - جولة الرويشان'),
              ),
              const ListTile(
                leading: Icon(Icons.payments, color: Colors.green),
                title: Text('الأجرة المقدرة: 3,500 ريال يمني (صنعاء)'),
              ),
              const Spacer(),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.green, padding: const EdgeInsets.all(12)),
                      onPressed: () {
                        Navigator.pop(ctx);
                        _showActiveRideDialog();
                      },
                      child: const Text('قبول الطلب', style: TextStyle(color: Colors.white, fontSize: 16)),
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
          title: const Text('الرحلة جارية...'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (!isNetworkConnected)
                Container(
                  padding: const EdgeInsets.all(8),
                  margin: const EdgeInsets.only(bottom: 10),
                  color: Colors.orange.shade100,
                  child: const Text('⚠️ الرحلة تسجل محلياً وسيتم رفع إحداثياتها فور توفر الإنترنت.', style: TextStyle(fontSize: 12, color: Colors.orange)),
                ),
              const Text('يرجى إدخال رمز OTP لبدء التحرك:'),
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
                  SnackBar(content: Text(isNetworkConnected ? 'تم إنهاء الرحلة بنجاح' : 'تم حفظ بيانات الرحلة محلياً بسبب انقطاع الإنترنت')),
                );
              },
              child: const Text('إنهاء الرحلة وتحصيل المبلغ', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
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
          title: const Text('نظام العمل بدون إنترنت (Offline)'),
          content: Text('يوجد حالياً ($pendingOfflineTrips) رحلات وحركات مالية مخزنة على الجوال محلياً.\n\nسيقوم التطبيق بمزامنتها تلقائياً مع السيرفر فور التقاط شبكة الإنترنت.'),
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
          title: const Text('العداد الذكي لركاب الشارع'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Text('المسافة المقطوعة: 4.5 كم (تتبع GPS محلي)'),
              Text('الوقت المنقضي: 12 دقيقة'),
              SizedBox(height: 10),
              Text('المبلغ الحالي: 2,500 YER', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green)),
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
          title: const Text('توثيق الحساب (KYC)'),
          content: const Text('جميع الوثائق مقبولة ومحدثة.'),
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
          content: const Text('حدد وجهتك الأخيرة لتلقي رحلات في مسارك فقط.'),
          actions: [
            TextButton(
              onPressed: () {
                setState(() => destinationFilterActive = !destinationFilterActive);
                Navigator.pop(ctx);
              },
              child: Text(destinationFilterActive ? 'إلغاء التصفية' : 'تفعيل طريق العودة'),
            ),
          ],
        ),
      ),
    );
  }
}
