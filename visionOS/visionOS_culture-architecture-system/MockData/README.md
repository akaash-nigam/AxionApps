# Mock Data - Culture Architecture System

**Generated**: January 20, 2025
**Purpose**: Realistic test data for development, demos, and testing

---

## Overview

This directory contains comprehensive mock data for the Culture Architecture System. All data is **anonymized** and generated using realistic patterns.

### Dataset Statistics

- **Organizations**: 50 companies across 10 industries
- **Departments**: 500 departments
- **Employees**: 15,226 anonymized employees
- **Cultural Values**: 385 values
- **Recognitions**: 37,400 peer recognition events
- **Behavior Events**: 60,686 behavior tracking events
- **Cultural Landscapes**: 50 3D landscape definitions

**Averages**:
- 304.5 employees per organization
- 7.7 values per organization
- 2.5 recognitions per employee

---

## Files

### JSON Files (For Swift Import)

| File | Records | Description |
|------|---------|-------------|
| `complete_dataset.json` | All | Complete dataset in one file |
| `organizations.json` | 50 | Organization entities |
| `departments.json` | 500 | Department entities |
| `employees.json` | 15,226 | Anonymized employee data |
| `cultural_values.json` | 385 | Cultural value definitions |
| `recognitions.json` | 37,400 | Recognition events |
| `behavior_events.json` | 60,686 | Behavior tracking events |
| `cultural_landscapes.json` | 50 | 3D landscape metadata |
| `statistics.json` | - | Dataset statistics |

### CSV Files (For Analysis)

| File | Records | Description |
|------|---------|-------------|
| `organizations.csv` | 50 | Spreadsheet format |
| `departments.csv` | 500 | Spreadsheet format |
| `employees.csv` | 15,226 | Spreadsheet format |
| `cultural_values.csv` | 385 | Spreadsheet format |
| `recognitions.csv` | 37,400 | Spreadsheet format |
| `behavior_events.csv` | 60,686 | Spreadsheet format |

---

## Data Schema

### Organizations

```json
{
  "id": "uuid",
  "name": "string",
  "industry": "string",
  "employeeCount": number,
  "foundedYear": number,
  "healthScore": number (60-95),
  "engagementScore": number (55-90),
  "alignmentScore": number (60-92),
  "retentionRate": number (80-95),
  "createdAt": "ISO 8601",
  "updatedAt": "ISO 8601"
}
```

**Industries**: Technology, Healthcare, Financial Services, Retail, Manufacturing, Professional Services, Education, Government, Nonprofit, Media & Entertainment

### Departments

```json
{
  "id": "uuid",
  "organizationId": "uuid",
  "name": "string",
  "headcount": number (10-200),
  "healthScore": number (60-95),
  "createdAt": "ISO 8601",
  "updatedAt": "ISO 8601"
}
```

**Department Names**: Engineering, Product, Design, Marketing, Sales, Customer Success, Operations, Finance, HR, Legal

### Employees (Anonymized)

```json
{
  "id": "uuid (SHA256 hash)",
  "organizationId": "uuid",
  "departmentId": "uuid",
  "teamId": "uuid",
  "role": "string (generalized)",
  "tenureMonths": number (1-240),
  "engagementScore": number (40-100),
  "culturalContributions": number (0-50),
  "recognitionsReceived": number (0-30),
  "recognitionsGiven": number (0-40),
  "lastActiveDate": "ISO 8601",
  "createdAt": "ISO 8601",
  "updatedAt": "ISO 8601"
}
```

**Roles (Generalized)**: Individual Contributor, Senior Contributor, Team Lead, Manager, Senior Manager, Director, Senior Director, VP, C-Level

⚠️ **Privacy Note**: All employee IDs are anonymized using SHA256 hashing. No personally identifiable information (PII) is included.

### Cultural Values

```json
{
  "id": "uuid",
  "organizationId": "uuid",
  "name": "string",
  "description": "string",
  "dimension": "Individual | Team | Organizational",
  "priority": number (1-5),
  "adoptionRate": number (40-95),
  "behaviorCount": number (10-500),
  "createdAt": "ISO 8601",
  "updatedAt": "ISO 8601"
}
```

**Value Categories**: Innovation, Collaboration, Integrity, Customer Focus, Excellence, Diversity, Sustainability, Agility, Accountability, Transparency, Respect, Empowerment

### Recognitions

```json
{
  "id": "uuid",
  "organizationId": "uuid",
  "giverId": "uuid (anonymous)",
  "receiverId": "uuid (anonymous)",
  "valueId": "uuid",
  "type": "string",
  "message": "string",
  "visibility": "Public | Team | Private",
  "reactionCount": number (0-50),
  "createdAt": "ISO 8601"
}
```

