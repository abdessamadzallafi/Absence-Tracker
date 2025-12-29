import express from 'express';
import {
    getAllModules,
    getModuleById,
    createModule,
    updateModule,
    deleteModule,
} from '../controllers/modules.controller.js';
import { validateModule } from '../utils/validators.js';
import { authenticateToken } from '../middleware/auth.middleware.js';

const router = express.Router();

// All routes are protected
router.use(authenticateToken);

router.get('/', getAllModules); // Supports ?groupId=X
router.get('/:id', getModuleById);
router.post('/', validateModule, createModule);
router.put('/:id', validateModule, updateModule);
router.delete('/:id', deleteModule);

export default router;
