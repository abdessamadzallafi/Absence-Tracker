import { PrismaClient } from '@prisma/client';

// Singleton pattern pour le client Prisma
// Évite de créer plusieurs instances en développement avec hot-reload
let prisma;

if (process.env.NODE_ENV === 'production') {
  prisma = new PrismaClient();
} else {
  if (!global.prisma) {
    global.prisma = new PrismaClient({
      log: ['query', 'error', 'warn'],
    });
  }
  prisma = global.prisma;
}

export default prisma;
