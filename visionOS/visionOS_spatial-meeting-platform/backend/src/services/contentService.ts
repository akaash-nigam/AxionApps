import { query } from '../config/database';
import { AppError } from '../middleware/errorHandler';
import { SharedContent } from '../types';

export class ContentService {
  async createContent(
    meetingId: string,
    creatorId: string,
    data: {
      title: string;
      content_type: string;
      content_url: string;
      position_x?: number;
      position_y?: number;
      position_z?: number;
      scale?: number;
    }
  ): Promise<SharedContent> {
    // Verify user is in the meeting
    const participant = await query(
      'SELECT * FROM participants WHERE meeting_id = $1 AND user_id = $2 AND left_at IS NULL',
      [meetingId, creatorId]
    );

    if (participant.rows.length === 0) {
      throw new AppError('Must be in the meeting to share content', 403);
    }

    const result = await query(
      `INSERT INTO shared_content
       (meeting_id, creator_id, title, content_type, content_url, position_x, position_y, position_z, scale)
       VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9)
       RETURNING *`,
      [
        meetingId,
        creatorId,
        data.title,
        data.content_type,
        data.content_url,
        data.position_x || 0,
        data.position_y || 1.5,
        data.position_z || -2,
        data.scale || 1
      ]
    );

    return result.rows[0];
  }

  async getContent(meetingId: string): Promise<SharedContent[]> {
    const result = await query(
      `SELECT c.*, u.username as creator_username, u.display_name as creator_name
       FROM shared_content c
       LEFT JOIN users u ON c.creator_id = u.id
       WHERE c.meeting_id = $1
       ORDER BY c.created_at DESC`,
      [meetingId]
    );

    return result.rows;
  }

  async updateContent(
    contentId: string,
    userId: string,
    updates: {
      position_x?: number;
      position_y?: number;
      position_z?: number;
      rotation_x?: number;
      rotation_y?: number;
      rotation_z?: number;
      scale?: number;
      is_locked?: boolean;
    }
  ): Promise<SharedContent> {
    // Check if content is locked
    const content = await query('SELECT * FROM shared_content WHERE id = $1', [contentId]);

    if (content.rows.length === 0) {
      throw new AppError('Content not found', 404);
    }

    if (content.rows[0].is_locked && content.rows[0].creator_id !== userId) {
      throw new AppError('Content is locked', 403);
    }

    const fields = [];
    const values = [];
    let index = 1;

    if (updates.position_x !== undefined) {
      fields.push(`position_x = $${index++}`);
      values.push(updates.position_x);
    }

    if (updates.position_y !== undefined) {
      fields.push(`position_y = $${index++}`);
      values.push(updates.position_y);
    }

    if (updates.position_z !== undefined) {
      fields.push(`position_z = $${index++}`);
      values.push(updates.position_z);
    }

    if (updates.rotation_x !== undefined) {
      fields.push(`rotation_x = $${index++}`);
      values.push(updates.rotation_x);
    }

    if (updates.rotation_y !== undefined) {
      fields.push(`rotation_y = $${index++}`);
      values.push(updates.rotation_y);
    }

    if (updates.rotation_z !== undefined) {
      fields.push(`rotation_z = $${index++}`);
      values.push(updates.rotation_z);
    }

    if (updates.scale !== undefined) {
      fields.push(`scale = $${index++}`);
      values.push(updates.scale);
    }

    if (updates.is_locked !== undefined && content.rows[0].creator_id === userId) {
      fields.push(`is_locked = $${index++}`);
      values.push(updates.is_locked);
    }

    if (fields.length === 0) {
      throw new AppError('No fields to update', 400);
    }

    fields.push(`updated_at = CURRENT_TIMESTAMP`);
    values.push(contentId);

    const result = await query(
      `UPDATE shared_content SET ${fields.join(', ')} WHERE id = $${index} RETURNING *`,
      values
    );

    return result.rows[0];
  }

  async deleteContent(contentId: string, userId: string): Promise<void> {
    const content = await query('SELECT * FROM shared_content WHERE id = $1', [contentId]);

    if (content.rows.length === 0) {
      throw new AppError('Content not found', 404);
    }

    // Only creator or meeting host can delete
    const meeting = await query('SELECT host_id FROM meetings WHERE id = $1', [content.rows[0].meeting_id]);

    if (content.rows[0].creator_id !== userId && meeting.rows[0].host_id !== userId) {
      throw new AppError('Only creator or host can delete content', 403);
    }

    await query('DELETE FROM shared_content WHERE id = $1', [contentId]);
  }
}

export const contentService = new ContentService();
