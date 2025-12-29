import express from 'express';
import {
    login,
    register,
    getMe,
} from '../controllers/auth.controller.js';
import { validateLogin, validateRegister } from '../utils/validators.js';
import { authenticateToken } from '../middleware/auth.middleware.js';

const router = express.Router();

// Public routes
router.post('/login', validateLogin, login);
router.post('/register', validateRegister, register);

// Protected routes
router.get('/me', authenticateToken, getMe);

export default router;
