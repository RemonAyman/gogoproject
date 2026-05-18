require('dotenv').config();
const express = require('express');
const mongoose = require('mongoose');
const cors = require('cors');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');

const { User, Specialty, Booking } = require('./models/models');
const { auth, adminOnly, doctorOnly } = require('./middleware/auth');

const app = express();
const PORT = process.env.PORT || 3000;

// Middleware
app.use(cors());
app.use(express.json());

// MongoDB Connection
mongoose.connect(process.env.MONGODB_URI)
  .then(() => {
    console.log('Successfully connected to MongoDB Atlas.');
    seedDatabase();
  })
  .catch(err => {
    console.error('MongoDB connection error:', err);
  });

// --- SEED DATABASE ---
async function seedDatabase() {
  try {
    // 1. Seed Admin
    const adminEmail = 'admin@docline.com';
    const adminExists = await User.findOne({ email: adminEmail });
    if (!adminExists) {
      const hashedPassword = await bcrypt.hash('admin123', 10);
      await User.create({
        name: 'System Admin',
        email: adminEmail,
        password: hashedPassword,
        role: 'admin',
        profileCompleted: true
      });
      console.log('Seeded default Admin: admin@docline.com / admin123');
    }

    // 2. Seed Specialties (Delete old English ones, seed Arabic)
    await Specialty.deleteMany({});
    const defaultSpecialties = [
      'أخصائي قلب',
      'أخصائي جلدية',
      'أخصائي أسنان',
      'أخصائي أطفال',
      'أخصائي مخ وأعصاب',
      'أخصائي عظام',
      'أخصائي عيون',
      'أخصائي نساء وتوليد',
      'أخصائي أنف وأذن وحنجرة',
      'أخصائي باطنة',
      'أخصائي جراحة عامة',
      'أخصائي مسالك بولية',
      'أخصائي نفسية وعصبية',
      'أخصائي علاج طبيعي'
    ];

    for (const specName of defaultSpecialties) {
      await Specialty.create({ name: specName });
    }
    console.log('Seeded default Arabic medical specialties.');

    // 3. Seed Sample Doctors
    // Clean old demo/docline emails
    await User.deleteMany({ 
      email: { 
        $in: [
          'doctor_d1@demo.com', 
          'doctor_d2@demo.com', 
          'doctor_d3@demo.com', 
          'doctor_d4@demo.com',
          'doctor.ahmed@docline.com',
          'doctor.sara@docline.com',
          'doctor.youssef@docline.com',
          'doctor.mona@docline.com',
          'doctor.ali@docline.com',
          'doctor.mohamed@docline.com',
          'doctor.ahmed@docline.com',
          'doctor.menna@docline.com'
        ] 
      } 
    });

    const doctorPassword = await bcrypt.hash('doctor123', 10);
    const sampleDoctors = [
      {
        name: 'د. علي عبد الرحمن',
        email: 'doctor.ali@gmail.com',
        password: doctorPassword,
        role: 'doctor',
        specialty: 'أخصائي قلب',
        price: '350 EGP',
        bio: 'أخصائي أمراض القلب والأوعية الدموية.\nخبرة ١٢ عاماً.\nرسم قلب متقدم وقسطرة.',
        workplaceType: 'عيادة',
        governorate: 'القاهرة',
        address: 'ميدان التحرير، وسط البلد',
        profileCompleted: true
      },
      {
        name: 'د. محمد يامن',
        email: 'doctor.mohamed@gmail.com',
        password: doctorPassword,
        role: 'doctor',
        specialty: 'أخصائي جلدية',
        price: '300 EGP',
        bio: 'أخصائي الجلدية والتجميل والليزر.\nعلاج كافة الأمراض الجلدية بأحدث التقنيات.',
        workplaceType: 'عيادة',
        governorate: 'الجيزة',
        address: 'شارع الهرم، أمام سبورتنج',
        profileCompleted: true
      },
      {
        name: 'د. أحمد أيمن',
        email: 'doctor.ahmed@gmail.com',
        password: doctorPassword,
        role: 'doctor',
        specialty: 'أخصائي أسنان',
        price: '250 EGP',
        bio: 'أخصائي طب وجراحة الفم والأسنان.\nحشو عصب وتجميل الأسنان بدون ألم.',
        workplaceType: 'عيادة',
        governorate: 'الأسكندرية',
        address: 'شارع أبو قير، جليم',
        profileCompleted: true
      },
      {
        name: 'د. منة الله أحمد',
        email: 'doctor.menna@gmail.com',
        password: doctorPassword,
        role: 'doctor',
        specialty: 'أخصائي أطفال',
        price: '280 EGP',
        bio: 'أخصائية طب الأطفال وحديثي الولادة.\nمتابعة نمو الطفل والتغذية السليمة.',
        workplaceType: 'مستشفى',
        governorate: 'القليوبية',
        address: 'بنها الجديدة، أمام المحكمة',
        profileCompleted: true
      }
    ];

    for (const doc of sampleDoctors) {
      const exists = await User.findOne({ email: doc.email });
      if (!exists) {
        await User.create(doc);
        console.log(`Seeded Arabic doctor: ${doc.name} (${doc.email})`);
      }
    }
  } catch (error) {
    console.error('Seeding database error:', error);
  }
}

