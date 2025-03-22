const mongoose = require("mongoose");

// Reports Schema
const ReportSchema = new mongoose.Schema({
  userId: { type: mongoose.Schema.Types.ObjectId, ref: "User", required: true },
  totalExpenses: { type: Number, default: 0 },
  totalIncome: { type: Number, default: 0 },
  savings: { type: Number, default: 0 }, // totalIncome - totalExpenses
  period: { type: String, required: true }, // e.g., "March 2024"
  createdAt: { type: Date, default: Date.now }
});

const Report = mongoose.model("Report", ReportSchema);

module.exports = Report;
