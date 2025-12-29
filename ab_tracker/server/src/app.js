import express from 'express';
import cors from 'cors';
import morgan from 'morgan';
import authRoutes from './routes/auth.routes.js';
import groupsRoutes from './routes/groups.routes.js';
import studentsRoutes from './routes/students.routes.js';
import modulesRoutes from './routes/modules.routes.js';
import sessionsRoutes from './routes/sessions.routes.js';
import attendanceRoutes from './routes/attendance.routes.js';
import { errorHandler, notFound } from './middleware/error.middleware.js';

const app = express();

// Middleware
app.use(cors()); // Enable CORS for Flutter app
app.use(express.json()); // Parse JSON bodies
app.use(express.urlencoded({ extended: true })); // Parse URL-encoded bodies
app.use(morgan('dev')); // HTTP request logger

// Health check
app.get('/', (req, res) => {
    res.json({
        message: 'API Absence Tracker ENIAD - Bienvenue!',
        version: '1.0.0',
        endpoints: {
            auth: '/api/auth',
            groups: '/api/groups',
            students: '/api/students',
            modules: '/api/modules',
            sessions: '/api/sessions',
            attendance: '/api/attendance',
        },
    });
});

app.get('/health', (req, res) => {
    res.json({ status: 'OK', timestamp: new Date().toISOString() });
});

// API Routes
app.use('/api/auth', authRoutes);
app.use('/api/groups', groupsRoutes);
app.use('/api/students', studentsRoutes);
app.use('/api/modules', modulesRoutes);
app.use('/api/sessions', sessionsRoutes);
app.use('/api/attendance', attendanceRoutes);

// Error handling
app.use(notFound); // 404 handler
app.use(errorHandler); // Global error handler

export default app;
