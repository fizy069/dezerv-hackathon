const express = require('express');
const connectDB = require('./config/db');
require('dotenv').config();

const app = express();
const port = process.env.PORT || 3000;

const authRoutes = require('./routes/auth');
const tripRoutes = require('./routes/trip');

// Middleware
app.use(express.json());

// Connect to MongoDB
connectDB();

// Routes
app.use('/api/auth', authRoutes);
app.use('/api/trip', tripRoutes);

// Basic route
app.get('/', (req, res) => {
    res.send('API is running');
});

// Export the app for Vercel
module.exports = app;

// Start the server if not in Vercel environment
if (require.main === module) {
    app.listen(port, () => {
        console.log(`Server is running on port ${port}`);
    });
}
