-- ============================================================================
-- Business Operating System (BOS) - Database Schema
-- ============================================================================
-- Version: 1.0.0
-- Database: PostgreSQL 15+
-- Description: Complete database schema for the BOS enterprise application
--
-- Design Principles:
-- - Multi-tenant architecture with organization-level isolation
-- - Optimized for read-heavy workloads (denormalization where appropriate)
-- - Audit trail for all critical entities
-- - Soft deletes for data recovery
-- - JSON columns for flexible metadata
-- - Full-text search capabilities
-- - Partitioning for high-volume tables
-- ============================================================================

-- ============================================================================
-- EXTENSIONS
-- ============================================================================

CREATE EXTENSION IF NOT EXISTS "uuid-ossp";       -- UUID generation
CREATE EXTENSION IF NOT EXISTS "pgcrypto";        -- Encryption functions
CREATE EXTENSION IF NOT EXISTS "pg_trgm";         -- Trigram similarity for search
CREATE EXTENSION IF NOT EXISTS "btree_gin";       -- GIN index support for arrays

-- ============================================================================
-- CUSTOM TYPES
-- ============================================================================

CREATE TYPE organization_type AS ENUM (
    'hierarchical',
    'matrix',
    'flat',
    'hybrid'
);

CREATE TYPE user_role AS ENUM (
    'executive',
    'manager',
    'employee',
    'analyst',
    'admin'
);

CREATE TYPE employee_status AS ENUM (
    'active',
    'on_leave',
    'terminated'
);

CREATE TYPE availability_status AS ENUM (
    'available',
    'busy',
    'offline',
    'in_meeting'
);

CREATE TYPE department_type AS ENUM (
    'executive',
    'finance',
    'operations',
    'sales',
    'marketing',
    'engineering',
    'hr',
    'customer_service',
    'legal',
    'custom'
);

CREATE TYPE kpi_category AS ENUM (
    'financial',
    'operational',
    'customer',
    'employee',
    'strategic'
);

CREATE TYPE performance_status AS ENUM (
    'exceeding',
    'on_track',
    'below_target',
    'critical'
);

CREATE TYPE trend_direction AS ENUM (
    'up',
    'down',
    'flat'
);

CREATE TYPE report_type AS ENUM (
    'financial',
    'operational',
    'executive',
    'custom'
);

CREATE TYPE visualization_type AS ENUM (
    'bar_chart',
    'line_chart',
    'pie_chart',
    'scatter_plot',
    'heat_map',
    'network_graph',
    'volumetric_3d'
);

CREATE TYPE integration_type AS ENUM (
    'sap',
    'salesforce',
    'workday',
    'oracle',
    'netsuite',
    'custom'
);

CREATE TYPE integration_status AS ENUM (
    'active',
    'inactive',
    'error',
    'pending'
);

CREATE TYPE anomaly_severity AS ENUM (
    'low',
    'medium',
    'high',
    'critical'
);

CREATE TYPE sync_status AS ENUM (
    'idle',
    'syncing',
    'synced',
    'error'
);

-- ============================================================================
-- BASE TABLES
-- ============================================================================

-- ----------------------------------------------------------------------------
-- ORGANIZATIONS
-- ----------------------------------------------------------------------------

CREATE TABLE organizations (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(255) NOT NULL,
    structure organization_type NOT NULL DEFAULT 'hierarchical',

    -- Metadata
    industry VARCHAR(100),
    size INTEGER,  -- Total employees
    revenue DECIMAL(20, 2),
    founded_year INTEGER,
    headquarters TEXT,

    -- Spatial configuration
    layout_algorithm VARCHAR(50) DEFAULT 'radial',
    spatial_scale REAL DEFAULT 1.0,
    custom_positions JSONB,

    -- Visual theme
    primary_color VARCHAR(7) DEFAULT '#007AFF',
    secondary_color VARCHAR(7) DEFAULT '#5856D6',
    accent_color VARCHAR(7) DEFAULT '#00D084',
    dark_mode BOOLEAN DEFAULT true,

    -- Settings
    settings JSONB DEFAULT '{}',

    -- Audit fields
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP WITH TIME ZONE,

    -- Constraints
    CONSTRAINT valid_colors CHECK (
        primary_color ~* '^#[0-9A-Fa-f]{6}$' AND
        secondary_color ~* '^#[0-9A-Fa-f]{6}$' AND
        accent_color ~* '^#[0-9A-Fa-f]{6}$'
    )
);

