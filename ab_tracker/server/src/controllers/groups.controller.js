import prisma from '../config/prisma.js';

// Get all groups
export const getAllGroups = async (req, res, next) => {
    try {
        const groups = await prisma.group.findMany({
            include: {
                _count: {
                    select: { students: true, modules: true },
                },
            },
            orderBy: { name: 'asc' },
        });

        res.json(groups);
    } catch (error) {
        next(error);
    }
};

// Get group by ID
export const getGroupById = async (req, res, next) => {
    try {
        const { id } = req.params;
        const group = await prisma.group.findUnique({
            where: { id: parseInt(id) },
            include: {
                students: {
                    orderBy: { lastName: 'asc' },
                },
                modules: {
                    orderBy: { name: 'asc' },
                },
            },
        });

        if (!group) {
            return res.status(404).json({ error: 'Groupe non trouvé' });
        }

        res.json(group);
    } catch (error) {
        next(error);
    }
};

// Create group
export const createGroup = async (req, res, next) => {
    try {
        const { name, filiere } = req.body;

        const group = await prisma.group.create({
            data: { name, filiere },
        });

        res.status(201).json(group);
    } catch (error) {
        next(error);
    }
};

// Update group
export const updateGroup = async (req, res, next) => {
    try {
        const { id } = req.params;
        const { name, filiere } = req.body;

        const group = await prisma.group.update({
            where: { id: parseInt(id) },
            data: { name, filiere },
        });

        res.json(group);
    } catch (error) {
        next(error);
    }
};

// Delete group
export const deleteGroup = async (req, res, next) => {
    try {
        const { id } = req.params;

        await prisma.group.delete({
            where: { id: parseInt(id) },
        });

        res.json({ message: 'Groupe supprimé avec succès' });
    } catch (error) {
        next(error);
    }
};
