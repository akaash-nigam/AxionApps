import { Router } from 'express';
import { meetingService } from '../services/meetingService';
import { authenticate, AuthRequest } from '../middleware/auth';
import { validate, schemas } from '../middleware/validation';
import { AppError } from '../middleware/errorHandler';

const router = Router();

// All routes require authentication
router.use(authenticate);

// Create meeting
router.post('/', validate(schemas.createMeeting), async (req: AuthRequest, res, next) => {
  try {
    if (!req.user) {
      throw new AppError('User not found', 404);
    }
    const meeting = await meetingService.createMeeting(req.user.id, req.body);
    res.status(201).json(meeting);
  } catch (error) {
    next(error);
  }
});

// Get meetings
router.get('/', async (req: AuthRequest, res, next) => {
  try {
    const { status, host_id, limit, offset } = req.query;
    const result = await meetingService.getMeetings({
      status: status as any,
      host_id: host_id as string,
      limit: limit ? parseInt(limit as string) : undefined,
      offset: offset ? parseInt(offset as string) : undefined,
    });
    res.json(result);
  } catch (error) {
    next(error);
  }
});

// Get meeting by ID
router.get('/:id', async (req, res, next) => {
  try {
    const meeting = await meetingService.getMeeting(req.params.id);
    res.json(meeting);
  } catch (error) {
    next(error);
  }
});

// Update meeting
router.patch('/:id', validate(schemas.updateMeeting), async (req: AuthRequest, res, next) => {
  try {
    if (!req.user) {
      throw new AppError('User not found', 404);
    }
    const meeting = await meetingService.updateMeeting(req.params.id, req.user.id, req.body);
    res.json(meeting);
  } catch (error) {
    next(error);
  }
});

// Delete meeting
router.delete('/:id', async (req: AuthRequest, res, next) => {
  try {
    if (!req.user) {
      throw new AppError('User not found', 404);
    }
    await meetingService.deleteMeeting(req.params.id, req.user.id);
    res.status(204).send();
  } catch (error) {
    next(error);
  }
});

// Join meeting
router.post('/:id/join', validate(schemas.joinMeeting), async (req: AuthRequest, res, next) => {
  try {
    if (!req.user) {
      throw new AppError('User not found', 404);
    }
    const participant = await meetingService.joinMeeting(req.params.id, req.user.id, req.body.role);
    res.status(201).json(participant);
  } catch (error) {
    next(error);
  }
});

// Leave meeting
router.post('/:id/leave', async (req: AuthRequest, res, next) => {
  try {
    if (!req.user) {
      throw new AppError('User not found', 404);
    }
    await meetingService.leaveMeeting(req.params.id, req.user.id);
    res.status(204).send();
  } catch (error) {
    next(error);
  }
});

// Get participants
router.get('/:id/participants', async (req, res, next) => {
  try {
    const participants = await meetingService.getParticipants(req.params.id);
    res.json(participants);
  } catch (error) {
    next(error);
  }
});

// Update participant position
router.patch('/:id/participants/position', async (req: AuthRequest, res, next) => {
  try {
    if (!req.user) {
      throw new AppError('User not found', 404);
    }
    const { x, y, z, rotX, rotY, rotZ } = req.body;
    const participant = await meetingService.updateParticipantPosition(
      req.params.id,
      req.user.id,
      { x, y, z, rotX, rotY, rotZ }
    );
    res.json(participant);
  } catch (error) {
    next(error);
  }
});

// Update participant audio/video
router.patch('/:id/participants/av', async (req: AuthRequest, res, next) => {
  try {
    if (!req.user) {
      throw new AppError('User not found', 404);
    }
    const { is_muted, is_video_enabled, is_speaking } = req.body;
    const participant = await meetingService.updateParticipantAudioVideo(
      req.params.id,
      req.user.id,
      { is_muted, is_video_enabled, is_speaking }
    );
    res.json(participant);
  } catch (error) {
    next(error);
  }
});

export default router;