CREATE INDEX idx_organizations_name ON organizations USING gin (name gin_trgm_ops);
CREATE INDEX idx_organizations_industry ON organizations(industry);
CREATE INDEX idx_organizations_deleted_at ON organizations(deleted_at) WHERE deleted_at IS NULL;

-- ----------------------------------------------------------------------------
-- USERS
-- ----------------------------------------------------------------------------

CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    organization_id UUID NOT NULL REFERENCES organizations(id) ON DELETE CASCADE,

    -- Authentication
    email VARCHAR(255) NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    email_verified BOOLEAN DEFAULT false,

    -- Profile
    name VARCHAR(255) NOT NULL,
    role user_role NOT NULL DEFAULT 'employee',
    department_id UUID,  -- FK added later
    avatar_url TEXT,

    -- Security
    mfa_enabled BOOLEAN DEFAULT false,
    mfa_secret VARCHAR(255),
    last_login_at TIMESTAMP WITH TIME ZONE,
    last_login_ip INET,

    -- Preferences
    preferences JSONB DEFAULT '{}',

    -- Audit fields
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP WITH TIME ZONE,

    -- Constraints
    CONSTRAINT unique_email_per_org UNIQUE (organization_id, email),
    CONSTRAINT valid_email CHECK (email ~* '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$')
);

CREATE INDEX idx_users_org_id ON users(organization_id);
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_department_id ON users(department_id);
CREATE INDEX idx_users_role ON users(role);
CREATE INDEX idx_users_deleted_at ON users(deleted_at) WHERE deleted_at IS NULL;

-- ----------------------------------------------------------------------------
-- DEPARTMENTS
-- ----------------------------------------------------------------------------

CREATE TABLE departments (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    organization_id UUID NOT NULL REFERENCES organizations(id) ON DELETE CASCADE,

    -- Basic info
    name VARCHAR(255) NOT NULL,
    type department_type NOT NULL,
    parent_id UUID REFERENCES departments(id) ON DELETE SET NULL,

    -- Hierarchy
    hierarchy_level INTEGER DEFAULT 0,
    hierarchy_path LTREE,  -- For efficient hierarchical queries

    -- Metrics
    budget_allocated DECIMAL(20, 2) NOT NULL DEFAULT 0,
    budget_spent DECIMAL(20, 2) NOT NULL DEFAULT 0,
    headcount INTEGER NOT NULL DEFAULT 0,

    -- Spatial representation
    position_x REAL,
    position_y REAL,
    position_z REAL,

    -- Visualization
    geometry_type VARCHAR(50) DEFAULT 'building',
    color VARCHAR(7),
    spatial_scale REAL DEFAULT 1.0,
    animation_state VARCHAR(50),

    -- Metadata
    description TEXT,
    metadata JSONB DEFAULT '{}',

    -- Audit fields
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP WITH TIME ZONE,

    -- Constraints
    CONSTRAINT budget_spent_not_negative CHECK (budget_spent >= 0),
    CONSTRAINT budget_allocated_not_negative CHECK (budget_allocated >= 0)
);

CREATE INDEX idx_departments_org_id ON departments(organization_id);
CREATE INDEX idx_departments_parent_id ON departments(parent_id);
CREATE INDEX idx_departments_type ON departments(type);
CREATE INDEX idx_departments_hierarchy_path ON departments USING gist (hierarchy_path);
CREATE INDEX idx_departments_name ON departments USING gin (name gin_trgm_ops);
CREATE INDEX idx_departments_deleted_at ON departments(deleted_at) WHERE deleted_at IS NULL;

-- Add foreign key to users table
ALTER TABLE users ADD CONSTRAINT fk_users_department
    FOREIGN KEY (department_id) REFERENCES departments(id) ON DELETE SET NULL;

-- ----------------------------------------------------------------------------
-- EMPLOYEES
-- ----------------------------------------------------------------------------

CREATE TABLE employees (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    organization_id UUID NOT NULL REFERENCES organizations(id) ON DELETE CASCADE,
    user_id UUID REFERENCES users(id) ON DELETE SET NULL,

    -- Basic info
    name VARCHAR(255) NOT NULL,
    email VARCHAR(255) NOT NULL,
    title VARCHAR(255) NOT NULL,
    department_id UUID NOT NULL REFERENCES departments(id) ON DELETE RESTRICT,

    -- Organizational structure
    manager_id UUID REFERENCES employees(id) ON DELETE SET NULL,

    -- Status
    status employee_status NOT NULL DEFAULT 'active',
    availability availability_status DEFAULT 'offline',
    hire_date DATE,
    termination_date DATE,

    -- Contact
    phone VARCHAR(50),
    location VARCHAR(255),
    timezone VARCHAR(100),

    -- Avatar
    avatar_url TEXT,

    -- Metadata
    metadata JSONB DEFAULT '{}',

    -- Audit fields
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP WITH TIME ZONE,

    -- Constraints
    CONSTRAINT unique_email_per_org UNIQUE (organization_id, email)
);

