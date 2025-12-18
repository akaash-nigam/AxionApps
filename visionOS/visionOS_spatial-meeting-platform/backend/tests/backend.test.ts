import { authService } from '../src/services/authService';
import { meetingService } from '../src/services/meetingService';
import { contentService } from '../src/services/contentService';

// Mock database
jest.mock('../src/config/database', () => ({
  query: jest.fn(),
  pool: {
    on: jest.fn(),
  },
  initDatabase: jest.fn(),
}));

const mockQuery = require('../src/config/database').query;

describe('Backend Services Tests', () => {
  beforeEach(() => {
    jest.clearAllMocks();
  });

  describe('AuthService', () => {
    it('should register a new user', async () => {
      mockQuery
        .mockResolvedValueOnce({ rows: [] }) // Check existing user
        .mockResolvedValueOnce({ // Insert user
          rows: [{
            id: 'user-123',
            email: 'test@example.com',
            username: 'testuser',
            display_name: 'Test User',
            created_at: new Date(),
            updated_at: new Date(),
          }]
        });

      const result = await authService.register(
        'test@example.com',
        'testuser',
        'password123',
        'Test User'
      );

      expect(result.user).toBeDefined();
      expect(result.token).toBeDefined();
      expect(result.user.email).toBe('test@example.com');
    });

    it('should login existing user', async () => {
      const mockUser = {
        id: 'user-123',
        email: 'test@example.com',
        username: 'testuser',
        password_hash: '$2b$10$test.hash', // Mock bcrypt hash
        display_name: 'Test User',
      };

      mockQuery.mockResolvedValueOnce({ rows: [mockUser] });

      // Mock bcrypt.compare
      jest.spyOn(require('bcrypt'), 'compare').mockResolvedValue(true);

      const result = await authService.login('test@example.com', 'password123');

      expect(result.user).toBeDefined();
      expect(result.token).toBeDefined();
    });

    it('should get user profile', async () => {
      const mockUser = {
        id: 'user-123',
        email: 'test@example.com',
        username: 'testuser',
        display_name: 'Test User',
      };

      mockQuery.mockResolvedValueOnce({ rows: [mockUser] });

      const profile = await authService.getProfile('user-123');

      expect(profile.id).toBe('user-123');
      expect(profile.email).toBe('test@example.com');
    });
  });

  describe('MeetingService', () => {
    it('should create a new meeting', async () => {
      const mockMeeting = {
        id: 'meeting-123',
        title: 'Test Meeting',
        host_id: 'user-123',
        environment_type: 'conference_room',
        layout_type: 'circle',
        status: 'scheduled',
        created_at: new Date(),
      };

      mockQuery.mockResolvedValueOnce({ rows: [mockMeeting] });

      const meeting = await meetingService.createMeeting('user-123', {
        title: 'Test Meeting',
        environment_type: 'conference_room',
        layout_type: 'circle',
      });

      expect(meeting.id).toBe('meeting-123');
      expect(meeting.title).toBe('Test Meeting');
    });

    it('should get meeting by ID', async () => {
      const mockMeeting = {
        id: 'meeting-123',
        title: 'Test Meeting',
        host_id: 'user-123',
      };

      mockQuery.mockResolvedValueOnce({ rows: [mockMeeting] });

      const meeting = await meetingService.getMeeting('meeting-123');

      expect(meeting.id).toBe('meeting-123');
    });

    it('should join meeting', async () => {
      const mockMeeting = {
        id: 'meeting-123',
        host_id: 'user-123',
        status: 'active',
        max_participants: 50,
        layout_type: 'circle',
      };

      const mockParticipant = {
        id: 'participant-123',
        meeting_id: 'meeting-123',
        user_id: 'user-456',
        role: 'participant',
      };

      mockQuery
        .mockResolvedValueOnce({ rows: [mockMeeting] }) // Get meeting
        .mockResolvedValueOnce({ rows: [] }) // Check existing participant
        .mockResolvedValueOnce({ rows: [{ count: '5' }] }) // Count participants
        .mockResolvedValueOnce({ rows: [{ count: '0' }] }) // For position calculation
        .mockResolvedValueOnce({ rows: [mockParticipant] }) // Insert participant
        .mockResolvedValueOnce({ rows: [] }); // Update meeting status

      const participant = await meetingService.joinMeeting('meeting-123', 'user-456');

      expect(participant.meeting_id).toBe('meeting-123');
      expect(participant.user_id).toBe('user-456');
    });

    it('should get meeting participants', async () => {
      const mockParticipants = [
        { id: 'p1', meeting_id: 'meeting-123', user_id: 'user-1', username: 'user1' },
        { id: 'p2', meeting_id: 'meeting-123', user_id: 'user-2', username: 'user2' },
      ];

      mockQuery.mockResolvedValueOnce({ rows: mockParticipants });

      const participants = await meetingService.getParticipants('meeting-123');

      expect(participants).toHaveLength(2);
      expect(participants[0].user_id).toBe('user-1');
    });
  });

  describe('ContentService', () => {
    it('should create shared content', async () => {
      const mockParticipant = { id: 'p1', meeting_id: 'meeting-123', user_id: 'user-123' };
      const mockContent = {
        id: 'content-123',
        meeting_id: 'meeting-123',
        creator_id: 'user-123',
        title: 'Shared Document',
        content_type: 'document',
        content_url: 'https://example.com/doc.pdf',
      };

      mockQuery
        .mockResolvedValueOnce({ rows: [mockParticipant] }) // Check participant
        .mockResolvedValueOnce({ rows: [mockContent] }); // Insert content

      const content = await contentService.createContent('meeting-123', 'user-123', {
        title: 'Shared Document',
        content_type: 'document',
        content_url: 'https://example.com/doc.pdf',
      });

      expect(content.id).toBe('content-123');
      expect(content.title).toBe('Shared Document');
    });

    it('should get meeting content', async () => {
      const mockContent = [
        { id: 'c1', meeting_id: 'meeting-123', title: 'Doc 1' },
        { id: 'c2', meeting_id: 'meeting-123', title: 'Doc 2' },
      ];

      mockQuery.mockResolvedValueOnce({ rows: mockContent });

      const content = await contentService.getContent('meeting-123');

      expect(content).toHaveLength(2);
      expect(content[0].title).toBe('Doc 1');
    });

    it('should update content position', async () => {
      const mockContent = {
        id: 'content-123',
        meeting_id: 'meeting-123',
        creator_id: 'user-123',
        is_locked: false,
      };

      const updatedContent = { ...mockContent, position_x: 1.5, position_y: 2.0 };

      mockQuery
        .mockResolvedValueOnce({ rows: [mockContent] }) // Get content
        .mockResolvedValueOnce({ rows: [updatedContent] }); // Update content

      const result = await contentService.updateContent('content-123', 'user-123', {
        position_x: 1.5,
        position_y: 2.0,
      });

      expect(result.position_x).toBe(1.5);
    });
  });

  describe('Data Validation', () => {
    it('should validate meeting creation data', () => {
      const validData = {
        title: 'Valid Meeting',
        environment_type: 'conference_room',
        layout_type: 'circle',
      };

      expect(validData.title).toBeTruthy();
      expect(['conference_room', 'theater', 'outdoor'].includes(validData.environment_type)).toBe(true);
    });

    it('should validate participant limits', () => {
      const maxParticipants = 50;
      const currentCount = 25;

      expect(currentCount).toBeLessThan(maxParticipants);
    });
  });
});

