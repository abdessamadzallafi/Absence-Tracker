import prisma from './src/config/prisma.js';
import bcrypt from 'bcryptjs';

async function main() {
    console.log('Seeding database...');

    try {
        const password = await bcrypt.hash('1234', 10);
        const user = await prisma.professor.upsert({
            where: { username: 'prof' },
            update: {},
            create: {
                username: 'prof',
                password,
                firstName: 'Prof',
                lastName: 'Demo',
                email: 'prof@demo.com',
            },
        });
        console.log('User "prof" created or already exists.');
    } catch (e) {
        console.error('Error seeding database:', e);
    } finally {
        await prisma.$disconnect();
    }
}

main();
