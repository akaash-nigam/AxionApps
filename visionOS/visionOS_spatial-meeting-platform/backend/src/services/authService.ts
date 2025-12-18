import bcrypt from 'bcrypt';
import jwt from 'jsonwebtoken';
import { query } from '../config/database';
import { config } from '../config';
import { AppError } from '../middleware/errorHandler';
import { User } from '../types';

const SALT_ROUNDS = 10;

export class AuthService {
  async register(
    email: string,
    username: string,
    password: string,
    display_name: string
  ): Promise<{ user: Partial<User>; token: string }> {
    // Check if user exists
    const existingUser = await query(
      'SELECT id FROM users WHERE email = $1 OR username = $2',
      [email, username]
    );

    if (existingUser.rows.length > 0) {
      throw new AppError('User already exists with this email or username', 409);
    }

    // Hash password
    const password_hash = await bcrypt.hash(password, SALT_ROUNDS);

    // Create user
    const result = await query(
      `INSERT INTO users (email, username, password_hash, display_name)
       VALUES ($1, $2, $3, $4)
       RETURNING id, email, username, display_name, avatar_url, created_at, updated_at`,
      [email, username, password_hash, display_name]
    );

    const user = result.rows[0];

    // Generate token
    const token = jwt.sign({ userId: user.id }, config.jwt.secret, {
      expiresIn: config.jwt.expiresIn,
    });

    return { user, token };
  }

  async login(email: string, password: string): Promise<{ user: Partial<User>; token: string }> {
    // Get user
    const result = await query(
      'SELECT * FROM users WHERE email = $1',
      [email]
    );

    if (result.rows.length === 0) {
      throw new AppError('Invalid email or password', 401);
    }

    const user = result.rows[0];

    // Verify password
    const isValid = await bcrypt.compare(password, user.password_hash);

    if (!isValid) {
      throw new AppError('Invalid email or password', 401);
    }

    // Generate token
    const token = jwt.sign({ userId: user.id }, config.jwt.secret, {
      expiresIn: config.jwt.expiresIn,
    });

    // Remove password_hash from response
    const { password_hash, ...userWithoutPassword } = user;

    return { user: userWithoutPassword, token };
  }

  async getProfile(userId: string): Promise<Partial<User>> {
    const result = await query(
      'SELECT id, email, username, display_name, avatar_url, created_at, updated_at FROM users WHERE id = $1',
      [userId]
    );

    if (result.rows.length === 0) {
      throw new AppError('User not found', 404);
    }

    return result.rows[0];
  }

  async updateProfile(
    userId: string,
    updates: { display_name?: string; avatar_url?: string }
  ): Promise<Partial<User>> {
    const fields = [];
    const values = [];
    let index = 1;

    if (updates.display_name) {
      fields.push(`display_name = $${index++}`);
      values.push(updates.display_name);
    }

    if (updates.avatar_url) {
      fields.push(`avatar_url = $${index++}`);
      values.push(updates.avatar_url);
    }

    if (fields.length === 0) {
      throw new AppError('No fields to update', 400);
    }

    fields.push(`updated_at = CURRENT_TIMESTAMP`);
    values.push(userId);

    const result = await query(
      `UPDATE users SET ${fields.join(', ')} WHERE id = $${index}
       RETURNING id, email, username, display_name, avatar_url, created_at, updated_at`,
      values
    );

    return result.rows[0];
  }
}

export const authService = new AuthService();