CREATE INDEX idx_employees_org_id ON employees(organization_id);
CREATE INDEX idx_employees_user_id ON employees(user_id);
CREATE INDEX idx_employees_department_id ON employees(department_id);
CREATE INDEX idx_employees_manager_id ON employees(manager_id);
CREATE INDEX idx_employees_status ON employees(status);
CREATE INDEX idx_employees_email ON employees(email);
CREATE INDEX idx_employees_name ON employees USING gin (name gin_trgm_ops);
CREATE INDEX idx_employees_deleted_at ON employees(deleted_at) WHERE deleted_at IS NULL;

-- ----------------------------------------------------------------------------
-- KPIs (Key Performance Indicators)
-- ----------------------------------------------------------------------------

CREATE TABLE kpis (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    organization_id UUID NOT NULL REFERENCES organizations(id) ON DELETE CASCADE,
    department_id UUID NOT NULL REFERENCES departments(id) ON DELETE CASCADE,

    -- Basic info
    name VARCHAR(255) NOT NULL,
    description TEXT,
    category kpi_category NOT NULL,

    -- Values
    current_value DECIMAL(20, 4) NOT NULL,
    target_value DECIMAL(20, 4) NOT NULL,
    unit VARCHAR(50) NOT NULL,

    -- Trend
    trend_direction trend_direction DEFAULT 'flat',
    trend_change_percent REAL DEFAULT 0,
    trend_period VARCHAR(100),

    -- Display
    format_style VARCHAR(50) DEFAULT 'number',
    decimal_places INTEGER DEFAULT 2,
    show_percentage BOOLEAN DEFAULT false,

    -- Alerts
    critical_threshold DECIMAL(20, 4),
    warning_threshold DECIMAL(20, 4),

    -- Metadata
    data_source VARCHAR(255),
    update_frequency VARCHAR(50),  -- e.g., "hourly", "daily"
    last_updated_at TIMESTAMP WITH TIME ZONE,
    metadata JSONB DEFAULT '{}',

    -- Audit fields
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP WITH TIME ZONE
);

CREATE INDEX idx_kpis_org_id ON kpis(organization_id);
CREATE INDEX idx_kpis_department_id ON kpis(department_id);
CREATE INDEX idx_kpis_category ON kpis(category);
CREATE INDEX idx_kpis_name ON kpis USING gin (name gin_trgm_ops);
CREATE INDEX idx_kpis_deleted_at ON kpis(deleted_at) WHERE deleted_at IS NULL;

-- ----------------------------------------------------------------------------
-- KPI HISTORY (Time-series data, partitioned by month)
-- ----------------------------------------------------------------------------

CREATE TABLE kpi_history (
    id BIGSERIAL,
    kpi_id UUID NOT NULL REFERENCES kpis(id) ON DELETE CASCADE,

    -- Time-series data
    timestamp TIMESTAMP WITH TIME ZONE NOT NULL,
    value DECIMAL(20, 4) NOT NULL,

    -- Metadata
    metadata JSONB DEFAULT '{}',

    -- Partition key
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,

    PRIMARY KEY (id, created_at)
) PARTITION BY RANGE (created_at);

-- Create partitions for the last 12 months and next 3 months
-- In production, use automated partition management
CREATE TABLE kpi_history_2025_01 PARTITION OF kpi_history
    FOR VALUES FROM ('2025-01-01') TO ('2025-02-01');

CREATE INDEX idx_kpi_history_kpi_id_2025_01 ON kpi_history_2025_01(kpi_id, timestamp DESC);

-- Additional partitions would be created by automation...

-- ----------------------------------------------------------------------------
-- REPORTS
-- ----------------------------------------------------------------------------

CREATE TABLE reports (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    organization_id UUID NOT NULL REFERENCES organizations(id) ON DELETE CASCADE,

    -- Basic info
    title VARCHAR(500) NOT NULL,
    description TEXT,
    type report_type NOT NULL,

    -- Content
    content JSONB NOT NULL DEFAULT '{}',

    -- Ownership
    created_by UUID NOT NULL REFERENCES users(id) ON DELETE RESTRICT,

    -- Sharing
    is_public BOOLEAN DEFAULT false,
    shared_with_user_ids UUID[],
    shared_with_department_ids UUID[],

    -- Scheduling
    is_scheduled BOOLEAN DEFAULT false,
    schedule_cron VARCHAR(100),
    next_run_at TIMESTAMP WITH TIME ZONE,

    -- Audit fields
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP WITH TIME ZONE
);

