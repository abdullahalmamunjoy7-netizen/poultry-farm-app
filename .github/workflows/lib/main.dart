import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const SmartKhamariApp());
}

class AgroTheme {
  static const Color primaryGreen = Color(0xFF186337);
  static const Color accentGreen = Color(0xFF76AB33);
  static const Color darkCharcoal = Color(0xFF1E221E);
  static const Color background = Color(0xFFF7F9F6);
  static const Color subtleBorder = Color(0xFFE2E8E0);
}

class SmartKhamariApp extends StatelessWidget {
  const SmartKhamariApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'স্মার্ট খামারি',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: AgroTheme.background,
        useMaterial3: true,
        fontFamily: 'Roboto',
        colorScheme: ColorScheme.fromSeed(
          seedColor: AgroTheme.primaryGreen,
          primary: AgroTheme.primaryGreen,
          secondary: AgroTheme.accentGreen,
        ),
      ),
      home: const HomeScreen(),
    );
  }
}

class VaccineInfo {
  final int day;
  final String name;
  final String route;
  final String note;
  VaccineInfo({required this.day, required this.name, required this.route, required this.note});
}

List<VaccineInfo> getVaccineSchedule(String birdType) {
  if (birdType == 'ব্রয়লার মুরগী') {
    return [
      VaccineInfo(day: 4, name: 'BCRDV (রাণীক্ষেত)', route: 'চোখে ড্রপ', note: '১ ফোঁটা করে চোখের কোনায় দিন'),
      VaccineInfo(day: 10, name: 'গামবোরো (১ম ডোজ)', route: 'পানি / চোখ', note: 'সকালের ঠাণ্ডা পানিতে মিশিয়ে দিন'),
      VaccineInfo(day: 18, name: 'গামবোরো (বুস্টার)', route: 'খাবার পানি', note: 'পানিতে হালকা গুঁড়াদুধ মেশাতে পারেন'),
      VaccineInfo(day: 22, name: 'BCRDV (বুস্টার)', route: 'চোখ / পানি', note: 'রাণীক্ষেত চূড়ান্ত প্রতিরোধে'),
    ];
  } else if (birdType.contains('হাঁস')) {
    return [
      VaccineInfo(day: 18, name: 'ডাক প্লেগ (১ম ডোজ)', route: 'চামড়ার নিচে', note: 'ঘাড়ের চামড়ার নিচে ১ মিলি'),
      VaccineInfo(day: 35, name: 'ডাক প্লেগ (বুস্টার)', route: 'বুকের মাংসে', note: 'বুকের মাংসে ১ মিলি'),
      VaccineInfo(day: 50, name: 'ডাক কলেরা (১ম ডোজ)', route: 'বুকের মাংসে', note: '১ মিলি করে ইনজেকশন'),
      VaccineInfo(day: 75, name: 'ডাক কলেরা (বুস্টার)', route: 'বুকের মাংসে', note: 'পূর্ণ প্রতিরোধ ক্ষমতার জন্য'),
    ];
  } else {
    return [
      VaccineInfo(day: 4, name: 'BCRDV (রাণীক্ষেত)', route: 'চোখে ড্রপ', note: 'চোখে ১ ফোঁটা'),
      VaccineInfo(day: 10, name: 'গামবোরো', route: 'চোখে ড্রপ / পানি', note: 'সকালে ঠাণ্ডা পানিতে'),
      VaccineInfo(day: 18, name: 'গামবোরো বুস্টার', route: 'পানি', note: 'বুস্টার ডোজ'),
      VaccineInfo(day: 24, name: 'BCRDV বুস্টার', route: 'চোখ / পানি', note: 'রাণীক্ষেত প্রতিরোধে'),
      VaccineInfo(day: 35, name: 'ফাউল পক্স (বসন্ত)', route: 'ডানার পর্দায়', note: 'ডানার চামড়ায় সুই ফুটিয়ে দিন'),
      VaccineInfo(day: 60, name: 'RDV (বড় রাণীক্ষেত)', route: 'মাংসে ইনজেকশন', note: 'বুকের মাংসে ০.৫ মিলি'),
      VaccineInfo(day: 75, name: 'ফাউল কলেরা', route: 'মাংসে ইনজেকশন', note: 'বুকের মাংসে ১ মিলি'),
    ];
  }
}

