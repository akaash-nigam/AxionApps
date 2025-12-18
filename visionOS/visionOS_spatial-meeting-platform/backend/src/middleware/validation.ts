import { Request, Response, NextFunction } from 'express';
import { z } from 'zod';
import { AppError } from './errorHandler';

export const validate = (schema: z.ZodSchema) => {
  return (req: Request, res: Response, next: NextFunction): void => {
    try {
      schema.parse({
        body: req.body,
        query: req.query,
        params: req.params,
      });
      next();
    } catch (error) {
      if (error instanceof z.ZodError) {
        const messages = error.errors.map(e => `${e.path.join('.')}: ${e.message}`);
        next(new AppError(`Validation failed: ${messages.join(', ')}`, 400));
      } else {
        next(error);
      }
    }
  };
};

// Common validation schemas
export const schemas = {
  register: z.object({
    body: z.object({
      email: z.string().email(),
      username: z.string().min(3).max(100),
      password: z.string().min(8),
      display_name: z.string().min(1).max(255),
    }),
  }),

  login: z.object({
    body: z.object({
      email: z.string().email(),
      password: z.string(),
    }),
  }),

  createMeeting: z.object({
    body: z.object({
      title: z.string().min(1).max(255),
      description: z.string().optional(),
      environment_type: z.enum(['conference_room', 'theater', 'outdoor', 'creative_studio', 'executive_boardroom', 'casual_lounge']),
      layout_type: z.enum(['circle', 'theater', 'u_shape', 'classroom', 'custom']),
      max_participants: z.number().int().min(2).max(100).optional(),
      scheduled_start: z.string().datetime().optional(),
      scheduled_end: z.string().datetime().optional(),
    }),
  }),

  updateMeeting: z.object({
    body: z.object({
      title: z.string().min(1).max(255).optional(),
      description: z.string().optional(),
      environment_type: z.enum(['conference_room', 'theater', 'outdoor', 'creative_studio', 'executive_boardroom', 'casual_lounge']).optional(),
      layout_type: z.enum(['circle', 'theater', 'u_shape', 'classroom', 'custom']).optional(),
      status: z.enum(['scheduled', 'active', 'ended', 'cancelled']).optional(),
    }),
  }),

  joinMeeting: z.object({
    body: z.object({
      role: z.enum(['host', 'presenter', 'participant', 'observer']).optional(),
    }),
  }),

  createContent: z.object({
    body: z.object({
      title: z.string().min(1).max(255),
      content_type: z.enum(['document', 'image', 'video', 'model_3d', 'whiteboard', 'screen_share']),
      content_url: z.string().url(),
      position_x: z.number().optional(),
      position_y: z.number().optional(),
      position_z: z.number().optional(),
      scale: z.number().positive().optional(),
    }),
  }),
};
