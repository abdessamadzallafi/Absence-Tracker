import express from 'express';
import {
    getAllSessions,
    getSessionById,
    createSession,
    updateSession,
    deleteSession,
} from '../controllers/sessions.controller.js';
import { validateSession } from '../utils/validators.js';
import { authenticateToken } from '../middleware/auth.middleware.js';

const router = express.Router();

// All routes are protected
router.use(authenticateToken);

router.get('/', getAllSessions); // Supports ?moduleId=X
router.get('/:id', getSessionById);
router.post('/', validateSession, createSession);
router.put('/:id', validateSession, updateSession);
router.delete('/:id', deleteSession);

export default router;
