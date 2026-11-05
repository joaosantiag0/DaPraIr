import {
  S3Client,
  PutObjectCommand,
  DeleteObjectCommand,
  HeadBucketCommand,
  CreateBucketCommand,
} from '@aws-sdk/client-s3';
import sharp from 'sharp';
import crypto from 'node:crypto';
import fs from 'node:fs';
import path from 'node:path';
import { config } from '../../config.js';

export class StorageService {
  private client: S3Client;
  private bucket: string;

  constructor() {
    this.bucket = config.S3_BUCKET_NAME;
    this.client = new S3Client({
      endpoint: config.S3_ENDPOINT,
      region: config.S3_REGION,
      credentials: {
        accessKeyId: config.S3_ACCESS_KEY,
        secretAccessKey: config.S3_SECRET_KEY,
      },
      forcePathStyle: config.S3_FORCE_PATH_STYLE,
    });
  }

  async ensureBucket(): Promise<void> {
    try {
      await this.client.send(new HeadBucketCommand({ Bucket: this.bucket }));
    } catch {
      try {
        await this.client.send(new CreateBucketCommand({ Bucket: this.bucket }));
      } catch (err) {
        console.warn(`Could not create bucket ${this.bucket}:`, err);
      }
    }
  }

  /**
   * Optimizes an uploaded image using Sharp and uploads full-size + thumbnail to S3/MinIO
   */
  async uploadImage(
    fileBuffer: Buffer,
    prefix = 'media'
  ): Promise<{
    mediaUrl: string;
    thumbnailUrl: string;
    mimeType: string;
    sizeBytes: number;
    key: string;
    thumbnailKey: string;
  }> {
    const fileId = crypto.randomUUID();
    const key = `${prefix}/${fileId}.webp`;
    const thumbKey = `${prefix}/${fileId}-thumb.webp`;

    // Process optimized full-size image (max 1920 width/height, webp quality 80)
    const optimizedBuffer = await sharp(fileBuffer)
      .resize(1920, 1920, { fit: 'inside', withoutEnlargement: true })
      .webp({ quality: 80 })
      .toBuffer();

    // Process thumbnail (max 400 width/height, webp quality 70)
    const thumbBuffer = await sharp(fileBuffer)
      .resize(400, 400, { fit: 'inside', withoutEnlargement: true })
      .webp({ quality: 70 })
      .toBuffer();

    try {
      await this.ensureBucket();

      await this.client.send(
        new PutObjectCommand({
          Bucket: this.bucket,
          Key: key,
          Body: optimizedBuffer,
          ContentType: 'image/webp',
        })
      );

      await this.client.send(
        new PutObjectCommand({
          Bucket: this.bucket,
          Key: thumbKey,
          Body: thumbBuffer,
          ContentType: 'image/webp',
        })
      );

      const baseUrl = `${config.S3_ENDPOINT}/${this.bucket}`;
      const mediaUrl = `${baseUrl}/${key}`;
      const thumbnailUrl = `${baseUrl}/${thumbKey}`;

      return {
        mediaUrl,
        thumbnailUrl,
        mimeType: 'image/webp',
        sizeBytes: optimizedBuffer.length,
        key,
        thumbnailKey: thumbKey,
      };
    } catch (s3Err: any) {
      console.warn('S3 upload warning (falling back to local disk storage):', s3Err?.message);
      try {
        const uploadDir = path.resolve(process.cwd(), 'uploads', prefix);
        await fs.promises.mkdir(uploadDir, { recursive: true });
        const filePath = path.join(uploadDir, `${fileId}.webp`);
        const thumbPath = path.join(uploadDir, `${fileId}-thumb.webp`);
        await fs.promises.writeFile(filePath, optimizedBuffer);
        await fs.promises.writeFile(thumbPath, thumbBuffer);

        const baseUrl = `http://localhost:${config.PORT}`;
        const mediaUrl = `${baseUrl}/uploads/${prefix}/${fileId}.webp`;
        const thumbnailUrl = `${baseUrl}/uploads/${prefix}/${fileId}-thumb.webp`;

        return {
          mediaUrl,
          thumbnailUrl,
          mimeType: 'image/webp',
          sizeBytes: optimizedBuffer.length,
          key,
          thumbnailKey: thumbKey,
        };
      } catch (diskErr: any) {
        console.warn('Local disk save error (falling back to data URL):', diskErr?.message);
        const base64Data = optimizedBuffer.toString('base64');
        const thumbBase64 = thumbBuffer.toString('base64');
        return {
          mediaUrl: `data:image/webp;base64,${base64Data}`,
          thumbnailUrl: `data:image/webp;base64,${thumbBase64}`,
          mimeType: 'image/webp',
          sizeBytes: optimizedBuffer.length,
          key,
          thumbnailKey: thumbKey,
        };
      }
    }
  }

  async deleteImage(key: string): Promise<void> {
    await this.client.send(
      new DeleteObjectCommand({
        Bucket: this.bucket,
        Key: key,
      })
    );
  }
}

export const storageService = new StorageService();
