// src/app.js
import express from "express";
import cors from "cors";
import admin from "./config/firebase.js"; // ✅ ADD THIS
import authRoutes from "./routes/auth.routes.js";

const app = express();

app.use(cors());
app.use(express.json());

app.get("/firebase-test", async (req, res) => {
  try {
    await admin.auth().listUsers(1);
    res.json({ success: true, message: "Firebase connected" });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

app.use("/auth", authRoutes);

export default app;