import { prisma } from '../../core/database/prisma.js';
import { storageService } from '../../core/storage/s3-client.js';
import { BadRequestError } from '../../core/errors/app-error.js';

export interface CreateMediaDTO {
  userId: string;
  placeId: string;
  altText: string;
  buffer: Buffer;
  mimeType: string;
}

export class MediaService {
  /**
   * Upload and optimize photo with mandatory alt_text for screen readers
   */
  async uploadPhoto(data: CreateMediaDTO) {
    const { userId, placeId, altText, buffer, mimeType } = data;

    // Strict validation for alt_text (Principle I & AR-001)
    if (!altText || altText.trim().length < 5) {
      throw new BadRequestError(
        'A audiodescrição (alt_text) da foto é obrigatória e deve conter pelo menos 5 caracteres'
      );
    }

    if (!['image/jpeg', 'image/png', 'image/webp'].includes(mimeType)) {
      throw new BadRequestError('Formato de imagem inválido. Suportados: JPEG, PNG, WebP');
    }

    // Process & store with Sharp and S3/MinIO
    const uploadResult = await storageService.uploadImage(buffer, `places/${placeId}`);

    // Create DB record
    const media = await prisma.placeMedia.create({
      data: {
        user_id: userId,
        place_id: placeId,
        alt_text: altText.trim(),
        media_url: uploadResult.mediaUrl,
        thumbnail_url: uploadResult.thumbnailUrl,
        mime_type: uploadResult.mimeType,
        size_bytes: uploadResult.sizeBytes,
        status: 'ACTIVE',
      },
    });

    return {
      id: media.id,
      placeId: media.place_id,
      mediaUrl: media.media_url,
      thumbnailUrl: media.thumbnail_url,
      altText: media.alt_text,
      status: media.status,
      createdAt: media.created_at,
    };
  }

  /**
   * Generates upload metadata / presigned url descriptor
   */
  async createPresignedUrl(params: {
    userId: string;
    placeId: string;
    altText: string;
    mimeType: string;
    sizeBytes: number;
  }) {
    if (!params.altText || params.altText.trim().length < 5) {
      throw new BadRequestError(
        'A audiodescrição (alt_text) da foto é obrigatória e deve conter pelo menos 5 caracteres'
      );
    }

    const placeholderId = crypto.randomUUID();
    return {
      mediaId: placeholderId,
      uploadUrl: `${storageService['bucket']}/direct-upload/${placeholderId}`,
      targetUrl: `${params.placeId}/${placeholderId}.webp`,
    };
  }
}

export const mediaService = new MediaService();
