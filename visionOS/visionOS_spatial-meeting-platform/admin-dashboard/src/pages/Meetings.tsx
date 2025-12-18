import React, { useEffect, useState } from 'react';
import { meetingsAPI } from '../services/api';
import { Meeting } from '../types';

export const Meetings: React.FC = () => {
  const [meetings, setMeetings] = useState<Meeting[]>([]);
  const [loading, setLoading] = useState(true);
  const [filter, setFilter] = useState<string>('all');

  useEffect(() => {
    loadMeetings();
  }, [filter]);

  const loadMeetings = async () => {
    try {
      const params = filter !== 'all' ? { status: filter } : {};
      const response = await meetingsAPI.getAll(params);
      setMeetings(response.data.meetings || []);
    } catch (error) {
      console.error('Failed to load meetings', error);
    } finally {
      setLoading(false);
    }
  };

  const deleteMeeting = async (id: string) => {
    if (!confirm('Are you sure you want to delete this meeting?')) return;

    try {
      await meetingsAPI.delete(id);
      setMeetings(meetings.filter(m => m.id !== id));
    } catch (error) {
      alert('Failed to delete meeting');
    }
  };

  if (loading) {
    return <div style={{ textAlign: 'center', padding: '3rem' }}>Loading...</div>;
  }

  return (
    <div>
      <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '2rem' }}>
        <h1 style={{ fontSize: '2rem', fontWeight: 'bold' }}>Meetings</h1>

        <select
          value={filter}
          onChange={(e) => setFilter(e.target.value)}
          style={{
            padding: '0.75rem 1rem',
            border: '2px solid #e0e0e0',
            borderRadius: '0.5rem',
            fontSize: '1rem',
          }}
        >
          <option value="all">All Meetings</option>
          <option value="active">Active</option>
          <option value="scheduled">Scheduled</option>
          <option value="ended">Ended</option>
        </select>
      </div>

      <div style={{ display: 'grid', gap: '1.5rem' }}>
        {meetings.length === 0 ? (
          <div style={{
            background: 'white',
            borderRadius: '1rem',
            padding: '3rem',
            textAlign: 'center',
            color: '#666',
          }}>
            No meetings found
          </div>
        ) : (
          meetings.map((meeting) => (
            <div
              key={meeting.id}
              style={{
                background: 'white',
                borderRadius: '1rem',
                padding: '1.5rem',
                boxShadow: '0 2px 8px rgba(0,0,0,0.1)',
              }}
            >
              <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'start' }}>
                <div style={{ flex: 1 }}>
                  <h3 style={{ fontSize: '1.25rem', fontWeight: 'bold', marginBottom: '0.5rem' }}>
                    {meeting.title}
                  </h3>
                  {meeting.description && (
                    <p style={{ color: '#666', marginBottom: '1rem' }}>
                      {meeting.description}
                    </p>
                  )}

                  <div style={{ display: 'flex', gap: '1rem', flexWrap: 'wrap', marginTop: '1rem' }}>
                    <div style={{ fontSize: '0.875rem' }}>
                      <span style={{ color: '#666' }}>Environment:</span>{' '}
                      <strong>{meeting.environment_type.replace('_', ' ')}</strong>
                    </div>
                    <div style={{ fontSize: '0.875rem' }}>
                      <span style={{ color: '#666' }}>Layout:</span>{' '}
                      <strong>{meeting.layout_type}</strong>
                    </div>
                    <div style={{ fontSize: '0.875rem' }}>
                      <span style={{ color: '#666' }}>Max Participants:</span>{' '}
                      <strong>{meeting.max_participants}</strong>
                    </div>
                    <div style={{ fontSize: '0.875rem' }}>
                      <span style={{ color: '#666' }}>Created:</span>{' '}
                      <strong>{new Date(meeting.created_at).toLocaleString()}</strong>
                    </div>
                  </div>
                </div>

                <div style={{ display: 'flex', gap: '0.5rem', alignItems: 'start' }}>
                  <span style={{
                    padding: '0.5rem 1rem',
                    borderRadius: '0.5rem',
                    fontSize: '0.875rem',
                    fontWeight: 500,
                    background: meeting.status === 'active' ? '#d1fae5' :
                               meeting.status === 'scheduled' ? '#fef3c7' : '#e5e7eb',
                    color: meeting.status === 'active' ? '#059669' :
                           meeting.status === 'scheduled' ? '#d97706' : '#6b7280',
                  }}>
                    {meeting.status}
                  </span>

                  <button
                    onClick={() => deleteMeeting(meeting.id)}
                    style={{
                      padding: '0.5rem 1rem',
                      background: '#fee',
                      color: '#c33',
                      border: 'none',
                      borderRadius: '0.5rem',
                      cursor: 'pointer',
                      fontSize: '0.875rem',
                      fontWeight: 500,
                    }}
                  >
                    Delete
                  </button>
                </div>
              </div>
            </div>
          ))
        )}
      </div>
    </div>
  );
};
