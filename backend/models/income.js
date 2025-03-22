const mongoose = require("mongoose");

// Income Schema
const IncomeSchema = new mongoose.Schema({
  userId: { type: mongoose.Schema.Types.ObjectId, ref: "User", required: true },
  amount: { type: Number, required: true },
  source: { type: String, required: true }, // Salary, Freelancing, Bonus
  description: { type: String },
  date: { type: Date, required: true },
  createdAt: { type: Date, default: Date.now }
});

const Income = mongoose.model("Income", IncomeSchema);

module.exports = Income;
