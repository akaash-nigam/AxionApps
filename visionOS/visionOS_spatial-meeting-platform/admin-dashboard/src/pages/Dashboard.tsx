import React, { useEffect, useState } from 'react';
import { meetingsAPI } from '../services/api';
import { Meeting } from '../types';

interface StatsCardProps {
  title: string;
  value: string | number;
  icon: string;
  color: string;
}

const StatsCard: React.FC<StatsCardProps> = ({ title, value, icon, color }) => (
  <div style={{
    background: 'white',
    borderRadius: '1rem',
    padding: '1.5rem',
    boxShadow: '0 2px 8px rgba(0,0,0,0.1)',
    borderLeft: `4px solid ${color}`,
  }}>
    <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'start' }}>
      <div>
        <div style={{ fontSize: '0.875rem', color: '#666', marginBottom: '0.5rem' }}>
          {title}
        </div>
        <div style={{ fontSize: '2rem', fontWeight: 'bold', color }}>
          {value}
        </div>
      </div>
      <div style={{ fontSize: '2.5rem' }}>{icon}</div>
    </div>
  </div>
);

export const Dashboard: React.FC = () => {
  const [meetings, setMeetings] = useState<Meeting[]>([]);
  const [stats, setStats] = useState({
    total: 0,
    active: 0,
    scheduled: 0,
    ended: 0,
  });
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    loadDashboard();
  }, []);

  const loadDashboard = async () => {
    try {
      const response = await meetingsAPI.getAll({ limit: 10 });
      const allMeetings = response.data.meetings || [];

      setMeetings(allMeetings);
      setStats({
        total: response.data.total || 0,
        active: allMeetings.filter((m: Meeting) => m.status === 'active').length,
        scheduled: allMeetings.filter((m: Meeting) => m.status === 'scheduled').length,
        ended: allMeetings.filter((m: Meeting) => m.status === 'ended').length,
      });
    } catch (error) {
      console.error('Failed to load dashboard', error);
    } finally {
      setLoading(false);
    }
  };

  if (loading) {
    return <div style={{ textAlign: 'center', padding: '3rem' }}>Loading...</div>;
  }

  return (
    <div>
      <h1 style={{ fontSize: '2rem', fontWeight: 'bold', marginBottom: '2rem' }}>
        Dashboard
      </h1>

      {/* Stats Grid */}
      <div style={{
        display: 'grid',
        gridTemplateColumns: 'repeat(auto-fit, minmax(250px, 1fr))',
        gap: '1.5rem',
        marginBottom: '2rem',
      }}>
        <StatsCard title="Total Meetings" value={stats.total} icon="📊" color="#667eea" />
        <StatsCard title="Active Now" value={stats.active} icon="🟢" color="#10b981" />
        <StatsCard title="Scheduled" value={stats.scheduled} icon="📅" color="#f59e0b" />
        <StatsCard title="Completed" value={stats.ended} icon="✅" color="#6366f1" />
      </div>

      {/* Recent Meetings */}
      <div style={{
        background: 'white',
        borderRadius: '1rem',
        padding: '1.5rem',
        boxShadow: '0 2px 8px rgba(0,0,0,0.1)',
      }}>
        <h2 style={{ fontSize: '1.5rem', fontWeight: 'bold', marginBottom: '1.5rem' }}>
          Recent Meetings
        </h2>

        {meetings.length === 0 ? (
          <div style={{ textAlign: 'center', padding: '2rem', color: '#666' }}>
            No meetings yet
          </div>
        ) : (
          <div style={{ overflowX: 'auto' }}>
            <table style={{ width: '100%', borderCollapse: 'collapse' }}>
              <thead>
                <tr style={{ borderBottom: '2px solid #e0e0e0' }}>
                  <th style={{ padding: '1rem', textAlign: 'left', fontWeight: 600 }}>Title</th>
                  <th style={{ padding: '1rem', textAlign: 'left', fontWeight: 600 }}>Environment</th>
                  <th style={{ padding: '1rem', textAlign: 'left', fontWeight: 600 }}>Status</th>
                  <th style={{ padding: '1rem', textAlign: 'left', fontWeight: 600 }}>Created</th>
                </tr>
              </thead>
              <tbody>
                {meetings.map((meeting) => (
                  <tr key={meeting.id} style={{ borderBottom: '1px solid #f0f0f0' }}>
                    <td style={{ padding: '1rem' }}>
                      <div style={{ fontWeight: 500 }}>{meeting.title}</div>
                      {meeting.description && (
                        <div style={{ fontSize: '0.875rem', color: '#666', marginTop: '0.25rem' }}>
                          {meeting.description}
                        </div>
                      )}
                    </td>
                    <td style={{ padding: '1rem' }}>
                      <span style={{
                        padding: '0.25rem 0.75rem',
                        borderRadius: '0.5rem',
                        fontSize: '0.875rem',
                        background: '#f3f4f6',
                      }}>
                        {meeting.environment_type.replace('_', ' ')}
                      </span>
                    </td>
                    <td style={{ padding: '1rem' }}>
                      <span style={{
                        padding: '0.25rem 0.75rem',
                        borderRadius: '0.5rem',
                        fontSize: '0.875rem',
                        background: meeting.status === 'active' ? '#d1fae5' :
                                   meeting.status === 'scheduled' ? '#fef3c7' : '#e5e7eb',
                        color: meeting.status === 'active' ? '#059669' :
                               meeting.status === 'scheduled' ? '#d97706' : '#6b7280',
                      }}>
                        {meeting.status}
                      </span>
                    </td>
                    <td style={{ padding: '1rem', color: '#666', fontSize: '0.875rem' }}>
                      {new Date(meeting.created_at).toLocaleDateString()}
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        )}
      </div>
    </div>
  );
};
