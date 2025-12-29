import express from 'express';
import {
    getAllGroups,
    getGroupById,
    createGroup,
    updateGroup,
    deleteGroup,
} from '../controllers/groups.controller.js';
import { validateGroup } from '../utils/validators.js';
import { authenticateToken } from '../middleware/auth.middleware.js';

const router = express.Router();

// All routes are protected
router.use(authenticateToken);

router.get('/', getAllGroups);
router.get('/:id', getGroupById);
router.post('/', validateGroup, createGroup);
router.put('/:id', validateGroup, updateGroup);
router.delete('/:id', deleteGroup);

export default router;
