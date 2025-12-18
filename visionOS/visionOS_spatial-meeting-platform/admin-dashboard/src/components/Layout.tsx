import React from 'react';
import { Link, useLocation } from 'react-router-dom';
import { useAuth } from '../hooks/useAuth';

interface LayoutProps {
  children: React.ReactNode;
}

export const Layout: React.FC<LayoutProps> = ({ children }) => {
  const location = useLocation();
  const { user, logout } = useAuth();

  const navItems = [
    { path: '/', label: 'Dashboard', icon: '📊' },
    { path: '/meetings', label: 'Meetings', icon: '🏢' },
    { path: '/users', label: 'Users', icon: '👥' },
    { path: '/analytics', label: 'Analytics', icon: '📈' },
  ];

  return (
    <div style={{ display: 'flex', minHeight: '100vh', background: '#f5f5f5' }}>
      {/* Sidebar */}
      <aside style={{
        width: '250px',
        background: 'linear-gradient(135deg, #667eea 0%, #764ba2 100%)',
        color: 'white',
        padding: '2rem 0',
      }}>
        <div style={{ padding: '0 1.5rem', marginBottom: '2rem' }}>
          <h1 style={{ fontSize: '1.5rem', fontWeight: 'bold', margin: 0 }}>
            Spatial Meeting
          </h1>
          <p style={{ fontSize: '0.875rem', opacity: 0.9, margin: '0.5rem 0 0 0' }}>
            Admin Dashboard
          </p>
        </div>

        <nav>
          {navItems.map((item) => (
            <Link
              key={item.path}
              to={item.path}
              style={{
                display: 'flex',
                alignItems: 'center',
                padding: '1rem 1.5rem',
                color: 'white',
                textDecoration: 'none',
                background: location.pathname === item.path ? 'rgba(255,255,255,0.2)' : 'transparent',
                borderLeft: location.pathname === item.path ? '4px solid white' : '4px solid transparent',
                transition: 'all 0.2s',
              }}
              onMouseEnter={(e) => {
                if (location.pathname !== item.path) {
                  e.currentTarget.style.background = 'rgba(255,255,255,0.1)';
                }
              }}
              onMouseLeave={(e) => {
                if (location.pathname !== item.path) {
                  e.currentTarget.style.background = 'transparent';
                }
              }}
            >
              <span style={{ marginRight: '0.75rem', fontSize: '1.25rem' }}>{item.icon}</span>
              <span style={{ fontWeight: 500 }}>{item.label}</span>
            </Link>
          ))}
        </nav>

        <div style={{ position: 'absolute', bottom: '2rem', left: 0, right: 0, padding: '0 1.5rem' }}>
          <div style={{
            background: 'rgba(255,255,255,0.1)',
            borderRadius: '0.5rem',
            padding: '1rem',
            marginBottom: '1rem',
          }}>
            <div style={{ fontSize: '0.875rem', fontWeight: 500 }}>{user?.display_name}</div>
            <div style={{ fontSize: '0.75rem', opacity: 0.8 }}>{user?.email}</div>
          </div>
          <button
            onClick={logout}
            style={{
              width: '100%',
              padding: '0.75rem',
              background: 'rgba(255,255,255,0.2)',
              border: 'none',
              borderRadius: '0.5rem',
              color: 'white',
              fontWeight: 500,
              cursor: 'pointer',
              transition: 'background 0.2s',
            }}
            onMouseEnter={(e) => e.currentTarget.style.background = 'rgba(255,255,255,0.3)'}
            onMouseLeave={(e) => e.currentTarget.style.background = 'rgba(255,255,255,0.2)'}
          >
            Logout
          </button>
        </div>
      </aside>

      {/* Main Content */}
      <main style={{ flex: 1, padding: '2rem' }}>
        {children}
      </main>
    </div>
  );
};
