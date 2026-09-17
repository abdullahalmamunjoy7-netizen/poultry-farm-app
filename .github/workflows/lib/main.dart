import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const PoultryApp());
}

class PoultryApp extends StatelessWidget {
  const PoultryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'খামারি হিসাব',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.teal,
        useMaterial3: true,
        fontFamily: 'Roboto',
      ),
      home: const HomeScreen(),
    );
  }
}

// Model: Shed/Batch
class Shed {
  String id;
  String name;
  String birdType;
  int chickCount;
  double chickPrice;
  DateTime startDate;
  bool isClosed;
  // Sale details
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

// Model: Daily Entry
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

// Home Screen: শেডের তালিকা
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Shed> sheds = [];

  @override
  void initState() {
    super.initState();
    _loadSheds();
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

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDState) => AlertDialog(
          title: const Text('নতুন শেড / ব্যাচ যোগ করুন'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'শেডের নাম/নম্বর (যেমন: শেড-১)')),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  value: selectedType,
                  items: types.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                  onChanged: (val) => setDState(() => selectedType = val!),
                  decoration: const InputDecoration(labelText: 'পাখির ধরন'),
                ),
                TextField(controller: chickCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'বাচ্চার সংখ্যা')),
                TextField(controller: priceCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'প্রতি বাচ্চার দর (টাকা)')),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('বাতিল')),
            ElevatedButton(
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
              child: const Text('তৈরি করুন'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🐔 খামারি হিসাব ও ড্যাশবোর্ড'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: sheds.isEmpty
          ? const Center(
              child: Text(
                'কোনো শেড যুক্ত করা নেই!\nনিচের (+) বাটনে চাপ দিয়ে নতুন শেড খুলুন।',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            )
          : ListView.builder(
              itemCount: sheds.length,
              itemBuilder: (ctx, i) {
                final s = sheds[i];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  elevation: 3,
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: s.isClosed ? Colors.grey : Colors.teal,
                      child: Icon(s.isClosed ? Icons.done_all : Icons.pets, color: Colors.white),
                    ),
                    title: Text(s.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                    subtitle: Text('${s.birdType} | বাচ্চা: ${s.chickCount} টি\nশুরু: ${DateFormat('dd MMM yyyy').format(s.startDate)}'),
                    isThreeLine: true,
                    trailing: s.isClosed
                        ? const Chip(label: Text('সম্পন্ন', style: TextStyle(color: Colors.white)), backgroundColor: Colors.grey)
                        : const Chip(label: Text('চলমান', style: TextStyle(color: Colors.white)), backgroundColor: Colors.green),
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addShedDialog,
        backgroundColor: Colors.teal,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('নতুন শেড', style: TextStyle(color: Colors.white)),
      ),
    );
  }
}

// Shed Details & Daily Entry Screen
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
    _tabCtrl = TabController(length: 2, vsync: this);
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

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDState) => AlertDialog(
          title: const Text('দৈনিক হিসাব যুক্ত করুন'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  title: Text('তারিখ: ${DateFormat('dd MMM yyyy').format(selectedDate)}'),
                  trailing: const Icon(Icons.calendar_month),
                  onTap: () async {
                    final d = await showDatePicker(
                      context: context,
                      initialDate: selectedDate,
                      firstDate: widget.shed.startDate,
                      lastDate: DateTime.now().add(const Duration(days: 1)),
                    );
                    if (d != null) setDState(() => selectedDate = d);
                  },
                ),
                TextField(controller: deadCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'মারা গেছে (সংখ্যা)')),
                TextField(controller: feedKgCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'খাবার খাওয়া হয়েছে (কেজি)')),
                TextField(controller: feedCostCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'খাবারের খরচ (টাকা)')),
                TextField(controller: medCostCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'ঔষধ/ভ্যাকসিন খরচ (টাকা)')),
                if (widget.shed.birdType.contains('ডিম'))
                  TextField(controller: eggsCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'ডিম সংগ্রহ (টি)')),
                TextField(controller: otherCostCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'অন্যান্য খরচ (বিদ্যুৎ, তুষ ইত্যাদি)')),
                TextField(controller: noteCtrl, decoration: const InputDecoration(labelText: 'খরচের বিবরণ/নোট')),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('বাতিল')),
            ElevatedButton(
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
              child: const Text('সংরক্ষণ করুন'),
            ),
          ],
        ),
      ),
    );
  }

  void _closeShedDialog() {
    final soldBirdsCtrl = TextEditingController();
    final weightCtrl = TextEditingController();
    final rateCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('ব্যাচ সমাপ্তি ও বিক্রির হিসাব'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: soldBirdsCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'বিক্রিত মোট পাখি (টি)')),
            TextField(controller: weightCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'মোট বিক্রিত ওজন (কেজি)')),
            TextField(controller: rateCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'প্রতি কেজি বিক্রয়মূল্য (টাকা)')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('বাতিল')),
          ElevatedButton(
            onPressed: () {
              setState(() {
                widget.shed.soldBirds = int.tryParse(soldBirdsCtrl.text) ?? 0;
                widget.shed.soldWeight = double.tryParse(weightCtrl.text) ?? 0;
                widget.shed.saleRate = double.tryParse(rateCtrl.text) ?? 0;
                widget.shed.isClosed = true;
              });
              widget.onUpdate();
              Navigator.pop(ctx);
            },
            child: const Text('হিসাব সম্পন্ন করুন'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Calculators
    final totalDead = logs.fold<int>(0, (sum, item) => sum + item.mortality);
    final totalFeedKg = logs.fold<double>(0, (sum, item) => sum + item.feedKg);
    final totalFeedCost = logs.fold<double>(0, (sum, item) => sum + item.feedCost);
    final totalMedCost = logs.fold<double>(0, (sum, item) => sum + item.medicineCost);
    final totalOtherCost = logs.fold<double>(0, (sum, item) => sum + item.otherCost);
    final totalEggs = logs.fold<int>(0, (sum, item) => sum + item.eggs);

    final chickCost = widget.shed.chickCount * widget.shed.chickPrice;
    final totalExpense = chickCost + totalFeedCost + totalMedCost + totalOtherCost;
    final totalRevenue = widget.shed.soldWeight * widget.shed.saleRate;
    final profitOrLoss = totalRevenue - totalExpense;

    final double fcr = widget.shed.soldWeight > 0 ? (totalFeedKg / widget.shed.soldWeight) : 0;
    final double mortalityRate = widget.shed.chickCount > 0 ? (totalDead / widget.shed.chickCount) * 100 : 0;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.shed.name),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabCtrl,
          indicatorColor: Colors.amber,
          tabs: const [
            Tab(icon: Icon(Icons.calendar_today), text: 'দৈনিক এন্ট্রি'),
            Tab(icon: Icon(Icons.analytics), text: 'রিপোর্ট ও বিশ্লেষণ'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabCtrl,
        children: [
          // Tab 1: Logs List
          logs.isEmpty
              ? const Center(child: Text('এখনও কোনো দৈনিক হিসাব দেওয়া হয়নি।'))
              : ListView.builder(
                  itemCount: logs.length,
                  itemBuilder: (ctx, i) {
                    final item = logs[i];
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      child: ListTile(
                        title: Text(DateFormat('dd MMMM yyyy').format(item.date), style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text('মারা গেছে: ${item.mortality} টি | ফিড: ${item.feedKg} কেজি\nদৈনিক খরচ: ৳${item.feedCost + item.medicineCost + item.otherCost}'),
                        trailing: item.note.isNotEmpty ? Tooltip(message: item.note, child: const Icon(Icons.info_outline, color: Colors.teal)) : null,
                      ),
                    );
                  },
                ),

          // Tab 2: Full Analytics & Feedback
          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Card(
                  color: Colors.teal.shade50,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('📊 সামগ্রিক পরিস্থিতি', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.teal)),
                        const Divider(),
                        Text('মোট বাচ্চা: ${widget.shed.chickCount} টি'),
                        Text('মোট মারা গেছে: $totalDead টি (${mortalityRate.toStringAsFixed(1)}%)'),
                        Text('মোট খাদ্য খেয়েছে: ${totalFeedKg.toStringAsFixed(1)} কেজি'),
                        if (widget.shed.birdType.contains('ডিম')) Text('মোট সংগৃহীত ডিম: $totalEggs টি'),
                        const SizedBox(height: 8),
                        Text('মোট খরচ: ৳${totalExpense.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.bold)),
                        if (widget.shed.isClosed) ...[
                          Text('মোট বিক্রি: ৳${totalRevenue.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)),
                          Text(
                            profitOrLoss >= 0 ? 'নীট লাভ: ৳${profitOrLoss.toStringAsFixed(0)}' : 'ক্ষতি: ৳${profitOrLoss.abs().toStringAsFixed(0)}',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: profitOrLoss >= 0 ? Colors.green : Colors.red),
                          ),
                          Text('FCR (ফিড কনভার্শন রেট): ${fcr.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Smart Feedback Box
                Card(
                  color: Colors.amber.shade50,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.lightbulb, color: Colors.amber),
                            SizedBox(width: 8),
                            Text('💡 স্মার্ট পরামর্শ ও বিশ্লেষণ', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          ],
                        ),
                        const Divider(),
                        if (!widget.shed.isClosed)
                          const Text('ব্যাচটি এখনো চলমান রয়েছে। ব্যাচ বিক্রি সম্পন্ন করে নিচের "ব্যাচ শেষ ও বিক্রি হিসাব" বাটনে চাপুন।')
                        else ...[
                          if (fcr > 1.65)
                            const Text('⚠️ FCR বেশি এসেছে! এর মানে খাবারের তুলনায় ওজন কম হয়েছে। খাবার ছিটকে পড়া বন্ধ করুন বা ফিডের মান পরিবর্তন করুন।')
                          else if (fcr > 0)
                            const Text('✅ অসাধারণ FCR! আপনি খুবই দক্ষতার সাথে খাবারের ব্যবহার নিয়ন্ত্রণ করেছেন।'),
                          const SizedBox(height: 6),
                          if (mortalityRate > 5)
                            const Text('⚠️ বাচ্চার মৃত্যুর হার ৫% এর বেশি! খামারের বায়োসিকিউরিটি ও লিটার ব্যবস্থাপনা আরো জোরদার করা প্রয়োজন।')
                          else
                            const Text('✅ বাচ্চার মৃত্যুর হার স্বাভাবিক মাত্রার মধ্যে ছিল।'),
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                if (!widget.shed.isClosed)
                  Center(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.deepOrange, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12)),
                      onPressed: _closeShedDialog,
                      icon: const Icon(Icons.check_circle),
                      label: const Text('ব্যাচ শেষ ও বিক্রির হিসাব করুন'),
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
              backgroundColor: Colors.teal,
              child: const Icon(Icons.add, color: Colors.white),
            )
          : null,
    );
  }
}
