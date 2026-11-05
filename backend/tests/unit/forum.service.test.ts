import { describe, it, expect, beforeAll, afterAll } from 'vitest';
import { prisma } from '../../src/core/database/prisma.js';
import { forumService } from '../../src/modules/forum/forum.service.js';

describe('ForumService Unit Tests (US1 - Categories, Topics & Visibility)', () => {
  let testUserId: string;
  let otherUserId: string;
  let testCategoryId: string;

  beforeAll(async () => {
    // Create test users
    const user1 = await prisma.user.upsert({
      where: { email: 'forum_unit_user1@daprair.com' },
      update: {},
      create: {
        email: 'forum_unit_user1@daprair.com',
        name: 'Unit User One',
        handle: 'unit_user_1',
      },
    });
    testUserId = user1.id;

    const user2 = await prisma.user.upsert({
      where: { email: 'forum_unit_user2@daprair.com' },
      update: {},
      create: {
        email: 'forum_unit_user2@daprair.com',
        name: 'Unit User Two',
        handle: 'unit_user_2',
      },
    });
    otherUserId = user2.id;

    // Create test category
    const cat = await prisma.forumCategory.upsert({
      where: { slug: 'unit-test-category' },
      update: {},
      create: {
        name: 'Unit Test Category',
        slug: 'unit-test-category',
        description: 'Category for service unit testing',
        icon_name: 'category',
        display_order: 10,
        is_active: true,
      },
    });
    testCategoryId = cat.id;
  });

  afterAll(async () => {
    // Cleanup
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
      where: {
        email: { in: ['forum_unit_user1@daprair.com', 'forum_unit_user2@daprair.com'] },
      },
    });
  });

  it('should list active categories ordered by display_order', async () => {
    const categories = await forumService.listCategories({ is_active: true });
    expect(Array.isArray(categories)).toBe(true);
    const found = categories.find((c) => c.id === testCategoryId);
    expect(found).toBeDefined();
    expect(found?.name).toBe('Unit Test Category');
  });

  it('should create a topic with valid category and default ACTIVE status', async () => {
    const topic = await forumService.createTopic(testUserId, {
      category_id: testCategoryId,
      title: 'Debate de acessibilidade nas estações de trem',
      content: 'Este é um debate de teste detalhado sobre elevadores de acesso.',
      visibility: 'PUBLIC',
    });

    expect(topic).toBeDefined();
    expect(topic.title).toBe('Debate de acessibilidade nas estações de trem');
    expect(topic.visibility).toBe('PUBLIC');
    expect(topic.status).toBe('ACTIVE');
    expect(topic.author_id).toBe(testUserId);
    expect(topic.likes_count).toBe(0);
    expect(topic.comments_count).toBe(0);

    // Verify category topics_count was incremented
    const cat = await prisma.forumCategory.findUnique({ where: { id: testCategoryId } });
    expect(cat?.topics_count).toBeGreaterThanOrEqual(1);
  });

  it('should filter topics strictly according to user session (anonymous vs authenticated vs author)', async () => {
    // Create a COMMUNITY topic by user 1
    const commTopic = await forumService.createTopic(testUserId, {
      category_id: testCategoryId,
      title: 'Tópico Comunitário Restrito',
      content: 'Apenas membros da comunidade podem visualizar.',
      visibility: 'COMMUNITY',
    });

    // Create an AUTHOR-only topic by user 1
    const authTopic = await forumService.createTopic(testUserId, {
      category_id: testCategoryId,
      title: 'Tópico Privado do Autor',
      content: 'Apenas o autor pode visualizar.',
      visibility: 'AUTHOR',
    });

    // Anonymous query
    const anonTopics = await forumService.listTopics(undefined, {
      category_id: testCategoryId,
    });
    const anonIds = anonTopics.map((t) => t.id);
    expect(anonIds).not.toContain(commTopic.id);
    expect(anonIds).not.toContain(authTopic.id);

    // Other authenticated user query
    const otherUserTopics = await forumService.listTopics(otherUserId, {
      category_id: testCategoryId,
    });
    const otherIds = otherUserTopics.map((t) => t.id);
    expect(otherIds).toContain(commTopic.id);
    expect(otherIds).not.toContain(authTopic.id);

    // Author query
    const authorTopics = await forumService.listTopics(testUserId, {
      category_id: testCategoryId,
    });
    const authorIds = authorTopics.map((t) => t.id);
    expect(authorIds).toContain(commTopic.id);
    expect(authorIds).toContain(authTopic.id);
  });

  it('should toggle topic likes atomically', async () => {
    const topic = await forumService.createTopic(testUserId, {
      category_id: testCategoryId,
      title: 'Tópico para teste de like',
      content: 'Conteúdo do tópico para testar likes com contagem correta.',
      visibility: 'PUBLIC',
    });

    // First like: should increment
    const like1 = await forumService.toggleTopicLike(testUserId, topic.id);
    expect(like1.liked).toBe(true);
    expect(like1.likes_count).toBe(1);

    // Check database
    let refreshed = await forumService.getTopicById(topic.id, testUserId);
    expect(refreshed.likes_count).toBe(1);
    expect(refreshed.is_liked_by_me).toBe(true);

    // Second like: should toggle off (unlike)
    const like2 = await forumService.toggleTopicLike(testUserId, topic.id);
    expect(like2.liked).toBe(false);
    expect(like2.likes_count).toBe(0);

    refreshed = await forumService.getTopicById(topic.id, testUserId);
    expect(refreshed.likes_count).toBe(0);
    expect(refreshed.is_liked_by_me).toBe(false);
  });

  it('should enforce ceiling rule for comment visibility and calculate depth up to 3', async () => {
    // Create community topic
    const commTopic = await forumService.createTopic(testUserId, {
      category_id: testCategoryId,
      title: 'Tópico Comunitário para Teste de Comentários',
      content: 'Discussão restrita a membros para teste da ceiling rule.',
      visibility: 'COMMUNITY',
    });

    // Try creating PUBLIC comment on COMMUNITY topic -> must reject or throw error
    await expect(
      forumService.createComment(testUserId, commTopic.id, {
        content: 'Tentativa de comentário público em tópico comunitário',
        visibility: 'PUBLIC',
      })
    ).rejects.toThrow(/regra do teto|ceiling rule|visibility/i);

    // Level 1 Root Comment (depth = 1)
    const commentL1 = await forumService.createComment(testUserId, commTopic.id, {
      content: 'Comentário raiz de nível 1',
      visibility: 'COMMUNITY',
    });
    expect(commentL1.depth).toBe(1);
    expect(commentL1.parent_id).toBeNull();

    // Level 2 Subthread Reply (depth = 2)
    const commentL2 = await forumService.createComment(otherUserId, commTopic.id, {
      parent_id: commentL1.id,
      content: 'Resposta de nível 2',
      visibility: 'COMMUNITY',
    });
    expect(commentL2.depth).toBe(2);
    expect(commentL2.parent_id).toBe(commentL1.id);
    expect(commentL2.reply_to_user_id).toBe(testUserId);

    // Level 3 Subthread Reply (depth = 3)
    const commentL3 = await forumService.createComment(testUserId, commTopic.id, {
      parent_id: commentL2.id,
      content: 'Resposta de nível 3',
      visibility: 'COMMUNITY',
    });
    expect(commentL3.depth).toBe(3);
    expect(commentL3.parent_id).toBe(commentL2.id);
    expect(commentL3.reply_to_user_id).toBe(otherUserId);

    // Level 4 (Flattened to depth = 3 with explicit mention)
    const commentL4 = await forumService.createComment(otherUserId, commTopic.id, {
      parent_id: commentL3.id,
      content: 'Resposta que ultrapassa o nível 3 (deve achatar para nível 3)',
      visibility: 'COMMUNITY',
    });
    expect(commentL4.depth).toBe(3);
    expect(commentL4.reply_to_user_id).toBe(testUserId);

    // Retrieve Tree Structure
    const tree = await forumService.listCommentsTree(commTopic.id, testUserId);
    expect(tree.length).toBe(1);
    expect(tree[0].id).toBe(commentL1.id);
    expect(tree[0].replies.length).toBe(1);
    expect(tree[0].replies[0].id).toBe(commentL2.id);
  });

  it('should toggle comment likes atomically', async () => {
    const topic = await forumService.createTopic(testUserId, {
      category_id: testCategoryId,
      title: 'Tópico para teste de like de comentário',
      content: 'Conteúdo do debate.',
      visibility: 'PUBLIC',
    });

    const comment = await forumService.createComment(testUserId, topic.id, {
      content: 'Comentário a ser curtido',
      visibility: 'PUBLIC',
    });

    // Like comment
    const likeRes1 = await forumService.toggleCommentLike(otherUserId, comment.id);
    expect(likeRes1.liked).toBe(true);
    expect(likeRes1.likes_count).toBe(1);

    // Unlike comment
    const likeRes2 = await forumService.toggleCommentLike(otherUserId, comment.id);
    expect(likeRes2.liked).toBe(false);
    expect(likeRes2.likes_count).toBe(0);
  });

  it('US4: should update topic with is_edited=true and reject non-authors', async () => {
    const topic = await forumService.createTopic(testUserId, {
      category_id: testCategoryId,
      title: 'Título Original',
      content: 'Conteúdo Original para edição.',
      visibility: 'PUBLIC',
    });

    // Non-author attempt should fail
    await expect(
      forumService.updateTopic(otherUserId, topic.id, {
        title: 'Título Hackeado',
      })
    ).rejects.toThrow();

    // Author update
    const updated = await forumService.updateTopic(testUserId, topic.id, {
      title: 'Título Atualizado',
      content: 'Conteúdo Atualizado com sucesso.',
    });
    expect(updated.title).toBe('Título Atualizado');
    expect(updated.content).toBe('Conteúdo Atualizado com sucesso.');
    expect(updated.is_edited).toBe(true);
    expect(updated.edited_at).toBeDefined();
  });

  it('US4: should update comment with is_edited=true and reject non-authors', async () => {
    const topic = await forumService.createTopic(testUserId, {
      category_id: testCategoryId,
      title: 'Tópico Comentário Editável',
      content: 'Conteúdo do tópico.',
      visibility: 'PUBLIC',
    });

    const comment = await forumService.createComment(testUserId, topic.id, {
      content: 'Comentário original antes de edição',
      visibility: 'PUBLIC',
    });

    // Non-author attempt
    await expect(
      forumService.updateComment(otherUserId, comment.id, {
        content: 'Alterado por outro',
      })
    ).rejects.toThrow();

    // Author update
    const updatedComment = await forumService.updateComment(testUserId, comment.id, {
      content: 'Comentário devidamente corrigido e editado',
    });
    expect(updatedComment.content).toBe('Comentário devidamente corrigido e editado');
    expect(updatedComment.is_edited).toBe(true);
    expect(updatedComment.edited_at).toBeDefined();
  });

  it('US4: should soft-delete comment preserving subthread tree and redacting author (LGPD)', async () => {
    const topic = await forumService.createTopic(testUserId, {
      category_id: testCategoryId,
      title: 'Tópico com Comentário a Ser Excluído',
      content: 'Conteúdo para teste de soft-delete de comentário.',
      visibility: 'PUBLIC',
    });

    const parentComment = await forumService.createComment(testUserId, topic.id, {
      content: 'Comentário Pai Sensível',
      visibility: 'PUBLIC',
    });

    const childComment = await forumService.createComment(otherUserId, topic.id, {
      parent_id: parentComment.id,
      content: 'Resposta de Filho que deve ser preservada',
      visibility: 'PUBLIC',
    });

    // Soft-delete parent comment
    const deleted = await forumService.softDeleteComment(testUserId, parentComment.id);
    expect(deleted.status).toBe('DELETED');
    expect(deleted.content).toBe('[Comentário removido pelo autor]');

    // Check tree retrieval preserves child
    const tree = await forumService.listCommentsTree(topic.id, testUserId);
    expect(tree.length).toBe(1);
    expect(tree[0].id).toBe(parentComment.id);
    expect(tree[0].content).toBe('[Comentário removido pelo autor]');
    expect(tree[0].status).toBe('DELETED');
    expect(tree[0].author).toBeNull(); // Redacted for LGPD
    expect(tree[0].replies.length).toBe(1);
    expect(tree[0].replies[0].id).toBe(childComment.id);
    expect(tree[0].replies[0].content).toBe('Resposta de Filho que deve ser preservada');
  });

  it('US4: should report forum topic and comment', async () => {
    const topic = await forumService.createTopic(testUserId, {
      category_id: testCategoryId,
      title: 'Tópico com Conteúdo Inadequado',
      content: 'Conteúdo a ser denunciado.',
      visibility: 'PUBLIC',
    });

    const reportTopic = await forumService.reportContent(otherUserId, {
      target_type: 'FORUM_TOPIC',
      target_id: topic.id,
      reason: 'HARASSMENT',
      details: 'Conteúdo ofensivo a usuários com deficiência.',
    });
    expect(reportTopic.id).toBeDefined();
    expect(reportTopic.status).toBe('PENDING');
    expect(reportTopic.target_type).toBe('FORUM_TOPIC');
  });
});
