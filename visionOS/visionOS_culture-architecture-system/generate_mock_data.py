#!/usr/bin/env python3
"""
Mock Data Generator for Culture Architecture System
Generates realistic, anonymized test data for demos and testing

Output:
- JSON files for Swift import
- CSV files for analysis
- README with data dictionary
"""

import json
import csv
import random
import uuid
from datetime import datetime, timedelta
from typing import List, Dict
import hashlib

class MockDataGenerator:
    def __init__(self, seed=42):
        random.seed(seed)

        # Industry verticals
        self.industries = [
            "Technology", "Healthcare", "Financial Services", "Retail",
            "Manufacturing", "Professional Services", "Education", "Government",
            "Nonprofit", "Media & Entertainment"
        ]

        # Company sizes
        self.company_sizes = [
            (100, 500), (500, 1000), (1000, 2500), (2500, 5000), (5000, 10000)
        ]

        # Cultural value categories
        self.value_categories = [
            "Innovation", "Collaboration", "Integrity", "Customer Focus",
            "Excellence", "Diversity", "Sustainability", "Agility",
            "Accountability", "Transparency", "Respect", "Empowerment"
        ]

        # Departments
        self.departments = [
            "Engineering", "Product", "Design", "Marketing", "Sales",
            "Customer Success", "Operations", "Finance", "HR", "Legal"
        ]

        # Job roles (generalized for privacy)
        self.roles = [
            "Individual Contributor", "Senior Contributor", "Team Lead",
            "Manager", "Senior Manager", "Director", "Senior Director",
            "VP", "C-Level"
        ]

        # Recognition types
        self.recognition_types = [
            "Peer Recognition", "Manager Recognition", "Team Award",
            "Innovation Award", "Culture Champion", "Customer Hero",
            "Collaboration Star", "Leadership Award"
        ]

        # Behavior event types
        self.behavior_types = [
            "Collaboration", "Innovation", "Mentoring", "Problem Solving",
            "Customer Service", "Leadership", "Learning", "Communication"
        ]

    def generate_anonymous_id(self, real_id: str) -> str:
        """Generate consistent anonymous ID using SHA256"""
        hash_obj = hashlib.sha256(real_id.encode())
        return str(uuid.UUID(hash_obj.hexdigest()[:32]))

    def generate_organizations(self, count: int) -> List[Dict]:
        """Generate mock organizations"""
        organizations = []

        company_prefixes = [
            "Tech", "Digital", "Cloud", "Smart", "Next", "Future", "Quantum",
            "Nova", "Apex", "Summit", "Prime", "Elite", "Global", "United"
        ]

        company_suffixes = [
            "Systems", "Solutions", "Technologies", "Enterprises", "Group",
            "Corporation", "Industries", "Partners", "Ventures", "Labs"
        ]

        for i in range(count):
            prefix = random.choice(company_prefixes)
            suffix = random.choice(company_suffixes)
            name = f"{prefix}{suffix}"

            size_range = random.choice(self.company_sizes)
            employee_count = random.randint(*size_range)

            org = {
                "id": str(uuid.uuid4()),
                "name": name,
                "industry": random.choice(self.industries),
                "employeeCount": employee_count,
                "foundedYear": random.randint(1990, 2020),
                "healthScore": round(random.uniform(60, 95), 1),
                "engagementScore": round(random.uniform(55, 90), 1),
                "alignmentScore": round(random.uniform(60, 92), 1),
                "retentionRate": round(random.uniform(80, 95), 1),
                "createdAt": (datetime.now() - timedelta(days=random.randint(30, 365))).isoformat(),
                "updatedAt": datetime.now().isoformat()
            }

            organizations.append(org)

        return organizations

    def generate_departments(self, org_id: str) -> List[Dict]:
        """Generate departments for an organization"""
        departments = []

        for dept_name in self.departments:
            dept = {
                "id": str(uuid.uuid4()),
                "organizationId": org_id,
                "name": dept_name,
                "headcount": random.randint(10, 200),
                "healthScore": round(random.uniform(60, 95), 1),
                "createdAt": datetime.now().isoformat(),
                "updatedAt": datetime.now().isoformat()
            }
            departments.append(dept)

        return departments

    def generate_employees(self, org_id: str, departments: List[Dict], count: int) -> List[Dict]:
        """Generate anonymized employees"""
        employees = []

        for i in range(count):
            # Generate fake real ID for hashing (never stored)
            real_id = f"employee_{org_id}_{i}@fake.com"
            anonymous_id = self.generate_anonymous_id(real_id)

            dept = random.choice(departments)

            # Tenure weighted toward newer employees
            tenure_months = int(random.triangular(1, 240, 24))

            employee = {
                "id": anonymous_id,
                "organizationId": org_id,
                "departmentId": dept["id"],
                "teamId": str(uuid.uuid4()),  # Random team assignment
                "role": random.choice(self.roles),
                "tenureMonths": tenure_months,
                "engagementScore": round(random.uniform(40, 100), 1),
                "culturalContributions": random.randint(0, 50),
                "recognitionsReceived": random.randint(0, 30),
                "recognitionsGiven": random.randint(0, 40),
                "lastActiveDate": (datetime.now() - timedelta(days=random.randint(0, 30))).isoformat(),
                "createdAt": (datetime.now() - timedelta(days=tenure_months * 30)).isoformat(),
                "updatedAt": datetime.now().isoformat()
            }

            employees.append(employee)

        return employees

    def generate_cultural_values(self, org_id: str, count: int) -> List[Dict]:
        """Generate cultural values"""
        values = []

        descriptors = [
            "Drive", "Foster", "Champion", "Embrace", "Cultivate",
            "Pursue", "Demonstrate", "Enable", "Build", "Create"
        ]

        for category in random.sample(self.value_categories, min(count, len(self.value_categories))):
            descriptor = random.choice(descriptors)

            value = {
                "id": str(uuid.uuid4()),
                "organizationId": org_id,
                "name": category,
                "description": f"{descriptor} {category.lower()} across the organization",
                "dimension": random.choice(["Individual", "Team", "Organizational"]),
                "priority": random.randint(1, 5),
                "adoptionRate": round(random.uniform(40, 95), 1),
                "behaviorCount": random.randint(10, 500),
                "createdAt": (datetime.now() - timedelta(days=random.randint(90, 365))).isoformat(),
                "updatedAt": datetime.now().isoformat()
            }

            values.append(value)

        return values

    def generate_recognitions(self, employees: List[Dict], values: List[Dict], count: int) -> List[Dict]:
        """Generate recognition events"""
        recognitions = []

        messages = [
            "Great work on the project!",
            "Thank you for your collaboration",
            "Outstanding customer service",
            "Innovative solution to a complex problem",
            "Excellent teamwork and communication",
            "Going above and beyond",
            "Mentoring and helping others grow",
            "Living our values every day"
        ]

        for i in range(count):
            giver = random.choice(employees)
            receiver = random.choice(employees)

            # Avoid self-recognition
            while giver["id"] == receiver["id"]:
                receiver = random.choice(employees)

            value = random.choice(values) if values else None

            recognition = {
                "id": str(uuid.uuid4()),
                "organizationId": giver["organizationId"],
                "giverId": giver["id"],
                "receiverId": receiver["id"],
                "valueId": value["id"] if value else None,
                "type": random.choice(self.recognition_types),
                "message": random.choice(messages),
                "visibility": random.choice(["Public", "Team", "Private"]),
                "reactionCount": random.randint(0, 50),
                "createdAt": (datetime.now() - timedelta(days=random.randint(0, 180))).isoformat()
            }

            recognitions.append(recognition)

        return recognitions

    def generate_behavior_events(self, employees: List[Dict], values: List[Dict], count: int) -> List[Dict]:
        """Generate behavior tracking events"""
        events = []

        for i in range(count):
            employee = random.choice(employees)
            value = random.choice(values) if values else None

            event = {
                "id": str(uuid.uuid4()),
                "organizationId": employee["organizationId"],
                "employeeId": employee["id"],
                "valueId": value["id"] if value else None,
                "behaviorType": random.choice(self.behavior_types),
                "impact": random.choice(["Low", "Medium", "High"]),
                "context": random.choice(["Meeting", "Project", "Daily Work", "Customer Interaction"]),
                "observed": random.choice([True, False]),
                "timestamp": (datetime.now() - timedelta(days=random.randint(0, 90))).isoformat()
            }

            events.append(event)

        return events

    def generate_cultural_landscapes(self, org_id: str, values: List[Dict]) -> List[Dict]:
        """Generate cultural landscape metadata"""
        landscapes = []

        landscape = {
            "id": str(uuid.uuid4()),
            "organizationId": org_id,
            "name": "Primary Culture Landscape",
            "description": "Main organizational culture visualization",
            "regionCount": len(values),
            "totalArea": random.randint(1000, 5000),
            "healthScore": round(random.uniform(60, 95), 1),
            "lastUpdated": datetime.now().isoformat()
        }

        landscapes.append(landscape)

        return landscapes

    def generate_all_data(self, org_count=50, employees_per_org_range=(100, 500)):
        """Generate complete dataset"""
        print("🎲 Generating mock data...")

        # Generate organizations
        print(f"  → Generating {org_count} organizations...")
        organizations = self.generate_organizations(org_count)

        all_departments = []
        all_employees = []
        all_values = []
        all_recognitions = []
        all_behavior_events = []
        all_landscapes = []

        for org in organizations:
            print(f"  → Processing {org['name']}...")

            # Departments
            departments = self.generate_departments(org["id"])
            all_departments.extend(departments)

            # Employees
            employee_count = random.randint(*employees_per_org_range)
            employees = self.generate_employees(org["id"], departments, employee_count)
            all_employees.extend(employees)

            # Values
            value_count = random.randint(5, 10)
            values = self.generate_cultural_values(org["id"], value_count)
            all_values.extend(values)

            # Recognitions (2-3 per employee on average)
            recognition_count = int(employee_count * random.uniform(2, 3))
            recognitions = self.generate_recognitions(employees, values, recognition_count)
            all_recognitions.extend(recognitions)

            # Behavior events (3-5 per employee on average)
            event_count = int(employee_count * random.uniform(3, 5))
            behavior_events = self.generate_behavior_events(employees, values, event_count)
            all_behavior_events.extend(behavior_events)

            # Landscapes
            landscapes = self.generate_cultural_landscapes(org["id"], values)
            all_landscapes.extend(landscapes)

        return {
            "organizations": organizations,
            "departments": all_departments,
            "employees": all_employees,
            "culturalValues": all_values,
            "recognitions": all_recognitions,
            "behaviorEvents": all_behavior_events,
            "culturalLandscapes": all_landscapes
        }

    def save_json(self, data: Dict, filename: str):
        """Save data as JSON"""
        with open(filename, 'w') as f:
            json.dump(data, f, indent=2)
        print(f"✅ Saved: {filename}")

    def save_csv(self, data: List[Dict], filename: str):
        """Save data as CSV"""
        if not data:
            return

        keys = data[0].keys()
        with open(filename, 'w', newline='') as f:
            writer = csv.DictWriter(f, fieldnames=keys)
            writer.writeheader()
            writer.writerows(data)
        print(f"✅ Saved: {filename}")

    def generate_statistics(self, data: Dict) -> Dict:
        """Generate statistics about the dataset"""
        return {
            "organizations": len(data["organizations"]),
            "departments": len(data["departments"]),
            "employees": len(data["employees"]),
            "culturalValues": len(data["culturalValues"]),
            "recognitions": len(data["recognitions"]),
            "behaviorEvents": len(data["behaviorEvents"]),
            "culturalLandscapes": len(data["culturalLandscapes"]),
            "avgEmployeesPerOrg": len(data["employees"]) / len(data["organizations"]),
            "avgValuesPerOrg": len(data["culturalValues"]) / len(data["organizations"]),
            "avgRecognitionsPerEmployee": len(data["recognitions"]) / len(data["employees"]),
            "generatedAt": datetime.now().isoformat()
        }

