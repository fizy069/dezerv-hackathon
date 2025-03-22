const mongoose = require("mongoose");

// Trip Schema
const TripSchema = new mongoose.Schema({
  name: { type: String, required: true },
  users: [{ type: mongoose.Schema.Types.ObjectId, ref: "User", required: true }],
  transactions: [{
    userId: { type: mongoose.Schema.Types.ObjectId, ref: "User", required: true },
    amount: { type: Number, required: true },
    description: { type: String, required: true },
    date: { type: Date, required: true }
  }],
  createdAt: { type: Date, default: Date.now }
});

const Trip = mongoose.model("Trip", TripSchema);

module.exports = Trip;
