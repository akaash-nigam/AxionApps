import { create } from 'zustand';
import { authAPI } from '../services/api';
import { AuthState, User } from '../types';

export const useAuth = create<AuthState>((set) => ({
  user: null,
  token: localStorage.getItem('token'),
  isAuthenticated: !!localStorage.getItem('token'),

  login: async (email: string, password: string) => {
    try {
      const response = await authAPI.login(email, password);
      const { user, token } = response.data;

      localStorage.setItem('token', token);
      set({ user, token, isAuthenticated: true });
    } catch (error: any) {
      throw new Error(error.response?.data?.error || 'Login failed');
    }
  },

  register: async (email: string, username: string, password: string, display_name: string) => {
    try {
      const response = await authAPI.register(email, username, password, display_name);
      const { user, token } = response.data;

      localStorage.setItem('token', token);
      set({ user, token, isAuthenticated: true });
    } catch (error: any) {
      throw new Error(error.response?.data?.error || 'Registration failed');
    }
  },

  logout: () => {
    localStorage.removeItem('token');
    set({ user: null, token: null, isAuthenticated: false });
  },
}));
