import { Router } from 'express';
import { authService } from '../services/authService';
import { authenticate, AuthRequest } from '../middleware/auth';
import { validate, schemas } from '../middleware/validation';
import { AppError } from '../middleware/errorHandler';

const router = Router();

// Register
router.post('/register', validate(schemas.register), async (req, res, next) => {
  try {
    const { email, username, password, display_name } = req.body;
    const result = await authService.register(email, username, password, display_name);
    res.status(201).json(result);
  } catch (error) {
    next(error);
  }
});

// Login
router.post('/login', validate(schemas.login), async (req, res, next) => {
  try {
    const { email, password } = req.body;
    const result = await authService.login(email, password);
    res.json(result);
  } catch (error) {
    next(error);
  }
});

// Get profile
router.get('/profile', authenticate, async (req: AuthRequest, res, next) => {
  try {
    if (!req.user) {
      throw new AppError('User not found', 404);
    }
    const profile = await authService.getProfile(req.user.id);
    res.json(profile);
  } catch (error) {
    next(error);
  }
});

// Update profile
router.patch('/profile', authenticate, async (req: AuthRequest, res, next) => {
  try {
    if (!req.user) {
      throw new AppError('User not found', 404);
    }
    const { display_name, avatar_url } = req.body;
    const updated = await authService.updateProfile(req.user.id, { display_name, avatar_url });
    res.json(updated);
  } catch (error) {
    next(error);
  }
});

export default router;
