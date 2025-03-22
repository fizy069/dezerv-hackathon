const mongoose = require("mongoose");

// Expense Schema (Auto-tracked from SMS)
const ExpenseSchema = new mongoose.Schema({
  userId: { type: mongoose.Schema.Types.ObjectId, ref: "User", required: true },
  amount: { type: Number, required: true },
  category: { type: String, required: true }, // e.g., Food, Travel, Shopping
  description: { type: String },
  paymentMethod: { type: String }, // e.g., UPI, Debit Card, Net Banking
  transactionId: { type: String, unique: true }, // Extracted from SMS
  bankName: { type: String }, // Extracted from SMS
  date: { type: Date, required: true },
  smsContent: { type: String }, // Raw SMS message for debugging
  createdAt: { type: Date, default: Date.now }
});

const Expense = mongoose.model("Expense", ExpenseSchema);

module.exports = Expense;
