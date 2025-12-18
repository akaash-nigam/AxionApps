import WebSocket, { WebSocketServer } from 'ws';
import { IncomingMessage } from 'http';
import jwt from 'jsonwebtoken';
import { config } from '../config';
import { logger } from '../utils/logger';
import { WSMessage, WSMessageType } from '../types';

interface AuthenticatedWebSocket extends WebSocket {
  userId?: string;
  meetingId?: string;
  isAlive?: boolean;
}

export class WebSocketService {
  private wss: WebSocketServer;
  private clients: Map<string, Set<AuthenticatedWebSocket>> = new Map(); // meetingId -> Set of clients

  constructor(port: number) {
    this.wss = new WebSocketServer({ port });
    this.setupWebSocketServer();
    this.startHeartbeat();
    logger.info(`WebSocket server started on port ${port}`);
  }

  private setupWebSocketServer(): void {
    this.wss.on('connection', (ws: AuthenticatedWebSocket, req: IncomingMessage) => {
      ws.isAlive = true;

      // Handle authentication
      const url = new URL(req.url || '', `http://${req.headers.host}`);
      const token = url.searchParams.get('token');

      if (!token) {
        ws.close(1008, 'Authentication required');
        return;
      }

      try {
        const decoded = jwt.verify(token, config.jwt.secret) as { userId: string };
        ws.userId = decoded.userId;
        logger.info(`WebSocket client authenticated: ${ws.userId}`);
      } catch (error) {
        logger.error('WebSocket authentication failed', error);
        ws.close(1008, 'Invalid token');
        return;
      }

      // Handle messages
      ws.on('message', (data: string) => {
        this.handleMessage(ws, data);
      });

      // Handle ping/pong for heartbeat
      ws.on('pong', () => {
        ws.isAlive = true;
      });

      // Handle disconnection
      ws.on('close', () => {
        this.handleDisconnect(ws);
      });

      // Handle errors
      ws.on('error', (error) => {
        logger.error('WebSocket error', { userId: ws.userId, error });
      });

      // Send connection confirmation
      this.send(ws, {
        type: WSMessageType.CONNECT,
        payload: { userId: ws.userId },
        timestamp: Date.now(),
      });
    });

    this.wss.on('error', (error) => {
      logger.error('WebSocket server error', error);
    });
  }

  private handleMessage(ws: AuthenticatedWebSocket, data: string): void {
    try {
      const message: WSMessage = JSON.parse(data);

      switch (message.type) {
        case WSMessageType.JOIN_MEETING:
          this.handleJoinMeeting(ws, message.payload);
          break;

        case WSMessageType.LEAVE_MEETING:
          this.handleLeaveMeeting(ws);
          break;

        case WSMessageType.PARTICIPANT_POSITION:
          this.handleParticipantPosition(ws, message.payload);
          break;

        case WSMessageType.AUDIO_STATE:
        case WSMessageType.VIDEO_STATE:
        case WSMessageType.SPEAKING_STATE:
          this.handleAVState(ws, message);
          break;

        case WSMessageType.CONTENT_ADDED:
        case WSMessageType.CONTENT_UPDATED:
        case WSMessageType.CONTENT_REMOVED:
          this.handleContentUpdate(ws, message);
          break;

        case WSMessageType.PING:
          this.send(ws, {
            type: WSMessageType.PONG,
            payload: {},
            timestamp: Date.now(),
          });
          break;

        default:
          logger.warn('Unknown message type', { type: message.type });
      }
    } catch (error) {
      logger.error('Failed to handle WebSocket message', { error, data });
      this.send(ws, {
        type: WSMessageType.ERROR,
        payload: { message: 'Invalid message format' },
        timestamp: Date.now(),
      });
    }
  }

