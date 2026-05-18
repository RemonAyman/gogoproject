const jwt = require('jsonwebtoken');

const auth = (req, res, next) => {
  try {
    const header = req.header('Authorization');
    if (!header) {
      return res.status(401).json({ message: 'No authorization token, access denied.' });
    }

    const token = header.replace('Bearer ', '');
    if (!token) {
      return res.status(401).json({ message: 'Token is empty, access denied.' });
    }

    const verified = jwt.verify(token, process.env.JWT_SECRET || 'supersecretjwtkey12345');
    if (!verified) {
      return res.status(401).json({ message: 'Token verification failed, access denied.' });
    }

    req.user = verified; // { id, role }
    next();
  } catch (err) {
    res.status(401).json({ error: err.message });
  }
};

const adminOnly = (req, res, next) => {
  if (req.user && req.user.role === 'admin') {
    next();
  } else {
    res.status(403).json({ message: 'Access denied: Admin only.' });
  }
};

const doctorOnly = (req, res, next) => {
  if (req.user && req.user.role === 'doctor') {
    next();
  } else {
    res.status(403).json({ message: 'Access denied: Doctor only.' });
  }
};

module.exports = { auth, adminOnly, doctorOnly };
