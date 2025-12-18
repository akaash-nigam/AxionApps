import { query } from '../config/database';
import { AppError } from '../middleware/errorHandler';
import { Meeting, MeetingStatus, Participant, ParticipantRole, LayoutType } from '../types';
import { v4 as uuidv4 } from 'uuid';

export class MeetingService {
  async createMeeting(
    hostId: string,
    data: {
      title: string;
      description?: string;
      environment_type: string;
      layout_type: string;
      max_participants?: number;
      scheduled_start?: string;
      scheduled_end?: string;
    }
  ): Promise<Meeting> {
    const result = await query(
      `INSERT INTO meetings
       (title, description, host_id, environment_type, layout_type, max_participants, scheduled_start, scheduled_end, status)
       VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9)
       RETURNING *`,
      [
        data.title,
        data.description || null,
        hostId,
        data.environment_type,
        data.layout_type,
        data.max_participants || 50,
        data.scheduled_start || null,
        data.scheduled_end || null,
        'scheduled'
      ]
    );

    return result.rows[0];
  }

  async getMeeting(meetingId: string): Promise<Meeting> {
    const result = await query(
      'SELECT * FROM meetings WHERE id = $1',
      [meetingId]
    );

    if (result.rows.length === 0) {
      throw new AppError('Meeting not found', 404);
    }

    return result.rows[0];
  }

  async getMeetings(filters?: {
    status?: MeetingStatus;
    host_id?: string;
    limit?: number;
    offset?: number;
  }): Promise<{ meetings: Meeting[]; total: number }> {
    let whereClause = '';
    const params: any[] = [];
    let paramIndex = 1;

    if (filters?.status) {
      whereClause += ` WHERE status = $${paramIndex++}`;
      params.push(filters.status);
    }

    if (filters?.host_id) {
      whereClause += whereClause ? ' AND' : ' WHERE';
      whereClause += ` host_id = $${paramIndex++}`;
      params.push(filters.host_id);
    }

    const countResult = await query(
      `SELECT COUNT(*) FROM meetings${whereClause}`,
      params
    );

    const total = parseInt(countResult.rows[0].count);

    const limit = filters?.limit || 50;
    const offset = filters?.offset || 0;

    const result = await query(
      `SELECT * FROM meetings${whereClause} ORDER BY created_at DESC LIMIT $${paramIndex++} OFFSET $${paramIndex}`,
      [...params, limit, offset]
    );

    return { meetings: result.rows, total };
  }

  async updateMeeting(
    meetingId: string,
    userId: string,
    updates: {
      title?: string;
      description?: string;
      environment_type?: string;
      layout_type?: string;
      status?: MeetingStatus;
    }
  ): Promise<Meeting> {
    // Verify user is host
    const meeting = await this.getMeeting(meetingId);
    if (meeting.host_id !== userId) {
      throw new AppError('Only the host can update the meeting', 403);
    }

    const fields = [];
    const values = [];
    let index = 1;

    if (updates.title) {
      fields.push(`title = $${index++}`);
      values.push(updates.title);
    }

    if (updates.description !== undefined) {
      fields.push(`description = $${index++}`);
      values.push(updates.description);
    }

    if (updates.environment_type) {
      fields.push(`environment_type = $${index++}`);
      values.push(updates.environment_type);
    }

    if (updates.layout_type) {
      fields.push(`layout_type = $${index++}`);
      values.push(updates.layout_type);
    }

    if (updates.status) {
      fields.push(`status = $${index++}`);
      values.push(updates.status);

      // Update timestamps based on status
      if (updates.status === 'active' && !meeting.actual_start) {
        fields.push(`actual_start = CURRENT_TIMESTAMP`);
      } else if (updates.status === 'ended' && !meeting.actual_end) {
        fields.push(`actual_end = CURRENT_TIMESTAMP`);
      }
    }

    if (fields.length === 0) {
      throw new AppError('No fields to update', 400);
    }

    fields.push(`updated_at = CURRENT_TIMESTAMP`);
    values.push(meetingId);

    const result = await query(
      `UPDATE meetings SET ${fields.join(', ')} WHERE id = $${index} RETURNING *`,
      values
    );

    return result.rows[0];
  }

  async deleteMeeting(meetingId: string, userId: string): Promise<void> {
    const meeting = await this.getMeeting(meetingId);
    if (meeting.host_id !== userId) {
      throw new AppError('Only the host can delete the meeting', 403);
    }

    await query('DELETE FROM meetings WHERE id = $1', [meetingId]);
  }

