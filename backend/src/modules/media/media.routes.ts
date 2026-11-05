import { FastifyInstance, FastifyRequest, FastifyReply } from 'fastify';
import { mediaService } from './media.service.js';
import { z } from 'zod';

const uploadUrlSchema = z.object({
  mimeType: z.enum(['image/jpeg', 'image/png', 'image/webp']),
  sizeBytes: z.number().max(15 * 1024 * 1024),
  altText: z.string().min(5),
  placeId: z.string().uuid(),
});

export async function mediaRoutes(app: FastifyInstance) {
  // Pre-signed upload metadata
  app.post(
    '/media/upload-url',
    { preHandler: [app.authenticate] },
    async (request: FastifyRequest, reply: FastifyReply) => {
      const body = uploadUrlSchema.parse(request.body);
      const result = await mediaService.createPresignedUrl({
        userId: request.user.id,
        placeId: body.placeId,
        altText: body.altText,
        mimeType: body.mimeType,
        sizeBytes: body.sizeBytes,
      });
      return reply.status(200).send(result);
    }
  );

  // Direct multipart upload with Sharp processing
  app.post(
    '/media/upload',
    { preHandler: [app.authenticate] },
    async (request: FastifyRequest, reply: FastifyReply) => {
      const data = await request.file();
      if (!data) {
        return reply.status(400).send({ message: 'Arquivo de imagem obrigatório' });
      }

      const buffer = await data.toBuffer();
      const altText = (data.fields.altText as any)?.value;
      const placeId = (data.fields.placeId as any)?.value;

      const uuidRegex = /^[0-9a-f]{8}-[0-9a-f]{4}-[1-5][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/i;
      if (!placeId || !uuidRegex.test(placeId)) {
        return reply.status(400).send({ message: 'placeId inválido (deve ser um UUID válido)' });
      }

      const result = await mediaService.uploadPhoto({
        userId: request.user.id,
        placeId,
        altText,
        buffer,
        mimeType: data.mimetype,
      });

      return reply.status(201).send(result);
    }
  );
}
