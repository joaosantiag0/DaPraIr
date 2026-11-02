import { WebSocket } from 'ws';

export class ChatWebSocketManager {
  private activeSockets = new Map<string, WebSocket>();

  registerSocket(userId: string, socket: WebSocket) {
    this.activeSockets.set(userId, socket);

    socket.on('close', () => {
      this.activeSockets.delete(userId);
    });
  }

  sendToUser(recipientId: string, payload: unknown) {
    const socket = this.activeSockets.get(recipientId);
    if (socket && socket.readyState === WebSocket.OPEN) {
      socket.send(JSON.stringify(payload));
    }
  }
}

export const chatWsManager = new ChatWebSocketManager();
