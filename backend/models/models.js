const mongoose = require('mongoose');

// User Schema (unified for Patient, Doctor, and Admin)
const UserSchema = new mongoose.Schema({
  name: {
    type: String,
    required: true,
    trim: true
  },
  email: {
    type: String,
    required: true,
    unique: true,
    lowercase: true,
    trim: true
  },
  password: {
    type: String,
    required: true
  },
  role: {
    type: String,
    enum: ['patient', 'doctor', 'admin'],
    default: 'patient'
  },
  
  // Doctor-specific fields
  specialty: {
    type: String,
    default: ''
  },
  bio: {
    type: String,
    default: ''
  },
  price: {
    type: String,
    default: ''
  },
  workplaceType: {
    type: String,
    default: 'عيادة'
  },
  governorate: {
    type: String,
    default: ''
  },
  address: {
    type: String,
    default: ''
  },

  // Patient-specific fields
  age: {
    type: String,
    default: ''
  },
  painLocation: {
    type: String,
    default: ''
  },
  description: {
    type: String,
    default: ''
  },

  // Completion flag
  profileCompleted: {
    type: Boolean,
    default: false
  },
  createdAt: {
    type: Date,
    default: Date.now
  }
});

// Specialty Schema
const SpecialtySchema = new mongoose.Schema({
  name: {
    type: String,
    required: true,
    unique: true,
    trim: true
  }
});

// Booking Schema
const BookingSchema = new mongoose.Schema({
  doctorId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true
  },
  doctorName: {
    type: String,
    required: true
  },
  patientId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true
  },
  patientName: {
    type: String,
    required: true
  },
  patientEmail: {
    type: String,
    required: true
  },
  date: {
    type: Date,
    required: true
  },
  description: {
    type: String,
    default: ''
  },
  price: {
    type: String,
    default: ''
  },
  status: {
    type: String,
    enum: ['pending', 'confirmed', 'cancelled'],
    default: 'pending'
  },
  createdAt: {
    type: Date,
    default: Date.now
  }
});

const User = mongoose.model('User', UserSchema);
const Specialty = mongoose.model('Specialty', SpecialtySchema);
const Booking = mongoose.model('Booking', BookingSchema);

module.exports = { User, Specialty, Booking };
