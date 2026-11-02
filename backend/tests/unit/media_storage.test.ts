import { describe, it, expect, vi } from 'vitest';
import sharp from 'sharp';
import { storageService } from '../../src/core/storage/s3-client.js';
import { mediaService } from '../../src/modules/media/media.service.js';

describe('Media & Storage Service (US1 / Accessibility)', () => {
  it('storageService processes and uploads image with Sharp optimization', async () => {
    // Mock S3 client send
    vi.spyOn((storageService as any).client, 'send').mockResolvedValue({} as any);

    // Generate valid 100x100 PNG buffer
    const testImageBuffer = await sharp({
      create: {
        width: 100,
        height: 100,
        channels: 4,
        background: { r: 255, g: 0, b: 0, alpha: 1 },
      },
    })
      .png()
      .toBuffer();

    const result = await storageService.uploadImage(testImageBuffer, 'test-folder');

    expect(result).toHaveProperty('mediaUrl');
    expect(result).toHaveProperty('thumbnailUrl');
    expect(result.mimeType).toBe('image/webp');
    expect(result.sizeBytes).toBeGreaterThan(0);
  });

  it('storageService deletes image and thumbnail', async () => {
    vi.spyOn((storageService as any).client, 'send').mockResolvedValue({} as any);
    await expect(storageService.deleteImage('test-folder/test-id.webp')).resolves.not.toThrow();
  });

  it('mediaService.uploadPhoto rejects photos without mandatory alt_text (Principle I)', async () => {
    await expect(
      mediaService.uploadPhoto({
        userId: '11111111-1111-1111-1111-111111111111',
        placeId: '22222222-2222-2222-2222-222222222222',
        altText: 'abc', // less than 5 characters
        buffer: Buffer.from([]),
        mimeType: 'image/jpeg',
      })
    ).rejects.toThrow('A audiodescrição (alt_text) da foto é obrigatória');
  });

  it('mediaService.uploadPhoto rejects unsupported mime types', async () => {
    await expect(
      mediaService.uploadPhoto({
        userId: '11111111-1111-1111-1111-111111111111',
        placeId: '22222222-2222-2222-2222-222222222222',
        altText: 'Entrada com rampa de acesso suave',
        buffer: Buffer.from([]),
        mimeType: 'application/pdf',
      })
    ).rejects.toThrow('Formato de imagem inválido');
  });

  it('mediaService.createPresignedUrl validates alt_text and returns presigned metadata', async () => {
    const res = await mediaService.createPresignedUrl({
      userId: '11111111-1111-1111-1111-111111111111',
      placeId: '22222222-2222-2222-2222-222222222222',
      mimeType: 'image/jpeg',
      altText: 'Rampa de acesso frontal com corrimão duplo',
      sizeBytes: 1024,
    });

    expect(res).toHaveProperty('uploadUrl');
    expect(res).toHaveProperty('mediaId');
    expect(res).toHaveProperty('targetUrl');
  });
});
