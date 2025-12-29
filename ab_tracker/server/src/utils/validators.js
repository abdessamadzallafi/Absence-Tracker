import { body, param, query, validationResult } from 'express-validator';

// Middleware pour vérifier les résultats de validation
export const validate = (req, res, next) => {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
        return res.status(400).json({ errors: errors.array() });
    }
    next();
};

// Validateurs pour les groupes
export const validateGroup = [
    body('name').trim().notEmpty().withMessage('Le nom du groupe est requis'),
    body('filiere').trim().notEmpty().withMessage('La filière est requise'),
    validate,
];

// Validateurs pour les étudiants
export const validateStudent = [
    body('groupId').isInt({ min: 1 }).withMessage('ID de groupe invalide'),
    body('massar').trim().notEmpty().withMessage('Le numéro MASSAR est requis'),
    body('firstName').trim().notEmpty().withMessage('Le prénom est requis'),
    body('lastName').trim().notEmpty().withMessage('Le nom est requis'),
    body('email').optional().isEmail().withMessage('Email invalide'),
    validate,
];

// Validateurs pour les modules
export const validateModule = [
    body('name').trim().notEmpty().withMessage('Le nom du module est requis'),
    body('semester').trim().notEmpty().withMessage('Le semestre est requis'),
    body('groupId').isInt({ min: 1 }).withMessage('ID de groupe invalide'),
    validate,
];

// Validateurs pour les sessions
export const validateSession = [
    body('moduleId').isInt({ min: 1 }).withMessage('ID de module invalide'),
    body('date').isISO8601().withMessage('Date invalide (format ISO8601 requis)'),
    body('time').matches(/^([0-1]?[0-9]|2[0-3]):[0-5][0-9]$/).withMessage('Heure invalide (format HH:mm)'),
    body('type').isIn(['cours', 'td', 'tp']).withMessage('Type invalide (cours, td, ou tp)'),
    validate,
];

// Validateurs pour les présences
export const validateAttendance = [
    body('sessionId').isInt({ min: 1 }).withMessage('ID de session invalide'),
    body('studentId').isInt({ min: 1 }).withMessage('ID d\'étudiant invalide'),
    body('status').isIn(['present', 'absent', 'justified']).withMessage('Statut invalide'),
    validate,
];

// Validateur pour l'authentification
export const validateLogin = [
    body('username').trim().notEmpty().withMessage('Le nom d\'utilisateur est requis'),
    body('password').notEmpty().withMessage('Le mot de passe est requis'),
    validate,
];

export const validateRegister = [
    body('username').trim().notEmpty().isLength({ min: 3 }).withMessage('Le nom d\'utilisateur doit contenir au moins 3 caractères'),
    body('password').isLength({ min: 6 }).withMessage('Le mot de passe doit contenir au moins 6 caractères'),
    body('firstName').trim().notEmpty().withMessage('Le prénom est requis'),
    body('lastName').trim().notEmpty().withMessage('Le nom est requis'),
    body('email').isEmail().withMessage('Email invalide'),
    validate,
];