class Shed {
  String id;
  String name;
  String birdType;
  int chickCount;
  double chickPrice;
  DateTime startDate;
  bool isClosed;
  double soldWeight;
  double saleRate;
  int soldBirds;

  Shed({
    required this.id,
    required this.name,
    required this.birdType,
    required this.chickCount,
    required this.chickPrice,
    required this.startDate,
    this.isClosed = false,
    this.soldWeight = 0,
    this.saleRate = 0,
    this.soldBirds = 0,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'birdType': birdType,
    'chickCount': chickCount,
    'chickPrice': chickPrice,
    'startDate': startDate.toIso8601String(),
    'isClosed': isClosed,
    'soldWeight': soldWeight,
    'saleRate': saleRate,
    'soldBirds': soldBirds,
  };

  factory Shed.fromJson(Map<String, dynamic> json) => Shed(
    id: json['id'],
    name: json['name'],
    birdType: json['birdType'],
    chickCount: json['chickCount'],
    chickPrice: (json['chickPrice'] as num).toDouble(),
    startDate: DateTime.parse(json['startDate']),
    isClosed: json['isClosed'] ?? false,
    soldWeight: (json['soldWeight'] as num?)?.toDouble() ?? 0,
    saleRate: (json['saleRate'] as num?)?.toDouble() ?? 0,
    soldBirds: json['soldBirds'] ?? 0,
  );
}

class DailyLog {
  String id;
  String shedId;
  DateTime date;
  int mortality;
  double feedKg;
  double feedCost;
  double medicineCost;
  int eggs;
  double otherCost;
  String note;

  DailyLog({
    required this.id,
    required this.shedId,
    required this.date,
    this.mortality = 0,
    this.feedKg = 0,
    this.feedCost = 0,
    this.medicineCost = 0,
    this.eggs = 0,
    this.otherCost = 0,
    this.note = '',
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'shedId': shedId,
    'date': date.toIso8601String(),
    'mortality': mortality,
    'feedKg': feedKg,
    'feedCost': feedCost,
    'medicineCost': medicineCost,
    'eggs': eggs,
    'otherCost': otherCost,
    'note': note,
  };

  factory DailyLog.fromJson(Map<String, dynamic> json) => DailyLog(
    id: json['id'],
    shedId: json['shedId'],
    date: DateTime.parse(json['date']),
    mortality: json['mortality'] ?? 0,
    feedKg: (json['feedKg'] as num?)?.toDouble() ?? 0,
    feedCost: (json['feedCost'] as num?)?.toDouble() ?? 0,
    medicineCost: (json['medicineCost'] as num?)?.toDouble() ?? 0,
    eggs: json['eggs'] ?? 0,
    otherCost: (json['otherCost'] as num?)?.toDouble() ?? 0,
    note: json['note'] ?? '',
  );
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Shed> sheds = [];
  double? currentTemp;
  int? currentHumidity;
  String weatherAdvice = 'আবহাওয়া তথ্য লোড হচ্ছে...';
  String selectedCity = 'ঢাকা';

  final Map<String, List<double>> cities = {
    'ঢাকা': [23.8103, 90.4125],
    'চট্টগ্রাম': [22.3569, 91.7832],
    'রাজশাহী': [24.3636, 88.6241],
    'রংপুর': [25.7439, 89.2752],
    'খুলনা': [22.8456, 89.5403],
    'ময়মনসিংহ': [24.7471, 90.4203],
    'সিলেট': [24.8949, 91.8687],
    'বরিশাল': [22.7010, 90.3535],
  };

  @override
  void initState() {
    super.initState();
    _loadSheds();
    _fetchWeather();
  }

  Future<void> _fetchWeather() async {
    try {
      final coords = cities[selectedCity] ?? [23.8103, 90.4125];
      final url = Uri.parse(
          'https://api.open-meteo.com/v1/forecast?latitude=${coords[0]}&longitude=${coords[1]}&current=temperature_2m,relative_humidity_2m');
      final res = await http.get(url).timeout(const Duration(seconds: 8));
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        final temp = (data['current']['temperature_2m'] as num).toDouble();
        final hum = (data['current']['relative_humidity_2m'] as num).toInt();

        String advice = '';
        if (temp >= 32) {
          advice = '🔥 অতিরিক্ত গরম ($temp°C)! দুপুর ১২টা-বিকেল ৪টা খাবার বন্ধ রাখুন। পানিতে স্যালাইন/ভিটামিন-সি দিন।';
        } else if (temp <= 20) {
          advice = '❄️ ঠাণ্ডা আবহাওয়া ($temp°C)! ব্রুডারে পর্যাপ্ত তাপ দিন ও পর্দা নামান।';
        } else if (hum >= 80) {
          advice = '🌧️ আর্দ্র আবহাওয়া ($hum%)! লিটার ভিজলে চুন দিন। কক্সিডিওসিস থেকে সাবধান।';
        } else {
          advice = '🌤️ অনুকুল আবহাওয়া ($temp°C, আর্দ্রতা $hum%)। নিয়মমাফিক খাবার ও পানি দিন।';
        }

        setState(() {
          currentTemp = temp;
          currentHumidity = hum;
          weatherAdvice = advice;
        });
      }
    } catch (_) {
      setState(() {
        weatherAdvice = 'অফলাইন মোড: নিয়মিত আলো-বাতাস ও পানির সুব্যবস্থা বজায় রাখুন।';
      });
    }
  }

