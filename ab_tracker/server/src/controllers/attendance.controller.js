import prisma from '../config/prisma.js';

// Get attendances for a specific session
export const getSessionAttendances = async (req, res, next) => {
    try {
        const { sessionId } = req.params;

        const attendances = await prisma.attendance.findMany({
            where: { sessionId: parseInt(sessionId) },
            include: {
                student: {
                    select: {
                        id: true,
                        massar: true,
                        firstName: true,
                        lastName: true,
                    },
                },
                session: {
                    include: {
                        module: true,
                    },
                },
            },
            orderBy: { student: { lastName: 'asc' } },
        });

        res.json(attendances);
    } catch (error) {
        next(error);
    }
};

// Mark attendance (create or update)
export const markAttendance = async (req, res, next) => {
    try {
        const { sessionId, studentId, status } = req.body;

        // Upsert: créer si n'existe pas, mettre à jour sinon
        const attendance = await prisma.attendance.upsert({
            where: {
                sessionId_studentId: {
                    sessionId,
                    studentId,
                },
            },
            update: {
                status,
            },
            create: {
                sessionId,
                studentId,
                status,
            },
            include: {
                student: true,
                session: {
                    include: {
                        module: true,
                    },
                },
            },
        });

        res.json(attendance);
    } catch (error) {
        next(error);
    }
};

// Mark multiple attendances at once
export const markBulkAttendance = async (req, res, next) => {
    try {
        const { sessionId, attendances } = req.body;
        // attendances: [{ studentId, status }, ...]

        const results = await Promise.all(
            attendances.map((att) =>
                prisma.attendance.upsert({
                    where: {
                        sessionId_studentId: {
                            sessionId,
                            studentId: att.studentId,
                        },
                    },
                    update: {
                        status: att.status,
                    },
                    create: {
                        sessionId,
                        studentId: att.studentId,
                        status: att.status,
                    },
                })
            )
        );

        res.json({
            message: `${results.length} présences enregistrées`,
            count: results.length,
        });
    } catch (error) {
        next(error);
    }
};

// Get student attendance history
export const getStudentHistory = async (req, res, next) => {
    try {
        const { studentId } = req.params;

        const attendances = await prisma.attendance.findMany({
            where: { studentId: parseInt(studentId) },
            include: {
                session: {
                    include: {
                        module: {
                            select: {
                                id: true,
                                name: true,
                                semester: true,
                            },
                        },
                    },
                },
            },
            orderBy: { session: { date: 'desc' } },
        });

        // Grouper par module
        const history = {};
        attendances.forEach((att) => {
            const moduleName = att.session.module.name;
            if (!history[moduleName]) {
                history[moduleName] = {
                    moduleName,
                    moduleId: att.session.module.id,
                    semester: att.session.module.semester,
                    absent: 0,
                    justified: 0,
                    present: 0,
                    dates: [],
                };
            }

            if (att.status === 'absent') {
                history[moduleName].absent++;
                history[moduleName].dates.push({
                    date: att.session.date,
                    type: att.session.type,
                    status: 'absent',
                });
            } else if (att.status === 'justified') {
                history[moduleName].justified++;
                history[moduleName].dates.push({
                    date: att.session.date,
                    type: att.session.type,
                    status: 'justified',
                });
            } else {
                history[moduleName].present++;
            }
        });

        res.json(Object.values(history));
    } catch (error) {
        next(error);
    }
};

// Get global statistics
export const getGlobalStats = async (req, res, next) => {
    try {
        const { groupId, moduleId, startDate, endDate } = req.query;

        // Construire les filtres
        const where = {};
        if (groupId || moduleId || startDate || endDate) {
            where.session = {};
            if (moduleId) {
                where.session.moduleId = parseInt(moduleId);
            }
            if (groupId) {
                where.session.module = {
                    groupId: parseInt(groupId),
                };
            }
            if (startDate || endDate) {
                where.session.date = {};
                if (startDate) where.session.date.gte = new Date(startDate);
                if (endDate) where.session.date.lte = new Date(endDate);
            }
        }

        // Compter les présences par statut
        const [present, absent, justified, total] = await Promise.all([
            prisma.attendance.count({ where: { ...where, status: 'present' } }),
            prisma.attendance.count({ where: { ...where, status: 'absent' } }),
            prisma.attendance.count({ where: { ...where, status: 'justified' } }),
            prisma.attendance.count({ where }),
        ]);

        res.json({
            present,
            absent,
            justified,
            total,
            presenceRate: total > 0 ? ((present / total) * 100).toFixed(2) : 0,
        });
    } catch (error) {
        next(error);
    }
};
