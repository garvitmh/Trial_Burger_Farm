// src/models/user.model.js
import mongoose from "mongoose";

const userSchema = new mongoose.Schema({
  phone: { type: String, required: true, unique: true },
  name: String,
  firebaseUid: String,
  createdAt: { type: Date, default: Date.now },
});

export default mongoose.model("User", userSchema);