  Future<void> _loadSheds() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString('sheds');
    if (data != null) {
      final List list = jsonDecode(data);
      setState(() {
        sheds = list.map((e) => Shed.fromJson(e)).toList();
      });
    }
  }

  Future<void> _saveSheds() async {
    final prefs = await SharedPreferences.getInstance();
    final data = jsonEncode(sheds.map((e) => e.toJson()).toList());
    await prefs.setString('sheds', data);
  }

  void _addShedDialog() {
    final nameCtrl = TextEditingController();
    final chickCtrl = TextEditingController();
    final priceCtrl = TextEditingController();
    String selectedType = 'ব্রয়লার মুরগী';
    final types = ['ব্রয়লার মুরগী', 'সোনালী মুরগী', 'পেকিং হাঁস', 'ডিমের মুরগী (লেয়ার)', 'ডিমের হাঁস'];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDState) => Padding(
          padding: EdgeInsets.only(
            left: 20, right: 20, top: 24,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('নতুন শেড বা ব্যাচ শুরু করুন', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AgroTheme.primaryGreen)),
                const SizedBox(height: 16),
                TextField(
                  controller: nameCtrl,
                  decoration: InputDecoration(
                    labelText: 'শেডের নাম / ব্যাচ নম্বর (যেমন: শেড-০১)',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: selectedType,
                  items: types.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                  onChanged: (val) => setDState(() => selectedType = val!),
                  decoration: InputDecoration(
                    labelText: 'পাখির জাত / ধরণ',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: chickCtrl,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'বাচ্চার সংখ্যা (টি)',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: priceCtrl,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'প্রতি বাচ্চার দর (টাকা)',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AgroTheme.primaryGreen,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () {
                      if (nameCtrl.text.isNotEmpty && chickCtrl.text.isNotEmpty) {
                        final newShed = Shed(
                          id: DateTime.now().millisecondsSinceEpoch.toString(),
                          name: nameCtrl.text,
                          birdType: selectedType,
                          chickCount: int.tryParse(chickCtrl.text) ?? 0,
                          chickPrice: double.tryParse(priceCtrl.text) ?? 0,
                          startDate: DateTime.now(),
                        );
                        setState(() => sheds.add(newShed));
                        _saveSheds();
                        Navigator.pop(ctx);
                      }
                    },
                    child: const Text('ব্যাচ শুরু করুন', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        title: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset(
                'assets/logo.png',
                height: 38,
                width: 38,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) => Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AgroTheme.primaryGreen.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.agriculture, color: AgroTheme.primaryGreen, size: 24),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('স্মার্ট খামারি', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AgroTheme.darkCharcoal)),
                Text('A Product of Engineer\'s Agro', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: AgroTheme.primaryGreen)),
              ],
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Container(
            margin: const EdgeInsets.fromLTRB(16, 12, 16, 6),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AgroTheme.subtleBorder),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 8, offset: const Offset(0, 3)),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(color: AgroTheme.accentGreen.withOpacity(0.15), shape: BoxShape.circle),
                          child: const Icon(Icons.wb_sunny_outlined, color: AgroTheme.primaryGreen, size: 18),
                        ),
                        const SizedBox(width: 8),
                        const Text('লাইভ আবহাওয়া ও পরামর্শ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AgroTheme.darkCharcoal)),
                      ],
                    ),
                    DropdownButton<String>(
                      value: selectedCity,
                      underline: const SizedBox(),
                      icon: const Icon(Icons.keyboard_arrow_down, size: 18, color: AgroTheme.primaryGreen),
                      style: const TextStyle(fontWeight: FontWeight.bold, color: AgroTheme.primaryGreen, fontSize: 13),
                      items: cities.keys.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setState(() => selectedCity = val);
                          _fetchWeather();
                        }
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  weatherAdvice,
                  style: const TextStyle(fontSize: 13, color: Colors.black88, height: 1.35),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('আমার খামার শেডসমূহ', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AgroTheme.darkCharcoal)),
                Text('${sheds.length} টি শেড', style: const TextStyle(color: Colors.grey, fontSize: 13)),
              ],
            ),
          ),
          Expanded(
            child: sheds.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.pets, size: 48, color: Colors.grey.shade400),
                        const SizedBox(height: 10),
                        const Text('কোনো শেড যুক্ত করা নেই!', style: TextStyle(color: Colors.black54, fontSize: 15, fontWeight: FontWeight.w500)),
                        const SizedBox(height: 4),
                        const Text('নিচের (+) বাটনে চাপ দিয়ে ব্যাচ খুলুন', style: TextStyle(color: Colors.grey, fontSize: 12)),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    itemCount: sheds.length,
                    itemBuilder: (ctx, i) {
                      final s = sheds[i];
                      final age = DateTime.now().difference(s.startDate).inDays + 1;
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AgroTheme.subtleBorder),
                          boxShadow: [
                            BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 6, offset: const Offset(0, 2)),
                          ],
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          leading: CircleAvatar(
                            radius: 24,
                            backgroundColor: s.isClosed ? Colors.grey.shade300 : AgroTheme.primaryGreen.withOpacity(0.12),
                            child: Icon(s.isClosed ? Icons.check : Icons.egg_outlined, color: s.isClosed ? Colors.grey : AgroTheme.primaryGreen),
                          ),
                          title: Text(s.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AgroTheme.darkCharcoal)),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 4),
                              Text('${s.birdType}  •  বাচ্চা: ${s.chickCount} টি', style: TextStyle(color: Colors.grey.shade700, fontSize: 13)),
                              const SizedBox(height: 2),
                              Text(
                                s.isClosed ? 'ব্যাচ সম্পন্ন' : 'বর্তমান বয়স: $age দিন',
                                style: TextStyle(color: s.isClosed ? Colors.grey : AgroTheme.accentGreen, fontWeight: FontWeight.w600, fontSize: 12),
                              ),
                            ],
                          ),
                          trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: Colors.grey),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => ShedDetailsScreen(shed: s, onUpdate: _saveSheds)),
                            ).then((_) => setState(() {}));
                          },
                        ),
                      );
                    },
                  ),
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: AgroTheme.subtleBorder)),
            ),
            child: Column(
              children: [
                const Text('Developed by Abdullah Al Mamun', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AgroTheme.darkCharcoal)),
                Text('A Product of Engineer\'s Agro', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: AgroTheme.primaryGreen)),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addShedDialog,
        backgroundColor: AgroTheme.primaryGreen,
        icon: const Icon(Icons.add_circle_outline, color: Colors.white),
        label: const Text('নতুন ব্যাচ', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }
}

