// src/controllers/auth.controller.js
import admin from "../config/firebase.js";
import User from "../models/user.model.js";
import jwt from "jsonwebtoken";

export const verifyOtp = async (req, res) => {
  try {
    const { idToken } = req.body;

    const decoded = await admin.auth().verifyIdToken(idToken);

    const phone = decoded.phone_number;
    const firebaseUid = decoded.uid;

    let user = await User.findOne({ phone });

    if (!user) {
      user = await User.create({ phone, firebaseUid });
    }

    const token = jwt.sign(
      { userId: user._id },
      process.env.JWT_SECRET,
      { expiresIn: "7d" }
    );

    res.json({
      success: true,
      token,
      user,
    });
  } catch (err) {
    res.status(401).json({ error: "Invalid token" });
  }
};