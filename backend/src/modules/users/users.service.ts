import { prisma } from '../../core/database/prisma.js';
import { CryptoService } from '../../core/crypto/encryption.js';
import { BadRequestError, NotFoundError } from '../../core/errors/app-error.js';

export interface UpdateProfileDTO {
  userId: string;
  disabilityTypes?: string[];
  assistanceNeeds?: string[];
  visibility: 'PUBLIC' | 'FRIENDS_ONLY' | 'PRIVATE';
  consentGranted: boolean;
  clientIp?: string;
  userAgent?: string;
}

export class UsersService {
  async getAccessibilityProfile(userId: string) {
    const profile = await prisma.userAccessibilityProfile.findUnique({
      where: { user_id: userId },
    });

    if (!profile) {
      return {
        userId,
        disabilityTypes: [],
        assistanceNeeds: [],
        visibility: 'PRIVATE',
      };
    }

    return {
      userId: profile.user_id,
      disabilityTypes: profile.disability_types,
      assistanceNeeds: profile.assistance_needs,
      visibility: profile.visibility,
    };
  }

  async updateAccessibilityProfile(data: UpdateProfileDTO) {
    const {
      userId,
      disabilityTypes = [],
      assistanceNeeds = [],
      visibility,
      consentGranted,
      clientIp = '127.0.0.1',
      userAgent,
    } = data;

    // LGPD Article 5, II check
    if (!consentGranted) {
      throw new BadRequestError(
        'O consentimento inequívoco para tratamento de dados sensíveis de acessibilidade é obrigatório conforme a LGPD'
      );
    }

    // Encrypt sensitive preferences for storage privacy
    const encryptedPayload = CryptoService.encryptPayload({
      disabilityTypes,
      assistanceNeeds,
      updatedAt: new Date().toISOString(),
    });

    const ipHash = CryptoService.hashPseudonym(clientIp);

    await prisma.$transaction(async (tx) => {
      // Upsert profile
      await tx.userAccessibilityProfile.upsert({
        where: { user_id: userId },
        update: {
          disability_types: disabilityTypes,
          assistance_needs: assistanceNeeds,
          visibility,
          encrypted_payload: encryptedPayload,
        },
        create: {
          user_id: userId,
          disability_types: disabilityTypes,
          assistance_needs: assistanceNeeds,
          visibility,
          encrypted_payload: encryptedPayload,
        },
      });

      // Audit consent
      await tx.userConsent.create({
        data: {
          user_id: userId,
          consent_type: 'SENSITIVE_ACCESSIBILITY_DATA',
          version: '1.0.0',
          granted: true,
          ip_address_hash: ipHash,
          user_agent: userAgent,
        },
      });
    });

    return {
      userId,
      disabilityTypes,
      assistanceNeeds,
      visibility,
    };
  }

  /**
   * Field-level visibility resolution when viewer fetches target user's profile
   */
  async getPublicProfile(targetUserId: string, viewerUserId?: string) {
    const user = await prisma.user.findUnique({
      where: { id: targetUserId },
      include: { accessibility_profile: true },
    });

    if (!user || user.status !== 'ACTIVE') {
      throw new NotFoundError('Usuário não encontrado');
    }

    let showAccessibility = false;
    const profile = user.accessibility_profile;

    if (profile) {
      if (profile.visibility === 'PUBLIC') {
        showAccessibility = true;
      } else if (profile.visibility === 'FRIENDS_ONLY' && viewerUserId) {
        // Check accepted friendship
        const connection = await prisma.socialConnection.findFirst({
          where: {
            OR: [
              { requester_id: viewerUserId, addressee_id: targetUserId, status: 'ACCEPTED' },
              { requester_id: targetUserId, addressee_id: viewerUserId, status: 'ACCEPTED' },
            ],
          },
        });
        showAccessibility = connection !== null;
      }
    }

    return {
      id: user.id,
      name: user.name,
      handle: user.handle,
      avatarUrl: user.avatar_url,
      bio: user.bio,
      badges: user.badges,
      accessibilityProfile: showAccessibility && profile
        ? {
            disabilityTypes: profile.disability_types,
            assistanceNeeds: profile.assistance_needs,
            visibility: profile.visibility,
          }
        : null,
    };
  }

  async updateUserLocation(userId: string, locationData: {
    label: string;
    address?: string | null;
    city?: string | null;
    state?: string | null;
    latitude: number;
    longitude: number;
    isGps?: boolean;
  }) {
    const encrypted = CryptoService.encryptPayload({
      ...locationData,
      updatedAt: new Date().toISOString(),
    });

    await prisma.user.update({
      where: { id: userId },
      data: { encrypted_location: encrypted },
    });

    return {
      success: true,
      message: 'Localização salva com criptografia AES-256',
      location: locationData,
    };
  }

  async getUserLocation(userId: string) {
    const user = await prisma.user.findUnique({
      where: { id: userId },
      select: { encrypted_location: true },
    });

    if (!user || !user.encrypted_location) {
      return null;
    }

    try {
      const decrypted = CryptoService.decryptPayload<any>(Buffer.from(user.encrypted_location));
      return decrypted;
    } catch {
      return null;
    }
  }
}

export const usersService = new UsersService();
