import { WebSocket } from 'ws';

export class ChatWebSocketManager {
  private activeSockets = new Map<string, Set<WebSocket>>();

  registerSocket(userId: string, socket: WebSocket) {
    let sockets = this.activeSockets.get(userId);
    if (!sockets) {
      sockets = new Set<WebSocket>();
      this.activeSockets.set(userId, sockets);
    }
    sockets.add(socket);

    socket.on('error', (err) => {
      // Safely prevent uncaught EventEmitter crash
      console.warn(`WebSocket connection error for user ${userId}:`, err?.message);
    });

    socket.on('close', () => {
      const current = this.activeSockets.get(userId);
      if (current) {
        current.delete(socket);
        if (current.size === 0) {
          this.activeSockets.delete(userId);
        }
      }
    });
  }

  sendToUser(recipientId: string, payload: unknown) {
    const sockets = this.activeSockets.get(recipientId);
    if (sockets && sockets.size > 0) {
      const serialized = JSON.stringify(payload);
      for (const socket of sockets) {
        if (socket.readyState === WebSocket.OPEN) {
          try {
            socket.send(serialized);
          } catch (err: any) {
            console.warn(`Failed to dispatch WS message to user ${recipientId}:`, err?.message);
          }
        }
      }
    }
  }
}

export const chatWsManager = new ChatWebSocketManager();
