import 'package:flutter/material.dart';

void main() {
  runApp(const GhamdanApp());
}

class GhamdanApp extends StatefulWidget {
  const GhamdanApp({super.key});

  @override
  State<GhamdanApp> createState() => _GhamdanAppState();
}

class _GhamdanAppState extends State<GhamdanApp> {
  bool isDarkMode = false;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'غمدان - Ghamdan',
      debugShowCheckedModeBanner: false,
      themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
      theme: ThemeData(
        primarySwatch: Colors.amber,
        scaffoldBackgroundColor: const Color(0xFFF5F5F5),
        fontFamily: 'Roboto',
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.amber,
        scaffoldBackgroundColor: const Color(0xFF121212),
      ),
      home: UberStyleMainScreen(
        isDarkMode: isDarkMode,
        onThemeChanged: (val) => setState(() => isDarkMode = val),
      ),
    );
  }
}

class UberStyleMainScreen extends StatefulWidget {
  final bool isDarkMode;
  final ValueChanged<bool> onThemeChanged;

  const UberStyleMainScreen({
    super.key,
    required this.isDarkMode,
    required this.onThemeChanged,
  });

  @override
  State<UberStyleMainScreen> createState() => _UberStyleMainScreenState();
}

enum BookingState { selectService, setLocations, searchingDriver, tripActive }

class _UberStyleMainScreenState extends State<UberStyleMainScreen> {
  BookingState currentStage = BookingState.selectService;
  
  String pickupLocation = 'موقعي الحالي (شارع الستين - صنعاء)';
  String destinationLocation = '';
  String selectedService = 'تاكسي سريع';
  double estimatedFare = 2500.0;
  String selectedCurrency = 'YER';

  final TextEditingController _destinationController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: Stack(
          children: [
            // 1. خريطة تفاعلية رئيسية مثل أوبـر خلف الواجهات
            Positioned.fill(
              child: CustomPaint(
                painter: LiveUberMapPainter(stage: currentStage),
              ),
            ),

            // 2. شريط البحث العلوي / القائمة
            Positioned(
              top: 50,
              left: 16,
              right: 16,
              child: Row(
                children: [
                  Builder(
                    builder: (ctx) => CircleAvatar(
                      backgroundColor: Colors.black,
                      child: IconButton(
                        icon: const Icon(Icons.menu, color: Colors.amber),
                        onPressed: () => Scaffold.of(ctx).openDrawer(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: widget.isDarkMode ? Colors.grey[900] : Colors.white,
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 10)],
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.location_on, color: Colors.red),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              pickupLocation,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // 3. النافذة السفلية المكونة لخيار الطلب مثل أوبـر تماماً
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: _buildBottomUberSheet(),
            ),
          ],
        ),
        drawer: Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              const UserAccountsDrawerHeader(
                decoration: BoxDecoration(color: Colors.black),
                accountName: Text('غمدان للنقل والخدمات', style: TextStyle(color: Colors.amber, fontSize: 18, fontWeight: FontWeight.bold)),
                accountEmail: Text('حساب العميل | صنعاء - اليمن', style: TextStyle(color: Colors.white70)),
                currentAccountPicture: CircleAvatar(
                  backgroundColor: Colors.amber,
                  child: Icon(Icons.local_taxi, size: 35, color: Colors.black),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.history, color: Colors.amber),
                title: const Text('سجل الرحلات السابق'),
                onTap: () {},
              ),
              ListTile(
                leading: const Icon(Icons.account_balance_wallet, color: Colors.amber),
                title: const Text('المحفظة والرصيد'),
                onTap: () {},
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
      ),
    );
  }

  // بناء اللوحة السفلية للطلب والتنقل كـ Uber
  Widget _buildBottomUberSheet() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: widget.isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: const [BoxShadow(color: Colors.black38, blurRadius: 15)],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(bottom: 15),
            decoration: BoxDecoration(color: Colors.grey[400], borderRadius: BorderRadius.circular(10)),
          ),

