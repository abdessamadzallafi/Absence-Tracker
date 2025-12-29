import prisma from '../config/prisma.js';

// Get all sessions (with optional filter by moduleId)
export const getAllSessions = async (req, res, next) => {
    try {
        const { moduleId } = req.query;

        const where = moduleId ? { moduleId: parseInt(moduleId) } : {};

        const sessions = await prisma.session.findMany({
            where,
            include: {
                module: {
                    include: {
                        group: {
                            select: { id: true, name: true, filiere: true },
                        },
                    },
                },
                _count: {
                    select: { attendances: true },
                },
            },
            orderBy: [{ date: 'desc' }, { time: 'desc' }],
        });

        res.json(sessions);
    } catch (error) {
        next(error);
    }
};

// Get session by ID
export const getSessionById = async (req, res, next) => {
    try {
        const { id } = req.params;
        const session = await prisma.session.findUnique({
            where: { id: parseInt(id) },
            include: {
                module: {
                    include: {
                        group: true,
                    },
                },
                attendances: {
                    include: {
                        student: true,
                    },
                    orderBy: { student: { lastName: 'asc' } },
                },
            },
        });

        if (!session) {
            return res.status(404).json({ error: 'Session non trouvée' });
        }

        res.json(session);
    } catch (error) {
        next(error);
    }
};

// Create session
export const createSession = async (req, res, next) => {
    try {
        const { moduleId, date, time, type } = req.body;

        const session = await prisma.session.create({
            data: {
                moduleId,
                date: new Date(date),
                time,
                type,
            },
            include: {
                module: {
                    include: {
                        group: true,
                    },
                },
            },
        });

        res.status(201).json(session);
    } catch (error) {
        next(error);
    }
};

// Update session
export const updateSession = async (req, res, next) => {
    try {
        const { id } = req.params;
        const { moduleId, date, time, type } = req.body;

        const session = await prisma.session.update({
            where: { id: parseInt(id) },
            data: {
                moduleId,
                date: new Date(date),
                time,
                type,
            },
            include: {
                module: {
                    include: {
                        group: true,
                    },
                },
            },
        });

        res.json(session);
    } catch (error) {
        next(error);
    }
};

// Delete session
export const deleteSession = async (req, res, next) => {
    try {
        const { id } = req.params;

        await prisma.session.delete({
            where: { id: parseInt(id) },
        });

        res.json({ message: 'Session supprimée avec succès' });
    } catch (error) {
        next(error);
    }
};
