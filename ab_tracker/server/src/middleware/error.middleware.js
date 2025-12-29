export const errorHandler = (err, req, res, next) => {
    console.error('Error:', err);

    // Erreur de validation Prisma
    if (err.code === 'P2002') {
        return res.status(400).json({
            error: 'Duplicate entry',
            message: `Une entrée avec cette valeur existe déjà pour le champ: ${err.meta?.target}`,
        });
    }

    // Erreur de relation non trouvée
    if (err.code === 'P2025') {
        return res.status(404).json({
            error: 'Not found',
            message: 'La ressource demandée n\'existe pas',
        });
    }

    // Erreur de validation express-validator
    if (err.array) {
        return res.status(400).json({
            error: 'Validation error',
            errors: err.array(),
        });
    }

    // Erreur par défaut
    const statusCode = err.statusCode || 500;
    res.status(statusCode).json({
        error: err.message || 'Erreur serveur interne',
        ...(process.env.NODE_ENV === 'development' && { stack: err.stack }),
    });
};

export const notFound = (req, res, next) => {
    res.status(404).json({
        error: 'Route non trouvée',
        path: req.originalUrl,
    });
};