  async joinMeeting(meetingId: string, userId: string, role?: ParticipantRole): Promise<Participant> {
    const meeting = await this.getMeeting(meetingId);

    // Check if meeting is active or scheduled
    if (meeting.status === 'ended' || meeting.status === 'cancelled') {
      throw new AppError('Cannot join ended or cancelled meeting', 400);
    }

    // Check if already joined
    const existingParticipant = await query(
      'SELECT * FROM participants WHERE meeting_id = $1 AND user_id = $2 AND left_at IS NULL',
      [meetingId, userId]
    );

    if (existingParticipant.rows.length > 0) {
      return existingParticipant.rows[0];
    }

    // Check participant limit
    const participantCount = await query(
      'SELECT COUNT(*) FROM participants WHERE meeting_id = $1 AND left_at IS NULL',
      [meetingId]
    );

    if (parseInt(participantCount.rows[0].count) >= meeting.max_participants) {
      throw new AppError('Meeting is full', 400);
    }

    // Determine role
    const participantRole = role || (meeting.host_id === userId ? 'host' : 'participant');

    // Calculate position based on layout
    const position = await this.calculateParticipantPosition(meetingId, meeting.layout_type);

    const result = await query(
      `INSERT INTO participants (meeting_id, user_id, role, position_x, position_y, position_z)
       VALUES ($1, $2, $3, $4, $5, $6)
       RETURNING *`,
      [meetingId, userId, participantRole, position.x, position.y, position.z]
    );

    // Update meeting status to active if not already
    if (meeting.status === 'scheduled') {
      await query(
        `UPDATE meetings SET status = 'active', actual_start = CURRENT_TIMESTAMP WHERE id = $1`,
        [meetingId]
      );
    }

    return result.rows[0];
  }

  async leaveMeeting(meetingId: string, userId: string): Promise<void> {
    const result = await query(
      `UPDATE participants SET left_at = CURRENT_TIMESTAMP
       WHERE meeting_id = $1 AND user_id = $2 AND left_at IS NULL
       RETURNING *`,
      [meetingId, userId]
    );

    if (result.rows.length === 0) {
      throw new AppError('Not in this meeting', 400);
    }
  }

  async getParticipants(meetingId: string): Promise<Participant[]> {
    const result = await query(
      `SELECT p.*, u.username, u.display_name, u.avatar_url
       FROM participants p
       JOIN users u ON p.user_id = u.id
       WHERE p.meeting_id = $1 AND p.left_at IS NULL
       ORDER BY p.joined_at`,
      [meetingId]
    );

    return result.rows;
  }

  async updateParticipantPosition(
    meetingId: string,
    userId: string,
    position: { x: number; y: number; z: number; rotX?: number; rotY?: number; rotZ?: number }
  ): Promise<Participant> {
    const result = await query(
      `UPDATE participants
       SET position_x = $1, position_y = $2, position_z = $3,
           rotation_x = $4, rotation_y = $5, rotation_z = $6
       WHERE meeting_id = $7 AND user_id = $8 AND left_at IS NULL
       RETURNING *`,
      [position.x, position.y, position.z, position.rotX || 0, position.rotY || 0, position.rotZ || 0, meetingId, userId]
    );

    if (result.rows.length === 0) {
      throw new AppError('Participant not found in meeting', 404);
    }

    return result.rows[0];
  }

  async updateParticipantAudioVideo(
    meetingId: string,
    userId: string,
    state: { is_muted?: boolean; is_video_enabled?: boolean; is_speaking?: boolean }
  ): Promise<Participant> {
    const fields = [];
    const values = [];
    let index = 1;

    if (state.is_muted !== undefined) {
      fields.push(`is_muted = $${index++}`);
      values.push(state.is_muted);
    }

    if (state.is_video_enabled !== undefined) {
      fields.push(`is_video_enabled = $${index++}`);
      values.push(state.is_video_enabled);
    }

    if (state.is_speaking !== undefined) {
      fields.push(`is_speaking = $${index++}`);
      values.push(state.is_speaking);
    }

    if (fields.length === 0) {
      throw new AppError('No fields to update', 400);
    }

    values.push(meetingId, userId);

    const result = await query(
      `UPDATE participants SET ${fields.join(', ')}
       WHERE meeting_id = $${index++} AND user_id = $${index} AND left_at IS NULL
       RETURNING *`,
      values
    );

    if (result.rows.length === 0) {
      throw new AppError('Participant not found in meeting', 404);
    }

    return result.rows[0];
  }

  private async calculateParticipantPosition(meetingId: string, layoutType: string): Promise<{ x: number; y: number; z: number }> {
    const participants = await query(
      'SELECT COUNT(*) FROM participants WHERE meeting_id = $1 AND left_at IS NULL',
      [meetingId]
    );

    const count = parseInt(participants.rows[0].count);
    const radius = 3.0;

    switch (layoutType) {
      case 'circle':
        const angle = (count * 2 * Math.PI) / 10; // Assume max 10 in circle
        return {
          x: radius * Math.cos(angle),
          y: 0,
          z: radius * Math.sin(angle)
        };

      case 'theater':
        const row = Math.floor(count / 5);
        const col = count % 5;
        return {
          x: (col - 2) * 1.2,
          y: 0,
          z: row * 1.5
        };

      case 'u_shape':
        if (count < 7) {
          const uAngle = (count * Math.PI) / 6;
          return {
            x: radius * Math.cos(uAngle),
            y: 0,
            z: radius * Math.sin(uAngle)
          };
        }
        return { x: 0, y: 0, z: -radius };

      default:
        return { x: 0, y: 0, z: -3 - count * 0.5 };
    }
  }
}

export const meetingService = new MeetingService();
