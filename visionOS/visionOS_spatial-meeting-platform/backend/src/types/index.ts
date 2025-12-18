export interface User {
  id: string;
  email: string;
  username: string;
  password_hash: string;
  display_name: string;
  avatar_url?: string;
  created_at: Date;
  updated_at: Date;
}

export interface Meeting {
  id: string;
  title: string;
  description?: string;
  host_id: string;
  environment_type: EnvironmentType;
  layout_type: LayoutType;
  status: MeetingStatus;
  max_participants: number;
  scheduled_start?: Date;
  scheduled_end?: Date;
  actual_start?: Date;
  actual_end?: Date;
  created_at: Date;
  updated_at: Date;
}

export interface Participant {
  id: string;
  meeting_id: string;
  user_id: string;
  role: ParticipantRole;
  position_x: number;
  position_y: number;
  position_z: number;
  rotation_x: number;
  rotation_y: number;
  rotation_z: number;
  is_speaking: boolean;
  is_muted: boolean;
  is_video_enabled: boolean;
  joined_at: Date;
  left_at?: Date;
}

export interface SharedContent {
  id: string;
  meeting_id: string;
  creator_id: string;
  title: string;
  content_type: ContentType;
  content_url: string;
  position_x: number;
  position_y: number;
  position_z: number;
  scale: number;
  rotation_x: number;
  rotation_y: number;
  rotation_z: number;
  is_locked: boolean;
  created_at: Date;
  updated_at: Date;
}

export interface MeetingAnalytics {
  id: string;
  meeting_id: string;
  total_participants: number;
  peak_participants: number;
  average_duration_minutes: number;
  engagement_score: number;
  content_shared_count: number;
  speaking_time_distribution: Record<string, number>;
  created_at: Date;
}

export enum EnvironmentType {
  CONFERENCE_ROOM = 'conference_room',
  THEATER = 'theater',
  OUTDOOR = 'outdoor',
  CREATIVE_STUDIO = 'creative_studio',
  EXECUTIVE_BOARDROOM = 'executive_boardroom',
  CASUAL_LOUNGE = 'casual_lounge'
}

export enum LayoutType {
  CIRCLE = 'circle',
  THEATER = 'theater',
  U_SHAPE = 'u_shape',
  CLASSROOM = 'classroom',
  CUSTOM = 'custom'
}

export enum MeetingStatus {
  SCHEDULED = 'scheduled',
  ACTIVE = 'active',
  ENDED = 'ended',
  CANCELLED = 'cancelled'
}

export enum ParticipantRole {
  HOST = 'host',
  PRESENTER = 'presenter',
  PARTICIPANT = 'participant',
  OBSERVER = 'observer'
}

export enum ContentType {
  DOCUMENT = 'document',
  IMAGE = 'image',
  VIDEO = 'video',
  MODEL_3D = 'model_3d',
  WHITEBOARD = 'whiteboard',
  SCREEN_SHARE = 'screen_share'
}

export interface WSMessage {
  type: WSMessageType;
  payload: any;
  timestamp: number;
}

export enum WSMessageType {
  // Connection
  CONNECT = 'connect',
  DISCONNECT = 'disconnect',

  // Meeting
  JOIN_MEETING = 'join_meeting',
  LEAVE_MEETING = 'leave_meeting',
  MEETING_UPDATE = 'meeting_update',

  // Participants
  PARTICIPANT_JOINED = 'participant_joined',
  PARTICIPANT_LEFT = 'participant_left',
  PARTICIPANT_UPDATE = 'participant_update',
  PARTICIPANT_POSITION = 'participant_position',

  // Content
  CONTENT_ADDED = 'content_added',
  CONTENT_UPDATED = 'content_updated',
  CONTENT_REMOVED = 'content_removed',

  // Audio/Video
  AUDIO_STATE = 'audio_state',
  VIDEO_STATE = 'video_state',
  SPEAKING_STATE = 'speaking_state',

  // System
  ERROR = 'error',
  PING = 'ping',
  PONG = 'pong'
}

export interface AuthRequest extends Request {
  user?: User;
}
