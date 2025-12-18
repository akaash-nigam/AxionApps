import React from 'react';

export const Analytics: React.FC = () => {
  return (
    <div>
      <h1 style={{ fontSize: '2rem', fontWeight: 'bold', marginBottom: '2rem' }}>
        Analytics
      </h1>

      <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fit, minmax(300px, 1fr))', gap: '1.5rem' }}>
        {/* Engagement Card */}
        <div style={{
          background: 'white',
          borderRadius: '1rem',
          padding: '1.5rem',
          boxShadow: '0 2px 8px rgba(0,0,0,0.1)',
        }}>
          <h3 style={{ fontSize: '1.25rem', marginBottom: '1rem' }}>Meeting Engagement</h3>
          <div style={{ textAlign: 'center', padding: '2rem' }}>
            <div style={{ fontSize: '3rem', color: '#667eea', fontWeight: 'bold' }}>85%</div>
            <div style={{ color: '#666', marginTop: '0.5rem' }}>Average Engagement Score</div>
          </div>
        </div>

        {/* Duration Card */}
        <div style={{
          background: 'white',
          borderRadius: '1rem',
          padding: '1.5rem',
          boxShadow: '0 2px 8px rgba(0,0,0,0.1)',
        }}>
          <h3 style={{ fontSize: '1.25rem', marginBottom: '1rem' }}>Average Duration</h3>
          <div style={{ textAlign: 'center', padding: '2rem' }}>
            <div style={{ fontSize: '3rem', color: '#10b981', fontWeight: 'bold' }}>42min</div>
            <div style={{ color: '#666', marginTop: '0.5rem' }}>Per Meeting</div>
          </div>
        </div>

        {/* Participants Card */}
        <div style={{
          background: 'white',
          borderRadius: '1rem',
          padding: '1.5rem',
          boxShadow: '0 2px 8px rgba(0,0,0,0.1)',
        }}>
          <h3 style={{ fontSize: '1.25rem', marginBottom: '1rem' }}>Peak Participants</h3>
          <div style={{ textAlign: 'center', padding: '2rem' }}>
            <div style={{ fontSize: '3rem', color: '#f59e0b', fontWeight: 'bold' }}>28</div>
            <div style={{ color: '#666', marginTop: '0.5rem' }}>Maximum Concurrent</div>
          </div>
        </div>
      </div>

      {/* Charts Placeholder */}
      <div style={{
        background: 'white',
        borderRadius: '1rem',
        padding: '2rem',
        boxShadow: '0 2px 8px rgba(0,0,0,0.1)',
        marginTop: '1.5rem',
      }}>
        <h3 style={{ fontSize: '1.25rem', marginBottom: '1.5rem' }}>Meeting Trends</h3>
        <div style={{
          height: '300px',
          display: 'flex',
          alignItems: 'center',
          justifyContent: 'center',
          background: '#f9fafb',
          borderRadius: '0.5rem',
          color: '#666',
        }}>
          📈 Interactive charts coming soon (using Recharts)
        </div>
      </div>
    </div>
  );
};
