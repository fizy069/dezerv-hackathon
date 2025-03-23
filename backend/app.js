const express = require('express');
const connectDB = require('./config/db');
require('dotenv').config();

const app = express();
const PORT = process.env.PORT || 3001;

const authRoutes = require('./routes/auth');
const tripRoutes = require('./routes/trip');
const transactionRoutes = require('./routes/transactions'); // Import the transaction routes

// Middleware
app.use(express.json());

// Connect to MongoDB
connectDB();

// Routes
app.use('/api/auth', authRoutes);
app.use('/api/trip', tripRoutes);
app.use('/api/transactions', transactionRoutes); // Use the transaction routes

// Basic route
app.get('/', (req, res) => {
    res.send('API is running');
});

// Export the app for Vercel
module.exports = app;

// Start the server if not in Vercel environment
if (require.main === module) {
    app.listen(PORT, () => {
        console.log(`Server running on port ${PORT}`);
    });
}
