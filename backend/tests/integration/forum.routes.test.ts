import { describe, it, expect, beforeAll, afterAll } from 'vitest';
import { buildApp } from '../../src/server.js';
import { prisma } from '../../src/core/database/prisma.js';
import { FastifyInstance } from 'fastify';

describe('Forum Routes Integration Tests (US1 - Categories, Topics & Likes)', () => {
  let app: FastifyInstance;
  let testUserToken: string;
  let testUserId: string;
  let testCategoryId: string;

  beforeAll(async () => {
    app = await buildApp();
    await app.ready();

    // Create test user
    const user = await prisma.user.upsert({
      where: { email: 'forum_routes_test@daprair.com' },
      update: {},
      create: {
        email: 'forum_routes_test@daprair.com',
        name: 'Forum Routes User',
        handle: 'forum_routes_user',
      },
    });
    testUserId = user.id;

    testUserToken = app.jwt.sign({
      id: user.id,
      email: user.email,
      role: user.role,
      handle: user.handle,
    });

    // Create test category
    const category = await prisma.forumCategory.upsert({
      where: { slug: 'routes-test-category' },
      update: {},
      create: {
        name: 'Routes Test Category',
        slug: 'routes-test-category',
        description: 'Category for route integration tests',
        icon_name: 'forum',
        display_order: 1,
        is_active: true,
      },
    });
    testCategoryId = category.id;
  });

  afterAll(async () => {
    await prisma.forumTopicLike.deleteMany({
      where: { topic: { category_id: testCategoryId } },
    });
    await prisma.forumComment.deleteMany({
      where: { topic: { category_id: testCategoryId } },
    });
    await prisma.forumTopic.deleteMany({
      where: { category_id: testCategoryId },
    });
    await prisma.forumCategory.deleteMany({
      where: { id: testCategoryId },
    });
    await prisma.user.deleteMany({
      where: { email: 'forum_routes_test@daprair.com' },
    });
    await app.close();
  });

  it('GET /api/v1/forum/categories - should list forum categories for guest without token', async () => {
    const res = await app.inject({
      method: 'GET',
      url: '/api/v1/forum/categories',
    });

    expect(res.statusCode).toBe(200);
    const data = JSON.parse(res.body);
    expect(Array.isArray(data)).toBe(true);
    const found = data.find((c: any) => c.id === testCategoryId);
    expect(found).toBeDefined();
    expect(found.slug).toBe('routes-test-category');
  });

  it('POST /api/v1/forum/topics - should reject unauthenticated request with 401', async () => {
    const res = await app.inject({
      method: 'POST',
      url: '/api/v1/forum/topics',
      payload: {
        category_id: testCategoryId,
        title: 'Tentativa sem token',
        content: 'Este tópico deve ser rejeitado com 401.',
      },
    });

    expect(res.statusCode).toBe(401);
  });

  it('POST /api/v1/forum/topics - should create topic when authenticated', async () => {
    const res = await app.inject({
      method: 'POST',
      url: '/api/v1/forum/topics',
      headers: {
        Authorization: `Bearer ${testUserToken}`,
      },
      payload: {
        category_id: testCategoryId,
        title: 'Acessibilidade em calçadas do centro',
        content: 'Discussão sobre guias rebaixadas e piso tátil nas principais esquinas.',
        visibility: 'PUBLIC',
      },
    });

    expect(res.statusCode).toBe(201);
    const data = JSON.parse(res.body);
    expect(data.id).toBeDefined();
    expect(data.title).toBe('Acessibilidade em calçadas do centro');
    expect(data.visibility).toBe('PUBLIC');
    expect(data.author.id).toBe(testUserId);
  });

  it('GET /api/v1/forum/topics - should list topics with filters', async () => {
    const res = await app.inject({
      method: 'GET',
      url: `/api/v1/forum/topics?category_id=${testCategoryId}&sort_by=recent`,
    });

    expect(res.statusCode).toBe(200);
    const data = JSON.parse(res.body);
    expect(Array.isArray(data)).toBe(true);
    expect(data.length).toBeGreaterThanOrEqual(1);
    expect(data[0].title).toBe('Acessibilidade em calçadas do centro');
  });

  it('POST /api/v1/forum/topics/:id/like - should toggle topic like', async () => {
    // List topics to get ID
    const topicsRes = await app.inject({
      method: 'GET',
      url: `/api/v1/forum/topics?category_id=${testCategoryId}`,
    });
    const topicId = JSON.parse(topicsRes.body)[0].id;

    // Like
    const likeRes = await app.inject({
      method: 'POST',
      url: `/api/v1/forum/topics/${topicId}/like`,
      headers: {
        Authorization: `Bearer ${testUserToken}`,
      },
    });

    expect(likeRes.statusCode).toBe(200);
    const likeData = JSON.parse(likeRes.body);
    expect(likeData.liked).toBe(true);
    expect(likeData.likes_count).toBe(1);

    // Unlike
    const unlikeRes = await app.inject({
      method: 'POST',
      url: `/api/v1/forum/topics/${topicId}/like`,
      headers: {
        Authorization: `Bearer ${testUserToken}`,
      },
    });

    expect(unlikeRes.statusCode).toBe(200);
    const unlikeData = JSON.parse(unlikeRes.body);
    expect(unlikeData.liked).toBe(false);
    expect(unlikeData.likes_count).toBe(0);
  });

  it('POST /api/v1/forum/topics/:id/comments - should create root comment and nested subthread reply', async () => {
    // 1. Create a topic
    const topicRes = await app.inject({
      method: 'POST',
      url: '/api/v1/forum/topics',
      headers: { Authorization: `Bearer ${testUserToken}` },
      payload: {
        category_id: testCategoryId,
        title: 'Tópico para teste de comentários e subthreads',
        content: 'Discussão detalhada com subthreads.',
        visibility: 'PUBLIC',
      },
    });
    const topic = JSON.parse(topicRes.body);

    // 2. Create Level 1 Comment
    const comment1Res = await app.inject({
      method: 'POST',
      url: `/api/v1/forum/topics/${topic.id}/comments`,
      headers: { Authorization: `Bearer ${testUserToken}` },
      payload: {
        content: 'Comentário raiz de nível 1',
        visibility: 'PUBLIC',
      },
    });
    expect(comment1Res.statusCode).toBe(201);
    const comment1 = JSON.parse(comment1Res.body);
    expect(comment1.depth).toBe(1);

    // 3. Create Level 2 Nested Reply
    const comment2Res = await app.inject({
      method: 'POST',
      url: `/api/v1/forum/topics/${topic.id}/comments`,
      headers: { Authorization: `Bearer ${testUserToken}` },
      payload: {
        parent_id: comment1.id,
        content: 'Resposta de nível 2 na subthread',
        visibility: 'PUBLIC',
      },
    });
    expect(comment2Res.statusCode).toBe(201);
    const comment2 = JSON.parse(comment2Res.body);
    expect(comment2.depth).toBe(2);
    expect(comment2.parent_id).toBe(comment1.id);

    // 4. GET /api/v1/forum/topics/:id/comments - should return nested comments tree
    const listCommentsRes = await app.inject({
      method: 'GET',
      url: `/api/v1/forum/topics/${topic.id}/comments`,
      headers: { Authorization: `Bearer ${testUserToken}` },
    });
    expect(listCommentsRes.statusCode).toBe(200);
    const commentsTree = JSON.parse(listCommentsRes.body);
    expect(Array.isArray(commentsTree)).toBe(true);
    expect(commentsTree.length).toBe(1);
    expect(commentsTree[0].id).toBe(comment1.id);
    expect(commentsTree[0].replies.length).toBe(1);
    expect(commentsTree[0].replies[0].id).toBe(comment2.id);

    // 5. POST /api/v1/forum/comments/:id/like - should toggle comment like
    const commentLikeRes = await app.inject({
      method: 'POST',
      url: `/api/v1/forum/comments/${comment1.id}/like`,
      headers: { Authorization: `Bearer ${testUserToken}` },
    });
    expect(commentLikeRes.statusCode).toBe(200);
    const commentLikeData = JSON.parse(commentLikeRes.body);
    expect(commentLikeData.liked).toBe(true);
    expect(commentLikeData.likes_count).toBe(1);
  });

  it('US3: should strictly isolate COMMUNITY and AUTHOR topics/comments from unauthenticated guests (100% privacy boundary)', async () => {
    // 1. Create a COMMUNITY topic
    const commTopicRes = await app.inject({
      method: 'POST',
      url: '/api/v1/forum/topics',
      headers: { Authorization: `Bearer ${testUserToken}` },
      payload: {
        category_id: testCategoryId,
        title: 'Tópico Secreto da Comunidade',
        content: 'Conteúdo restrito a usuários autenticados.',
        visibility: 'COMMUNITY',
      },
    });
    const commTopic = JSON.parse(commTopicRes.body);

    // 2. Create an AUTHOR private topic
    const authorTopicRes = await app.inject({
      method: 'POST',
      url: '/api/v1/forum/topics',
      headers: { Authorization: `Bearer ${testUserToken}` },
      payload: {
        category_id: testCategoryId,
        title: 'Tópico Privado do Autor',
        content: 'Conteúdo exclusivo do autor.',
        visibility: 'AUTHOR',
      },
    });
    const authorTopic = JSON.parse(authorTopicRes.body);

    // 3. Guest query for topics in category
    const guestTopicsRes = await app.inject({
      method: 'GET',
      url: `/api/v1/forum/topics?category_id=${testCategoryId}`,
    });
    expect(guestTopicsRes.statusCode).toBe(200);
    const guestTopics = JSON.parse(guestTopicsRes.body);
    const guestTopicIds = guestTopics.map((t: any) => t.id);

    expect(guestTopicIds).not.toContain(commTopic.id);
    expect(guestTopicIds).not.toContain(authorTopic.id);

    // 4. Guest direct access to COMMUNITY topic
    const directCommRes = await app.inject({
      method: 'GET',
      url: `/api/v1/forum/topics/${commTopic.id}`,
    });
    expect(directCommRes.statusCode).toBe(403);

    // 5. Guest direct access to AUTHOR topic
    const directAuthRes = await app.inject({
      method: 'GET',
      url: `/api/v1/forum/topics/${authorTopic.id}`,
    });
    expect(directAuthRes.statusCode).toBe(403);
  });

  it('US4: should edit topic and comment, soft-delete comment and create content report', async () => {
    // 1. Create a topic to edit
    const topicRes = await app.inject({
      method: 'POST',
      url: '/api/v1/forum/topics',
      headers: { authorization: `Bearer ${testUserToken}` },
      payload: {
        category_id: testCategoryId,
        title: 'Tópico Para Moderação',
        content: 'Conteúdo a ser modificado.',
        visibility: 'PUBLIC',
      },
    });
    expect(topicRes.statusCode).toBe(201);
    const topic = JSON.parse(topicRes.body);

    // 2. PATCH topic
    const patchTopicRes = await app.inject({
      method: 'PATCH',
      url: `/api/v1/forum/topics/${topic.id}`,
      headers: { authorization: `Bearer ${testUserToken}` },
      payload: {
        title: 'Tópico Com Título Editado',
        content: 'Conteúdo devidamente alterado.',
      },
    });
    expect(patchTopicRes.statusCode).toBe(200);
    const patchedTopic = JSON.parse(patchTopicRes.body);
    expect(patchedTopic.title).toBe('Tópico Com Título Editado');
    expect(patchedTopic.is_edited).toBe(true);
    expect(patchedTopic.edited_at).toBeDefined();

    // 3. Create a comment to edit and delete
    const commentRes = await app.inject({
      method: 'POST',
      url: `/api/v1/forum/topics/${topic.id}/comments`,
      headers: { authorization: `Bearer ${testUserToken}` },
      payload: {
        content: 'Comentário a ser editado',
        visibility: 'PUBLIC',
      },
    });
    expect(commentRes.statusCode).toBe(201);
    const comment = JSON.parse(commentRes.body);

    // 4. PATCH comment
    const patchCommentRes = await app.inject({
      method: 'PATCH',
      url: `/api/v1/forum/comments/${comment.id}`,
      headers: { authorization: `Bearer ${testUserToken}` },
      payload: {
        content: 'Comentário com edição confirmada',
      },
    });
    expect(patchCommentRes.statusCode).toBe(200);
    const patchedComment = JSON.parse(patchCommentRes.body);
    expect(patchedComment.content).toBe('Comentário com edição confirmada');
    expect(patchedComment.is_edited).toBe(true);

    // 5. DELETE comment (soft-delete)
    const deleteCommentRes = await app.inject({
      method: 'DELETE',
      url: `/api/v1/forum/comments/${comment.id}`,
      headers: { authorization: `Bearer ${testUserToken}` },
    });
    expect(deleteCommentRes.statusCode).toBe(200);
    const deletedComment = JSON.parse(deleteCommentRes.body);
    expect(deletedComment.status).toBe('DELETED');
    expect(deletedComment.content).toBe('[Comentário removido pelo autor]');

    // 6. POST report
    const reportRes = await app.inject({
      method: 'POST',
      url: '/api/v1/forum/reports',
      headers: { authorization: `Bearer ${testUserToken}` },
      payload: {
        target_type: 'FORUM_TOPIC',
        target_id: topic.id,
        reason: 'SPAM',
        details: 'Tópico repetido.',
      },
    });
    expect(reportRes.statusCode).toBe(201);
    const report = JSON.parse(reportRes.body);
    expect(report.status).toBe('PENDING');
  });
});
