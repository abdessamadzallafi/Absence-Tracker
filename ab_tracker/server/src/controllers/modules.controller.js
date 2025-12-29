import prisma from '../config/prisma.js';

// Get all modules (with optional filter by groupId)
export const getAllModules = async (req, res, next) => {
    try {
        const { groupId } = req.query;

        const where = groupId ? { groupId: parseInt(groupId) } : {};

        const modules = await prisma.module.findMany({
            where,
            include: {
                group: {
                    select: { id: true, name: true, filiere: true },
                },
                _count: {
                    select: { sessions: true },
                },
            },
            orderBy: { name: 'asc' },
        });

        res.json(modules);
    } catch (error) {
        next(error);
    }
};

// Get module by ID
export const getModuleById = async (req, res, next) => {
    try {
        const { id } = req.params;
        const module = await prisma.module.findUnique({
            where: { id: parseInt(id) },
            include: {
                group: true,
                sessions: {
                    orderBy: [{ date: 'desc' }, { time: 'desc' }],
                },
            },
        });

        if (!module) {
            return res.status(404).json({ error: 'Module non trouvé' });
        }

        res.json(module);
    } catch (error) {
        next(error);
    }
};

// Create module
export const createModule = async (req, res, next) => {
    try {
        const { name, semester, groupId } = req.body;

        const module = await prisma.module.create({
            data: {
                name,
                semester,
                groupId,
            },
            include: {
                group: true,
            },
        });

        res.status(201).json(module);
    } catch (error) {
        next(error);
    }
};

// Update module
export const updateModule = async (req, res, next) => {
    try {
        const { id } = req.params;
        const { name, semester, groupId } = req.body;

        const module = await prisma.module.update({
            where: { id: parseInt(id) },
            data: {
                name,
                semester,
                groupId,
            },
            include: {
                group: true,
            },
        });

        res.json(module);
    } catch (error) {
        next(error);
    }
};

// Delete module
export const deleteModule = async (req, res, next) => {
    try {
        const { id } = req.params;

        await prisma.module.delete({
            where: { id: parseInt(id) },
        });

        res.json({ message: 'Module supprimé avec succès' });
    } catch (error) {
        next(error);
    }
};