CREATE INDEX idx_reports_org_id ON reports(organization_id);
CREATE INDEX idx_reports_created_by ON reports(created_by);
CREATE INDEX idx_reports_type ON reports(type);
CREATE INDEX idx_reports_title ON reports USING gin (title gin_trgm_ops);
CREATE INDEX idx_reports_next_run_at ON reports(next_run_at) WHERE is_scheduled = true;
CREATE INDEX idx_reports_deleted_at ON reports(deleted_at) WHERE deleted_at IS NULL;

-- ----------------------------------------------------------------------------
-- VISUALIZATIONS
-- ----------------------------------------------------------------------------

CREATE TABLE visualizations (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    organization_id UUID NOT NULL REFERENCES organizations(id) ON DELETE CASCADE,
    report_id UUID REFERENCES reports(id) ON DELETE CASCADE,

    -- Basic info
    title VARCHAR(500) NOT NULL,
    type visualization_type NOT NULL,

    -- Data source
    data_source_type VARCHAR(50) NOT NULL,  -- 'kpi', 'query', 'custom'
    data_source_config JSONB NOT NULL,

    -- Configuration
    dimensions_x REAL,
    dimensions_y REAL,
    dimensions_z REAL,
    color_scheme VARCHAR(100),
    is_interactive BOOLEAN DEFAULT true,
    animation_enabled BOOLEAN DEFAULT true,

    -- Metadata
    configuration JSONB DEFAULT '{}',

    -- Audit fields
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP WITH TIME ZONE
);

CREATE INDEX idx_visualizations_org_id ON visualizations(organization_id);
CREATE INDEX idx_visualizations_report_id ON visualizations(report_id);
CREATE INDEX idx_visualizations_type ON visualizations(type);
CREATE INDEX idx_visualizations_deleted_at ON visualizations(deleted_at) WHERE deleted_at IS NULL;

-- ----------------------------------------------------------------------------
-- COLLABORATION SESSIONS
-- ----------------------------------------------------------------------------

CREATE TABLE collaboration_sessions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    organization_id UUID NOT NULL REFERENCES organizations(id) ON DELETE CASCADE,

    -- Session info
    title VARCHAR(500) NOT NULL,
    host_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    active_space VARCHAR(255) NOT NULL,

    -- Status
    is_active BOOLEAN DEFAULT true,
    started_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    ended_at TIMESTAMP WITH TIME ZONE,

    -- Participants
    participant_ids UUID[] NOT NULL DEFAULT '{}',
    max_participants INTEGER DEFAULT 8,

    -- Metadata
    metadata JSONB DEFAULT '{}',

    -- Audit fields
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_collaboration_sessions_org_id ON collaboration_sessions(organization_id);
CREATE INDEX idx_collaboration_sessions_host_id ON collaboration_sessions(host_id);
CREATE INDEX idx_collaboration_sessions_active ON collaboration_sessions(is_active) WHERE is_active = true;
CREATE INDEX idx_collaboration_sessions_participant_ids ON collaboration_sessions USING gin(participant_ids);

-- ----------------------------------------------------------------------------
-- SPATIAL ANNOTATIONS
-- ----------------------------------------------------------------------------

CREATE TABLE spatial_annotations (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    organization_id UUID NOT NULL REFERENCES organizations(id) ON DELETE CASCADE,
    session_id UUID REFERENCES collaboration_sessions(id) ON DELETE CASCADE,

    -- Author
    author_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,

    -- Position
    position_x REAL NOT NULL,
    position_y REAL NOT NULL,
    position_z REAL NOT NULL,

    -- Content
    content TEXT NOT NULL,
    content_type VARCHAR(50) DEFAULT 'text',  -- 'text', 'voice', 'drawing'

    -- Attachments
    attachment_url TEXT,

    -- Metadata
    metadata JSONB DEFAULT '{}',

    -- Audit fields
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP WITH TIME ZONE
);

CREATE INDEX idx_spatial_annotations_org_id ON spatial_annotations(organization_id);
CREATE INDEX idx_spatial_annotations_session_id ON spatial_annotations(session_id);
CREATE INDEX idx_spatial_annotations_author_id ON spatial_annotations(author_id);
CREATE INDEX idx_spatial_annotations_deleted_at ON spatial_annotations(deleted_at) WHERE deleted_at IS NULL;

