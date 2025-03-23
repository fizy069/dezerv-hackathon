const express = require('express');
const router = express.Router();
const User = require('../models/user');
const Expense = require('../models/expense');
const Income = require('../models/income');

// POST API for saving expense or income
router.post('/save', async (req, res) => {
    const { email, amount, description, type, category, paymentMethod, transactionId, bankName, source, date } = req.body;

    try {
        const user = await User.findOne({ email });
        if (!user) {
            return res.status(404).json({ msg: 'User not found' });
        }

        if (type === 'expense') {
            const expense = new Expense({
                userId: user._id,
                amount,
                category,
                description,
                paymentMethod,
                transactionId,
                bankName,
                date
            });
            await expense.save();
            res.json(expense);
        } else if (type === 'income') {
            const income = new Income({
                userId: user._id,
                amount,
                source,
                description,
                date
            });
            await income.save();
            res.json(income);
        } else {
            res.status(400).json({ msg: 'Invalid type' });
        }
    } catch (err) {
        console.error(err.message);
        res.status(500).send('Server error');
    }
});

// GET API for getting all transactions
router.post('/transactions', async (req, res) => {
    const { email } = req.body;

    try {
        const user = await User.findOne({ email });
        if (!user) {
            return res.status(404).json({ msg: 'User not found' });
        }

        const expenses = await Expense.find({ userId: user._id }).sort({ date: -1 });
        const incomes = await Income.find({ userId: user._id }).sort({ date: -1 });

        const transactions = [
            ...expenses.map(expense => ({ ...expense._doc, type: 'expense' })),
            ...incomes.map(income => ({ ...income._doc, type: 'income' }))
        ];

        transactions.sort((a, b) => new Date(b.date) - new Date(a.date));

        res.json(transactions);
    } catch (err) {
        console.error(err.message);
        res.status(500).send('Server error');
    }
});

module.exports = router;