class ShedDetailsScreen extends StatefulWidget {
  final Shed shed;
  final VoidCallback onUpdate;
  const ShedDetailsScreen({super.key, required this.shed, required this.onUpdate});

  @override
  State<ShedDetailsScreen> createState() => _ShedDetailsScreenState();
}

class _ShedDetailsScreenState extends State<ShedDetailsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;
  List<DailyLog> logs = [];

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 3, vsync: this);
    _loadLogs();
  }

  Future<void> _loadLogs() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString('logs_${widget.shed.id}');
    if (data != null) {
      final List list = jsonDecode(data);
      setState(() {
        logs = list.map((e) => DailyLog.fromJson(e)).toList();
      });
    }
  }

  Future<void> _saveLogs() async {
    final prefs = await SharedPreferences.getInstance();
    final data = jsonEncode(logs.map((e) => e.toJson()).toList());
    await prefs.setString('logs_${widget.shed.id}', data);
  }

  void _addDailyLogDialog() {
    DateTime selectedDate = DateTime.now();
    final deadCtrl = TextEditingController(text: '0');
    final feedKgCtrl = TextEditingController();
    final feedCostCtrl = TextEditingController();
    final medCostCtrl = TextEditingController();
    final eggsCtrl = TextEditingController(text: '0');
    final otherCostCtrl = TextEditingController();
    final noteCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDState) => Padding(
          padding: EdgeInsets.only(
            left: 20, right: 20, top: 20,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('আজকের দৈনিক হিসাব এন্ট্রি', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AgroTheme.primaryGreen)),
                const SizedBox(height: 12),
                InkWell(
                  onTap: () async {
                    final d = await showDatePicker(
                      context: context,
                      initialDate: selectedDate,
                      firstDate: widget.shed.startDate,
                      lastDate: DateTime.now().add(const Duration(days: 1)),
                    );
                    if (d != null) setDState(() => selectedDate = d);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(border: Border.all(color: AgroTheme.subtleBorder), borderRadius: BorderRadius.circular(12)),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('তারিখ: ${DateFormat('dd MMMM yyyy').format(selectedDate)}', style: const TextStyle(fontWeight: FontWeight.w600)),
                        const Icon(Icons.calendar_today_outlined, size: 18, color: AgroTheme.primaryGreen),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(controller: deadCtrl, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: 'মারা গেছে (টি)', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)))),
                const SizedBox(height: 10),
                TextField(controller: feedKgCtrl, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: 'খাবার খাওয়া হয়েছে (কেজি)', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)))),
                const SizedBox(height: 10),
                TextField(controller: feedCostCtrl, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: 'খাবারের মোট দাম (টাকা)', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)))),
                const SizedBox(height: 10),
                TextField(controller: medCostCtrl, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: 'ঔষধ / ভ্যাকসিন খরচ (টাকা)', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)))),
                if (widget.shed.birdType.contains('ডিম')) ...[
                  const SizedBox(height: 10),
                  TextField(controller: eggsCtrl, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: 'ডিম সংগ্রহ (টি)', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)))),
                ],
                const SizedBox(height: 10),
                TextField(controller: otherCostCtrl, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: 'অন্যান্য খরচ (টাকা)', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)))),
                const SizedBox(height: 10),
                TextField(controller: noteCtrl, decoration: InputDecoration(labelText: 'খরচের নোট / বিবরণ', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)))),
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: AgroTheme.primaryGreen, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                    onPressed: () {
                      final log = DailyLog(
                        id: DateTime.now().millisecondsSinceEpoch.toString(),
                        shedId: widget.shed.id,
                        date: selectedDate,
                        mortality: int.tryParse(deadCtrl.text) ?? 0,
                        feedKg: double.tryParse(feedKgCtrl.text) ?? 0,
                        feedCost: double.tryParse(feedCostCtrl.text) ?? 0,
                        medicineCost: double.tryParse(medCostCtrl.text) ?? 0,
                        eggs: int.tryParse(eggsCtrl.text) ?? 0,
                        otherCost: double.tryParse(otherCostCtrl.text) ?? 0,
                        note: noteCtrl.text,
                      );
                      setState(() => logs.insert(0, log));
                      _saveLogs();
                      Navigator.pop(ctx);
                    },
                    child: const Text('হিসাব সংরক্ষণ করুন', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _closeShedDialog() {
    final weightCtrl = TextEditingController();
    final rateCtrl = TextEditingController();
    final birdsCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Text('ব্যাচ বিক্রির চূড়ান্ত হিসাব', style: TextStyle(color: AgroTheme.primaryGreen, fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: birdsCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'মোট জীবিত বিক্রি (টি)')),
            TextField(controller: weightCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'মোট বিক্রিত ওজন (কেজি)')),
            TextField(controller: rateCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'প্রতি কেজি বিক্রয়মূল্য (টাকা)')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('বাতিল')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AgroTheme.primaryGreen, foregroundColor: Colors.white),
            onPressed: () {
              setState(() {
                widget.shed.soldBirds = int.tryParse(birdsCtrl.text) ?? 0;
                widget.shed.soldWeight = double.tryParse(weightCtrl.text) ?? 0;
                widget.shed.saleRate = double.tryParse(rateCtrl.text) ?? 0;
                widget.shed.isClosed = true;
              });
              widget.onUpdate();
              Navigator.pop(ctx);
            },
            child: const Text('হিসাব চূড়ান্ত করুন'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentAge = DateTime.now().difference(widget.shed.startDate).inDays + 1;
    final schedules = getVaccineSchedule(widget.shed.birdType);
    final todayVaccines = schedules.where((v) => (v.day - currentAge).abs() <= 1).toList();

    final totalDead = logs.fold<int>(0, (sum, item) => sum + item.mortality);
    final totalFeedKg = logs.fold<double>(0, (sum, item) => sum + item.feedKg);
    final totalFeedCost = logs.fold<double>(0, (sum, item) => sum + item.feedCost);
    final totalMedCost = logs.fold<double>(0, (sum, item) => sum + item.medicineCost);
    final totalOtherCost = logs.fold<double>(0, (sum, item) => sum + item.otherCost);
    final totalExpense = (widget.shed.chickCount * widget.shed.chickPrice) + totalFeedCost + totalMedCost + totalOtherCost;
    final totalRevenue = widget.shed.soldWeight * widget.shed.saleRate;
    final profitOrLoss = totalRevenue - totalExpense;
    final double fcr = widget.shed.soldWeight > 0 ? (totalFeedKg / widget.shed.soldWeight) : 0;
    final double mortalityRate = widget.shed.chickCount > 0 ? (totalDead / widget.shed.chickCount) * 100 : 0;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AgroTheme.primaryGreen,
        foregroundColor: Colors.white,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.shed.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            Text('${widget.shed.birdType}  |  বয়স: $currentAge দিন', style: const TextStyle(fontSize: 12, color: Colors.white70)),
          ],
        ),
        bottom: TabBar(
          controller: _tabCtrl,
          indicatorColor: AgroTheme.accentGreen,
          indicatorWeight: 3,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: 'দৈনিক হিসাব'),
            Tab(text: 'ভ্যাকসিন চার্ট'),
            Tab(text: 'লাভ ও রিপোর্ট'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabCtrl,
        children: [
          Column(
            children: [
              if (todayVaccines.isNotEmpty && !widget.shed.isClosed)
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.all(12),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF3E0),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.orange.shade300),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.notifications_active, color: Colors.orange, size: 24),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('জরুরি ভ্যাকসিন এলার্ট!', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.orange)),
                            ...todayVaccines.map((v) => Text('• ${v.name} (${v.route}) - ${v.note}', style: const TextStyle(fontSize: 12))),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              Expanded(
                child: logs.isEmpty
                    ? const Center(child: Text('এখনও কোনো হিসাব দেওয়া হয়নি। নিচে (+) চাপুন।'))
                    : ListView.builder(
                        padding: const EdgeInsets.all(12),
                        itemCount: logs.length,
                        itemBuilder: (ctx, i) {
                          final item = logs[i];
                          return Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AgroTheme.subtleBorder),
                            ),
                            child: ListTile(
                              title: Text(DateFormat('dd MMMM yyyy').format(item.date), style: const TextStyle(fontWeight: FontWeight.bold)),
                              subtitle: Text('মারা গেছে: ${item.mortality} টি  |  ফিড: ${item.feedKg} কেজি\nমোট খরচ: ৳${item.feedCost + item.medicineCost + item.otherCost}'),
                              trailing: item.note.isNotEmpty ? Tooltip(message: item.note, child: const Icon(Icons.info_outline, color: AgroTheme.primaryGreen)) : null,
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
          ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: schedules.length,
            itemBuilder: (ctx, i) {
              final v = schedules[i];
              final isPassed = currentAge > v.day;
              final isToday = currentAge == v.day;

              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                decoration: BoxDecoration(
                  color: isToday ? AgroTheme.accentGreen.withOpacity(0.12) : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: isToday ? AgroTheme.accentGreen : AgroTheme.subtleBorder),
                ),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: isToday ? AgroTheme.accentGreen : (isPassed ? Colors.grey : AgroTheme.primaryGreen),
                    child: Text('${v.day}d', style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                  ),
                  title: Text(v.name, style: TextStyle(fontWeight: FontWeight.bold, color: isPassed ? Colors.grey : AgroTheme.darkCharcoal)),
                  subtitle: Text('নিয়ম: ${v.route}\nপরামর্শ: ${v.note}'),
                  trailing: isPassed
                      ? const Icon(Icons.check_circle, color: AgroTheme.accentGreen)
                      : (isToday ? const Chip(label: Text('আজকে দিন', style: TextStyle(color: Colors.white, fontSize: 11)), backgroundColor: AgroTheme.accentGreen) : null),
                ),
              );
            },
          ),
          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: AgroTheme.subtleBorder)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('📊 সামগ্রিক ব্যাচ পারফর্মেন্স', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AgroTheme.primaryGreen)),
                      const Divider(height: 24),
                      _buildDataRow('মোট বাচ্চা তোলা:', '${widget.shed.chickCount} টি'),
                      _buildDataRow('মোট মৃত্যু (Mortality):', '$totalDead টি (${mortalityRate.toStringAsFixed(1)}%)'),
                      _buildDataRow('মোট ফিড খাওয়া হয়েছে:', '${totalFeedKg.toStringAsFixed(1)} কেজি'),
                      _buildDataRow('মোট খরচ হয়েছে:', '৳ ${totalExpense.toStringAsFixed(0)}'),
                      if (widget.shed.isClosed) ...[
                        const Divider(height: 20),
                        _buildDataRow('মোট বিক্রয়মূল্য:', '৳ ${totalRevenue.toStringAsFixed(0)}'),
                        _buildDataRow('FCR অনুপাত:', fcr.toStringAsFixed(2)),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('নীট ফলাফল:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                            Text(
                              profitOrLoss >= 0 ? '৳ ${profitOrLoss.toStringAsFixed(0)} (লাভ)' : '৳ ${profitOrLoss.abs().toStringAsFixed(0)} (ক্ষতি)',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: profitOrLoss >= 0 ? AgroTheme.primaryGreen : Colors.red),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                if (widget.shed.isClosed)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(color: AgroTheme.accentGreen.withOpacity(0.1), borderRadius: BorderRadius.circular(14), border: Border.all(color: AgroTheme.accentGreen)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('💡 ইঞ্জিনিয়ার্স এগ্রো ফিডব্যাক:', style: TextStyle(fontWeight: FontWeight.bold, color: AgroTheme.primaryGreen)),
                        const SizedBox(height: 4),
                        Text(fcr > 1.65 ? '• FCR কিছুটা বেশি। পরবর্তী ব্যাচে খাবারের অপচয় হ্রাস করার চেষ্টা করুন।' : '• দারুণ এফসিআর অর্জিত হয়েছে! আপনার খাদ্য ব্যবস্থাপনা চমৎকার ছিল।'),
                        Text(mortalityRate > 5 ? '• মৃত্যুর হার ৫% এর বেশি ছিল। বায়োসিকিউরিটি ও লিটার ব্যবস্থাপনা বাড়ান।' : '• বাচ্চার মৃত্যুর হার নিয়ন্ত্রণে ছিল।'),
                      ],
                    ),
                  ),
                const SizedBox(height: 20),
                if (!widget.shed.isClosed)
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(backgroundColor: AgroTheme.primaryGreen, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                      onPressed: _closeShedDialog,
                      icon: const Icon(Icons.check_circle_outline),
                      label: const Text('ব্যাচ সম্পন্ন ও বিক্রির হিসাব দিন', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: !widget.shed.isClosed
          ? FloatingActionButton(
              onPressed: _addDailyLogDialog,
              backgroundColor: AgroTheme.primaryGreen,
              child: const Icon(Icons.add, color: Colors.white),
            )
          : null,
    );
  }

  Widget _buildDataRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.black88)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold, color: AgroTheme.darkCharcoal)),
        ],
      ),
    );
  }
}
