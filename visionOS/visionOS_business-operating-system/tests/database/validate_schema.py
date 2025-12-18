#!/usr/bin/env python3
"""
Database Schema Validation
Tests PostgreSQL schema without requiring a running database
"""

import re
import sys

def validate_sql_file(filepath):
    """Validate SQL schema file"""
    print(f"=== Validating {filepath} ===\n")

    with open(filepath, 'r') as f:
        content = f.read()

    # Track findings
    tables = []
    indexes = []
    foreign_keys = []
    errors = []

    # Find CREATE TABLE statements
    table_pattern = r'CREATE TABLE\s+(\w+)\s*\('
    tables = re.findall(table_pattern, content, re.IGNORECASE)
    print(f"✓ Found {len(tables)} tables: {', '.join(tables)}\n")

    # Expected tables
    expected_tables = [
        'organizations', 'users', 'departments', 'employees',
        'kpis', 'reports', 'collaboration_sessions', 'audit_logs',
        'kpi_history', 'analytics_events', 'notifications'
    ]

    for table in expected_tables:
        if table in tables:
            print(f"✓ Table '{table}' defined")
        else:
            errors.append(f"✗ Missing required table: {table}")

    print()

    # Find indexes
    index_pattern = r'CREATE INDEX\s+(\w+)'
    indexes = re.findall(index_pattern, content, re.IGNORECASE)
    print(f"✓ Found {len(indexes)} indexes\n")

    # Find foreign keys
    fk_pattern = r'FOREIGN KEY\s*\([^)]+\)\s*REFERENCES\s+(\w+)'
    foreign_keys = re.findall(fk_pattern, content, re.IGNORECASE)
    print(f"✓ Found {len(foreign_keys)} foreign key relationships\n")

    # Check for RLS policies
    if 'ROW LEVEL SECURITY' in content:
        print("✓ Row Level Security policies defined\n")
    else:
        errors.append("✗ No Row Level Security policies found")

    # Check for partitioning
    if 'PARTITION BY' in content:
        partition_pattern = r'(\w+).*PARTITION BY'
        partitioned_tables = re.findall(partition_pattern, content, re.IGNORECASE)
        print(f"✓ Found {len(partitioned_tables)} partitioned tables: {', '.join(partitioned_tables)}\n")

    # Check for triggers
    if 'CREATE TRIGGER' in content or 'CREATE OR REPLACE FUNCTION' in content:
        print("✓ Database triggers/functions defined\n")

    # Print errors
    if errors:
        print("\n⚠️  WARNINGS:")
        for error in errors:
            print(f"  {error}")
        print()

    # Summary
    print("=" * 50)
    print(f"SUMMARY:")
    print(f"  Tables: {len(tables)}")
    print(f"  Indexes: {len(indexes)}")
    print(f"  Foreign Keys: {len(foreign_keys)}")
    print(f"  Errors: {len(errors)}")
    print("=" * 50)

    if errors:
        return False

    print("\n✅ Schema validation passed!")
    return True

if __name__ == "__main__":
    filepath = "database-schema.sql"
    success = validate_sql_file(filepath)
    sys.exit(0 if success else 1)
