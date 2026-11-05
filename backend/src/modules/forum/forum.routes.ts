import { FastifyInstance, FastifyRequest, FastifyReply } from 'fastify';
import { forumService } from './forum.service.js';
import {
  createTopicSchema,
  queryTopicsSchema,
  queryCategoriesSchema,
  createCommentSchema,
  updateTopicSchema,
  updateCommentSchema,
  reportForumContentSchema,
} from './forum.schemas.js';

export async function forumRoutes(app: FastifyInstance) {
  // GET /forum/categories - List active categories (Guest accessible)
  app.get(
    '/forum/categories',
    { preHandler: [app.optionalAuthenticate] },
    async (request: FastifyRequest, reply: FastifyReply) => {
      const query = queryCategoriesSchema.parse(request.query);
      const categories = await forumService.listCategories(query);
      return reply.status(200).send(categories);
    }
  );

  // GET /forum/categories/:id - Get category details
  app.get(
    '/forum/categories/:id',
    { preHandler: [app.optionalAuthenticate] },
    async (request: FastifyRequest, reply: FastifyReply) => {
      const { id } = request.params as { id: string };
      try {
        const category = await forumService.getCategoryById(id);
        return reply.status(200).send(category);
      } catch (err: any) {
        return reply.status(404).send({ message: err.message });
      }
    }
  );

  // GET /forum/topics - List topics with filters (Guest accessible with public filtering)
  app.get(
    '/forum/topics',
    { preHandler: [app.optionalAuthenticate] },
    async (request: FastifyRequest, reply: FastifyReply) => {
      const query = queryTopicsSchema.parse(request.query);
      const userId = request.user?.id;
      const topics = await forumService.listTopics(userId, query);
      return reply.status(200).send(topics);
    }
  );

  // GET /forum/topics/:id - Topic detail (Guest accessible with public filtering)
  app.get(
    '/forum/topics/:id',
    { preHandler: [app.optionalAuthenticate] },
    async (request: FastifyRequest, reply: FastifyReply) => {
      const { id } = request.params as { id: string };
      const userId = request.user?.id;
      try {
        const topic = await forumService.getTopicById(id, userId);
        return reply.status(200).send(topic);
      } catch (err: any) {
        if (err.message.includes('Forbidden')) {
          return reply.status(403).send({ message: err.message });
        }
        return reply.status(404).send({ message: err.message });
      }
    }
  );

  // POST /forum/topics - Create topic (Authentication required)
  app.post(
    '/forum/topics',
    { preHandler: [app.authenticate] },
    async (request: FastifyRequest, reply: FastifyReply) => {
      const body = createTopicSchema.parse(request.body);
      const userId = request.user.id;
      try {
        const topic = await forumService.createTopic(userId, body);
        return reply.status(201).send(topic);
      } catch (err: any) {
        return reply.status(400).send({ message: err.message });
      }
    }
  );

  // POST /forum/topics/:id/like - Toggle topic like (Authentication required)
  app.post(
    '/forum/topics/:id/like',
    { preHandler: [app.authenticate] },
    async (request: FastifyRequest, reply: FastifyReply) => {
      const { id } = request.params as { id: string };
      const userId = request.user.id;
      try {
        const result = await forumService.toggleTopicLike(userId, id);
        return reply.status(200).send(result);
      } catch (err: any) {
        return reply.status(404).send({ message: err.message });
      }
    }
  );

  // GET /forum/topics/:id/comments - List nested comments tree (Guest accessible with public filtering)
  app.get(
    '/forum/topics/:id/comments',
    { preHandler: [app.optionalAuthenticate] },
    async (request: FastifyRequest, reply: FastifyReply) => {
      const { id } = request.params as { id: string };
      const userId = request.user?.id;
      try {
        const tree = await forumService.listCommentsTree(id, userId);
        return reply.status(200).send(tree);
      } catch (err: any) {
        return reply.status(404).send({ message: err.message });
      }
    }
  );

  // POST /forum/topics/:id/comments - Post comment or reply (Authentication required)
  app.post(
    '/forum/topics/:id/comments',
    { preHandler: [app.authenticate] },
    async (request: FastifyRequest, reply: FastifyReply) => {
      const { id } = request.params as { id: string };
      const body = createCommentSchema.parse(request.body);
      const userId = request.user.id;
      try {
        const comment = await forumService.createComment(userId, id, body);
        return reply.status(201).send(comment);
      } catch (err: any) {
        return reply.status(400).send({ message: err.message });
      }
    }
  );

  // POST /forum/comments/:id/like - Toggle comment like (Authentication required)
  app.post(
    '/forum/comments/:id/like',
    { preHandler: [app.authenticate] },
    async (request: FastifyRequest, reply: FastifyReply) => {
      const { id } = request.params as { id: string };
      const userId = request.user.id;
      try {
        const result = await forumService.toggleCommentLike(userId, id);
        return reply.status(200).send(result);
      } catch (err: any) {
        return reply.status(404).send({ message: err.message });
      }
    }
  );

  // PATCH /forum/topics/:id - Edit topic (Author only)
  app.patch(
    '/forum/topics/:id',
    { preHandler: [app.authenticate] },
    async (request: FastifyRequest, reply: FastifyReply) => {
      const { id } = request.params as { id: string };
      const body = updateTopicSchema.parse(request.body);
      const userId = request.user.id;
      try {
        const updated = await forumService.updateTopic(userId, id, body);
        return reply.status(200).send(updated);
      } catch (err: any) {
        const status = err.message.includes('Forbidden') ? 403 : 400;
        return reply.status(status).send({ message: err.message });
      }
    }
  );

  // DELETE /forum/topics/:id - Soft-delete topic (Author only)
  app.delete(
    '/forum/topics/:id',
    { preHandler: [app.authenticate] },
    async (request: FastifyRequest, reply: FastifyReply) => {
      const { id } = request.params as { id: string };
      const userId = request.user.id;
      try {
        const result = await forumService.softDeleteTopic(userId, id);
        return reply.status(200).send(result);
      } catch (err: any) {
        const status = err.message.includes('Forbidden') ? 403 : 400;
        return reply.status(status).send({ message: err.message });
      }
    }
  );

  // PATCH /forum/comments/:id - Edit comment (Author only)
  app.patch(
    '/forum/comments/:id',
    { preHandler: [app.authenticate] },
    async (request: FastifyRequest, reply: FastifyReply) => {
      const { id } = request.params as { id: string };
      const body = updateCommentSchema.parse(request.body);
      const userId = request.user.id;
      try {
        const updated = await forumService.updateComment(userId, id, body as any);
        return reply.status(200).send(updated);
      } catch (err: any) {
        const status = err.message.includes('Forbidden') ? 403 : 400;
        return reply.status(status).send({ message: err.message });
      }
    }
  );

  // DELETE /forum/comments/:id - Soft-delete comment (Author only)
  app.delete(
    '/forum/comments/:id',
    { preHandler: [app.authenticate] },
    async (request: FastifyRequest, reply: FastifyReply) => {
      const { id } = request.params as { id: string };
      const userId = request.user.id;
      try {
        const result = await forumService.softDeleteComment(userId, id);
        return reply.status(200).send(result);
      } catch (err: any) {
        const status = err.message.includes('Forbidden') ? 403 : 400;
        return reply.status(status).send({ message: err.message });
      }
    }
  );

  // POST /forum/reports - Report content (Authentication required)
  app.post(
    '/forum/reports',
    { preHandler: [app.authenticate] },
    async (request: FastifyRequest, reply: FastifyReply) => {
      const body = reportForumContentSchema.parse(request.body);
      const userId = request.user.id;
      try {
        const report = await forumService.reportContent(userId, body);
        return reply.status(201).send(report);
      } catch (err: any) {
        return reply.status(400).send({ message: err.message });
      }
    }
  );
}
