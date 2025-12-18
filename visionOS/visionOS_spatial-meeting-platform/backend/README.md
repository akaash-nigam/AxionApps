# Spatial Meeting Platform - Backend API

Production-ready backend server for the Spatial Meeting Platform with REST API, WebSocket support, and PostgreSQL database.

## Features

- **REST API**: Complete CRUD operations for users, meetings, participants, and content
- **WebSocket Server**: Real-time synchronization for live meetings
- **Authentication**: JWT-based authentication with bcrypt password hashing
- **Database**: PostgreSQL with comprehensive schema
- **Validation**: Input validation using Zod
- **Logging**: Winston-based logging system
- **Security**: Helmet, CORS, rate limiting
- **TypeScript**: Full type safety

## Quick Start

### Prerequisites

- Node.js 18+
- PostgreSQL 14+
- npm or yarn

### Installation

```bash
# Install dependencies
npm install

# Set up environment variables
cp .env.example .env
# Edit .env with your database credentials

# Start PostgreSQL (if not running)
# macOS: brew services start postgresql
# Linux: sudo service postgresql start

# Run in development mode
npm run dev
```

### Build for Production

```bash
# Build TypeScript
npm run build

# Start production server
npm start
```

## API Endpoints

### Authentication

- `POST /api/auth/register` - Register new user
- `POST /api/auth/login` - Login user
- `GET /api/auth/profile` - Get user profile (requires auth)
- `PATCH /api/auth/profile` - Update profile (requires auth)

### Meetings

- `POST /api/meetings` - Create meeting
- `GET /api/meetings` - List meetings
- `GET /api/meetings/:id` - Get meeting details
- `PATCH /api/meetings/:id` - Update meeting
- `DELETE /api/meetings/:id` - Delete meeting
- `POST /api/meetings/:id/join` - Join meeting
- `POST /api/meetings/:id/leave` - Leave meeting
- `GET /api/meetings/:id/participants` - Get participants
- `PATCH /api/meetings/:id/participants/position` - Update position
- `PATCH /api/meetings/:id/participants/av` - Update audio/video state

### Content

- `POST /api/meetings/:meetingId/content` - Create shared content
- `GET /api/meetings/:meetingId/content` - Get meeting content
- `PATCH /api/content/:id` - Update content
- `DELETE /api/content/:id` - Delete content

## WebSocket API

Connect to WebSocket server:

```javascript
const ws = new WebSocket('ws://localhost:3001?token=YOUR_JWT_TOKEN');
```

### Message Types

**Join Meeting:**
```json
{
  "type": "join_meeting",
  "payload": { "meetingId": "meeting-123" },
  "timestamp": 1234567890
}
```

**Update Position:**
```json
{
  "type": "participant_position",
  "payload": { "x": 1.0, "y": 0.0, "z": -2.0 },
  "timestamp": 1234567890
}
```

**Audio/Video State:**
```json
{
  "type": "audio_state",
  "payload": { "is_muted": true },
  "timestamp": 1234567890
}
```

## Testing

```bash
# Run tests
npm test

# Run tests in watch mode
npm run test:watch

# Run with coverage
npm test -- --coverage
```

## Database Schema

The backend uses PostgreSQL with the following tables:

- **users** - User accounts
- **meetings** - Meeting sessions
- **participants** - Meeting participants
- **shared_content** - Shared content in meetings
- **meeting_analytics** - Meeting analytics data

## Environment Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `NODE_ENV` | Environment | development |
| `PORT` | HTTP server port | 3000 |
| `WS_PORT` | WebSocket port | 3001 |
| `DB_HOST` | PostgreSQL host | localhost |
| `DB_PORT` | PostgreSQL port | 5432 |
| `DB_NAME` | Database name | spatial_meetings |
| `DB_USER` | Database user | postgres |
| `DB_PASSWORD` | Database password | postgres |
| `JWT_SECRET` | JWT secret key | (required) |
| `JWT_EXPIRES_IN` | JWT expiration | 7d |
| `CORS_ORIGIN` | CORS allowed origins | http://localhost:3000 |

## Architecture

```
backend/
├── src/
│   ├── config/         # Configuration files
│   ├── middleware/     # Express middleware
│   ├── models/         # Data models (future ORM)
│   ├── routes/         # API routes
│   ├── services/       # Business logic
│   ├── types/          # TypeScript types
│   ├── utils/          # Utilities
│   └── index.ts        # Entry point
├── tests/              # Test files
└── logs/               # Log files
```

## Security

- JWT authentication for all protected routes
- Bcrypt password hashing (10 rounds)
- Helmet.js for HTTP security headers
- CORS configuration
- Rate limiting (100 requests per 15 minutes)
- Input validation with Zod
- SQL injection prevention via parameterized queries

## Performance

- Connection pooling for PostgreSQL (max 20 connections)
- WebSocket heartbeat (30s intervals)
- Efficient spatial positioning algorithms
- Indexed database queries

## Development

```bash
# Install dependencies
npm install

# Run development server with hot reload
npm run dev

# Lint code
npm run lint

# Run database migrations
npm run migrate

# Seed database with test data
npm run seed
```

## Production Deployment

1. Build the application:
   ```bash
   npm run build
   ```

2. Set production environment variables

3. Start the server:
   ```bash
   npm start
   ```

4. Use a process manager like PM2:
   ```bash
   pm2 start dist/index.js --name spatial-meeting-backend
   ```

## License

MIT
