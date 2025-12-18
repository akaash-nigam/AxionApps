export const swaggerDocument = {
  openapi: '3.0.0',
  info: {
    title: 'Spatial Meeting Platform API',
    version: '1.0.0',
    description: 'REST API and WebSocket documentation for the Spatial Meeting Platform',
    contact: {
      name: 'Spatial Meeting Platform Team',
      email: 'support@spatialmeeting.com',
    },
    license: {
      name: 'MIT',
      url: 'https://opensource.org/licenses/MIT',
    },
  },
  servers: [
    {
      url: 'http://localhost:3000/api',
      description: 'Development server',
    },
    {
      url: 'https://api.spatialmeeting.com/api',
      description: 'Production server',
    },
  ],
  components: {
    securitySchemes: {
      bearerAuth: {
        type: 'http',
        scheme: 'bearer',
        bearerFormat: 'JWT',
      },
    },
    schemas: {
      User: {
        type: 'object',
        properties: {
          id: { type: 'string', format: 'uuid' },
          email: { type: 'string', format: 'email' },
          username: { type: 'string' },
          display_name: { type: 'string' },
          avatar_url: { type: 'string', format: 'uri', nullable: true },
          created_at: { type: 'string', format: 'date-time' },
          updated_at: { type: 'string', format: 'date-time' },
        },
      },
      Meeting: {
        type: 'object',
        properties: {
          id: { type: 'string', format: 'uuid' },
          title: { type: 'string' },
          description: { type: 'string', nullable: true },
          host_id: { type: 'string', format: 'uuid' },
          environment_type: {
            type: 'string',
            enum: ['conference_room', 'theater', 'outdoor', 'creative_studio', 'executive_boardroom', 'casual_lounge'],
          },
          layout_type: {
            type: 'string',
            enum: ['circle', 'theater', 'u_shape', 'classroom', 'custom'],
          },
          status: {
            type: 'string',
            enum: ['scheduled', 'active', 'ended', 'cancelled'],
          },
          max_participants: { type: 'integer', minimum: 2, maximum: 100 },
          scheduled_start: { type: 'string', format: 'date-time', nullable: true },
          scheduled_end: { type: 'string', format: 'date-time', nullable: true },
          actual_start: { type: 'string', format: 'date-time', nullable: true },
          actual_end: { type: 'string', format: 'date-time', nullable: true },
          created_at: { type: 'string', format: 'date-time' },
          updated_at: { type: 'string', format: 'date-time' },
        },
      },
      Participant: {
        type: 'object',
        properties: {
          id: { type: 'string', format: 'uuid' },
          meeting_id: { type: 'string', format: 'uuid' },
          user_id: { type: 'string', format: 'uuid' },
          role: {
            type: 'string',
            enum: ['host', 'presenter', 'participant', 'observer'],
          },
          position_x: { type: 'number', format: 'float' },
          position_y: { type: 'number', format: 'float' },
          position_z: { type: 'number', format: 'float' },
          rotation_x: { type: 'number', format: 'float' },
          rotation_y: { type: 'number', format: 'float' },
          rotation_z: { type: 'number', format: 'float' },
          is_speaking: { type: 'boolean' },
          is_muted: { type: 'boolean' },
          is_video_enabled: { type: 'boolean' },
          joined_at: { type: 'string', format: 'date-time' },
          left_at: { type: 'string', format: 'date-time', nullable: true },
        },
      },
      SharedContent: {
        type: 'object',
        properties: {
          id: { type: 'string', format: 'uuid' },
          meeting_id: { type: 'string', format: 'uuid' },
          creator_id: { type: 'string', format: 'uuid' },
          title: { type: 'string' },
          content_type: {
            type: 'string',
            enum: ['document', 'image', 'video', 'model_3d', 'whiteboard', 'screen_share'],
          },
          content_url: { type: 'string', format: 'uri' },
          position_x: { type: 'number', format: 'float' },
          position_y: { type: 'number', format: 'float' },
          position_z: { type: 'number', format: 'float' },
          scale: { type: 'number', format: 'float' },
          rotation_x: { type: 'number', format: 'float' },
          rotation_y: { type: 'number', format: 'float' },
          rotation_z: { type: 'number', format: 'float' },
          is_locked: { type: 'boolean' },
          created_at: { type: 'string', format: 'date-time' },
          updated_at: { type: 'string', format: 'date-time' },
        },
      },
      Error: {
        type: 'object',
        properties: {
          error: { type: 'string' },
        },
      },
    },
  },
  paths: {
    '/auth/register': {
      post: {
        tags: ['Authentication'],
        summary: 'Register a new user',
        requestBody: {
          required: true,
          content: {
            'application/json': {
              schema: {
                type: 'object',
                required: ['email', 'username', 'password', 'display_name'],
                properties: {
                  email: { type: 'string', format: 'email' },
                  username: { type: 'string', minLength: 3, maxLength: 100 },
                  password: { type: 'string', minLength: 8 },
                  display_name: { type: 'string', minLength: 1, maxLength: 255 },
                },
              },
            },
          },
        },
        responses: {
          '201': {
            description: 'User registered successfully',
            content: {
              'application/json': {
                schema: {
                  type: 'object',
                  properties: {
                    user: { $ref: '#/components/schemas/User' },
                    token: { type: 'string' },
                  },
                },
              },
            },
          },
          '409': {
            description: 'User already exists',
            content: {
              'application/json': {
                schema: { $ref: '#/components/schemas/Error' },
              },
            },
          },
        },
      },
    },
    '/auth/login': {
      post: {
        tags: ['Authentication'],
        summary: 'Login user',
        requestBody: {
          required: true,
          content: {
            'application/json': {
              schema: {
                type: 'object',
                required: ['email', 'password'],
                properties: {
                  email: { type: 'string', format: 'email' },
                  password: { type: 'string' },
                },
              },
            },
          },
        },
        responses: {
          '200': {
            description: 'Login successful',
            content: {
              'application/json': {
                schema: {
                  type: 'object',
                  properties: {
                    user: { $ref: '#/components/schemas/User' },
                    token: { type: 'string' },
                  },
                },
              },
            },
          },
          '401': {
            description: 'Invalid credentials',
            content: {
              'application/json': {
                schema: { $ref: '#/components/schemas/Error' },
              },
            },
          },
        },
      },
    },
    '/auth/profile': {
      get: {
        tags: ['Authentication'],
        summary: 'Get user profile',
        security: [{ bearerAuth: [] }],
        responses: {
          '200': {
            description: 'User profile',
            content: {
              'application/json': {
                schema: { $ref: '#/components/schemas/User' },
              },
            },
          },
          '401': {
            description: 'Unauthorized',
            content: {
              'application/json': {
                schema: { $ref: '#/components/schemas/Error' },
              },
            },
          },
        },
      },
      patch: {
        tags: ['Authentication'],
        summary: 'Update user profile',
        security: [{ bearerAuth: [] }],
        requestBody: {
          required: true,
          content: {
            'application/json': {
              schema: {
                type: 'object',
                properties: {
                  display_name: { type: 'string' },
                  avatar_url: { type: 'string', format: 'uri' },
                },
              },
            },
          },
        },
        responses: {
          '200': {
            description: 'Profile updated',
            content: {
              'application/json': {
                schema: { $ref: '#/components/schemas/User' },
              },
            },
          },
        },
      },
    },
    '/meetings': {
      get: {
        tags: ['Meetings'],
        summary: 'Get all meetings',
        security: [{ bearerAuth: [] }],
        parameters: [
          {
            name: 'status',
            in: 'query',
            schema: {
              type: 'string',
              enum: ['scheduled', 'active', 'ended', 'cancelled'],
            },
          },
          {
            name: 'limit',
            in: 'query',
            schema: { type: 'integer', default: 50 },
          },
          {
            name: 'offset',
            in: 'query',
            schema: { type: 'integer', default: 0 },
          },
        ],
        responses: {
          '200': {
            description: 'List of meetings',
            content: {
              'application/json': {
                schema: {
                  type: 'object',
                  properties: {
                    meetings: {
                      type: 'array',
                      items: { $ref: '#/components/schemas/Meeting' },
                    },
                    total: { type: 'integer' },
                  },
                },
              },
            },
          },
        },
      },
      post: {
        tags: ['Meetings'],
        summary: 'Create a new meeting',
        security: [{ bearerAuth: [] }],
        requestBody: {
          required: true,
          content: {
            'application/json': {
              schema: {
                type: 'object',
                required: ['title', 'environment_type', 'layout_type'],
                properties: {
                  title: { type: 'string' },
                  description: { type: 'string' },
                  environment_type: { type: 'string' },
                  layout_type: { type: 'string' },
                  max_participants: { type: 'integer' },
                  scheduled_start: { type: 'string', format: 'date-time' },
                  scheduled_end: { type: 'string', format: 'date-time' },
                },
              },
            },
          },
        },
        responses: {
          '201': {
            description: 'Meeting created',
            content: {
              'application/json': {
                schema: { $ref: '#/components/schemas/Meeting' },
              },
            },
          },
        },
      },
    },
    '/meetings/{id}': {
      get: {
        tags: ['Meetings'],
        summary: 'Get meeting by ID',
        security: [{ bearerAuth: [] }],
        parameters: [
          {
            name: 'id',
            in: 'path',
            required: true,
            schema: { type: 'string', format: 'uuid' },
          },
        ],
        responses: {
          '200': {
            description: 'Meeting details',
            content: {
              'application/json': {
                schema: { $ref: '#/components/schemas/Meeting' },
              },
            },
          },
          '404': {
            description: 'Meeting not found',
          },
        },
      },
      patch: {
        tags: ['Meetings'],
        summary: 'Update meeting',
        security: [{ bearerAuth: [] }],
        parameters: [
          {
            name: 'id',
            in: 'path',
            required: true,
            schema: { type: 'string', format: 'uuid' },
          },
        ],
        requestBody: {
          content: {
            'application/json': {
              schema: {
                type: 'object',
                properties: {
                  title: { type: 'string' },
                  description: { type: 'string' },
                  environment_type: { type: 'string' },
                  layout_type: { type: 'string' },
                  status: { type: 'string' },
                },
              },
            },
          },
        },
        responses: {
          '200': {
            description: 'Meeting updated',
            content: {
              'application/json': {
                schema: { $ref: '#/components/schemas/Meeting' },
              },
            },
          },
        },
      },
      delete: {
        tags: ['Meetings'],
        summary: 'Delete meeting',
        security: [{ bearerAuth: [] }],
        parameters: [
          {
            name: 'id',
            in: 'path',
            required: true,
            schema: { type: 'string', format: 'uuid' },
          },
        ],
        responses: {
          '204': {
            description: 'Meeting deleted',
          },
        },
      },
    },
    '/meetings/{id}/join': {
      post: {
        tags: ['Meetings'],
        summary: 'Join a meeting',
        security: [{ bearerAuth: [] }],
        parameters: [
          {
            name: 'id',
            in: 'path',
            required: true,
            schema: { type: 'string', format: 'uuid' },
          },
        ],
        requestBody: {
          content: {
            'application/json': {
              schema: {
                type: 'object',
                properties: {
                  role: {
                    type: 'string',
                    enum: ['host', 'presenter', 'participant', 'observer'],
                  },
                },
              },
            },
          },
        },
        responses: {
          '201': {
            description: 'Joined meeting',
            content: {
              'application/json': {
                schema: { $ref: '#/components/schemas/Participant' },
              },
            },
          },
        },
      },
    },
    '/meetings/{id}/participants': {
      get: {
        tags: ['Meetings'],
        summary: 'Get meeting participants',
        security: [{ bearerAuth: [] }],
        parameters: [
          {
            name: 'id',
            in: 'path',
            required: true,
            schema: { type: 'string', format: 'uuid' },
          },
        ],
        responses: {
          '200': {
            description: 'List of participants',
            content: {
              'application/json': {
                schema: {
                  type: 'array',
                  items: { $ref: '#/components/schemas/Participant' },
                },
              },
            },
          },
        },
      },
    },
  },
};
