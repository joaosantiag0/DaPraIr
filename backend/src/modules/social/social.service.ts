import { prisma } from '../../core/database/prisma.js';
import { BadRequestError, NotFoundError, ForbiddenError } from '../../core/errors/app-error.js';

export class SocialService {
  /**
   * Get connections (friends, pending sent, pending received)
   */
  async getConnections(userId: string) {
    const connections = await prisma.socialConnection.findMany({
      where: {
        OR: [{ requester_id: userId }, { addressee_id: userId }],
        status: { in: ['ACCEPTED', 'PENDING'] },
      },
      include: {
        requester: true,
        addressee: true,
      },
      orderBy: { updated_at: 'desc' },
    });

    return connections.map((c) => {
      const isRequester = c.requester_id === userId;
      const peer = isRequester ? c.addressee : c.requester;
      return {
        id: c.id,
        status: c.status,
        isOutgoing: isRequester,
        createdAt: c.created_at,
        peer: {
          id: peer.id,
          name: peer.name,
          handle: peer.handle,
          avatarUrl: peer.avatar_url,
          bio: peer.bio,
        },
      };
    });
  }

  /**
   * Send friend request
   */
  async sendRequest(requesterId: string, addresseeId: string) {
    if (requesterId === addresseeId) {
      throw new BadRequestError('Não é possível adicionar a si mesmo');
    }

    const targetUser = await prisma.user.findUnique({ where: { id: addresseeId } });
    if (!targetUser || targetUser.status !== 'ACTIVE') {
      throw new NotFoundError('Usuário não encontrado');
    }

    const existing = await prisma.socialConnection.findFirst({
      where: {
        OR: [
          { requester_id: requesterId, addressee_id: addresseeId },
          { requester_id: addresseeId, addressee_id: requesterId },
        ],
      },
    });

    if (existing) {
      if (existing.status === 'BLOCKED') {
        throw new ForbiddenError('Conexão indisponível');
      }
      if (existing.status === 'ACCEPTED') {
        throw new BadRequestError('Vocês já são amigos conectados');
      }
      if (existing.status === 'PENDING') {
        throw new BadRequestError('Já existe uma solicitação pendente entre vocês');
      }
    }

    return prisma.socialConnection.create({
      data: {
        requester_id: requesterId,
        addressee_id: addresseeId,
        status: 'PENDING',
      },
    });
  }

  /**
   * Get blocked users for the current user
   */
  async getBlockedUsers(userId: string) {
    const connections = await prisma.socialConnection.findMany({
      where: {
        OR: [{ requester_id: userId }, { addressee_id: userId }],
        status: 'BLOCKED',
      },
      include: {
        requester: true,
        addressee: true,
      },
      orderBy: { updated_at: 'desc' },
    });

    return connections.map((c) => {
      const isRequester = c.requester_id === userId;
      const peer = isRequester ? c.addressee : c.requester;
      return {
        id: c.id,
        status: c.status,
        isOutgoing: isRequester,
        createdAt: c.created_at,
        peer: {
          id: peer.id,
          name: peer.name,
          handle: peer.handle,
          avatarUrl: peer.avatar_url,
          bio: peer.bio,
        },
      };
    });
  }

  /**
   * Block a user directly by their targetUserId
   */
  async blockUser(userId: string, targetUserId: string) {
    if (userId === targetUserId) {
      throw new BadRequestError('Não é possível bloquear a si mesmo');
    }

    const existing = await prisma.socialConnection.findFirst({
      where: {
        OR: [
          { requester_id: userId, addressee_id: targetUserId },
          { requester_id: targetUserId, addressee_id: userId },
        ],
      },
    });

    if (existing) {
      return prisma.socialConnection.update({
        where: { id: existing.id },
        data: {
          requester_id: userId,
          addressee_id: targetUserId,
          status: 'BLOCKED',
        },
      });
    }

    return prisma.socialConnection.create({
      data: {
        requester_id: userId,
        addressee_id: targetUserId,
        status: 'BLOCKED',
      },
    });
  }

  /**
   * Unblock user (removes the connection record completely)
   */
  async unblockUser(userId: string, connectionId: string) {
    const connection = await prisma.socialConnection.findUnique({
      where: { id: connectionId },
    });

    if (!connection) {
      throw new NotFoundError('Conexão não encontrada');
    }

    if (connection.requester_id !== userId && connection.addressee_id !== userId) {
      throw new ForbiddenError('Acesso não autorizado');
    }

    await prisma.socialConnection.delete({
      where: { id: connectionId },
    });

    return { message: 'Contato desbloqueado com sucesso' };
  }

  /**
   * Update connection status (ACCEPT, DECLINE, BLOCK)
   */
  async updateStatus(
    userId: string,
    connectionId: string,
    newStatus: 'ACCEPTED' | 'DECLINED' | 'BLOCKED'
  ) {
    const connection = await prisma.socialConnection.findUnique({
      where: { id: connectionId },
    });

    if (!connection) {
      throw new NotFoundError('Conexão não encontrada');
    }

    // Only addressee can accept or decline a pending request
    if (newStatus === 'ACCEPTED' || newStatus === 'DECLINED') {
      if (connection.addressee_id !== userId) {
        throw new ForbiddenError('Apenas o destinatário pode aceitar ou recusar a solicitação');
      }
    }

    // Either user can block
    if (connection.requester_id !== userId && connection.addressee_id !== userId) {
      throw new ForbiddenError('Acesso não autorizado a esta conexão');
    }

    if (newStatus === 'BLOCKED') {
      return prisma.socialConnection.update({
        where: { id: connectionId },
        data: {
          requester_id: userId,
          addressee_id: connection.requester_id === userId ? connection.addressee_id : connection.requester_id,
          status: newStatus,
        },
      });
    }

    return prisma.socialConnection.update({
      where: { id: connectionId },
      data: { status: newStatus },
    });
  }

  /**
   * Peer recommendation based on matching public accessibility preferences
   */
  async getRecommendations(userId: string) {
    const userProfile = await prisma.userAccessibilityProfile.findUnique({
      where: { user_id: userId },
    });

    const userDisabilities = userProfile?.disability_types || [];
    const userNeeds = userProfile?.assistance_needs || [];

    // Find other active users who are not already connected or self
    const connectedIds = (
      await prisma.socialConnection.findMany({
        where: { OR: [{ requester_id: userId }, { addressee_id: userId }] },
        select: { requester_id: true, addressee_id: true },
      })
    ).flatMap((c) => [c.requester_id, c.addressee_id]);

    const excludedIds = [...new Set([userId, ...connectedIds])];

    const candidates = await prisma.user.findMany({
      where: {
        id: { notIn: excludedIds },
        status: 'ACTIVE',
        is_anonymous: false,
      },
      include: {
        accessibility_profile: true,
      },
      take: 10,
    });

    return candidates.map((c) => {
      let affinityScore = 50; // base affinity
      if (c.accessibility_profile && c.accessibility_profile.visibility === 'PUBLIC') {
        const commonDisabilities = c.accessibility_profile.disability_types.filter((d) =>
          userDisabilities.includes(d)
        );
        const commonNeeds = c.accessibility_profile.assistance_needs.filter((n) =>
          userNeeds.includes(n)
        );
        affinityScore += (commonDisabilities.length + commonNeeds.length) * 15;
      }

      return {
        id: c.id,
        name: c.name,
        handle: c.handle,
        avatarUrl: c.avatar_url,
        bio: c.bio,
        badges: c.badges,
        affinityScore: Math.min(affinityScore, 100),
      };
    });
  }
}

export const socialService = new SocialService();