**Recognition Types**: Peer Recognition, Manager Recognition, Team Award, Innovation Award, Culture Champion, Customer Hero, Collaboration Star, Leadership Award

### Behavior Events

```json
{
  "id": "uuid",
  "organizationId": "uuid",
  "employeeId": "uuid (anonymous)",
  "valueId": "uuid",
  "behaviorType": "string",
  "impact": "Low | Medium | High",
  "context": "string",
  "observed": boolean,
  "timestamp": "ISO 8601"
}
```

**Behavior Types**: Collaboration, Innovation, Mentoring, Problem Solving, Customer Service, Leadership, Learning, Communication

**Contexts**: Meeting, Project, Daily Work, Customer Interaction

---

## Usage

### Import into Swift/Xcode

```swift
// Read JSON file
if let path = Bundle.main.path(forResource: "organizations", ofType: "json") {
    let data = try Data(contentsOf: URL(fileURLWithPath: path))
    let organizations = try JSONDecoder().decode([Organization].self, from: data)
}
```

### Import into SwiftData

```swift
let modelContainer = try ModelContainer(for: Organization.self, Employee.self, ...)

// Import organizations
for org in organizations {
    modelContainer.mainContext.insert(org)
}

try modelContainer.mainContext.save()
```

### Analyze with Python

```python
import pandas as pd

# Read CSV
df = pd.read_csv('employees.csv')

# Analyze
avg_engagement = df['engagementScore'].mean()
print(f"Average engagement: {avg_engagement}")
```

### Load Complete Dataset

```python
import json

with open('complete_dataset.json') as f:
    data = json.load(f)

organizations = data['organizations']
employees = data['employees']
# ... etc
```

---

## Data Characteristics

### Distribution

**Employee Tenure**:
- Weighted toward newer employees (realistic)
- Range: 1-240 months (0-20 years)
- Median: ~24 months

**Company Sizes**:
- Small: 100-500 employees
- Medium: 500-1,000 employees
- Large: 1,000-2,500 employees
- Enterprise: 2,500-10,000 employees

**Engagement Scores**:
- Range: 40-100
- Mean: ~70
- Realistic variation by department and tenure

**Recognition Patterns**:
- Some employees give more (givers)
- Some receive more (high performers)
- Realistic social graph patterns

### Relationships

- Each employee belongs to one organization
- Each employee belongs to one department
- Each department belongs to one organization
- Each recognition references:
  - One giver (employee)
  - One receiver (employee)
  - One value (optional)
- Each behavior event references:
  - One employee
  - One value (optional)

---

## Privacy & Compliance

### ✅ Privacy-First Design

All data is **fully anonymized**:
- Employee IDs are SHA256 hashes (irreversible)
- No names, emails, or contact information
- No birth dates or demographic data
- Roles are generalized (no specific titles)
- K-anonymity: Minimum 5 employees per team

### ✅ GDPR Compliant

- No personal data stored
- No data subject rights issues
- No consent required
- No data protection impact assessment needed

### ✅ Enterprise-Ready

- Safe for demos and presentations
- No risk of data leakage
- Can be shared publicly
- Production-quality test data

---

## Regeneration

To generate fresh data with different patterns:

```bash
# Generate new dataset (default: 50 orgs)
python3 generate_mock_data.py

# Custom parameters (edit script):
generator.generate_all_data(
    org_count=100,
    employees_per_org_range=(50, 1000)
)
```

**Seed**: Set to 42 for reproducibility. Change seed for different random data.

---

## Use Cases

### Development
- Test SwiftData models
- Test API endpoints
- Test UI with realistic data
- Performance testing

### Demos
- Sales presentations
- Customer demos
- Conference talks
- Training sessions

### Testing
- Unit tests
- Integration tests
- Load testing
- Edge case testing

### Analysis
- Algorithm development
- Analytics validation
- Visualization testing
- ML model training

---

## Known Limitations

1. **Simplified Relationships**: Real organizational data is more complex
2. **Random Patterns**: Real behavior has more structure
3. **No Time Series**: Events are randomly distributed
4. **Uniform Distributions**: Real data often has power-law distributions
5. **No Outliers**: Real data has edge cases and anomalies

For production use, supplement with real (anonymized) data where possible.

---

## Support

For questions about the mock data:
- Check `generate_mock_data.py` source code
- Review `statistics.json` for dataset overview
- See main project documentation

---

**Generated by**: `generate_mock_data.py`
**Version**: 1.0
**Last Updated**: January 20, 2025