          if (currentStage == BookingState.selectService) ...[
            const Align(
              alignment: Alignment.centerRight,
              child: Text('إلى أين تريد الذهاب؟', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _destinationController,
              decoration: InputDecoration(
                hintText: 'أدخل وجهتك (مثال: جولة الرويشان، حدة)',
                prefixIcon: const Icon(Icons.search, color: Colors.amber),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
              ),
              onSubmitted: (val) {
                if (val.isNotEmpty) {
                  setState(() {
                    destinationLocation = val;
                    currentStage = BookingState.setLocations;
                  });
                }
              },
            ),
            const SizedBox(height: 15),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildServiceOption('تاكسي', Icons.directions_car, true),
                _buildServiceOption('باص نقل', Icons.directions_bus, false),
                _buildServiceOption('شحن طرود', Icons.local_shipping, false),
              ],
            ),
          ] else if (currentStage == BookingState.setLocations) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('الوجهة: $destinationLocation', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                IconButton(icon: const Icon(Icons.close), onPressed: () => setState(() => currentStage = BookingState.selectService)),
              ],
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.local_taxi, color: Colors.amber, size: 30),
              title: Text(selectedService, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: const Text('وصول خلال 3-5 دقائق'),
              trailing: Text('$estimatedFare $selectedCurrency', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green)),
            ),
            const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.amber,
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () {
                      setState(() => currentStage = BookingState.searchingDriver);
                      // محاكاة العثور على سائق بعد 3 ثوانٍ
                      Future.delayed(const Duration(seconds: 3), () {
                        if (mounted) setState(() => currentStage = BookingState.tripActive);
                      });
                    },
                    child: const Text('تأكيد طلب الرحلة الآن', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ),
          ] else if (currentStage == BookingState.searchingDriver) ...[
            const CircularProgressIndicator(color: Colors.amber),
            const SizedBox(height: 15),
            const Text('جاري البحث عن أقرب سائق غمدان...', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            TextButton(
              onPressed: () => setState(() => currentStage = BookingState.selectService),
              child: const Text('إلغاء الطلب', style: TextStyle(color: Colors.red)),
            ),
          ] else if (currentStage == BookingState.tripActive) ...[
            const ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.black,
                child: Icon(Icons.person, color: Colors.amber),
              ),
              title: Text('السائق: الكابتن أبو غمدان', style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text('نيسان تاكسي | رقم اللوحة: 12345/أ'),
              trailing: Icon(Icons.phone, color: Colors.green),
            ),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('رمز أمان الرحلة (OTP):', style: TextStyle(color: Colors.grey)),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(color: Colors.amber, borderRadius: BorderRadius.circular(8)),
                  child: const Text('4821', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black)),
                ),
              ],
            ),
            const SizedBox(height: 15),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  setState(() => currentStage = BookingState.selectService);
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تمت إنهاء الرحلة بنجاح. شكراً لاستخدامك غمدان!')));
                },
                child: const Text('إنهاء الرحلة'),
              ),
            )
          ]
        ],
      ),
    );
  }

  Widget _buildServiceOption(String title, IconData icon, bool active) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: active ? Colors.amber : Colors.grey[200],
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(icon, size: 30, color: active ? Colors.black : Colors.grey[700]),
        ),
        const SizedBox(height: 6),
        Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
      ],
    );
  }
}

// رسم الخريطة المتجهة للرحلة والمواقع
class LiveUberMapPainter extends CustomPainter {
  final BookingState stage;
  LiveUberMapPainter({required this.stage});

  @override
  void paint(Canvas canvas, Size size) {
    final bgPaint = Paint()..color = const Color(0xFF242F3E);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);

    final roadPaint = Paint()
      ..color = Colors.white12
      ..strokeWidth = 3;

    for (double i = 0; i < size.width; i += 50) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), roadPaint);
    }
    for (double j = 0; j < size.height; j += 50) {
      canvas.drawLine(Offset(0, j), Offset(size.width, j), roadPaint);
    }

    // رسم موقع العميل دائمًا
    final userPin = Paint()..color = Colors.blue;
    canvas.drawCircle(Offset(size.width * 0.5, size.height * 0.45), 10, userPin);

    // مسار أوبـر التفاعلي عند طلب الرحلة
    if (stage == BookingState.setLocations || stage == BookingState.tripActive) {
      final routePaint = Paint()
        ..color = Colors.amber
        ..strokeWidth = 5
        ..style = PaintingStyle.stroke;

      final path = Path();
      path.moveTo(size.width * 0.5, size.height * 0.45);
      path.lineTo(size.width * 0.75, size.height * 0.25);
      canvas.drawPath(path, routePaint);

      final destPin = Paint()..color = Colors.red;
      canvas.drawCircle(Offset(size.width * 0.75, size.height * 0.25), 10, destPin);
    }
  }

  @override
  bool shouldRepaint(covariant LiveUberMapPainter oldDelegate) => oldDelegate.stage != stage;
}