  private handleJoinMeeting(ws: AuthenticatedWebSocket, payload: { meetingId: string }): void {
    const { meetingId } = payload;

    // Leave previous meeting if any
    if (ws.meetingId) {
      this.handleLeaveMeeting(ws);
    }

    // Join new meeting
    ws.meetingId = meetingId;

    if (!this.clients.has(meetingId)) {
      this.clients.set(meetingId, new Set());
    }

    this.clients.get(meetingId)!.add(ws);

    logger.info(`User ${ws.userId} joined meeting ${meetingId}`);

    // Notify other participants
    this.broadcast(meetingId, {
      type: WSMessageType.PARTICIPANT_JOINED,
      payload: {
        userId: ws.userId,
        meetingId,
      },
      timestamp: Date.now(),
    }, ws);

    // Send current participants to the new user
    const participants = Array.from(this.clients.get(meetingId)!)
      .filter(client => client !== ws)
      .map(client => ({ userId: client.userId }));

    this.send(ws, {
      type: WSMessageType.MEETING_UPDATE,
      payload: {
        meetingId,
        participants,
      },
      timestamp: Date.now(),
    });
  }

  private handleLeaveMeeting(ws: AuthenticatedWebSocket): void {
    if (!ws.meetingId) return;

    const meetingId = ws.meetingId;
    const clients = this.clients.get(meetingId);

    if (clients) {
      clients.delete(ws);

      // Notify other participants
      this.broadcast(meetingId, {
        type: WSMessageType.PARTICIPANT_LEFT,
        payload: {
          userId: ws.userId,
          meetingId,
        },
        timestamp: Date.now(),
      });

      // Clean up empty meetings
      if (clients.size === 0) {
        this.clients.delete(meetingId);
      }
    }

    logger.info(`User ${ws.userId} left meeting ${meetingId}`);
    ws.meetingId = undefined;
  }

  private handleParticipantPosition(ws: AuthenticatedWebSocket, payload: any): void {
    if (!ws.meetingId) return;

    this.broadcast(ws.meetingId, {
      type: WSMessageType.PARTICIPANT_POSITION,
      payload: {
        userId: ws.userId,
        ...payload,
      },
      timestamp: Date.now(),
    }, ws);
  }

  private handleAVState(ws: AuthenticatedWebSocket, message: WSMessage): void {
    if (!ws.meetingId) return;

    this.broadcast(ws.meetingId, {
      type: message.type,
      payload: {
        userId: ws.userId,
        ...message.payload,
      },
      timestamp: Date.now(),
    }, ws);
  }

  private handleContentUpdate(ws: AuthenticatedWebSocket, message: WSMessage): void {
    if (!ws.meetingId) return;

    this.broadcast(ws.meetingId, message, ws);
  }

  private handleDisconnect(ws: AuthenticatedWebSocket): void {
    logger.info(`WebSocket client disconnected: ${ws.userId}`);
    this.handleLeaveMeeting(ws);
  }

  private broadcast(meetingId: string, message: WSMessage, exclude?: AuthenticatedWebSocket): void {
    const clients = this.clients.get(meetingId);

    if (!clients) return;

    const messageStr = JSON.stringify(message);

    clients.forEach((client) => {
      if (client !== exclude && client.readyState === WebSocket.OPEN) {
        client.send(messageStr);
      }
    });
  }

  private send(ws: AuthenticatedWebSocket, message: WSMessage): void {
    if (ws.readyState === WebSocket.OPEN) {
      ws.send(JSON.stringify(message));
    }
  }

  private startHeartbeat(): void {
    setInterval(() => {
      this.wss.clients.forEach((ws: WebSocket) => {
        const client = ws as AuthenticatedWebSocket;

        if (client.isAlive === false) {
          logger.warn(`Terminating inactive WebSocket client: ${client.userId}`);
          return client.terminate();
        }

        client.isAlive = false;
        client.ping();
      });
    }, 30000); // 30 seconds
  }

  public getMeetingParticipantCount(meetingId: string): number {
    return this.clients.get(meetingId)?.size || 0;
  }

  public getActiveMeetings(): string[] {
    return Array.from(this.clients.keys());
  }
}
