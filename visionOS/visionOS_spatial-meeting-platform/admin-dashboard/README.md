# Spatial Meeting Platform - Admin Dashboard

Modern React admin dashboard for managing the Spatial Meeting Platform.

## Features

- **Dashboard**: Overview of meetings, users, and analytics
- **Meeting Management**: View, filter, and manage meetings
- **User Management**: User administration interface
- **Analytics**: Meeting engagement and performance metrics
- **Real-time Updates**: Live data synchronization
- **Authentication**: Secure login with JWT

## Technology Stack

- React 18
- TypeScript
- Vite (fast build tool)
- React Router (routing)
- Zustand (state management)
- Axios (HTTP client)
- Recharts (analytics charts)

## Quick Start

### Installation

```bash
# Install dependencies
npm install

# Set up environment variables
cp .env.example .env
```

### Development

```bash
# Start development server
npm run dev

# Admin dashboard will be available at:
# http://localhost:3002
```

### Build for Production

```bash
# Build optimized production bundle
npm run build

# Preview production build
npm run preview
```

## Configuration

Edit `.env` file:

```env
VITE_API_URL=http://localhost:3000/api
```

## Project Structure

```
admin-dashboard/
├── src/
│   ├── components/      # Reusable components
│   │   └── Layout.tsx   # Main layout with sidebar
│   ├── pages/           # Page components
│   │   ├── Login.tsx    # Login/Register page
│   │   ├── Dashboard.tsx
│   │   ├── Meetings.tsx
│   │   ├── Users.tsx
│   │   └── Analytics.tsx
│   ├── services/        # API services
│   │   └── api.ts       # API client
│   ├── hooks/           # Custom React hooks
│   │   └── useAuth.ts   # Authentication hook
│   ├── types/           # TypeScript types
│   ├── App.tsx          # Main app component
│   └── main.tsx         # Entry point
├── public/              # Static assets
└── index.html           # HTML template
```

## Pages

### Dashboard (`/`)
- Overview statistics
- Recent meetings list
- Quick actions

### Meetings (`/meetings`)
- All meetings list
- Filter by status (active, scheduled, ended)
- Delete meetings

### Users (`/users`)
- User management (coming soon)
- User permissions

### Analytics (`/analytics`)
- Meeting engagement metrics
- Duration analytics
- Participant trends
- Interactive charts (coming soon)

## Authentication

The dashboard uses JWT authentication:

1. Login or register at `/login`
2. Token is stored in localStorage
3. Token is automatically attached to API requests
4. Protected routes redirect to login if not authenticated

## API Integration

The dashboard communicates with the backend API at `http://localhost:3000/api`:

- `POST /auth/login` - Login
- `POST /auth/register` - Register
- `GET /meetings` - Get meetings
- `DELETE /meetings/:id` - Delete meeting
- And more...

## Development Notes

- Uses Vite for fast hot module replacement (HMR)
- TypeScript for type safety
- Zustand for lightweight state management
- Inline styles for simplicity (can be replaced with CSS modules or styled-components)

## Production Deployment

```bash
# Build for production
npm run build

# Deploy the /dist folder to your hosting service
# (Netlify, Vercel, AWS S3, etc.)
```

## Future Enhancements

- [ ] User management interface
- [ ] Real-time WebSocket updates
- [ ] Advanced analytics with Recharts
- [ ] Meeting creation/editing
- [ ] Participant monitoring
- [ ] Content management
- [ ] Export functionality
- [ ] Dark mode
- [ ] Mobile responsive improvements

## License

MIT
