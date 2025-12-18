import { Pool } from 'pg';
import dotenv from 'dotenv';
import { logger } from '../utils/logger';

dotenv.config();

export const pool = new Pool({
  host: process.env.DB_HOST || 'localhost',
  port: parseInt(process.env.DB_PORT || '5432'),
  database: process.env.DB_NAME || 'spatial_meetings',
  user: process.env.DB_USER || 'postgres',
  password: process.env.DB_PASSWORD || 'postgres',
  max: 20,
  idleTimeoutMillis: 30000,
  connectionTimeoutMillis: 2000,
});

pool.on('error', (err) => {
  logger.error('Unexpected database error', err);
  process.exit(-1);
});

export const initDatabase = async (): Promise<void> => {
  const client = await pool.connect();

  try {
    logger.info('Initializing database schema...');

    // Create tables
    await client.query(`
      CREATE TABLE IF NOT EXISTS users (
        id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
        email VARCHAR(255) UNIQUE NOT NULL,
        username VARCHAR(100) UNIQUE NOT NULL,
        password_hash VARCHAR(255) NOT NULL,
        display_name VARCHAR(255) NOT NULL,
        avatar_url TEXT,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      );

      CREATE TABLE IF NOT EXISTS meetings (
        id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
        title VARCHAR(255) NOT NULL,
        description TEXT,
        host_id UUID REFERENCES users(id) ON DELETE CASCADE,
        environment_type VARCHAR(50) NOT NULL,
        layout_type VARCHAR(50) NOT NULL,
        status VARCHAR(50) DEFAULT 'scheduled',
        max_participants INTEGER DEFAULT 50,
        scheduled_start TIMESTAMP,
        scheduled_end TIMESTAMP,
        actual_start TIMESTAMP,
        actual_end TIMESTAMP,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      );

      CREATE TABLE IF NOT EXISTS participants (
        id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
        meeting_id UUID REFERENCES meetings(id) ON DELETE CASCADE,
        user_id UUID REFERENCES users(id) ON DELETE CASCADE,
        role VARCHAR(50) DEFAULT 'participant',
        position_x FLOAT DEFAULT 0,
        position_y FLOAT DEFAULT 0,
        position_z FLOAT DEFAULT 0,
        rotation_x FLOAT DEFAULT 0,
        rotation_y FLOAT DEFAULT 0,
        rotation_z FLOAT DEFAULT 0,
        is_speaking BOOLEAN DEFAULT false,
        is_muted BOOLEAN DEFAULT false,
        is_video_enabled BOOLEAN DEFAULT true,
        joined_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        left_at TIMESTAMP,
        UNIQUE(meeting_id, user_id)
      );

      CREATE TABLE IF NOT EXISTS shared_content (
        id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
        meeting_id UUID REFERENCES meetings(id) ON DELETE CASCADE,
        creator_id UUID REFERENCES users(id) ON DELETE SET NULL,
        title VARCHAR(255) NOT NULL,
        content_type VARCHAR(50) NOT NULL,
        content_url TEXT NOT NULL,
        position_x FLOAT DEFAULT 0,
        position_y FLOAT DEFAULT 1.5,
        position_z FLOAT DEFAULT -2,
        scale FLOAT DEFAULT 1,
        rotation_x FLOAT DEFAULT 0,
        rotation_y FLOAT DEFAULT 0,
        rotation_z FLOAT DEFAULT 0,
        is_locked BOOLEAN DEFAULT false,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      );

      CREATE TABLE IF NOT EXISTS meeting_analytics (
        id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
        meeting_id UUID REFERENCES meetings(id) ON DELETE CASCADE UNIQUE,
        total_participants INTEGER DEFAULT 0,
        peak_participants INTEGER DEFAULT 0,
        average_duration_minutes INTEGER DEFAULT 0,
        engagement_score FLOAT DEFAULT 0,
        content_shared_count INTEGER DEFAULT 0,
        speaking_time_distribution JSONB DEFAULT '{}',
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      );

      CREATE INDEX IF NOT EXISTS idx_meetings_host ON meetings(host_id);
      CREATE INDEX IF NOT EXISTS idx_meetings_status ON meetings(status);
      CREATE INDEX IF NOT EXISTS idx_participants_meeting ON participants(meeting_id);
      CREATE INDEX IF NOT EXISTS idx_participants_user ON participants(user_id);
      CREATE INDEX IF NOT EXISTS idx_content_meeting ON shared_content(meeting_id);
    `);

    logger.info('Database schema initialized successfully');
  } catch (error) {
    logger.error('Failed to initialize database', error);
    throw error;
  } finally {
    client.release();
  }
};

export const query = (text: string, params?: any[]) => pool.query(text, params);
