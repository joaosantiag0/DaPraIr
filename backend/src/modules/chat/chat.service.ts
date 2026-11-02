import { prisma } from '../../core/database/prisma.js';
import { ForbiddenError, BadRequestError } from '../../core/errors/app-error.js';

export interface SendMessageDTO {
  senderId: string;
  recipientId: string;
  content: string;
}

export class ChatService {
  /**
   * Send 1:1 direct message.
   * STRICT SECURITY BARRIER: ONLY ALLOWED IF AN ACCEPTED FRIENDSHIP EXISTS.
   */
  async sendMessage(data: SendMessageDTO) {
    const { senderId, recipientId, content } = data;

    if (!content || content.trim().length === 0) {
      throw new BadRequestError('Mensagem não pode ser vazia');
    }

    if (content.length > 2000) {
      throw new BadRequestError('Mensagem excede o limite de 2000 caracteres');
    }

    if (senderId === recipientId) {
      throw new BadRequestError('Não é possível enviar mensagem para si mesmo');
    }

    // Verify friendship barrier
    const friendship = await prisma.socialConnection.findFirst({
      where: {
        OR: [
          { requester_id: senderId, addressee_id: recipientId, status: 'ACCEPTED' },
          { requester_id: recipientId, addressee_id: senderId, status: 'ACCEPTED' },
        ],
      },
    });

    if (!friendship) {
      throw new ForbiddenError(
        'Canal de conversa restrito: mensagens diretas 1:1 só podem ser trocadas entre amigos aceitos'
      );
    }

    const message = await prisma.directMessage.create({
      data: {
        sender_id: senderId,
        recipient_id: recipientId,
        content: content.trim(),
        status: 'SENT',
      },
      include: {
        sender: {
          select: { id: true, name: true, handle: true, avatar_url: true },
        },
      },
    });

    return {
      id: message.id,
      senderId: message.sender_id,
      recipientId: message.recipient_id,
      content: message.content,
      status: message.status,
      createdAt: message.created_at,
      sender: message.sender,
    };
  }

  /**
   * Retrieve conversation history with an accepted friend
   */
  async getMessages(userId: string, peerUserId: string, limit = 50, offset = 0) {
    // Check friendship barrier
    const friendship = await prisma.socialConnection.findFirst({
      where: {
        OR: [
          { requester_id: userId, addressee_id: peerUserId, status: 'ACCEPTED' },
          { requester_id: peerUserId, addressee_id: userId, status: 'ACCEPTED' },
        ],
      },
    });

    if (!friendship) {
      throw new ForbiddenError(
        'Canal de conversa restrito: histórico disponível apenas para amigos aceitos'
      );
    }

    const messages = await prisma.directMessage.findMany({
      where: {
        OR: [
          { sender_id: userId, recipient_id: peerUserId },
          { sender_id: peerUserId, recipient_id: userId },
        ],
      },
      orderBy: { created_at: 'asc' },
      take: limit,
      skip: offset,
      include: {
        sender: {
          select: { id: true, name: true, handle: true, avatar_url: true },
        },
      },
    });

    // Mark unread messages sent by peer as read
    await prisma.directMessage.updateMany({
      where: {
        sender_id: peerUserId,
        recipient_id: userId,
        status: { in: ['SENT', 'DELIVERED'] },
      },
      data: {
        status: 'READ',
        read_at: new Date(),
      },
    });

    return messages.map((m) => ({
      id: m.id,
      senderId: m.sender_id,
      recipientId: m.recipient_id,
      content: m.content,
      status: m.status,
      createdAt: m.created_at,
      sender: m.sender,
    }));
  }
}

export const chatService = new ChatService();