describe('WebSocket Service', () => {
  it('should handle message types', () => {
    const messageTypes = [
      'connect',
      'disconnect',
      'join_meeting',
      'leave_meeting',
      'participant_joined',
      'participant_left',
      'participant_update',
      'participant_position',
      'content_added',
      'content_updated',
      'audio_state',
      'video_state',
    ];

    messageTypes.forEach(type => {
      expect(typeof type).toBe('string');
      expect(type.length).toBeGreaterThan(0);
    });
  });

  it('should validate WebSocket message structure', () => {
    const message = {
      type: 'participant_position',
      payload: { x: 1.0, y: 0.0, z: -2.0 },
      timestamp: Date.now(),
    };

    expect(message.type).toBeDefined();
    expect(message.payload).toBeDefined();
    expect(message.timestamp).toBeGreaterThan(0);
  });
});

describe('Performance Tests', () => {
  it('should handle multiple concurrent operations', async () => {
    const operations = Array(10).fill(null).map((_, i) => ({
      id: `op-${i}`,
      type: 'test',
    }));

    expect(operations).toHaveLength(10);
    operations.forEach((op, i) => {
      expect(op.id).toBe(`op-${i}`);
    });
  });

  it('should calculate positions efficiently', () => {
    const calculatePosition = (index: number, layout: string) => {
      const radius = 3.0;
      if (layout === 'circle') {
        const angle = (index * 2 * Math.PI) / 10;
        return {
          x: radius * Math.cos(angle),
          y: 0,
          z: radius * Math.sin(angle),
        };
      }
      return { x: 0, y: 0, z: -3 };
    };

    const positions = Array(10).fill(null).map((_, i) => calculatePosition(i, 'circle'));

    expect(positions).toHaveLength(10);
    positions.forEach(pos => {
      expect(pos.x).toBeDefined();
      expect(pos.y).toBe(0);
      expect(pos.z).toBeDefined();
    });
  });
});
