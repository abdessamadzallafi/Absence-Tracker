import bcrypt from 'bcryptjs';
import jwt from 'jsonwebtoken';
import prisma from '../config/prisma.js';

// Login
export const login = async (req, res, next) => {
    try {
        const { username, password } = req.body;

        console.log(username);
        console.log(password);
        // Rechercher le professeur
        const professor = await prisma.professor.findUnique({
            where: { username },
        });

        if (!professor) {
            return res.status(401).json({ error: 'Identifiants invalides' });
        }

        // Vérifier le mot de passe
        const isPasswordValid = await bcrypt.compare(password, professor.password);
        if (!isPasswordValid) {
            return res.status(401).json({ error: 'Identifiants invalides' });
        }

        // Créer le token JWT
        const token = jwt.sign(
            {
                id: professor.id,
                username: professor.username,
                email: professor.email,
            },
            process.env.JWT_SECRET,
            { expiresIn: '7d' }
        );

        res.json({
            message: 'Connexion réussie',
            token,
            user: {
                id: professor.id,
                username: professor.username,
                firstName: professor.firstName,
                lastName: professor.lastName,
                email: professor.email,
            },
        });
    } catch (error) {
        next(error);
    }
};

// Register (optionnel - pour créer un compte)
export const register = async (req, res, next) => {
    try {
        const { username, password, firstName, lastName, email } = req.body;

        // Hasher le mot de passe
        const hashedPassword = await bcrypt.hash(password, 10);

        // Créer le professeur
        const professor = await prisma.professor.create({
            data: {
                username,
                password: hashedPassword,
                firstName,
                lastName,
                email,
            },
        });

        res.status(201).json({
            message: 'Compte créé avec succès',
            user: {
                id: professor.id,
                username: professor.username,
                firstName: professor.firstName,
                lastName: professor.lastName,
                email: professor.email,
            },
        });
    } catch (error) {
        next(error);
    }
};

// Get current user info
export const getMe = async (req, res, next) => {
    try {
        const professor = await prisma.professor.findUnique({
            where: { id: req.user.id },
            select: {
                id: true,
                username: true,
                firstName: true,
                lastName: true,
                email: true,
                createdAt: true,
            },
        });

        res.json(professor);
    } catch (error) {
        next(error);
    }
};
