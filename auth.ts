import NextAuth, { DefaultSession } from 'next-auth';
import Credentials from 'next-auth/providers/credentials';
import { authConfig } from './auth.config';
import { z } from 'zod';
import { sql } from '@vercel/postgres';
import type { User } from '@/app/lib/definitions';
import bcrypt from 'bcrypt';

async function getUser(email: string): Promise<User | undefined> {
  try {
    console.log(email);
    const user = await sql<User>`SELECT * FROM users WHERE email=${email}`;
    return user.rows[0];
  } catch (error) {
    console.error('Failed to fetch user:', error);
    throw new Error('Failed to fetch user.');
  }
}

declare module 'next-auth' {
  interface User {
    id?: string;
    name?: string | null;
    email?: string | null;
    image?: string | null;
    role: 'admin' | 'user' | unknown;
  }
  interface Session {
    user: {
      role: 'admin' | 'user';
    } & DefaultSession['user'];
  }
}

export const { auth, signIn, signOut } = NextAuth({
  ...authConfig,
  providers: [
    Credentials({
      async authorize(credentials) {
        const parsedCredentials = z
          .object({ email: z.string().email(), password: z.string().min(6) })
          .safeParse(credentials);

        if (parsedCredentials.success) {
          const { email, password } = parsedCredentials.data;
          const user = await getUser(email);
          console.log(user);
          if (!user) return null;

          const passwordsMatch = await bcrypt.compare(password, user.password);

          if (passwordsMatch)
            return {
              id: user.id,
              email: user.email,
              role: user.role,
            };
        }

        console.log('Invalid credentials');
        return null;
      },
    }),
  ],
});
