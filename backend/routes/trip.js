const express = require('express');
const router = express.Router();
const Trip = require('../models/trip');
const User = require('../models/user');
const Transaction = require('../models/transaction'); 

// Get list of all users
router.get('/users', async (req, res) => {
    try {
        const users = await User.find().select('-passwordHash');
        res.json(users);
    } catch (err) {
        console.error(err.message);
        res.status(500).send('Server error');
    }
});

// Create a new trip
router.post('/create', async (req, res) => {
    const { name, emails } = req.body;

    try {
        const users = await User.find({ email: { $in: emails } });
        const userIds = users.map(user => user._id);

        const trip = new Trip({
            name,
            users: userIds
        });

        await trip.save();
        res.json(trip);
    } catch (err) {
        console.error(err.message);
        res.status(500).send('Server error');
    }
});

// Add a transaction to a trip
router.post('/:tripId/transaction', async (req, res) => {
    const { tripId } = req.params;
    const { email, amount, description, date } = req.body;

    try {
        const user = await User.findOne({ email });
        if (!user) {
            return res.status(404).json({ msg: 'User not found' });
        }

        const trip = await Trip.findById(tripId);
        if (!trip) {
            return res.status(404).json({ msg: 'Trip not found' });
        }

        const transaction = new Transaction({
            userId: user._id,
            amount,
            description,
            date
        });

        trip.transactions.push(transaction);
        await trip.save();

        res.json(trip);
    } catch (err) {
        console.error(err.message);
        res.status(500).send('Server error');
    }
});

// Get all trips for a user by email
router.post('/user-trips', async (req, res) => {
    const { email } = req.body;

    try {
        const user = await User.findOne({ email });
        if (!user) {
            return res.status(404).json({ msg: 'User not found' });
        }

        const trips = await Trip.find({ users: user._id }).populate('users', '-passwordHash').populate('transactions');
        res.json(trips);
    } catch (err) {
        console.error(err.message);
        res.status(500).send('Server error');
    }
});

router.post('/:tripId/balance', async (req, res) => {
    const { tripId } = req.params;
    const { email } = req.body;

    try {
        const user = await User.findOne({ email });
        if (!user) {
            return res.status(404).json({ msg: 'User not found' });
        }

        // Find trip and populate user details
        const trip = await Trip.findById(tripId)
            .populate('users', '-passwordHash')
            .populate('transactions');
        
        if (!trip) {
            return res.status(404).json({ msg: 'Trip not found' });
        }

        // Calculate total spent by each user
        const userSpends = {};
        trip.users.forEach(u => {
            userSpends[u._id.toString()] = 0;
        });

        // Sum up all transactions
        trip.transactions.forEach(transaction => {
            userSpends[transaction.userId.toString()] += transaction.amount;
        });

        // Calculate total spent in trip
        const totalSpent = Object.values(userSpends).reduce((sum, amount) => sum + amount, 0);
        
        // Calculate equal share per person
        const equalShare = totalSpent / trip.users.length;

        // Calculate balances
        const balances = [];
        trip.users.forEach(otherUser => {
            if (otherUser._id.toString() !== user._id.toString()) {
                const otherUserSpent = userSpends[otherUser._id.toString()];
                const currentUserSpent = userSpends[user._id.toString()];
                
                let amount = 0;
                if (currentUserSpent < equalShare && otherUserSpent > equalShare) {
                    // Current user needs to pay
                    amount = Math.min(
                        equalShare - currentUserSpent,
                        otherUserSpent - equalShare
                    );
                    balances.push({
                        user: {
                            _id: otherUser._id,
                            name: otherUser.name,
                            email: otherUser.email
                        },
                        amount: amount,
                        type: 'owe'
                    });
                } else if (currentUserSpent > equalShare && otherUserSpent < equalShare) {
                    // Current user needs to receive
                    amount = Math.min(
                        currentUserSpent - equalShare,
                        equalShare - otherUserSpent
                    );
                    balances.push({
                        user: {
                            _id: otherUser._id,
                            name: otherUser.name,
                            email: otherUser.email
                        },
                        amount: amount,
                        type: 'receive'
                    });
                }
            }
        });

        res.json({
            totalSpent,
            equalShare,
            userSpent: userSpends[user._id.toString()],
            balances
        });

    } catch (err) {
        console.error(err.message);
        res.status(500).send('Server error');
    }
});

module.exports = router;