-- ----------------------------------------------------------------------------
-- INTEGRATIONS
-- ----------------------------------------------------------------------------

CREATE TABLE integrations (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    organization_id UUID NOT NULL REFERENCES organizations(id) ON DELETE CASCADE,

    -- Integration info
    name VARCHAR(255) NOT NULL,
    type integration_type NOT NULL,
    status integration_status NOT NULL DEFAULT 'pending',

    -- Connection
    endpoint_url TEXT,
    api_key_encrypted BYTEA,  -- Encrypted API key
    oauth_credentials_encrypted BYTEA,  -- Encrypted OAuth tokens

    -- Configuration
    configuration JSONB DEFAULT '{}',
    field_mappings JSONB DEFAULT '{}',

    -- Sync
    sync_enabled BOOLEAN DEFAULT true,
    sync_frequency VARCHAR(50) DEFAULT 'hourly',
    last_synced_at TIMESTAMP WITH TIME ZONE,
    last_sync_status VARCHAR(50),
    last_sync_error TEXT,

    -- Metadata
    metadata JSONB DEFAULT '{}',

    -- Audit fields
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP WITH TIME ZONE
);

CREATE INDEX idx_integrations_org_id ON integrations(organization_id);
CREATE INDEX idx_integrations_type ON integrations(type);
CREATE INDEX idx_integrations_status ON integrations(status);
CREATE INDEX idx_integrations_last_synced_at ON integrations(last_synced_at);
CREATE INDEX idx_integrations_deleted_at ON integrations(deleted_at) WHERE deleted_at IS NULL;

-- ----------------------------------------------------------------------------
-- SYNC EVENTS (Audit trail for data synchronization)
-- ----------------------------------------------------------------------------

CREATE TABLE sync_events (
    id BIGSERIAL PRIMARY KEY,
    integration_id UUID NOT NULL REFERENCES integrations(id) ON DELETE CASCADE,
    organization_id UUID NOT NULL REFERENCES organizations(id) ON DELETE CASCADE,

    -- Event details
    entity_type VARCHAR(100) NOT NULL,  -- 'department', 'employee', 'kpi', etc.
    entity_id UUID NOT NULL,
    change_type VARCHAR(50) NOT NULL,  -- 'created', 'updated', 'deleted'

    -- Data
    old_data JSONB,
    new_data JSONB,

    -- Status
    status VARCHAR(50) NOT NULL DEFAULT 'pending',  -- 'pending', 'synced', 'failed'
    error_message TEXT,
    retry_count INTEGER DEFAULT 0,

    -- Metadata
    metadata JSONB DEFAULT '{}',

    -- Timestamp
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    synced_at TIMESTAMP WITH TIME ZONE
);

CREATE INDEX idx_sync_events_integration_id ON sync_events(integration_id);
CREATE INDEX idx_sync_events_org_id ON sync_events(organization_id);
CREATE INDEX idx_sync_events_entity ON sync_events(entity_type, entity_id);
CREATE INDEX idx_sync_events_status ON sync_events(status);
CREATE INDEX idx_sync_events_created_at ON sync_events(created_at DESC);

-- ----------------------------------------------------------------------------
-- AI INSIGHTS & ANOMALIES
-- ----------------------------------------------------------------------------

CREATE TABLE ai_insights (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    organization_id UUID NOT NULL REFERENCES organizations(id) ON DELETE CASCADE,

    -- Insight type
    insight_type VARCHAR(100) NOT NULL,  -- 'anomaly', 'recommendation', 'prediction'

    -- Related entities
    related_department_id UUID REFERENCES departments(id) ON DELETE CASCADE,
    related_kpi_id UUID REFERENCES kpis(id) ON DELETE CASCADE,

    -- Content
    title VARCHAR(500) NOT NULL,
    description TEXT NOT NULL,
    severity anomaly_severity,

    -- Data
    affected_entities JSONB DEFAULT '[]',
    recommended_actions JSONB DEFAULT '[]',
    confidence_score REAL,  -- 0.0 to 1.0

    -- Status
    is_acknowledged BOOLEAN DEFAULT false,
    acknowledged_by UUID REFERENCES users(id) ON DELETE SET NULL,
    acknowledged_at TIMESTAMP WITH TIME ZONE,

    -- Metadata
    metadata JSONB DEFAULT '{}',

    -- Audit fields
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    expires_at TIMESTAMP WITH TIME ZONE
);

