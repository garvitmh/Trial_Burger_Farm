// src/routes/auth.routes.js
import express from "express";
import { verifyOtp } from "../controllers/auth.controller.js";

const router = express.Router();

router.post("/verify-otp", verifyOtp);

export default router;