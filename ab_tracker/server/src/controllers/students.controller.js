import prisma from '../config/prisma.js';

// Get all students (with optional filter by groupId)
export const getAllStudents = async (req, res, next) => {
    try {
        const { groupId } = req.query;

        const where = groupId ? { groupId: parseInt(groupId) } : {};

        const students = await prisma.student.findMany({
            where,
            include: {
                group: {
                    select: { id: true, name: true, filiere: true },
                },
            },
            orderBy: [{ lastName: 'asc' }, { firstName: 'asc' }],
        });

        res.json(students);
    } catch (error) {
        next(error);
    }
};

// Get student by ID
export const getStudentById = async (req, res, next) => {
    try {
        const { id } = req.params;
        const student = await prisma.student.findUnique({
            where: { id: parseInt(id) },
            include: {
                group: true,
                attendances: {
                    include: {
                        session: {
                            include: {
                                module: true,
                            },
                        },
                    },
                    orderBy: { createdAt: 'desc' },
                },
            },
        });

        if (!student) {
            return res.status(404).json({ error: 'Étudiant non trouvé' });
        }

        res.json(student);
    } catch (error) {
        next(error);
    }
};

// Create student
export const createStudent = async (req, res, next) => {
    try {
        const { groupId, massar, firstName, lastName, email } = req.body;

        const student = await prisma.student.create({
            data: {
                groupId,
                massar,
                firstName,
                lastName,
                email,
            },
            include: {
                group: true,
            },
        });

        res.status(201).json(student);
    } catch (error) {
        next(error);
    }
};

// Update student
export const updateStudent = async (req, res, next) => {
    try {
        const { id } = req.params;
        const { groupId, massar, firstName, lastName, email } = req.body;

        const student = await prisma.student.update({
            where: { id: parseInt(id) },
            data: {
                groupId,
                massar,
                firstName,
                lastName,
                email,
            },
            include: {
                group: true,
            },
        });

        res.json(student);
    } catch (error) {
        next(error);
    }
};

// Delete student
export const deleteStudent = async (req, res, next) => {
    try {
        const { id } = req.params;

        await prisma.student.delete({
            where: { id: parseInt(id) },
        });

        res.json({ message: 'Étudiant supprimé avec succès' });
    } catch (error) {
        next(error);
    }
};