CREATE INDEX idx_ai_insights_org_id ON ai_insights(organization_id);
CREATE INDEX idx_ai_insights_type ON ai_insights(insight_type);
CREATE INDEX idx_ai_insights_department_id ON ai_insights(related_department_id);
CREATE INDEX idx_ai_insights_kpi_id ON ai_insights(related_kpi_id);
CREATE INDEX idx_ai_insights_acknowledged ON ai_insights(is_acknowledged);
CREATE INDEX idx_ai_insights_expires_at ON ai_insights(expires_at) WHERE expires_at IS NOT NULL;

-- ----------------------------------------------------------------------------
-- ANALYTICS EVENTS (User behavior tracking)
-- ----------------------------------------------------------------------------

CREATE TABLE analytics_events (
    id BIGSERIAL PRIMARY KEY,
    organization_id UUID NOT NULL REFERENCES organizations(id) ON DELETE CASCADE,
    user_id UUID REFERENCES users(id) ON DELETE SET NULL,

    -- Event details
    event_name VARCHAR(255) NOT NULL,
    event_category VARCHAR(100),

    -- Context
    screen VARCHAR(255),
    department_id UUID REFERENCES departments(id) ON DELETE SET NULL,
    kpi_id UUID REFERENCES kpis(id) ON DELETE SET NULL,

    -- Properties
    properties JSONB DEFAULT '{}',

    -- Session
    session_id UUID,

    -- Device/Platform
    platform VARCHAR(50) DEFAULT 'visionOS',
    app_version VARCHAR(50),
    os_version VARCHAR(50),
    device_model VARCHAR(100),

    -- Timestamp
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
) PARTITION BY RANGE (created_at);

-- Create monthly partitions
CREATE TABLE analytics_events_2025_01 PARTITION OF analytics_events
    FOR VALUES FROM ('2025-01-01') TO ('2025-02-01');

CREATE INDEX idx_analytics_events_org_id_2025_01 ON analytics_events_2025_01(organization_id);
CREATE INDEX idx_analytics_events_user_id_2025_01 ON analytics_events_2025_01(user_id);
CREATE INDEX idx_analytics_events_name_2025_01 ON analytics_events_2025_01(event_name);
CREATE INDEX idx_analytics_events_created_at_2025_01 ON analytics_events_2025_01(created_at DESC);

-- ----------------------------------------------------------------------------
-- AUDIT LOGS (System-wide audit trail)
-- ----------------------------------------------------------------------------

CREATE TABLE audit_logs (
    id BIGSERIAL PRIMARY KEY,
    organization_id UUID REFERENCES organizations(id) ON DELETE SET NULL,
    user_id UUID REFERENCES users(id) ON DELETE SET NULL,

    -- Action details
    action VARCHAR(100) NOT NULL,  -- 'create', 'update', 'delete', 'login', etc.
    entity_type VARCHAR(100) NOT NULL,
    entity_id UUID,

    -- Changes
    old_values JSONB,
    new_values JSONB,

    -- Context
    ip_address INET,
    user_agent TEXT,
    request_id UUID,

    -- Metadata
    metadata JSONB DEFAULT '{}',

    -- Timestamp
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
) PARTITION BY RANGE (created_at);

-- Create monthly partitions
CREATE TABLE audit_logs_2025_01 PARTITION OF audit_logs
    FOR VALUES FROM ('2025-01-01') TO ('2025-02-01');

CREATE INDEX idx_audit_logs_org_id_2025_01 ON audit_logs_2025_01(organization_id);
CREATE INDEX idx_audit_logs_user_id_2025_01 ON audit_logs_2025_01(user_id);
CREATE INDEX idx_audit_logs_action_2025_01 ON audit_logs_2025_01(action);
CREATE INDEX idx_audit_logs_entity_2025_01 ON audit_logs_2025_01(entity_type, entity_id);
CREATE INDEX idx_audit_logs_created_at_2025_01 ON audit_logs_2025_01(created_at DESC);

-- ============================================================================
-- VIEWS
-- ============================================================================

-- ----------------------------------------------------------------------------
-- Department hierarchy with aggregated metrics
-- ----------------------------------------------------------------------------

