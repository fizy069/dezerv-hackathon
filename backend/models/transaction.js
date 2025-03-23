const mongoose = require('mongoose');
const Schema = mongoose.Schema;

const TransactionSchema = new Schema({
    userId: {
        type: Schema.Types.ObjectId,
        ref: 'User',
        required: true
    },
    amount: {
        type: Number,
        required: true
    },
    description: {
        type: String,
    },
    date: {
        type: Date,
        default: Date.now()
    }
});

module.exports = mongoose.model('Transaction', TransactionSchema);