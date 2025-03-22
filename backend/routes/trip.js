const express = require('express');
const router = express.Router();
const Trip = require('../models/trip');
const User = require('../models/user');

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
    const { name, userIds } = req.body;

    try {
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
    const { userId, amount, description, date } = req.body;

    try {
        const trip = await Trip.findById(tripId);
        if (!trip) {
            return res.status(404).json({ msg: 'Trip not found' });
        }

        const transaction = {
            userId,
            amount,
            description,
            date
        };

        trip.transactions.push(transaction);
        await trip.save();

        res.json(trip);
    } catch (err) {
        console.error(err.message);
        res.status(500).send('Server error');
    }
});

// Get all trips for a user
router.post('/user-trips', async (req, res) => {
    const { email } = req.body;

    try {
        // First find the user by email
        const user = await User.findOne({ email });
        if (!user) {
            return res.status(404).json({ msg: 'User not found' });
        }

        // Find all trips where the user's ID is in the users array
        const trips = await Trip.find({ users: user._id })
            .populate('users', '-passwordHash') // Populate user details except password
            .populate('transactions.userId', '-passwordHash'); // Populate transaction user details

        res.json(trips);
    } catch (err) {
        console.error(err.message);
        res.status(500).send('Server error');
    }
});

module.exports = router;
