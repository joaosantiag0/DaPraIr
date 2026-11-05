import { prisma } from '../../core/database/prisma.js';
import { CryptoService } from '../../core/crypto/encryption.js';
import { NotFoundError } from '../../core/errors/app-error.js';

export class PrivacyService {
  /**
   * LGPD Data Portability (Art. 18, V): Export all personal data as JSON
   */
  async exportUserData(userId: string) {
    const user = await prisma.user.findUnique({
      where: { id: userId },
      include: {
        accessibility_profile: true,
        consents: { orderBy: { granted_at: 'desc' } },
        reviews: {
          include: { ratings: { include: { criterion: true } }, media: true },
        },
        favorites: { include: { place: true } },
      },
    });

    if (!user) {
      throw new NotFoundError('Usuário não encontrado');
    }

    return {
      exportedAt: new Date().toISOString(),
      userData: {
        id: user.id,
        name: user.name,
        email: user.email,
        handle: user.handle,
        bio: user.bio,
        createdAt: user.created_at,
      },
      savedLocation: user.encrypted_location
        ? (() => {
            try {
              return CryptoService.decryptPayload(user.encrypted_location);
            } catch {
              return null;
            }
          })()
        : null,
      accessibilityProfile: user.accessibility_profile
        ? {
            disabilityTypes: user.accessibility_profile.disability_types,
            assistanceNeeds: user.accessibility_profile.assistance_needs,
            visibility: user.accessibility_profile.visibility,
          }
        : null,
      consentLog: user.consents.map((c) => ({
        consentType: c.consent_type,
        version: c.version,
        granted: c.granted,
        timestamp: c.granted_at,
      })),
      reviews: user.reviews.map((r) => ({
        id: r.id,
        placeId: r.place_id,
        comment: r.general_comment,
        averageScore: Number(r.average_score),
        ratings: r.ratings.map((rt) => ({
          criterion: rt.criterion.title,
          score: rt.score,
          notes: rt.notes,
        })),
        createdAt: r.created_at,
      })),
      favorites: user.favorites.map((f) => ({
        placeId: f.place.id,
        placeName: f.place.name,
        address: f.place.address,
      })),
    };
  }

  /**
   * LGPD Right to be Forgotten / Anonymization (Art. 18, VI)
   */
  async anonymizeAccount(userId: string, clientIp = '127.0.0.1') {
    const user = await prisma.user.findUnique({ where: { id: userId } });
    if (!user) {
      throw new NotFoundError('Usuário não encontrado');
    }

    const anonSuffix = crypto.randomUUID().slice(0, 8);
    const ipHash = CryptoService.hashPseudonym(clientIp);

    await prisma.$transaction(async (tx) => {
      // 1. Delete sensitive accessibility profile
      await tx.userAccessibilityProfile.deleteMany({
        where: { user_id: userId },
      });

      // 2. Revoke all consents
      await tx.userConsent.create({
        data: {
          user_id: userId,
          consent_type: 'RIGHT_TO_FORGOTTEN_ANONYMIZED',
          version: '1.0.0',
          granted: false,
          ip_address_hash: ipHash,
        },
      });

      // 3. Anonymize user record
      await tx.user.update({
        where: { id: userId },
        data: {
          name: 'Usuário Anônimo',
          email: `anonymized_${anonSuffix}@daprair.internal`,
          handle: `anon_${anonSuffix}`,
          password_hash: null,
          avatar_url: null,
          bio: null,
          encrypted_location: null,
          is_anonymous: true,
          status: 'DELETED',
        },
      });
    });

    return {
      success: true,
      message: 'Conta anonimizada com sucesso conforme as diretrizes da LGPD',
    };
  }
}

export const privacyService = new PrivacyService();
