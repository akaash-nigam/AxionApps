import axios from 'axios';

const API_URL = import.meta.env.VITE_API_URL || 'http://localhost:3000/api';

const api = axios.create({
  baseURL: API_URL,
  headers: {
    'Content-Type': 'application/json',
  },
});

// Add auth token to requests
api.interceptors.request.use((config) => {
  const token = localStorage.getItem('token');
  if (token) {
    config.headers.Authorization = `Bearer ${token}`;
  }
  return config;
});

// Auth API
export const authAPI = {
  login: (email: string, password: string) =>
    api.post('/auth/login', { email, password }),

  register: (email: string, username: string, password: string, display_name: string) =>
    api.post('/auth/register', { email, username, password, display_name }),

  getProfile: () => api.get('/auth/profile'),
};

// Meetings API
export const meetingsAPI = {
  getAll: (params?: { status?: string; limit?: number; offset?: number }) =>
    api.get('/meetings', { params }),

  getById: (id: string) => api.get(`/meetings/${id}`),

  create: (data: any) => api.post('/meetings', data),

  update: (id: string, data: any) => api.patch(`/meetings/${id}`, data),

  delete: (id: string) => api.delete(`/meetings/${id}`),

  getParticipants: (id: string) => api.get(`/meetings/${id}/participants`),

  join: (id: string, role?: string) => api.post(`/meetings/${id}/join`, { role }),

  leave: (id: string) => api.post(`/meetings/${id}/leave`),
};

// Content API
export const contentAPI = {
  getByMeeting: (meetingId: string) =>
    api.get(`/meetings/${meetingId}/content`),

  create: (meetingId: string, data: any) =>
    api.post(`/meetings/${meetingId}/content`, data),

  update: (id: string, data: any) => api.patch(`/content/${id}`, data),

  delete: (id: string) => api.delete(`/content/${id}`),
};

export default api;