CREATE OR REPLACE VIEW department_hierarchy_view AS
WITH RECURSIVE dept_tree AS (
    -- Base case: root departments
    SELECT
        d.id,
        d.organization_id,
        d.name,
        d.type,
        d.parent_id,
        d.budget_allocated,
        d.budget_spent,
        d.headcount,
        0 AS level,
        ARRAY[d.id] AS path,
        d.name::TEXT AS path_names
    FROM departments d
    WHERE d.parent_id IS NULL AND d.deleted_at IS NULL

    UNION ALL

    -- Recursive case: child departments
    SELECT
        d.id,
        d.organization_id,
        d.name,
        d.type,
        d.parent_id,
        d.budget_allocated,
        d.budget_spent,
        d.headcount,
        dt.level + 1,
        dt.path || d.id,
        dt.path_names || ' > ' || d.name
    FROM departments d
    INNER JOIN dept_tree dt ON d.parent_id = dt.id
    WHERE d.deleted_at IS NULL
)
SELECT
    dt.*,
    (SELECT COUNT(*) FROM employees e WHERE e.department_id = dt.id AND e.status = 'active' AND e.deleted_at IS NULL) AS active_employees,
    (SELECT COUNT(*) FROM kpis k WHERE k.department_id = dt.id AND k.deleted_at IS NULL) AS kpi_count,
    ROUND((dt.budget_spent / NULLIF(dt.budget_allocated, 0) * 100)::NUMERIC, 2) AS budget_utilization_percent
FROM dept_tree dt
ORDER BY dt.path;

-- ----------------------------------------------------------------------------
-- KPI performance dashboard view
-- ----------------------------------------------------------------------------

CREATE OR REPLACE VIEW kpi_performance_view AS
SELECT
    k.id,
    k.organization_id,
    k.department_id,
    d.name AS department_name,
    k.name AS kpi_name,
    k.category,
    k.current_value,
    k.target_value,
    k.unit,
    k.trend_direction,
    k.trend_change_percent,
    ROUND((k.current_value / NULLIF(k.target_value, 0))::NUMERIC, 4) AS performance_ratio,
    CASE
        WHEN k.current_value / NULLIF(k.target_value, 0) >= 1.1 THEN 'exceeding'
        WHEN k.current_value / NULLIF(k.target_value, 0) >= 0.9 THEN 'on_track'
        WHEN k.current_value / NULLIF(k.target_value, 0) >= 0.7 THEN 'below_target'
        ELSE 'critical'
    END::performance_status AS performance_status,
    k.last_updated_at,
    k.created_at
FROM kpis k
INNER JOIN departments d ON k.department_id = d.id
WHERE k.deleted_at IS NULL AND d.deleted_at IS NULL;

-- ----------------------------------------------------------------------------
-- User activity summary
-- ----------------------------------------------------------------------------

CREATE OR REPLACE VIEW user_activity_summary AS
SELECT
    u.id AS user_id,
    u.organization_id,
    u.name,
    u.email,
    u.role,
    u.last_login_at,
    (SELECT COUNT(*) FROM analytics_events ae WHERE ae.user_id = u.id AND ae.created_at > CURRENT_TIMESTAMP - INTERVAL '30 days') AS events_last_30_days,
    (SELECT COUNT(*) FROM reports r WHERE r.created_by = u.id AND r.deleted_at IS NULL) AS reports_created,
    (SELECT COUNT(*) FROM collaboration_sessions cs WHERE cs.host_id = u.id) AS sessions_hosted
FROM users u
WHERE u.deleted_at IS NULL;

-- ============================================================================
-- FUNCTIONS & TRIGGERS
-- ============================================================================

-- ----------------------------------------------------------------------------
-- Function: Update updated_at timestamp
-- ----------------------------------------------------------------------------

CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Apply to all tables with updated_at
CREATE TRIGGER tr_organizations_updated_at BEFORE UPDATE ON organizations
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER tr_users_updated_at BEFORE UPDATE ON users
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER tr_departments_updated_at BEFORE UPDATE ON departments
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER tr_employees_updated_at BEFORE UPDATE ON employees
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER tr_kpis_updated_at BEFORE UPDATE ON kpis
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER tr_reports_updated_at BEFORE UPDATE ON reports
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER tr_visualizations_updated_at BEFORE UPDATE ON visualizations
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER tr_collaboration_sessions_updated_at BEFORE UPDATE ON collaboration_sessions
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER tr_spatial_annotations_updated_at BEFORE UPDATE ON spatial_annotations
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER tr_integrations_updated_at BEFORE UPDATE ON integrations
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER tr_ai_insights_updated_at BEFORE UPDATE ON ai_insights
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- ----------------------------------------------------------------------------
-- Function: Update department hierarchy path
-- ----------------------------------------------------------------------------

