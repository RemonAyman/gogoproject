import 'package:flutter/material.dart';
import '../../core/config/routes/routes.dart';
import '../../services/api_service.dart';

class SpecialtiesGridPage extends StatefulWidget {
  const SpecialtiesGridPage({super.key});

  @override
  State<SpecialtiesGridPage> createState() => _SpecialtiesGridPageState();
}

class _SpecialtiesGridPageState extends State<SpecialtiesGridPage> {
  final ApiService _apiService = ApiService();
  late Future<List<dynamic>> _specialtiesFuture;

  @override
  void initState() {
    super.initState();
    _specialtiesFuture = _apiService.getSpecialties();
  }

  void _refresh() {
    setState(() {
      _specialtiesFuture = _apiService.getSpecialties();
    });
  }

  IconData _getIconForSpecialty(String name) {
    name = name.toLowerCase();
    if (name.contains('cardio') || name.contains('قلب')) {
      return Icons.favorite;
    } else if (name.contains('dermato') || name.contains('جلد')) {
      return Icons.face;
    } else if (name.contains('dent') || name.contains('أسنان')) {
      return Icons.medical_services;
    } else if (name.contains('pediatr') || name.contains('أطفال')) {
      return Icons.child_care;
    } else if (name.contains('neuro') || name.contains('أعصاب') || name.contains('نفسية')) {
      return Icons.psychology;
    } else if (name.contains('ortho') || name.contains('عظام')) {
      return Icons.healing;
    } else if (name.contains('عيون')) {
      return Icons.remove_red_eye;
    } else if (name.contains('نساء') || name.contains('توليد')) {
      return Icons.pregnant_woman;
    } else if (name.contains('أنف') || name.contains('أذن')) {
      return Icons.hearing;
    } else if (name.contains('باطنة')) {
      return Icons.local_hospital;
    } else if (name.contains('جراحة')) {
      return Icons.content_cut;
    } else if (name.contains('مسالك')) {
      return Icons.water_drop;
    } else if (name.contains('علاج طبيعي')) {
      return Icons.accessibility_new;
    }
    return Icons.health_and_safety;
  }

  Color _getColorForSpecialty(String name) {
    name = name.toLowerCase();
    if (name.contains('cardio') || name.contains('قلب')) {
      return Colors.red.shade100;
    } else if (name.contains('dermato') || name.contains('جلد')) {
      return Colors.orange.shade100;
    } else if (name.contains('dent') || name.contains('أسنان')) {
      return Colors.blue.shade100;
    } else if (name.contains('pediatr') || name.contains('أطفال')) {
      return Colors.green.shade100;
    } else if (name.contains('neuro') || name.contains('أعصاب') || name.contains('نفسية')) {
      return Colors.purple.shade100;
    } else if (name.contains('ortho') || name.contains('عظام')) {
      return Colors.teal.shade100;
    } else if (name.contains('عيون')) {
      return Colors.cyan.shade100;
    } else if (name.contains('نساء') || name.contains('توليد')) {
      return Colors.pink.shade100;
    } else if (name.contains('أنف') || name.contains('أذن')) {
      return Colors.amber.shade100;
    } else if (name.contains('باطنة')) {
      return Colors.indigo.shade100;
    } else if (name.contains('جراحة')) {
      return Colors.red.shade100;
    } else if (name.contains('مسالك')) {
      return Colors.lightBlue.shade100;
    } else if (name.contains('علاج طبيعي')) {
      return Colors.lightGreen.shade100;
    }
    return Colors.teal.shade50;
  }

  Color _getIconColorForSpecialty(String name) {
    name = name.toLowerCase();
    if (name.contains('cardio') || name.contains('قلب')) {
      return Colors.red;
    } else if (name.contains('dermato') || name.contains('جلد')) {
      return Colors.orange.shade800;
    } else if (name.contains('dent') || name.contains('أسنان')) {
      return Colors.blue.shade800;
    } else if (name.contains('pediatr') || name.contains('أطفال')) {
      return Colors.green.shade800;
    } else if (name.contains('neuro') || name.contains('أعصاب') || name.contains('نفسية')) {
      return Colors.purple.shade800;
    } else if (name.contains('ortho') || name.contains('عظام')) {
      return Colors.teal.shade800;
    } else if (name.contains('عيون')) {
      return Colors.cyan.shade800;
    } else if (name.contains('نساء') || name.contains('توليد')) {
      return Colors.pink.shade800;
    } else if (name.contains('أنف') || name.contains('أذن')) {
      return Colors.amber.shade900;
    } else if (name.contains('باطنة')) {
      return Colors.indigo.shade800;
    } else if (name.contains('جراحة')) {
      return Colors.red.shade800;
    } else if (name.contains('مسالك')) {
      return Colors.lightBlue.shade800;
    } else if (name.contains('علاج طبيعي')) {
      return Colors.lightGreen.shade800;
    }
    return Colors.teal;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'التخصصات الطبية',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => Navigator.pushNamed(context, AppRoutes.settings),
          ),
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () => Navigator.pushNamed(context, AppRoutes.patientProfile),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              _apiService.logout();
              Navigator.pushNamedAndRemoveUntil(
                context,
                AppRoutes.login,
                (route) => false,
              );
            },
          ),
        ],
      ),
      body: FutureBuilder<List<dynamic>>(
        future: _specialtiesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 60, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    'فشل تحميل التخصصات: ${snapshot.error}',
                    style: const TextStyle(fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _refresh,
                    child: const Text('إعادة المحاولة'),
                  ),
                ],
              ),
            );
          }

          final specialties = snapshot.data ?? [];
          if (specialties.isEmpty) {
            return const Center(child: Text('لا يوجد تخصصات طبية متاحة حالياً'));
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Theme.of(context).primaryColor, Theme.of(context).primaryColor.withOpacity(0.8)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(24),
                    bottomRight: Radius.circular(24),
                  ),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'مرحباً بك في DocLine 👋',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'اختر التخصص الطبي المطلوب لحجز موعد مع نخبة من أفضل الأطباء',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
              const Padding(
                padding: EdgeInsets.only(left: 16.0, right: 16.0, top: 20.0, bottom: 10.0),
                child: Text(
                  'جميع التخصصات',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: GridView.builder(
                    itemCount: specialties.length,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 1.1,
                    ),
                    itemBuilder: (context, index) {
                      final specialty = specialties[index];
                      final name = specialty['name'] ?? '';
                      final icon = _getIconForSpecialty(name);
                      final bgColor = _getColorForSpecialty(name);
                      final iconColor = _getIconColorForSpecialty(name);

                      return GestureDetector(
                        onTap: () {
                          // Navigate to doctors list filtering by this specialty
                          Navigator.pushNamed(
                            context,
                            '/patient/doctors_list',
                            arguments: name,
                          );
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.15),
                                spreadRadius: 2,
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: bgColor,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  icon,
                                  size: 36,
                                  color: iconColor,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                name,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, AppRoutes.myAppointments);
        },
        tooltip: 'حجوزاتي',
        child: const Icon(Icons.calendar_month),
      ),
    );
  }
}
