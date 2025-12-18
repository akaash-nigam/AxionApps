import { Router } from 'express';
import { contentService } from '../services/contentService';
import { authenticate, AuthRequest } from '../middleware/auth';
import { validate, schemas } from '../middleware/validation';
import { AppError } from '../middleware/errorHandler';

const router = Router();

// All routes require authentication
router.use(authenticate);

// Create content in meeting
router.post('/meetings/:meetingId/content', validate(schemas.createContent), async (req: AuthRequest, res, next) => {
  try {
    if (!req.user) {
      throw new AppError('User not found', 404);
    }
    const content = await contentService.createContent(req.params.meetingId, req.user.id, req.body);
    res.status(201).json(content);
  } catch (error) {
    next(error);
  }
});

// Get content in meeting
router.get('/meetings/:meetingId/content', async (req, res, next) => {
  try {
    const content = await contentService.getContent(req.params.meetingId);
    res.json(content);
  } catch (error) {
    next(error);
  }
});

// Update content
router.patch('/content/:id', async (req: AuthRequest, res, next) => {
  try {
    if (!req.user) {
      throw new AppError('User not found', 404);
    }
    const content = await contentService.updateContent(req.params.id, req.user.id, req.body);
    res.json(content);
  } catch (error) {
    next(error);
  }
});

// Delete content
router.delete('/content/:id', async (req: AuthRequest, res, next) => {
  try {
    if (!req.user) {
      throw new AppError('User not found', 404);
    }
    await contentService.deleteContent(req.params.id, req.user.id);
    res.status(204).send();
  } catch (error) {
    next(error);
  }
});

export default router;
