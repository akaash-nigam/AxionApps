import React from 'react';

export const Users: React.FC = () => {
  return (
    <div>
      <h1 style={{ fontSize: '2rem', fontWeight: 'bold', marginBottom: '2rem' }}>
        Users
      </h1>

      <div style={{
        background: 'white',
        borderRadius: '1rem',
        padding: '3rem',
        boxShadow: '0 2px 8px rgba(0,0,0,0.1)',
        textAlign: 'center',
      }}>
        <div style={{ fontSize: '3rem', marginBottom: '1rem' }}>👥</div>
        <h2 style={{ fontSize: '1.5rem', marginBottom: '0.5rem' }}>User Management</h2>
        <p style={{ color: '#666' }}>
          User management interface coming soon. This will include user listing, editing, and permission management.
        </p>
      </div>
    </div>
  );
};
