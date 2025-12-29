import express from 'express';
import {
    getSessionAttendances,
    markAttendance,
    markBulkAttendance,
    getStudentHistory,
    getGlobalStats,
} from '../controllers/attendance.controller.js';
import { validateAttendance } from '../utils/validators.js';
import { authenticateToken } from '../middleware/auth.middleware.js';
import { body } from 'express-validator';
import { validate } from '../utils/validators.js';

const router = express.Router();

// All routes are protected
router.use(authenticateToken);

// Get all attendances for a session
router.get('/session/:sessionId', getSessionAttendances);

// Mark single attendance
router.post('/mark', validateAttendance, markAttendance);

// Mark multiple attendances at once
router.post(
    '/mark-bulk',
    [
        body('sessionId').isInt({ min: 1 }).withMessage('ID de session invalide'),
        body('attendances').isArray({ min: 1 }).withMessage('Liste de présences requise'),
        body('attendances.*.studentId').isInt({ min: 1 }).withMessage('ID d\'étudiant invalide'),
        body('attendances.*.status').isIn(['present', 'absent', 'justified']).withMessage('Statut invalide'),
        validate,
    ],
    markBulkAttendance
);

// Get student attendance history
router.get('/student/:studentId/history', getStudentHistory);

// Get global statistics
router.get('/stats', getGlobalStats); // Supports ?groupId=X&moduleId=X&startDate=X&endDate=X

export default router;