// --- REST API ENDPOINTS ---

// 1. Unified Auth Endpoints

// Patient Register
app.post('/api/auth/register', async (req, res) => {
  try {
    const { name, email, password } = req.body;
    if (!name || !email || !password) {
      return res.status(400).json({ message: 'الرجاء ملء جميع الحقول المطلوبة' });
    }

    const emailExists = await User.findOne({ email });
    if (emailExists) {
      return res.status(400).json({ message: 'هذا البريد الإلكتروني مسجل بالفعل' });
    }

    const hashedPassword = await bcrypt.hash(password, 10);
    const newUser = await User.create({
      name,
      email,
      password: hashedPassword,
      role: 'patient'
    });

    const token = jwt.sign(
      { id: newUser._id, role: newUser.role },
      process.env.JWT_SECRET || 'supersecretjwtkey12345'
    );

    res.status(201).json({
      token,
      user: {
        id: newUser._id,
        name: newUser.name,
        email: newUser.email,
        role: newUser.role,
        profileCompleted: newUser.profileCompleted
      }
    });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Unified Login (Patient, Doctor, Admin)
app.post('/api/auth/login', async (req, res) => {
  try {
    const { email, password } = req.body;
    if (!email || !password) {
      return res.status(400).json({ message: 'الرجاء إدخال البريد الإلكتروني وكلمة المرور' });
    }

    const user = await User.findOne({ email });
    if (!user) {
      return res.status(400).json({ message: 'البريد الإلكتروني أو كلمة المرور غير صحيحة' });
    }

    const isMatch = await bcrypt.compare(password, user.password);
    if (!isMatch) {
      return res.status(400).json({ message: 'البريد الإلكتروني أو كلمة المرور غير صحيحة' });
    }

    const token = jwt.sign(
      { id: user._id, role: user.role },
      process.env.JWT_SECRET || 'supersecretjwtkey12345'
    );

    res.json({
      token,
      user: {
        id: user._id,
        name: user.name,
        email: user.email,
        role: user.role,
        profileCompleted: user.profileCompleted
      }
    });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Get current user info
app.get('/api/auth/me', auth, async (req, res) => {
  try {
    const user = await User.findById(req.user.id).select('-password');
    if (!user) return res.status(404).json({ message: 'User not found' });
    res.json(user);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Complete patient profile details
app.post('/api/auth/complete-profile', auth, async (req, res) => {
  try {
    const { age, painLocation, description } = req.body;
    const updatedUser = await User.findByIdAndUpdate(
      req.user.id,
      {
        age,
        painLocation,
        description,
        profileCompleted: true
      },
      { new: true }
    ).select('-password');

    res.json(updatedUser);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Edit doctor profile details
app.post('/api/auth/edit-profile', auth, async (req, res) => {
  try {
    const { name, specialty, price, bio, workplaceType, governorate, address } = req.body;
    const updatedUser = await User.findByIdAndUpdate(
      req.user.id,
      {
        name,
        specialty,
        price,
        bio,
        workplaceType,
        governorate,
        address,
        profileCompleted: true
      },
      { new: true }
    ).select('-password');

    res.json(updatedUser);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// 2. Specialty Endpoints

// Get all specialties
app.get('/api/specialties', async (req, res) => {
  try {
    const specialties = await Specialty.find({});
    res.json(specialties);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Create specialty (Admin only)
app.post('/api/specialties', auth, adminOnly, async (req, res) => {
  try {
    const { name } = req.body;
    if (!name) return res.status(400).json({ message: 'Specialty name required' });

    const exists = await Specialty.findOne({ name });
    if (exists) return res.status(400).json({ message: 'Specialty already exists' });

    const newSpec = await Specialty.create({ name });
    res.status(201).json(newSpec);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// 3. Doctor Endpoints

// Get doctors (optionally filtered by specialty)
app.get('/api/doctors', async (req, res) => {
  try {
    const { specialty } = req.query;
    let query = { role: 'doctor' };
    if (specialty) {
      query.specialty = specialty;
    }
    const doctors = await User.find(query).select('-password');
    res.json(doctors);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// 4. Admin Management Endpoints

// Admin creates/registers a Doctor account
app.post('/api/admin/doctors', auth, adminOnly, async (req, res) => {
  try {
    const { name, email, password, specialty, price, bio, workplaceType, governorate, address } = req.body;
    if (!name || !email || !password || !specialty) {
      return res.status(400).json({ message: 'الرجاء إدخال الاسم، البريد الإلكتروني، الباسورد، والتخصص للطبيب' });
    }

    const emailExists = await User.findOne({ email });
    if (emailExists) {
      return res.status(400).json({ message: 'هذا البريد الإلكتروني مسجل بالفعل لمستخدم آخر' });
    }

    const hashedPassword = await bcrypt.hash(password, 10);
    const newDoctor = await User.create({
      name,
      email,
      password: hashedPassword,
      role: 'doctor',
      specialty,
      price: price || '300 EGP',
      bio: bio || '',
      workplaceType: workplaceType || 'عيادة',
      governorate: governorate || '',
      address: address || '',
      profileCompleted: true
    });

    res.status(201).json({
      message: 'تم إضافة الطبيب بنجاح',
      doctor: {
        id: newDoctor._id,
        name: newDoctor.name,
        email: newDoctor.email,
        specialty: newDoctor.specialty
      }
    });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Admin views all booking requests
app.get('/api/admin/bookings', auth, adminOnly, async (req, res) => {
  try {
    const bookings = await Booking.find({}).sort({ createdAt: -1 });
    res.json(bookings);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// 5. Booking Endpoints

// Patient requests/creates a booking
app.post('/api/bookings', auth, async (req, res) => {
  try {
    const { doctorId, doctorName, date, description, price } = req.body;
    if (!doctorId || !doctorName || !date) {
      return res.status(400).json({ message: 'الرجاء تحديد الطبيب وتاريخ الحجز' });
    }

    const patient = await User.findById(req.user.id);
    if (!patient) return res.status(404).json({ message: 'Patient not found' });

    const newBooking = await Booking.create({
      doctorId,
      doctorName,
      patientId: patient._id,
      patientName: patient.name,
      patientEmail: patient.email,
      date: new Date(date),
      description: description || '',
      price: price || '',
      status: 'pending'
    });

    res.status(201).json(newBooking);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Patient fetches their bookings
app.get('/api/bookings/patient', auth, async (req, res) => {
  try {
    const bookings = await Booking.find({ patientId: req.user.id }).sort({ date: -1 });
    res.json(bookings);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Doctor fetches their appointments
app.get('/api/bookings/doctor', auth, doctorOnly, async (req, res) => {
  try {
    const bookings = await Booking.find({ doctorId: req.user.id }).sort({ date: -1 });
    res.json(bookings);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Doctor accepts/rejects (updates status) booking request
app.put('/api/bookings/:id/status', auth, doctorOnly, async (req, res) => {
  try {
    const { status } = req.body;
    if (!['confirmed', 'cancelled'].includes(status)) {
      return res.status(400).json({ message: 'حالة غير صالحة. اختر مؤكد أو ملغي' });
    }

    const booking = await Booking.findById(req.params.id);
    if (!booking) return res.status(404).json({ message: 'Appointment not found' });

    if (booking.doctorId.toString() !== req.user.id) {
      return res.status(403).json({ message: 'Unauthorized update' });
    }

    booking.status = status;
    await booking.save();
    res.json(booking);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Listen on all interfaces
app.listen(PORT, '0.0.0.0', () => {
  console.log(`Clinic Booking System Backend listening on port ${PORT}`);
});
