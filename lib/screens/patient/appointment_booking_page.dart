import 'package:flutter/material.dart';
import '../../services/api_service.dart';

class AppointmentBookingPage extends StatefulWidget {
  final dynamic doctor;
  const AppointmentBookingPage({super.key, required this.doctor});

  @override
  State<AppointmentBookingPage> createState() => _AppointmentBookingPageState();
}

class _AppointmentBookingPageState extends State<AppointmentBookingPage> {
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  final _descriptionController = TextEditingController();
  bool _isBooking = false;

  Future<void> _bookAppointment() async {
    if (_selectedDate == null || _selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يرجى اختيار التاريخ والوقت')),
      );
      return;
    }

    setState(() => _isBooking = true);
    try {
      final dateTime = DateTime(
        _selectedDate!.year,
        _selectedDate!.month,
        _selectedDate!.day,
        _selectedTime!.hour,
        _selectedTime!.minute,
      );

      await ApiService().createBooking(
        doctorId: widget.doctor['id'] ?? widget.doctor['_id'] ?? '',
        doctorName: widget.doctor['name'] ?? 'طبيب',
        date: dateTime.toIso8601String(),
        description: _descriptionController.text.trim(),
        price: widget.doctor['price'] ?? '',
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم حجز الموعد بنجاح')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('فشل الحجز: ${e.toString().replaceAll('Exception: ', '')}')),
        );
      }
    } finally {
      if (mounted) setState(() => _isBooking = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('حجز موعد')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text('حجز موعد مع د. ${widget.doctor['name'] ?? ''}',
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            if (widget.doctor['price'] != null)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('سعر الكشف: ${widget.doctor['price']}',
                        style: const TextStyle(
                            fontSize: 16,
                            color: Colors.green,
                            fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text('المكان: ${widget.doctor['workplaceType'] ?? 'عيادة'}',
                        style: const TextStyle(fontSize: 14)),
                    Text('العنوان: ${widget.doctor['governorate'] ?? ''} - ${widget.doctor['address'] ?? ''}',
                        style: const TextStyle(fontSize: 14)),
                  ],
                ),
              ),
              
            if (widget.doctor['bio'] != null && widget.doctor['bio'].isNotEmpty)
               Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Card(
                  color: Colors.grey.shade100,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      widget.doctor['bio'],
                      style: const TextStyle(fontSize: 14, fontStyle: FontStyle.italic),
                    ),
                  ),
                ),
              ),

            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 30)),
                      );
                      if (date != null) {
                        setState(() => _selectedDate = date);
                      }
                    },
                    icon: const Icon(Icons.calendar_today),
                    label: Text(_selectedDate == null
                        ? 'اختر التاريخ'
                        : '${_selectedDate!.year}-${_selectedDate!.month}-${_selectedDate!.day}'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      final time = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.now(),
                      );
                      if (time != null) {
                        setState(() => _selectedTime = time);
                      }
                    },
                    icon: const Icon(Icons.access_time),
                    label: Text(_selectedTime == null
                        ? 'اختر الوقت'
                        : _selectedTime!.format(context)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'وصف الشكوى',
                hintText: 'اكتب تفاصيل الأعراض...',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: _isBooking
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: _bookAppointment,
                      child: const Text('تأكيد الحجز'),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}