CREATE OR REPLACE FUNCTION update_department_hierarchy_path()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.parent_id IS NULL THEN
        NEW.hierarchy_level := 0;
        NEW.hierarchy_path := NEW.id::TEXT::LTREE;
    ELSE
        SELECT
            hierarchy_level + 1,
            hierarchy_path::TEXT || '.' || NEW.id::TEXT
        INTO NEW.hierarchy_level, NEW.hierarchy_path
        FROM departments
        WHERE id = NEW.parent_id;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER tr_departments_hierarchy BEFORE INSERT OR UPDATE OF parent_id ON departments
    FOR EACH ROW EXECUTE FUNCTION update_department_hierarchy_path();

-- ----------------------------------------------------------------------------
-- Function: Log audit trail
-- ----------------------------------------------------------------------------

CREATE OR REPLACE FUNCTION log_audit_trail()
RETURNS TRIGGER AS $$
DECLARE
    old_data JSONB;
    new_data JSONB;
    action_type VARCHAR(100);
BEGIN
    IF (TG_OP = 'DELETE') THEN
        old_data := row_to_json(OLD)::JSONB;
        new_data := NULL;
        action_type := 'delete';
    ELSIF (TG_OP = 'UPDATE') THEN
        old_data := row_to_json(OLD)::JSONB;
        new_data := row_to_json(NEW)::JSONB;
        action_type := 'update';
    ELSIF (TG_OP = 'INSERT') THEN
        old_data := NULL;
        new_data := row_to_json(NEW)::JSONB;
        action_type := 'create';
    END IF;

    INSERT INTO audit_logs (
        organization_id,
        action,
        entity_type,
        entity_id,
        old_values,
        new_values
    ) VALUES (
        COALESCE(NEW.organization_id, OLD.organization_id),
        action_type,
        TG_TABLE_NAME,
        COALESCE(NEW.id, OLD.id),
        old_data,
        new_data
    );

    RETURN COALESCE(NEW, OLD);
END;
$$ LANGUAGE plpgsql;

-- Apply audit logging to critical tables
CREATE TRIGGER tr_departments_audit AFTER INSERT OR UPDATE OR DELETE ON departments
    FOR EACH ROW EXECUTE FUNCTION log_audit_trail();

CREATE TRIGGER tr_kpis_audit AFTER INSERT OR UPDATE OR DELETE ON kpis
    FOR EACH ROW EXECUTE FUNCTION log_audit_trail();

-- ============================================================================
-- SECURITY
-- ============================================================================

-- Row-level security for multi-tenancy
ALTER TABLE organizations ENABLE ROW LEVEL SECURITY;
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE departments ENABLE ROW LEVEL SECURITY;
ALTER TABLE employees ENABLE ROW LEVEL SECURITY;
ALTER TABLE kpis ENABLE ROW LEVEL SECURITY;
ALTER TABLE reports ENABLE ROW LEVEL SECURITY;

-- Example policy (customize based on authentication method)
CREATE POLICY org_isolation_policy ON users
    USING (organization_id = current_setting('app.current_organization_id', true)::UUID);

-- ============================================================================
-- SAMPLE DATA (for development/testing)
-- ============================================================================

-- Insert sample organization
INSERT INTO organizations (id, name, structure, industry, size, revenue)
VALUES
    ('00000000-0000-0000-0000-000000000001', 'Acme Corporation', 'hierarchical', 'Technology', 1250, 125000000.00);

-- Insert sample user
INSERT INTO users (id, organization_id, email, password_hash, name, role)
VALUES
    ('00000000-0000-0000-0000-000000000002', '00000000-0000-0000-0000-000000000001',
     'admin@acme.com', '$2b$12$dummyhash', 'Admin User', 'admin');

-- ============================================================================
-- COMMENTS
-- ============================================================================

COMMENT ON TABLE organizations IS 'Multi-tenant organizations';
COMMENT ON TABLE users IS 'Application users with authentication';
COMMENT ON TABLE departments IS 'Organizational departments with hierarchy';
COMMENT ON TABLE employees IS 'Employee records';
COMMENT ON TABLE kpis IS 'Key Performance Indicators';
COMMENT ON TABLE kpi_history IS 'Time-series KPI values (partitioned by month)';
COMMENT ON TABLE reports IS 'Generated reports';
COMMENT ON TABLE collaboration_sessions IS 'Real-time collaboration sessions';
COMMENT ON TABLE spatial_annotations IS 'Spatial annotations in 3D space';
COMMENT ON TABLE integrations IS 'Enterprise system integrations';
COMMENT ON TABLE ai_insights IS 'AI-generated insights and anomalies';
COMMENT ON TABLE analytics_events IS 'User behavior analytics (partitioned by month)';
COMMENT ON TABLE audit_logs IS 'System-wide audit trail (partitioned by month)';

-- ============================================================================
-- END OF SCHEMA
-- ============================================================================
