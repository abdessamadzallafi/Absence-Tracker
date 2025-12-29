import 'dotenv/config';
import app from './src/app.js';
import prisma from './src/config/prisma.js';

const PORT = process.env.PORT || 3000;

// Graceful shutdown function
const gracefulShutdown = async () => {
    console.log('\n🔄 Shutting down gracefully...');
    await prisma.$disconnect();
    console.log('✅ Database connection closed');
    process.exit(0);
};

// Handle shutdown signals
process.on('SIGINT', gracefulShutdown);
process.on('SIGTERM', gracefulShutdown);

// Start server
// MODIFICATION ICI : Ajout de '0.0.0.0' pour écouter sur tout le réseau
const server = app.listen(PORT, '0.0.0.0', async () => {
    try {
        // Test database connection
        await prisma.$connect();
        console.log('✅ Database connected successfully');
        console.log(`🚀 Server running locally on http://localhost:${PORT}`);
        console.log(`📡 Accessible on network via your IP (e.g., http://192.168.x.x:${PORT})`);
        console.log(`📚 API Documentation: http://localhost:${PORT}/`);
        console.log(`❤️  Health check: http://localhost:${PORT}/health`);
    } catch (error) {
        console.error('❌ Failed to connect to database:', error);
        process.exit(1);
    }
});

// Handle server errors
server.on('error', (error) => {
    console.error('❌ Server error:', error);
    process.exit(1);
});