def main():
    print("=" * 80)
    print("CULTURE ARCHITECTURE SYSTEM - MOCK DATA GENERATOR")
    print("=" * 80)
    print()

    generator = MockDataGenerator(seed=42)

    # Generate data
    data = generator.generate_all_data(
        org_count=50,
        employees_per_org_range=(100, 500)
    )

    print()
    print("💾 Saving data files...")

    # Create output directory
    import os
    os.makedirs("MockData", exist_ok=True)

    # Save complete dataset as JSON
    generator.save_json(data, "MockData/complete_dataset.json")

    # Save individual collections
    generator.save_json(data["organizations"], "MockData/organizations.json")
    generator.save_json(data["departments"], "MockData/departments.json")
    generator.save_json(data["employees"], "MockData/employees.json")
    generator.save_json(data["culturalValues"], "MockData/cultural_values.json")
    generator.save_json(data["recognitions"], "MockData/recognitions.json")
    generator.save_json(data["behaviorEvents"], "MockData/behavior_events.json")
    generator.save_json(data["culturalLandscapes"], "MockData/cultural_landscapes.json")

    # Save as CSV for analysis
    generator.save_csv(data["organizations"], "MockData/organizations.csv")
    generator.save_csv(data["departments"], "MockData/departments.csv")
    generator.save_csv(data["employees"], "MockData/employees.csv")
    generator.save_csv(data["culturalValues"], "MockData/cultural_values.csv")
    generator.save_csv(data["recognitions"], "MockData/recognitions.csv")
    generator.save_csv(data["behaviorEvents"], "MockData/behavior_events.csv")

    # Generate statistics
    stats = generator.generate_statistics(data)
    generator.save_json(stats, "MockData/statistics.json")

    print()
    print("=" * 80)
    print("📊 DATASET STATISTICS")
    print("=" * 80)
    print(f"Organizations:        {stats['organizations']:,}")
    print(f"Departments:          {stats['departments']:,}")
    print(f"Employees:            {stats['employees']:,}")
    print(f"Cultural Values:      {stats['culturalValues']:,}")
    print(f"Recognitions:         {stats['recognitions']:,}")
    print(f"Behavior Events:      {stats['behaviorEvents']:,}")
    print(f"Cultural Landscapes:  {stats['culturalLandscapes']:,}")
    print()
    print(f"Avg Employees/Org:    {stats['avgEmployeesPerOrg']:.1f}")
    print(f"Avg Values/Org:       {stats['avgValuesPerOrg']:.1f}")
    print(f"Avg Recognitions/Emp: {stats['avgRecognitionsPerEmployee']:.1f}")
    print()
    print("✅ Mock data generation complete!")
    print(f"📁 Files saved in: MockData/")
    print()

if __name__ == "__main__":
    main()
