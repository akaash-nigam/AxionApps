export interface User {
  id: string;
  email: string;
  username: string;
  display_name: string;
  avatar_url?: string;
  created_at: string;
  updated_at: string;
}

export interface Meeting {
  id: string;
  title: string;
  description?: string;
  host_id: string;
  environment_type: string;
  layout_type: string;
  status: 'scheduled' | 'active' | 'ended' | 'cancelled';
  max_participants: number;
  scheduled_start?: string;
  scheduled_end?: string;
  actual_start?: string;
  actual_end?: string;
  created_at: string;
  updated_at: string;
}

export interface Participant {
  id: string;
  meeting_id: string;
  user_id: string;
  role: string;
  username?: string;
  display_name?: string;
  is_speaking: boolean;
  is_muted: boolean;
  is_video_enabled: boolean;
  joined_at: string;
  left_at?: string;
}

export interface SharedContent {
  id: string;
  meeting_id: string;
  creator_id: string;
  creator_username?: string;
  title: string;
  content_type: string;
  content_url: string;
  created_at: string;
}

export interface AuthState {
  user: User | null;
  token: string | null;
  login: (email: string, password: string) => Promise<void>;
  register: (email: string, username: string, password: string, display_name: string) => Promise<void>;
  logout: () => void;
  isAuthenticated: boolean;
}

export interface DashboardStats {
  totalUsers: number;
  activeMeetings: number;
  totalMeetings: number;
  activeParticipants: number;
}
