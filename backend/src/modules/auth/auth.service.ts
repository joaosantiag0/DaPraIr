import { prisma } from '../../core/database/prisma.js';
import { CryptoService } from '../../core/crypto/encryption.js';
import { BadRequestError, UnauthorizedError, ConflictError } from '../../core/errors/app-error.js';

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

    // Create user and initial LGPD consent in transaction
    const user = await prisma.$transaction(async (tx) => {
      const newUser = await tx.user.create({
        data: {
          name,
          email: normalizedEmail,
          handle: normalizedHandle,
          password_hash: passwordHash,
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

  async login(data: LoginDTO) {
    const { email, password } = data;
    const normalizedEmail = email.toLowerCase().trim();

    const user = await prisma.user.findUnique({
      where: { email: normalizedEmail },
    });

    if (!user || !user.password_hash || user.status !== 'ACTIVE') {
      throw new UnauthorizedError('Credenciais inválidas ou conta desativada');
    }

    const isMatch = await CryptoService.verifyPassword(user.password_hash, password);
    if (!isMatch) {
      throw new UnauthorizedError('Credenciais inválidas');
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
