import express from 'express';
import {
    getAllStudents,
    getStudentById,
    createStudent,
    updateStudent,
    deleteStudent,
} from '../controllers/students.controller.js';
import { validateStudent } from '../utils/validators.js';
import { authenticateToken } from '../middleware/auth.middleware.js';

const router = express.Router();

// All routes are protected
router.use(authenticateToken);

router.get('/', getAllStudents); // Supports ?groupId=X
router.get('/:id', getStudentById);
router.post('/', validateStudent, createStudent);
router.put('/:id', validateStudent, updateStudent);
router.delete('/:id', deleteStudent);

export default router;
