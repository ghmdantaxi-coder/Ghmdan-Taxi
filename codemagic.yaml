import 'package:flutter/material.dart';

void main() {
  runApp(const GhmdanCaptainApp());
}

class GhmdanCaptainApp extends StatelessWidget {
  const GhmdanCaptainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'كابتن غمدان',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.green,
        fontFamily: 'Roboto',
      ),
      home: const DriverHomeScreen(),
    );
  }
}

class DriverHomeScreen extends StatefulWidget {
  const DriverHomeScreen({super.key});

  @override
  State<DriverHomeScreen> createState() => _DriverHomeScreenState();
}

class _DriverHomeScreenState extends State<DriverHomeScreen> {
  bool isOnline = true;
  int _currentIndex = 0;

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
              icon: const Icon(Icons.notifications_none),
              onPressed: () {
                _showSnackBar('لا توجد إشعارات جديدة حالياً');
              },
            ),
          ],
        ),
        
        // القائمة الجانبية الشاملة للسائق
        drawer: Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              UserAccountsDrawerHeader(
                decoration: const BoxDecoration(color: Colors.green),
                accountName: const Text('أبو غمدان (الكابتن)', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                accountEmail: const Text('رقم السائق: #10204 | تويوتا'),
                currentAccountPicture: const CircleAvatar(
                  backgroundColor: Colors.white,
                  child: Icon(Icons.person, size: 40, color: Colors.green),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.account_balance_wallet, color: Colors.green),
                title: const Text('المحفظة والأرباح'),
                subtitle: const Text('رصيدك: 15,000 ريال يمني'),
                onTap: () {
                  Navigator.pop(context);
                  _showEarningsDialog();
                },
              ),
              ListTile(
                leading: const Icon(Icons.history, color: Colors.green),
                title: const Text('سجل الرحلات'),
                onTap: () {
                  Navigator.pop(context);
                  _showSnackBar('صفحة سجل الرحلات المكتملة');
                },
              ),
              ListTile(
                leading: const Icon(Icons.description, color: Colors.green),
                title: const Text('وثائق الكابتن والسيارة'),
                onTap: () {
                  Navigator.pop(context);
                  _showSnackBar('الوثائق مقبولة ومحدثة');
                },
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.headset_mic, color: Colors.green),
                title: const Text('الدعم الفني والخدمة'),
                onTap: () {
                  Navigator.pop(context);
                  _showSnackBar('الاتصال بعمليات غمدان');
                },
              ),
              ListTile(
                leading: const Icon(Icons.settings, color: Colors.green),
                title: const Text('الإعدادات'),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.exit_to_app, color: Colors.red),
                title: const Text('تسجيل الخروج'),
                onTap: () {},
              ),
            ],
          ),
        ),

        // المحتوى المتغير بحسب التبويب
        body: _buildSelectedBody(),

        // شريط التنقل السفلي للسائق
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
            BottomNavigationBarItem(
              icon: Icon(Icons.navigation),
              label: 'الرئيسية',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.account_balance_wallet),
              label: 'الأرباح',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: 'الحساب',
            ),
          ],
        ),
      ),
    );
  }

  // بناء واجهة التبويب المختار
  Widget _buildSelectedBody() {
    if (_currentIndex == 1) {
      return _buildEarningsScreen();
    } else if (_currentIndex == 2) {
      return _buildProfileScreen();
    }

    // الواجهة الرئيسية (رادار الطلبات)
    return Column(
      children: [
        Container(
          margin: const EdgeInsets.all(16),
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
                  setState(() {
                    isOnline = val;
                  });
                },
              ),
            ],
          ),
        ),
        Expanded(
          child: Center(
            child: isOnline
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.radar, size: 100, color: Colors.green),
                      SizedBox(height: 16),
                      Text('...جاري البحث عن رحلات قريبة', style: TextStyle(fontSize: 18, color: Colors.grey)),
                    ],
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.power_settings_new, size: 100, color: Colors.grey),
                      SizedBox(height: 16),
                      Text('أنت غير متصل الآن. قم بتفعيل الخيار لاستقبال الطلبات.', style: TextStyle(fontSize: 16, color: Colors.grey)),
                    ],
                  ),
          ),
        ),
      ],
    );
  }

  // شاشة الأرباح
  Widget _buildEarningsScreen() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('ملخص الأرباح', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Card(
            color: Colors.green.shade700,
            child: const ListTile(
              title: Text('أرباح اليوم', style: TextStyle(color: Colors.white)),
              subtitle: Text('24,500 ريال يمني', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
              trailing: Icon(Icons.monetization_on, color: Colors.white, size: 40),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: const [
                        Text('عدد الرحلات'),
                        SizedBox(height: 8),
                        Text('8', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: const [
                        Text('ساعات العمل'),
                        SizedBox(height: 8),
                        Text('5.5 ساعة', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // شاشة الملف الشخصي
  Widget _buildProfileScreen() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: const [
        Center(
          child: CircleAvatar(
            radius: 50,
            backgroundColor: Colors.green,
            child: Icon(Icons.person, size: 60, color: Colors.white),
          ),
        ),
        SizedBox(height: 12),
        Center(child: Text('أبو غمدان', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold))),
        Center(child: Text('تقييم الكابتن: ★ 4.9', style: TextStyle(color: Colors.amber, fontSize: 16))),
        Divider(height: 32),
        ListTile(
          leading: Icon(Icons.directions_car),
          title: Text('بيانات المركبة'),
          subtitle: Text('باص نيسان - 2006'),
        ),
        ListTile(
          leading: Icon(Icons.phone),
          title: Text('رقم الهاتف'),
          subtitle: Text('+967 770 000 000'),
        ),
      ],
    );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  void _showEarningsDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('تفاصيل المحفظة'),
        content: const Text('الرصيد المتاح للسحب: 15,000 ريال يمني\nنسبة التطبيق المخصومة: 10%'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('إغلاق')),
        ],
      ),
    );
  }
}
