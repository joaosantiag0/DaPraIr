import { prisma } from '../../core/database/prisma.js';
import { CryptoService } from '../../core/crypto/encryption.js';
import { BadRequestError, UnauthorizedError, ConflictError } from '../../core/errors/app-error.js';
import { config } from '../../config.js';

export interface RegisterDTO {
  name: string;
  email: string;
  handle: string;
  password: string;
  acceptTermsVersion: string;
  clientIp?: string;
  userAgent?: string;
}

export interface LoginDTO {
  email: string;
  password: string;
}

export class AuthService {
  private isAdminEmail(email: string): boolean {
    const rawList = `${config.ADMIN_EMAILS || ''},${config.ADMIN_EMAIL || ''}`;
    const adminEmails = rawList
      .split(',')
      .map((e) => e.trim().toLowerCase())
      .filter(Boolean);
    return adminEmails.includes(email.toLowerCase().trim());
  }

  async register(data: RegisterDTO) {
    const { name, email, handle, password, acceptTermsVersion, clientIp = '127.0.0.1', userAgent } = data;

    // Check unique email and handle
    const normalizedEmail = email.toLowerCase().trim();
    const normalizedHandle = handle.toLowerCase().trim().replace(/^@/, '');

    const existingUser = await prisma.user.findFirst({
      where: {
        OR: [{ email: normalizedEmail }, { handle: normalizedHandle }],
      },
    });

    if (existingUser) {
      if (existingUser.email === normalizedEmail) {
        throw new ConflictError('E-mail já cadastrado');
      }
      throw new ConflictError('Nome de usuário (handle) já está em uso');
    }

    const passwordHash = await CryptoService.hashPassword(password);
    const ipHash = CryptoService.hashPseudonym(clientIp);
    const initialRole = this.isAdminEmail(normalizedEmail) ? 'ADMIN' : 'USER';

    // Create user and initial LGPD consent in transaction
    const user = await prisma.$transaction(async (tx) => {
      const newUser = await tx.user.create({
        data: {
          name,
          email: normalizedEmail,
          handle: normalizedHandle,
          password_hash: passwordHash,
          role: initialRole,
          status: 'ACTIVE',
        },
      });

      // Record LGPD Terms and Privacy consent
      await tx.userConsent.createMany({
        data: [
          {
            user_id: newUser.id,
            consent_type: 'TERMS_OF_SERVICE',
            version: acceptTermsVersion,
            granted: true,
            ip_address_hash: ipHash,
            user_agent: userAgent,
          },
          {
            user_id: newUser.id,
            consent_type: 'PRIVACY_POLICY',
            version: acceptTermsVersion,
            granted: true,
            ip_address_hash: ipHash,
            user_agent: userAgent,
          },
        ],
      });

      return newUser;
    });

    return {
      id: user.id,
      name: user.name,
      email: user.email,
      handle: user.handle,
      role: user.role,
      avatarUrl: user.avatar_url,
    };
  }

  // Pre-computed dummy argon2id hash to mitigate timing attacks on non-existent user lookups
  private static readonly DUMMY_HASH = '$argon2id$v=19$m=19456,t=2,p=1$c29tZXNhbHR2YWx1ZQ$c29tZXNhbHR2YWx1ZQ';

  async login(data: LoginDTO) {
    const { email, password } = data;
    const normalizedEmail = email.toLowerCase().trim();

    const user = await prisma.user.findUnique({
      where: { email: normalizedEmail },
    });

    const hashToVerify = user && user.password_hash && user.status === 'ACTIVE'
      ? user.password_hash
      : AuthService.DUMMY_HASH;

    const isMatch = await CryptoService.verifyPassword(hashToVerify, password);

    if (!user || !user.password_hash || user.status !== 'ACTIVE' || !isMatch) {
      throw new UnauthorizedError('Credenciais inválidas');
    }

    if (this.isAdminEmail(normalizedEmail) && user.role !== 'ADMIN') {
      await prisma.user.update({
        where: { id: user.id },
        data: { role: 'ADMIN' },
      });
      user.role = 'ADMIN';
    }

    return {
      id: user.id,
      name: user.name,
      email: user.email,
      handle: user.handle,
      role: user.role,
      avatarUrl: user.avatar_url,
    };
  }
}

export const authService = new AuthService();
