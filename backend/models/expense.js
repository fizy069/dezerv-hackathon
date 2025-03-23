const mongoose = require("mongoose");

// Expense Schema (Auto-tracked from SMS)
const ExpenseSchema = new mongoose.Schema({
  userId: { type: mongoose.Schema.Types.ObjectId, ref: "User", required: true },
  amount: { type: Number, required: true },
  category: { type: String, required: true },
  description: { type: String },
  paymentMethod: { type: String },
  transactionId: { type: String, unique: true },
  bankName: { type: String }, 
  
  date: {
    type: Date,
    default: Date.now()
  },
  
  createdAt: { type: Date, default: Date.now }
});

const Expense = mongoose.model("Expense", ExpenseSchema);

module.exports = Expense;
