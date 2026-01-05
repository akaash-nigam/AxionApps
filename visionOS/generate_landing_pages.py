#!/usr/bin/env python3
"""
visionOS Landing Page Generator
Generates landing pages for all non-gaming visionOS apps using the visionOS Design System
"""

import os
import json

# App metadata - category, color, tagline, description, features
APPS_DATA = {
    # AI & Technology (Purple #a855f7)
    "visionOS_ai-agent-coordinator": {
        "name": "AI Agent Coordinator",
        "icon": "AC",
        "category": "AI & Technology",
        "accent": "#a855f7",
        "accent_rgb": "168, 85, 247",
        "tagline": "Orchestrate AI Agents in Spatial 3D",
        "description": "Visualize and control multiple AI agents working together in a spatial command center. See task flows, agent interactions, and workflow orchestration in immersive 3D space. Manage up to 50,000+ agents with real-time monitoring.",
        "features": [
            ("🤖", "Spatial Agent Map", "Visualize all AI agents and their relationships in 3D space with real-time status"),
            ("🔄", "Workflow Orchestration", "Design complex multi-agent workflows with spatial drag-and-drop"),
            ("📊", "Real-Time Monitoring", "Track agent performance at 100Hz across spatial dashboards"),
            ("🎯", "Gesture Control", "Direct agents using natural hand gestures"),
            ("🔗", "Agent Collaboration", "Visualize agent communication in immersive networks"),
            ("👥", "SharePlay Integration", "Collaborate with up to 8 team members")
        ],
        "stats": [("50K+", "Agents"), ("100Hz", "Updates"), ("60fps", "Performance"), ("8+", "Users")]
    },
    "visionOS_digital-twin-orchestrator": {
        "name": "Digital Twin Orchestrator",
        "icon": "DT",
        "category": "AI & Technology",
        "accent": "#a855f7",
        "accent_rgb": "168, 85, 247",
        "tagline": "Manage Digital Twins in Spatial Reality",
        "description": "Create, monitor, and control digital twins of physical assets in immersive 3D space. Real-time synchronization with IoT sensors and predictive analytics.",
        "features": [
            ("🏭", "Asset Visualization", "View digital twins of physical assets in true-to-scale 3D"),
            ("📡", "IoT Integration", "Real-time data from thousands of sensors"),
            ("🔮", "Predictive Analytics", "AI-powered failure prediction and maintenance scheduling"),
            ("🔄", "Sync Engine", "Sub-second synchronization with physical assets"),
            ("📊", "Performance Metrics", "Comprehensive dashboards for asset health"),
            ("👁️", "Remote Inspection", "Virtual walkthroughs of remote facilities")
        ],
        "stats": [("10K+", "Assets"), ("1ms", "Sync"), ("99.9%", "Uptime"), ("24/7", "Monitoring")]
    },
    "visionOS_Research-Web-Crawler": {
        "name": "Research Web Crawler",
        "icon": "RW",
        "category": "AI & Technology",
        "accent": "#a855f7",
        "accent_rgb": "168, 85, 247",
        "tagline": "Visualize Research Networks in 3D",
        "description": "Explore academic research, citations, and knowledge graphs in immersive spatial visualization. Discover connections across millions of papers.",
        "features": [
            ("🕸️", "Knowledge Graph", "Explore citation networks in 3D space"),
            ("🔍", "Smart Search", "AI-powered research discovery"),
            ("📚", "Paper Analysis", "Deep analysis of academic papers"),
            ("🔗", "Citation Mapping", "Visualize research influence"),
            ("📊", "Trend Detection", "Identify emerging research areas"),
            ("👥", "Collaboration", "Share discoveries with team")
        ],
        "stats": [("50M+", "Papers"), ("1B+", "Citations"), ("100+", "Fields"), ("Real-time", "Updates")]
    },
    "visionOS_Spatial-Code-Reviewer": {
        "name": "Spatial Code Reviewer",
        "icon": "CR",
        "category": "AI & Technology",
        "accent": "#a855f7",
        "accent_rgb": "168, 85, 247",
        "tagline": "Review Code in Immersive 3D",
        "description": "Visualize codebases, dependencies, and architecture in spatial 3D. AI-powered code review with visual diff and collaboration.",
        "features": [
            ("📦", "Codebase Map", "3D visualization of code architecture"),
            ("🔍", "Smart Review", "AI-assisted code analysis"),
            ("🔗", "Dependency Graph", "Visualize module relationships"),
            ("📝", "Inline Comments", "Spatial code annotations"),
            ("👥", "Team Review", "Collaborative code walkthroughs"),
            ("📊", "Code Metrics", "Quality and complexity analysis")
        ],
        "stats": [("1M+", "Lines"), ("100+", "Languages"), ("AI", "Powered"), ("Real-time", "Collab")]
    },

    # Healthcare (Teal #14b8a6)
    "visionOS_healthcare-ecosystem-orchestrator": {
        "name": "Healthcare Ecosystem Orchestrator",
        "icon": "HE",
        "category": "Healthcare",
        "accent": "#14b8a6",
        "accent_rgb": "20, 184, 166",
        "tagline": "Coordinate Healthcare Systems in 3D",
        "description": "Manage complex healthcare operations in spatial reality. Coordinate patient care, resources, and workflows across hospitals in an immersive command center.",
        "features": [
            ("🏥", "Hospital Operations", "Monitor bed capacity and ER flow in 3D"),
            ("👨‍⚕️", "Care Coordination", "Track patient journeys across departments"),
            ("📊", "Resource Management", "Optimize staff and equipment allocation"),
            ("🚑", "Emergency Response", "Real-time spatial incident tracking"),
            ("📈", "Health Analytics", "Population health visualization"),
            ("🔒", "HIPAA Compliant", "Enterprise-grade security")
        ],
        "stats": [("500+", "Beds"), ("24/7", "Monitoring"), ("99.9%", "Uptime"), ("HIPAA", "Compliant")]
    },
    "visionOS_Medical-Imaging-Suite": {
        "name": "Medical Imaging Suite",
        "icon": "MI",
        "category": "Healthcare",
        "accent": "#14b8a6",
        "accent_rgb": "20, 184, 166",
        "tagline": "3D Medical Imaging in Spatial Reality",
        "description": "View CT, MRI, and X-ray images in true 3D space. Collaborate on diagnoses with spatial annotations and AI-assisted analysis.",
        "features": [
            ("🩻", "3D Reconstruction", "View scans in volumetric 3D"),
            ("🔍", "AI Analysis", "Automated anomaly detection"),
            ("✏️", "Spatial Annotation", "Mark findings in 3D space"),
            ("👥", "Collaboration", "Multi-physician review sessions"),
            ("📊", "Comparison Tools", "Side-by-side scan analysis"),
            ("📱", "DICOM Support", "Full medical imaging standards")
        ],
        "stats": [("4K+", "Resolution"), ("AI", "Enhanced"), ("DICOM", "Compatible"), ("HIPAA", "Compliant")]
    },
    "visionOS_surgical-training-universe": {
        "name": "Surgical Training Universe",
        "icon": "ST",
        "category": "Healthcare",
        "accent": "#14b8a6",
        "accent_rgb": "20, 184, 166",
        "tagline": "Immersive Surgical Training",
        "description": "Practice surgical procedures in realistic 3D simulations. Learn from expert-guided tutorials with haptic feedback and real-time assessment.",
        "features": [
            ("🔬", "Realistic Anatomy", "True-to-life 3D organ models"),
            ("🎓", "Expert Tutorials", "Step-by-step guided procedures"),
            ("📊", "Performance Tracking", "Detailed skill assessment"),
            ("🤝", "Mentorship Mode", "Remote expert supervision"),
            ("🔄", "Procedure Library", "100+ surgical procedures"),
            ("📈", "Progress Analytics", "Track improvement over time")
        ],
        "stats": [("100+", "Procedures"), ("4K", "Graphics"), ("Haptic", "Feedback"), ("CE", "Certified")]
    },
    "visionOS_spatial-wellness-platform": {
        "name": "Spatial Wellness Platform",
        "icon": "SW",
        "category": "Healthcare",
        "accent": "#14b8a6",
        "accent_rgb": "20, 184, 166",
        "tagline": "Wellness in Immersive Space",
        "description": "Transform mental and physical wellness with immersive environments. Guided meditation, therapy sessions, and fitness in spatial reality.",
        "features": [
            ("🧘", "Guided Meditation", "Immersive mindfulness environments"),
            ("💪", "Fitness Programs", "Spatial workout experiences"),
            ("🌿", "Nature Escapes", "Calming virtual environments"),
            ("📊", "Health Tracking", "Biometric integration"),
            ("👥", "Group Sessions", "Shared wellness experiences"),
            ("🎯", "Goal Setting", "Personalized wellness plans")
        ],
        "stats": [("1000+", "Sessions"), ("50+", "Environments"), ("Health", "Sync"), ("Daily", "Programs")]
    },

    # Finance (Blue #3b82f6)
    "visionOS_Financial-Trading-Cockpit": {
        "name": "Financial Trading Cockpit",
        "icon": "FT",
        "category": "Finance",
        "accent": "#3b82f6",
        "accent_rgb": "59, 130, 246",
        "tagline": "Trade in Immersive 3D Markets",
        "description": "Experience financial markets in spatial 3D. Real-time data visualization, multi-asset trading, and portfolio management in an immersive trading environment.",
        "features": [
            ("📈", "3D Market View", "Visualize market data in spatial layers"),
            ("⚡", "Real-Time Data", "Sub-millisecond market feeds"),
            ("📊", "Portfolio Analytics", "Comprehensive risk analysis"),
            ("🤖", "AI Signals", "Machine learning trade signals"),
            ("🔔", "Smart Alerts", "Spatial notification system"),
            ("👥", "Team Trading", "Collaborative trading rooms")
        ],
        "stats": [("1ms", "Latency"), ("100+", "Markets"), ("AI", "Signals"), ("24/7", "Trading")]
    },
    "visionOS_financial-trading-dimension": {
        "name": "Financial Trading Dimension",
        "icon": "TD",
        "category": "Finance",
        "accent": "#3b82f6",
        "accent_rgb": "59, 130, 246",
        "tagline": "Next-Gen Trading Interface",
        "description": "Advanced financial trading with spatial interfaces. Multi-dimensional data analysis and algorithmic trading in immersive 3D.",
        "features": [
            ("📊", "Multi-Dimensional Charts", "View data across multiple dimensions"),
            ("🤖", "Algo Trading", "Spatial algorithm visualization"),
            ("📈", "Pattern Recognition", "AI-powered chart patterns"),
            ("⚡", "HFT Compatible", "High-frequency trading support"),
            ("🔐", "Secure Trading", "Bank-grade security"),
            ("📱", "Cross-Platform", "Sync across devices")
        ],
        "stats": [("<1ms", "Execution"), ("1000+", "Algos"), ("256-bit", "Encryption"), ("SEC", "Compliant")]
    },
    "visionOS_financial-operations-platform": {
        "name": "Financial Operations Platform",
        "icon": "FO",
        "category": "Finance",
        "accent": "#3b82f6",
        "accent_rgb": "59, 130, 246",
        "tagline": "Enterprise FinOps in Spatial Reality",
        "description": "Manage financial operations across your organization in immersive 3D. Treasury, accounting, and reporting in a unified spatial interface.",
        "features": [
            ("💰", "Treasury Management", "Cash flow visualization in 3D"),
            ("📊", "Financial Reporting", "Interactive spatial reports"),
            ("🔄", "Reconciliation", "Automated matching workflows"),
            ("📈", "Forecasting", "AI-powered financial predictions"),
            ("✅", "Compliance", "Regulatory reporting automation"),
            ("👥", "Team Workflows", "Collaborative approval processes")
        ],
        "stats": [("SOX", "Compliant"), ("99.99%", "Accuracy"), ("Real-time", "Reporting"), ("Multi", "Currency")]
    },
    "visionOS_Personal-Finance-Navigator": {
        "name": "Personal Finance Navigator",
        "icon": "PF",
        "category": "Finance",
        "accent": "#3b82f6",
        "accent_rgb": "59, 130, 246",
        "tagline": "Your Financial Future in 3D",
        "description": "Visualize your financial journey in immersive 3D. Budget tracking, investment planning, and goal setting in spatial reality.",
        "features": [
            ("📊", "3D Budget View", "See spending patterns spatially"),
            ("📈", "Investment Tracker", "Portfolio visualization"),
            ("🎯", "Goal Planning", "Visual financial milestones"),
            ("🔔", "Smart Alerts", "Spending notifications"),
            ("📱", "Bank Sync", "Automatic transaction import"),
            ("🔐", "Privacy First", "Bank-level encryption")
        ],
        "stats": [("10K+", "Banks"), ("256-bit", "Security"), ("AI", "Insights"), ("Real-time", "Sync")]
    },
    "visionOS_insurance-risk-assessor": {
        "name": "Insurance Risk Assessor",
        "icon": "IR",
        "category": "Finance",
        "accent": "#3b82f6",
        "accent_rgb": "59, 130, 246",
        "tagline": "Risk Assessment in Spatial 3D",
        "description": "Evaluate insurance risks with spatial visualization. Property inspection, damage assessment, and underwriting in immersive 3D.",
        "features": [
            ("🏠", "Property Inspection", "Virtual property walkthroughs"),
            ("📊", "Risk Scoring", "AI-powered risk analysis"),
            ("📸", "Damage Assessment", "3D damage documentation"),
            ("📝", "Underwriting Tools", "Spatial policy evaluation"),
            ("🔍", "Claims Analysis", "Visual claims investigation"),
            ("📈", "Portfolio Risk", "Aggregate risk visualization")
        ],
        "stats": [("AI", "Scoring"), ("3D", "Inspection"), ("Real-time", "Analysis"), ("SOC2", "Compliant")]
    },

    # Enterprise & Operations (Indigo #6366f1)
    "visionOS_spatial-erp": {
        "name": "Spatial ERP",
        "icon": "SE",
        "category": "Enterprise",
        "accent": "#6366f1",
        "accent_rgb": "99, 102, 241",
        "tagline": "Enterprise Resource Planning in 3D",
        "description": "Transform ERP with spatial computing. Manage operations, inventory, and resources in an immersive 3D command center.",
        "features": [
            ("📦", "Inventory 3D", "Visualize stock across locations"),
            ("🔄", "Process Flows", "Spatial workflow management"),
            ("📊", "Real-Time Analytics", "Live operational dashboards"),
            ("👥", "Team Collaboration", "Shared spatial workspaces"),
            ("🔗", "Integration Hub", "Connect to existing systems"),
            ("📈", "Performance KPIs", "Visual goal tracking")
        ],
        "stats": [("SAP", "Compatible"), ("Oracle", "Ready"), ("Real-time", "Sync"), ("Unlimited", "Users")]
    },
    "visionOS_spatial-crm": {
        "name": "Spatial CRM",
        "icon": "SC",
        "category": "Enterprise",
        "accent": "#6366f1",
        "accent_rgb": "99, 102, 241",
        "tagline": "Customer Relations in Spatial Reality",
        "description": "Reimagine customer relationship management in 3D space. Visualize sales pipelines, customer journeys, and team performance.",
        "features": [
            ("📊", "3D Pipeline", "Spatial sales funnel visualization"),
            ("👥", "Customer 360", "Complete customer view in 3D"),
            ("📈", "Sales Analytics", "Performance metrics dashboard"),
            ("📧", "Communication Hub", "Integrated outreach tools"),
            ("🎯", "Lead Scoring", "AI-powered prioritization"),
            ("🔄", "Workflow Automation", "Spatial process automation")
        ],
        "stats": [("Salesforce", "Sync"), ("AI", "Scoring"), ("360°", "View"), ("Real-time", "Updates")]
    },
    "visionOS_spatial-hcm": {
        "name": "Spatial HCM",
        "icon": "SH",
        "category": "Enterprise",
        "accent": "#6366f1",
        "accent_rgb": "99, 102, 241",
        "tagline": "Human Capital in Spatial 3D",
        "description": "Manage your workforce in immersive 3D. Org charts, talent mapping, and team collaboration in spatial reality.",
        "features": [
            ("👥", "3D Org Chart", "Interactive organizational visualization"),
            ("🎯", "Talent Mapping", "Skills and succession planning"),
            ("📊", "HR Analytics", "Workforce metrics dashboard"),
            ("📋", "Performance Reviews", "Spatial feedback sessions"),
            ("🎓", "Learning Paths", "Visual career development"),
            ("🔄", "Onboarding", "Immersive new hire experience")
        ],
        "stats": [("Workday", "Sync"), ("AI", "Matching"), ("360", "Feedback"), ("Unlimited", "Employees")]
    },
    "visionOS_business-operating-system": {
        "name": "Business Operating System",
        "icon": "BO",
        "category": "Enterprise",
        "accent": "#6366f1",
        "accent_rgb": "99, 102, 241",
        "tagline": "Run Your Business in Spatial 3D",
        "description": "A complete business operating system for spatial computing. Strategy, operations, and execution in one immersive platform.",
        "features": [
            ("🎯", "Strategy Canvas", "Visual strategic planning"),
            ("📊", "OKR Tracking", "3D goal visualization"),
            ("👥", "Team Alignment", "Spatial collaboration tools"),
            ("📈", "Performance Dashboard", "Real-time business metrics"),
            ("🔄", "Process Management", "Visual workflow optimization"),
            ("📋", "Meeting Rooms", "Immersive team sessions")
        ],
        "stats": [("OKR", "Framework"), ("AI", "Insights"), ("Unlimited", "Goals"), ("Real-time", "Tracking")]
    },
    "visionOS_enterprise-apps": {
        "name": "Enterprise Apps Hub",
        "icon": "EA",
        "category": "Enterprise",
        "accent": "#6366f1",
        "accent_rgb": "99, 102, 241",
        "tagline": "Enterprise Applications in Spatial Reality",
        "description": "Access all your enterprise applications in a unified spatial interface. Single sign-on, integrated workflows, and seamless collaboration.",
        "features": [
            ("🏢", "App Launcher", "Spatial application hub"),
            ("🔐", "SSO Integration", "Single sign-on for all apps"),
            ("🔄", "Cross-App Workflows", "Unified process automation"),
            ("📊", "Usage Analytics", "Application insights"),
            ("👥", "Team Spaces", "Shared app environments"),
            ("🔗", "API Gateway", "Connect any enterprise app")
        ],
        "stats": [("1000+", "Apps"), ("SSO", "Enabled"), ("SOC2", "Certified"), ("24/7", "Support")]
    },
    "visionOS_executive-briefing": {
        "name": "Executive Briefing",
        "icon": "EB",
        "category": "Enterprise",
        "accent": "#6366f1",
        "accent_rgb": "99, 102, 241",
        "tagline": "Executive Intelligence in 3D",
        "description": "Deliver and receive executive briefings in immersive 3D. Data visualization, scenario planning, and strategic decision support.",
        "features": [
            ("📊", "Data Stories", "Immersive data presentations"),
            ("🎯", "Scenario Planning", "3D what-if analysis"),
            ("📈", "KPI Dashboard", "Executive metrics at a glance"),
            ("🌍", "Global View", "Worldwide operations visualization"),
            ("👥", "Board Meetings", "Spatial boardroom experience"),
            ("🔐", "Confidential Mode", "Secure briefing environments")
        ],
        "stats": [("C-Suite", "Ready"), ("AI", "Insights"), ("256-bit", "Security"), ("Real-time", "Data")]
    },
    "visionOS_board-meeting-dimension": {
        "name": "Board Meeting Dimension",
        "icon": "BM",
        "category": "Enterprise",
        "accent": "#6366f1",
        "accent_rgb": "99, 102, 241",
        "tagline": "Board Meetings in Spatial Reality",
        "description": "Transform board meetings with spatial computing. Immersive presentations, collaborative decision-making, and secure discussions.",
        "features": [
            ("🏛️", "Virtual Boardroom", "Premium meeting environment"),
            ("📊", "3D Presentations", "Immersive data visualization"),
            ("📝", "Voting System", "Secure digital voting"),
            ("📋", "Minutes Capture", "AI-powered meeting notes"),
            ("🔐", "End-to-End Encryption", "Confidential discussions"),
            ("👥", "Remote Attendance", "Global board participation")
        ],
        "stats": [("Fortune", "500 Ready"), ("E2E", "Encrypted"), ("AI", "Minutes"), ("Global", "Access")]
    },

    # Industrial & Construction (Orange #f97316)
    "visionOS_construction-site-manager": {
        "name": "Construction Site Manager",
        "icon": "CS",
        "category": "Industrial",
        "accent": "#f97316",
        "accent_rgb": "249, 115, 22",
        "tagline": "Manage Construction in Spatial 3D",
        "description": "Oversee construction projects with spatial BIM visualization. Real-time progress tracking, safety monitoring, and team coordination.",
        "features": [
            ("🏗️", "3D BIM Viewer", "Immersive building models"),
            ("📊", "Progress Tracking", "Real-time construction status"),
            ("⚠️", "Safety Monitoring", "Hazard detection and alerts"),
            ("👷", "Workforce Management", "Team coordination tools"),
            ("📅", "Schedule Visualization", "4D construction timeline"),
            ("📸", "Site Documentation", "3D progress photos")
        ],
        "stats": [("BIM", "Ready"), ("Real-time", "Updates"), ("OSHA", "Compliant"), ("Multi-site", "Support")]
    },
    "visionOS_industrial-cad-cam-suite": {
        "name": "Industrial CAD/CAM Suite",
        "icon": "IC",
        "category": "Industrial",
        "accent": "#f97316",
        "accent_rgb": "249, 115, 22",
        "tagline": "Design & Manufacturing in 3D",
        "description": "Professional CAD/CAM tools for spatial computing. Design, simulate, and manufacture in true 3D immersive environment.",
        "features": [
            ("✏️", "3D Design", "Spatial CAD modeling"),
            ("⚙️", "CAM Integration", "Direct manufacturing output"),
            ("🔬", "Simulation", "Physics-based testing"),
            ("📐", "Precision Tools", "Sub-millimeter accuracy"),
            ("📦", "Part Library", "Standard component database"),
            ("👥", "Design Review", "Collaborative sessions")
        ],
        "stats": [("0.001mm", "Precision"), ("STL/STEP", "Export"), ("FEA", "Analysis"), ("Real-time", "Collab")]
    },
    "visionOS_industrial-safety-simulator": {
        "name": "Industrial Safety Simulator",
        "icon": "IS",
        "category": "Industrial",
        "accent": "#f97316",
        "accent_rgb": "249, 115, 22",
        "tagline": "Safety Training in Immersive 3D",
        "description": "Train workers on industrial safety in realistic 3D simulations. Hazard recognition, emergency procedures, and compliance training.",
        "features": [
            ("⚠️", "Hazard Simulation", "Realistic danger scenarios"),
            ("🔥", "Emergency Drills", "Fire and evacuation training"),
            ("🎓", "Certification Tracks", "OSHA-aligned courses"),
            ("📊", "Performance Tracking", "Trainee progress analytics"),
            ("👥", "Team Exercises", "Group safety drills"),
            ("📋", "Compliance Reports", "Audit-ready documentation")
        ],
        "stats": [("OSHA", "Aligned"), ("100+", "Scenarios"), ("Cert", "Tracking"), ("Multi-lang", "Support")]
    },
    "visionOS_supply-chain-control-tower": {
        "name": "Supply Chain Control Tower",
        "icon": "CT",
        "category": "Industrial",
        "accent": "#f97316",
        "accent_rgb": "249, 115, 22",
        "tagline": "Global Supply Chain in 3D",
        "description": "Visualize and manage your entire supply chain in spatial 3D. Real-time tracking, risk monitoring, and optimization.",
        "features": [
            ("🌍", "Global View", "3D map of supply network"),
            ("📦", "Shipment Tracking", "Real-time cargo visibility"),
            ("⚠️", "Risk Monitoring", "Disruption alerts"),
            ("📊", "Demand Forecasting", "AI-powered predictions"),
            ("🏭", "Supplier Management", "Vendor performance tracking"),
            ("🔄", "Optimization", "Route and inventory optimization")
        ],
        "stats": [("Global", "Coverage"), ("Real-time", "Tracking"), ("AI", "Forecasting"), ("ISO", "Certified")]
    },

    # Smart Infrastructure (Emerald #10b981)
    "visionOS_smart-city-command-platform": {
        "name": "Smart City Command Platform",
        "icon": "CC",
        "category": "Smart Infrastructure",
        "accent": "#10b981",
        "accent_rgb": "16, 185, 129",
        "tagline": "City Operations in Spatial 3D",
        "description": "Manage smart city infrastructure in immersive 3D. Traffic, utilities, public safety, and services in one command center.",
        "features": [
            ("🚦", "Traffic Control", "Real-time flow management"),
            ("💡", "Utility Monitoring", "Power, water, gas visualization"),
            ("🚔", "Public Safety", "Emergency response coordination"),
            ("🌳", "Environmental", "Air quality and sensors"),
            ("🚌", "Transit Management", "Public transport optimization"),
            ("📊", "City Analytics", "Urban intelligence dashboard")
        ],
        "stats": [("1M+", "Sensors"), ("Real-time", "Data"), ("AI", "Optimization"), ("24/7", "Operations")]
    },
    "visionOS_smart-agriculture": {
        "name": "Smart Agriculture",
        "icon": "SA",
        "category": "Smart Infrastructure",
        "accent": "#10b981",
        "accent_rgb": "16, 185, 129",
        "tagline": "Precision Farming in Spatial 3D",
        "description": "Transform farming with spatial computing. Crop monitoring, irrigation management, and yield optimization in immersive 3D.",
        "features": [
            ("🌾", "Crop Monitoring", "3D field visualization"),
            ("💧", "Irrigation Control", "Smart water management"),
            ("🛰️", "Satellite Integration", "Aerial imagery analysis"),
            ("🌡️", "Sensor Network", "Soil and weather data"),
            ("🚜", "Equipment Tracking", "Farm machinery management"),
            ("📈", "Yield Prediction", "AI harvest forecasting")
        ],
        "stats": [("10K+", "Acres"), ("Satellite", "Imagery"), ("AI", "Analytics"), ("IoT", "Connected")]
    },
    "visionOS_energy-grid-visualizer": {
        "name": "Energy Grid Visualizer",
        "icon": "EG",
        "category": "Smart Infrastructure",
        "accent": "#10b981",
        "accent_rgb": "16, 185, 129",
        "tagline": "Power Grid Management in 3D",
        "description": "Visualize and manage energy grids in spatial 3D. Real-time monitoring, load balancing, and renewable integration.",
        "features": [
            ("⚡", "Grid Visualization", "3D power network view"),
            ("📊", "Load Monitoring", "Real-time demand tracking"),
            ("🌞", "Renewable Integration", "Solar and wind management"),
            ("⚠️", "Fault Detection", "Automated outage alerts"),
            ("🔋", "Storage Management", "Battery system control"),
            ("📈", "Demand Forecasting", "AI load prediction")
        ],
        "stats": [("GW", "Scale"), ("Real-time", "Monitoring"), ("AI", "Prediction"), ("NERC", "Compliant")]
    },
    "visionOS_sustainability-command": {
        "name": "Sustainability Command",
        "icon": "SU",
        "category": "Smart Infrastructure",
        "accent": "#10b981",
        "accent_rgb": "16, 185, 129",
        "tagline": "ESG Management in Spatial 3D",
        "description": "Track and manage sustainability goals in immersive 3D. Carbon footprint, ESG reporting, and environmental impact visualization.",
        "features": [
            ("🌍", "Carbon Dashboard", "Emissions visualization"),
            ("📊", "ESG Reporting", "Compliance dashboards"),
            ("🌱", "Impact Tracking", "Environmental KPIs"),
            ("🎯", "Goal Management", "Net-zero planning"),
            ("📋", "Audit Ready", "Regulatory reporting"),
            ("🔄", "Supply Chain", "Scope 3 tracking")
        ],
        "stats": [("GRI", "Compliant"), ("TCFD", "Aligned"), ("CDP", "Ready"), ("Real-time", "Tracking")]
    },
    "visionOS_Living-Building-System": {
        "name": "Living Building System",
        "icon": "LB",
        "category": "Smart Infrastructure",
        "accent": "#10b981",
        "accent_rgb": "16, 185, 129",
        "tagline": "Smart Buildings in Spatial 3D",
        "description": "Manage smart buildings with spatial computing. Energy, HVAC, security, and occupancy in one immersive interface.",
        "features": [
            ("🏢", "Building Twin", "3D digital building model"),
            ("🌡️", "HVAC Control", "Climate management"),
            ("💡", "Energy Management", "Usage optimization"),
            ("🔐", "Security Systems", "Access and surveillance"),
            ("👥", "Occupancy Tracking", "Space utilization"),
            ("📊", "Performance Analytics", "Building efficiency KPIs")
        ],
        "stats": [("IoT", "Connected"), ("30%", "Energy Savings"), ("LEED", "Certified"), ("Real-time", "Control")]
    },

    # Creative & Design (Pink #ec4899)
    "visionOS_architectural-visualization-studio": {
        "name": "Architectural Visualization Studio",
        "icon": "AV",
        "category": "Creative",
        "accent": "#ec4899",
        "accent_rgb": "236, 72, 153",
        "tagline": "Architecture in Immersive 3D",
        "description": "Create stunning architectural visualizations in spatial reality. Design, render, and present buildings in true-to-scale 3D.",
        "features": [
            ("🏛️", "3D Modeling", "Spatial architectural design"),
            ("🎨", "Material Library", "Photorealistic textures"),
            ("☀️", "Lighting Simulation", "Natural and artificial light"),
            ("👥", "Client Walkthrough", "Immersive presentations"),
            ("📐", "Scale Accuracy", "True-to-life dimensions"),
            ("🔄", "Design Iteration", "Real-time modifications")
        ],
        "stats": [("4K", "Rendering"), ("1000+", "Materials"), ("Real-time", "Ray Tracing"), ("VR", "Export")]
    },
    "visionOS_Architecture-Time-Machine": {
        "name": "Architecture Time Machine",
        "icon": "AT",
        "category": "Creative",
        "accent": "#ec4899",
        "accent_rgb": "236, 72, 153",
        "tagline": "Historical Architecture in 3D",
        "description": "Experience historical architecture through time in spatial 3D. Explore ancient buildings, reconstruct lost monuments, and travel through architectural history.",
        "features": [
            ("🏛️", "Historical Models", "Accurate period reconstructions"),
            ("⏳", "Time Navigation", "Journey through eras"),
            ("📚", "Educational Content", "Architectural history lessons"),
            ("🔍", "Detail Exploration", "Zoom into intricate details"),
            ("📸", "Virtual Tourism", "Visit world heritage sites"),
            ("👥", "Guided Tours", "Expert-narrated experiences")
        ],
        "stats": [("1000+", "Buildings"), ("5000", "Years"), ("UNESCO", "Sites"), ("8K", "Detail")]
    },
    "visionOS_Spatial-Screenplay-Workshop": {
        "name": "Spatial Screenplay Workshop",
        "icon": "SS",
        "category": "Creative",
        "accent": "#ec4899",
        "accent_rgb": "236, 72, 153",
        "tagline": "Write Scripts in Spatial Reality",
        "description": "Create screenplays in immersive 3D. Visualize scenes, block actors, and storyboard in spatial environments.",
        "features": [
            ("📝", "Spatial Writing", "Immersive script editor"),
            ("🎬", "Scene Visualization", "3D scene blocking"),
            ("👥", "Character Placement", "Actor positioning tools"),
            ("🎥", "Camera Planning", "Shot composition preview"),
            ("📊", "Story Structure", "Visual narrative tools"),
            ("🤝", "Collaboration", "Writers room experience")
        ],
        "stats": [("Pro", "Tools"), ("3D", "Storyboarding"), ("Real-time", "Collab"), ("Export", "Final Draft")]
    },
    "visionOS_Wardrobe-Consultant": {
        "name": "Wardrobe Consultant",
        "icon": "WC",
        "category": "Creative",
        "accent": "#ec4899",
        "accent_rgb": "236, 72, 153",
        "tagline": "Fashion in Spatial 3D",
        "description": "Personal styling and wardrobe management in spatial reality. Virtual try-on, outfit planning, and style recommendations.",
        "features": [
            ("👗", "Virtual Try-On", "See clothes on your avatar"),
            ("👚", "Wardrobe Catalog", "3D closet organization"),
            ("🎨", "Color Matching", "AI style recommendations"),
            ("📅", "Outfit Planning", "Calendar-based styling"),
            ("🛍️", "Shopping Integration", "Try before you buy"),
            ("👥", "Style Sharing", "Get feedback from friends")
        ],
        "stats": [("AI", "Styling"), ("1000+", "Brands"), ("AR", "Try-On"), ("Personal", "Recommendations")]
    },

    # Education & Training (Green #22c55e)
    "visionOS_corporate-university-platform": {
        "name": "Corporate University Platform",
        "icon": "CU",
        "category": "Education",
        "accent": "#22c55e",
        "accent_rgb": "34, 197, 94",
        "tagline": "Enterprise Learning in Spatial 3D",
        "description": "Transform corporate training with spatial computing. Immersive learning experiences, virtual classrooms, and skill development.",
        "features": [
            ("🎓", "Virtual Classrooms", "Immersive training spaces"),
            ("📚", "Course Library", "Spatial learning content"),
            ("🎯", "Skill Tracking", "Competency development"),
            ("👥", "Cohort Learning", "Group training sessions"),
            ("📊", "Analytics", "Learning effectiveness metrics"),
            ("🏆", "Certifications", "Digital credential management")
        ],
        "stats": [("LMS", "Integration"), ("SCORM", "Compliant"), ("Unlimited", "Learners"), ("AI", "Personalization")]
    },
    "visionOS_Language-Immersion-Rooms": {
        "name": "Language Immersion Rooms",
        "icon": "LI",
        "category": "Education",
        "accent": "#22c55e",
        "accent_rgb": "34, 197, 94",
        "tagline": "Learn Languages in Spatial Reality",
        "description": "Master languages through immersive spatial environments. Practice conversations, explore cultures, and learn naturally.",
        "features": [
            ("🌍", "Cultural Immersion", "Visit virtual countries"),
            ("🗣️", "Conversation Practice", "AI-powered dialogues"),
            ("📚", "Lesson Library", "Structured curriculum"),
            ("🎯", "Progress Tracking", "Skill level assessment"),
            ("👥", "Language Partners", "Practice with others"),
            ("🎮", "Gamified Learning", "Engaging challenges")
        ],
        "stats": [("50+", "Languages"), ("AI", "Tutoring"), ("Native", "Audio"), ("Cert", "Prep")]
    },
    "visionOS_military-defense-training": {
        "name": "Military Defense Training",
        "icon": "MD",
        "category": "Education",
        "accent": "#22c55e",
        "accent_rgb": "34, 197, 94",
        "tagline": "Defense Training in Spatial 3D",
        "description": "Advanced military and defense training simulations in spatial reality. Tactical scenarios, equipment training, and team coordination.",
        "features": [
            ("🎯", "Tactical Simulations", "Realistic combat scenarios"),
            ("🔧", "Equipment Training", "Virtual weapons systems"),
            ("👥", "Team Exercises", "Multi-unit coordination"),
            ("📊", "Performance Analytics", "After-action reviews"),
            ("🗺️", "Terrain Modeling", "Custom environment creation"),
            ("🔐", "Classified Mode", "Secure training environments")
        ],
        "stats": [("DoD", "Compliant"), ("Classified", "Capable"), ("Real-time", "Scenarios"), ("Multi-domain", "Training")]
    },

    # Legal & Compliance (Slate #64748b)
    "visionOS_legal-discovery-universe": {
        "name": "Legal Discovery Universe",
        "icon": "LD",
        "category": "Legal",
        "accent": "#64748b",
        "accent_rgb": "100, 116, 139",
        "tagline": "eDiscovery in Spatial 3D",
        "description": "Transform legal discovery with spatial visualization. Document review, case analysis, and evidence mapping in immersive 3D.",
        "features": [
            ("📄", "Document Review", "Spatial document analysis"),
            ("🔍", "Smart Search", "AI-powered discovery"),
            ("🗺️", "Evidence Mapping", "3D case visualization"),
            ("👥", "Team Review", "Collaborative analysis"),
            ("📊", "Case Analytics", "Pattern detection"),
            ("🔐", "Privilege Protection", "Secure handling")
        ],
        "stats": [("AI", "Review"), ("TAR", "2.0"), ("Privilege", "Log"), ("SOC2", "Certified")]
    },
    "visionOS_regulatory-navigation-space": {
        "name": "Regulatory Navigation Space",
        "icon": "RN",
        "category": "Legal",
        "accent": "#64748b",
        "accent_rgb": "100, 116, 139",
        "tagline": "Compliance in Spatial Reality",
        "description": "Navigate complex regulations with spatial visualization. Compliance mapping, regulatory tracking, and audit preparation.",
        "features": [
            ("📋", "Regulation Mapping", "Visual compliance landscape"),
            ("🔍", "Change Tracking", "Regulatory updates"),
            ("✅", "Compliance Checks", "Automated assessment"),
            ("📊", "Risk Dashboard", "Compliance status overview"),
            ("📝", "Audit Preparation", "Evidence collection"),
            ("👥", "Team Workflows", "Compliance assignments")
        ],
        "stats": [("100+", "Regulations"), ("Real-time", "Updates"), ("AI", "Analysis"), ("Audit", "Ready")]
    },
    "visionOS_institutional-memory-vault": {
        "name": "Institutional Memory Vault",
        "icon": "IM",
        "category": "Legal",
        "accent": "#64748b",
        "accent_rgb": "100, 116, 139",
        "tagline": "Knowledge Preservation in 3D",
        "description": "Preserve and access institutional knowledge in spatial 3D. Document archives, knowledge graphs, and organizational memory.",
        "features": [
            ("📚", "Archive Visualization", "3D document collections"),
            ("🔍", "Smart Search", "AI-powered retrieval"),
            ("🗺️", "Knowledge Graph", "Relationship mapping"),
            ("📊", "Usage Analytics", "Access patterns"),
            ("🔐", "Access Control", "Role-based permissions"),
            ("📝", "Annotation System", "Collaborative notes")
        ],
        "stats": [("Unlimited", "Storage"), ("AI", "Indexing"), ("256-bit", "Encryption"), ("Audit", "Trail")]
    },

    # Real Estate & Retail (Amber #f59e0b)
    "visionOS_real-estate-spatial": {
        "name": "Real Estate Spatial",
        "icon": "RE",
        "category": "Real Estate",
        "accent": "#f59e0b",
        "accent_rgb": "245, 158, 11",
        "tagline": "Property in Immersive 3D",
        "description": "Transform real estate with spatial computing. Virtual tours, property comparison, and deal management in 3D.",
        "features": [
            ("🏠", "Virtual Tours", "Immersive property walkthroughs"),
            ("📊", "Market Analytics", "Spatial market data"),
            ("📐", "Space Planning", "Interior layout tools"),
            ("💰", "Deal Management", "Transaction tracking"),
            ("👥", "Client Presentations", "Immersive showings"),
            ("🔍", "Property Search", "3D listing exploration")
        ],
        "stats": [("MLS", "Integration"), ("3D", "Scanning"), ("AI", "Valuation"), ("Virtual", "Staging")]
    },
    "visionOS_retail-space-optimizer": {
        "name": "Retail Space Optimizer",
        "icon": "RS",
        "category": "Real Estate",
        "accent": "#f59e0b",
        "accent_rgb": "245, 158, 11",
        "tagline": "Retail Optimization in 3D",
        "description": "Optimize retail spaces with spatial computing. Store layout, merchandising, and customer flow analysis in 3D.",
        "features": [
            ("🏪", "Store Layout", "3D floor planning"),
            ("📊", "Traffic Analysis", "Customer flow heatmaps"),
            ("📦", "Planogramming", "Shelf optimization"),
            ("💰", "Sales Analytics", "Performance by location"),
            ("👥", "A/B Testing", "Layout experiments"),
            ("🔄", "Seasonal Planning", "Dynamic merchandising")
        ],
        "stats": [("AI", "Optimization"), ("Heat", "Mapping"), ("ROI", "Tracking"), ("Multi-store", "Support")]
    },

    # Collaboration (Cyan #06b6d4)
    "visionOS_spatial-meeting-platform": {
        "name": "Spatial Meeting Platform",
        "icon": "SM",
        "category": "Collaboration",
        "accent": "#06b6d4",
        "accent_rgb": "6, 182, 212",
        "tagline": "Meetings in Spatial Reality",
        "description": "Transform meetings with spatial computing. Immersive meeting rooms, collaborative whiteboards, and presence like never before.",
        "features": [
            ("🏢", "Virtual Rooms", "Premium meeting environments"),
            ("📝", "Spatial Whiteboard", "3D collaborative canvas"),
            ("📊", "Presentation Mode", "Immersive slide viewing"),
            ("👥", "Avatar Presence", "Feel truly present"),
            ("🔗", "Screen Sharing", "Multi-display support"),
            ("📹", "Recording", "Spatial meeting capture")
        ],
        "stats": [("100+", "Participants"), ("4K", "Quality"), ("Spatial", "Audio"), ("E2E", "Encrypted")]
    },
    "visionOS_virtual-collaboration-arena": {
        "name": "Virtual Collaboration Arena",
        "icon": "VA",
        "category": "Collaboration",
        "accent": "#06b6d4",
        "accent_rgb": "6, 182, 212",
        "tagline": "Team Collaboration in 3D",
        "description": "Next-generation team collaboration in spatial 3D. Design sprints, brainstorming, and project work in immersive environments.",
        "features": [
            ("🎯", "Design Sprints", "Structured collaboration sessions"),
            ("💡", "Brainstorming", "3D idea visualization"),
            ("📋", "Project Boards", "Spatial kanban"),
            ("👥", "Team Presence", "Real-time collaboration"),
            ("🔄", "Integrations", "Connect your tools"),
            ("📊", "Session Analytics", "Productivity insights")
        ],
        "stats": [("Unlimited", "Boards"), ("Real-time", "Sync"), ("50+", "Integrations"), ("Async", "Support")]
    },
    "visionOS_research-collaboration-space": {
        "name": "Research Collaboration Space",
        "icon": "RC",
        "category": "Collaboration",
        "accent": "#06b6d4",
        "accent_rgb": "6, 182, 212",
        "tagline": "Research in Spatial Reality",
        "description": "Accelerate research collaboration with spatial computing. Data visualization, paper review, and team research in 3D.",
        "features": [
            ("📊", "Data Visualization", "3D research data"),
            ("📄", "Paper Review", "Collaborative analysis"),
            ("🔬", "Lab Notebooks", "Spatial research notes"),
            ("👥", "Research Teams", "Global collaboration"),
            ("📈", "Citation Tracking", "Impact metrics"),
            ("🔗", "Tool Integration", "Connect research tools")
        ],
        "stats": [("Lab", "Notebooks"), ("Citation", "Tracking"), ("Real-time", "Collab"), ("Secure", "Sharing")]
    },
    "visionOS_innovation-laboratory": {
        "name": "Innovation Laboratory",
        "icon": "IL",
        "category": "Collaboration",
        "accent": "#06b6d4",
        "accent_rgb": "6, 182, 212",
        "tagline": "Innovation in Spatial 3D",
        "description": "Accelerate innovation with spatial computing. Ideation, prototyping, and validation in immersive 3D environments.",
        "features": [
            ("💡", "Ideation Space", "3D brainstorming tools"),
            ("🔧", "Rapid Prototyping", "Spatial design tools"),
            ("📊", "Validation", "Test and measure concepts"),
            ("👥", "Innovation Teams", "Cross-functional collaboration"),
            ("🎯", "Challenge Tracking", "Innovation portfolio"),
            ("📈", "Impact Metrics", "Innovation ROI")
        ],
        "stats": [("Ideation", "Tools"), ("Prototype", "Builder"), ("Team", "Spaces"), ("ROI", "Tracking")]
    },

    # Additional Enterprise Apps
    "visionOS_culture-architecture-system": {
        "name": "Culture Architecture System",
        "icon": "CA",
        "category": "Enterprise",
        "accent": "#6366f1",
        "accent_rgb": "99, 102, 241",
        "tagline": "Build Culture in Spatial 3D",
        "description": "Design and nurture organizational culture with spatial computing. Values visualization, engagement tracking, and culture building.",
        "features": [
            ("🎯", "Values Mapping", "3D culture visualization"),
            ("📊", "Engagement Analytics", "Culture health metrics"),
            ("👥", "Team Rituals", "Shared experiences"),
            ("🏆", "Recognition", "Celebrate achievements"),
            ("📈", "Culture Tracking", "Measure improvement"),
            ("🔄", "Change Management", "Culture transformation")
        ],
        "stats": [("Culture", "Analytics"), ("Engagement", "Scores"), ("Recognition", "System"), ("Real-time", "Feedback")]
    },
    "visionOS_Home-Maintenance-Oracle": {
        "name": "Home Maintenance Oracle",
        "icon": "HM",
        "category": "Smart Infrastructure",
        "accent": "#10b981",
        "accent_rgb": "16, 185, 129",
        "tagline": "Home Care in Spatial 3D",
        "description": "Manage home maintenance with spatial computing. 3D home model, maintenance scheduling, and DIY guides.",
        "features": [
            ("🏠", "Home Twin", "3D model of your home"),
            ("🔧", "Maintenance Tracker", "Scheduled upkeep"),
            ("📚", "DIY Guides", "Step-by-step tutorials"),
            ("👷", "Pro Connect", "Find local contractors"),
            ("📊", "Cost Tracking", "Maintenance spending"),
            ("⚠️", "Alerts", "Proactive reminders")
        ],
        "stats": [("AI", "Recommendations"), ("1000+", "Guides"), ("Pro", "Network"), ("Cost", "Tracking")]
    },
    "visionOS_Physical-Digital-Twins": {
        "name": "Physical Digital Twins",
        "icon": "PD",
        "category": "AI & Technology",
        "accent": "#a855f7",
        "accent_rgb": "168, 85, 247",
        "tagline": "Digital Twins in Spatial Reality",
        "description": "Create and manage digital twins of physical assets in immersive 3D. Real-time synchronization and predictive analytics.",
        "features": [
            ("🏭", "Asset Modeling", "3D digital twin creation"),
            ("📡", "Sensor Integration", "Real-time IoT data"),
            ("🔮", "Predictive Analytics", "AI-powered insights"),
            ("🔄", "Sync Engine", "Live synchronization"),
            ("📊", "Performance Dashboard", "Asset health metrics"),
            ("🔧", "Maintenance Planning", "Predictive scheduling")
        ],
        "stats": [("IoT", "Connected"), ("AI", "Analytics"), ("Real-time", "Sync"), ("Predictive", "Maintenance")]
    },
    "visionOS_Reality-Annotation-Platform": {
        "name": "Reality Annotation Platform",
        "icon": "RA",
        "category": "AI & Technology",
        "accent": "#a855f7",
        "accent_rgb": "168, 85, 247",
        "tagline": "Annotate Reality in 3D",
        "description": "Add persistent annotations to physical spaces in spatial 3D. Mark up reality for training, documentation, and collaboration.",
        "features": [
            ("✏️", "Spatial Annotations", "Mark up 3D space"),
            ("📸", "Scene Capture", "Record environments"),
            ("👥", "Shared Notes", "Team collaboration"),
            ("🔗", "Object Linking", "Connect to data"),
            ("📊", "Analytics", "Usage tracking"),
            ("🔐", "Access Control", "Permission management")
        ],
        "stats": [("Persistent", "Annotations"), ("3D", "Scanning"), ("Team", "Sharing"), ("API", "Access")]
    },
    "visionOS_global-war-room": {
        "name": "Global War Room",
        "icon": "GW",
        "category": "Enterprise",
        "accent": "#6366f1",
        "accent_rgb": "99, 102, 241",
        "tagline": "Command Center in Spatial 3D",
        "description": "Enterprise command and control in immersive 3D. Crisis management, global operations, and strategic decision-making.",
        "features": [
            ("🌍", "Global View", "Worldwide operations map"),
            ("⚠️", "Crisis Management", "Emergency response"),
            ("📊", "Real-Time Data", "Live operational feeds"),
            ("👥", "Command Team", "Collaborative decision-making"),
            ("🔐", "Secure Comms", "Encrypted communications"),
            ("📋", "Action Tracking", "Task management")
        ],
        "stats": [("Global", "Coverage"), ("Real-time", "Data"), ("E2E", "Encrypted"), ("24/7", "Operations")]
    },
    "visionOS_cybersecurity-command-center": {
        "name": "Cybersecurity Command Center",
        "icon": "CC",
        "category": "Enterprise",
        "accent": "#6366f1",
        "accent_rgb": "99, 102, 241",
        "tagline": "Security Operations in 3D",
        "description": "Visualize and manage cybersecurity in spatial 3D. Threat detection, incident response, and security posture in one view.",
        "features": [
            ("🛡️", "Threat Visualization", "3D attack surface"),
            ("⚠️", "Alert Dashboard", "Real-time threat detection"),
            ("🔍", "Investigation Tools", "Forensic analysis"),
            ("📊", "Security Metrics", "Posture scoring"),
            ("👥", "SOC Collaboration", "Team response"),
            ("🔗", "Tool Integration", "Connect security stack")
        ],
        "stats": [("SIEM", "Integration"), ("Real-time", "Detection"), ("AI", "Analysis"), ("SOC2", "Compliant")]
    },
    "visionOS_molecular-design-platform": {
        "name": "Molecular Design Platform",
        "icon": "MP",
        "category": "Healthcare",
        "accent": "#14b8a6",
        "accent_rgb": "20, 184, 166",
        "tagline": "Molecular Science in 3D",
        "description": "Design and visualize molecules in spatial 3D. Drug discovery, protein folding, and molecular simulations.",
        "features": [
            ("🧬", "Molecular Modeling", "3D structure visualization"),
            ("💊", "Drug Design", "Compound optimization"),
            ("🔬", "Simulation", "Physics-based modeling"),
            ("📊", "Property Prediction", "AI-powered analysis"),
            ("👥", "Collaboration", "Team research"),
            ("📚", "Compound Library", "Chemical database")
        ],
        "stats": [("AI", "Prediction"), ("Quantum", "Ready"), ("1M+", "Compounds"), ("Real-time", "Simulation")]
    },
    "visionOS_business-intelligence-suite": {
        "name": "Business Intelligence Suite",
        "icon": "BI",
        "category": "Enterprise",
        "accent": "#6366f1",
        "accent_rgb": "99, 102, 241",
        "tagline": "BI in Spatial Reality",
        "description": "Transform business intelligence with spatial computing. Immersive dashboards, data exploration, and insights in 3D.",
        "features": [
            ("📊", "3D Dashboards", "Immersive data visualization"),
            ("🔍", "Data Exploration", "Spatial data discovery"),
            ("🤖", "AI Insights", "Automated analysis"),
            ("📈", "Trend Detection", "Pattern recognition"),
            ("👥", "Shared Views", "Collaborative analytics"),
            ("🔗", "Data Connectors", "Connect any source")
        ],
        "stats": [("100+", "Connectors"), ("AI", "Insights"), ("Real-time", "Data"), ("Unlimited", "Dashboards")]
    },
}

TEMPLATE = '''<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>{name} - {tagline} | Apple Vision Pro</title>
    <meta name="description" content="{description}">
    <meta property="og:type" content="website">
    <meta property="og:title" content="{name} - {tagline}">
    <meta property="og:description" content="{description}">
    <meta property="og:image" content="hero-spatial.png">
    <meta name="twitter:card" content="summary_large_image">
    <style>
        * {{ margin: 0; padding: 0; box-sizing: border-box; }}
        :root {{
            --accent: {accent};
            --accent-rgb: {accent_rgb};
            --accent-glow: rgba({accent_rgb}, 0.3);
            --accent-border: rgba({accent_rgb}, 0.2);
            --accent-hover: rgba({accent_rgb}, 0.5);
            --bg-dark: #0a0a0f;
            --bg-card: rgba(30, 27, 75, 0.4);
            --text-primary: rgba(255, 255, 255, 0.95);
            --text-secondary: rgba(255, 255, 255, 0.7);
            --text-muted: rgba(255, 255, 255, 0.5);
        }}
        body {{ font-family: -apple-system, BlinkMacSystemFont, 'SF Pro Display', sans-serif; background: var(--bg-dark); color: var(--text-primary); overflow-x: hidden; line-height: 1.6; }}
        .depth-layer {{ position: fixed; width: 200%; height: 200%; top: -50%; left: -50%; pointer-events: none; z-index: 0; }}
        .depth-layer-1 {{ background: radial-gradient(circle at 20% 30%, rgba({accent_rgb}, 0.15) 0%, transparent 50%); animation: float 20s ease-in-out infinite; }}
        .depth-layer-2 {{ background: radial-gradient(circle at 80% 70%, rgba({accent_rgb}, 0.12) 0%, transparent 50%); animation: float 25s ease-in-out infinite reverse; }}
        .depth-layer-3 {{ background: radial-gradient(circle at 50% 50%, rgba({accent_rgb}, 0.08) 0%, transparent 60%); animation: float 30s ease-in-out infinite; }}
        @keyframes float {{ 0%, 100% {{ transform: translate(0, 0) rotate(0deg); }} 33% {{ transform: translate(30px, -30px) rotate(3deg); }} 66% {{ transform: translate(-20px, 20px) rotate(-3deg); }} }}
        .vision-strip {{ position: fixed; top: 0; left: 0; right: 0; z-index: 1000; background: rgba(10, 10, 15, 0.85); backdrop-filter: blur(20px); -webkit-backdrop-filter: blur(20px); border-bottom: 1px solid rgba(255, 255, 255, 0.1); padding: 10px 20px; display: flex; justify-content: center; align-items: center; gap: 20px; flex-wrap: wrap; }}
        .vision-strip .badge {{ display: flex; align-items: center; gap: 6px; font-size: 12px; font-weight: 600; color: var(--text-secondary); text-transform: uppercase; letter-spacing: 0.5px; }}
        .vision-strip .badge.highlight {{ background: var(--accent-glow); padding: 4px 12px; border-radius: 12px; color: white; border: 1px solid var(--accent-border); }}
        .container {{ max-width: 1400px; margin: 0 auto; padding: 0 20px; position: relative; z-index: 1; }}
        nav {{ position: fixed; top: 44px; left: 0; right: 0; z-index: 999; background: rgba(10, 10, 15, 0.7); backdrop-filter: blur(20px); -webkit-backdrop-filter: blur(20px); border-bottom: 1px solid rgba(255, 255, 255, 0.05); padding: 15px 20px; }}
        nav .nav-content {{ max-width: 1400px; margin: 0 auto; display: flex; justify-content: space-between; align-items: center; }}
        .logo {{ font-size: 1.3rem; font-weight: 700; color: white; display: flex; align-items: center; gap: 10px; }}
        .logo-icon {{ width: 36px; height: 36px; background: var(--accent-glow); border: 1px solid var(--accent-border); border-radius: 10px; display: flex; align-items: center; justify-content: center; font-size: 14px; }}
        nav ul {{ display: flex; list-style: none; gap: 30px; }}
        nav a {{ color: var(--text-secondary); text-decoration: none; font-size: 14px; font-weight: 500; transition: color 0.3s; }}
        nav a:hover {{ color: white; }}
        .hero {{ padding: 180px 20px 100px; }}
        .hero-grid {{ display: grid; grid-template-columns: 1fr 1.2fr; gap: 60px; align-items: center; max-width: 1400px; margin: 0 auto; }}
        .hero-content {{ text-align: left; }}
        .hero-badge {{ display: inline-block; background: var(--accent-glow); backdrop-filter: blur(20px); border: 1px solid var(--accent-hover); padding: 8px 20px; border-radius: 20px; font-size: 13px; font-weight: 600; margin-bottom: 24px; color: white; }}
        h1 {{ font-size: 52px; font-weight: 700; margin-bottom: 20px; background: linear-gradient(135deg, #ffffff 0%, var(--accent) 100%); -webkit-background-clip: text; -webkit-text-fill-color: transparent; background-clip: text; line-height: 1.1; }}
        .tagline {{ font-size: 24px; color: var(--text-primary); margin-bottom: 20px; font-weight: 500; }}
        .description {{ font-size: 17px; color: var(--text-secondary); margin-bottom: 32px; line-height: 1.7; }}
        .cta-group {{ display: flex; gap: 16px; flex-wrap: wrap; }}
        .cta-button {{ display: inline-flex; align-items: center; gap: 8px; background: var(--accent); color: white; padding: 16px 32px; border-radius: 12px; text-decoration: none; font-size: 16px; font-weight: 600; transition: all 0.3s; box-shadow: 0 10px 40px var(--accent-glow); border: 1px solid rgba(255, 255, 255, 0.1); }}
        .cta-button:hover {{ transform: translateY(-2px); box-shadow: 0 15px 50px var(--accent-hover); }}
        .cta-secondary {{ background: transparent; border: 1px solid var(--accent-border); box-shadow: none; }}
        .cta-secondary:hover {{ background: var(--accent-glow); box-shadow: none; }}
        .hero-image {{ position: relative; }}
        .hero-image img {{ width: 100%; border-radius: 20px; box-shadow: 0 30px 80px rgba(0, 0, 0, 0.5), 0 0 0 1px var(--accent-border); }}
        .hero-image::before {{ content: ''; position: absolute; inset: -2px; background: linear-gradient(135deg, var(--accent-hover), transparent 50%); border-radius: 22px; z-index: -1; }}
        .hero-placeholder {{ width: 100%; aspect-ratio: 16/10; background: linear-gradient(135deg, rgba({accent_rgb}, 0.2) 0%, rgba(30, 27, 75, 0.6) 100%); border-radius: 20px; display: flex; align-items: center; justify-content: center; color: var(--text-muted); font-size: 18px; border: 1px dashed var(--accent-border); }}
        .section {{ padding: 100px 20px; }}
        .section-header {{ text-align: center; margin-bottom: 60px; }}
        .section-title {{ font-size: 42px; font-weight: 700; margin-bottom: 16px; }}
        .section-subtitle {{ font-size: 18px; color: var(--text-secondary); max-width: 600px; margin: 0 auto; }}
        .pillars-grid {{ display: grid; grid-template-columns: repeat(auto-fit, minmax(280px, 1fr)); gap: 24px; }}
        .pillar-card {{ background: var(--bg-card); backdrop-filter: blur(20px); -webkit-backdrop-filter: blur(20px); border: 1px solid var(--accent-border); border-radius: 20px; padding: 32px; transition: all 0.3s ease; box-shadow: 0 8px 32px rgba(0, 0, 0, 0.3), inset 0 1px 0 rgba(255, 255, 255, 0.05); }}
        .pillar-card:hover {{ transform: translateY(-5px); border-color: var(--accent-hover); box-shadow: 0 12px 48px rgba(0, 0, 0, 0.4), 0 0 0 1px var(--accent-border); }}
        .pillar-icon {{ font-size: 40px; margin-bottom: 16px; }}
        .pillar-card h3 {{ font-size: 20px; margin-bottom: 12px; color: var(--accent); }}
        .pillar-card p {{ font-size: 15px; color: var(--text-secondary); line-height: 1.6; }}
        .benefits-grid {{ display: grid; grid-template-columns: repeat(4, 1fr); gap: 24px; }}
        .benefit-card {{ text-align: center; padding: 32px 20px; background: var(--bg-card); border: 1px solid var(--accent-border); border-radius: 16px; }}
        .benefit-stat {{ font-size: 48px; font-weight: 700; color: var(--accent); margin-bottom: 8px; }}
        .benefit-label {{ font-size: 14px; color: var(--text-secondary); }}
        .testimonials-grid {{ display: grid; grid-template-columns: repeat(3, 1fr); gap: 24px; }}
        .testimonial-card {{ background: var(--bg-card); border: 1px solid var(--accent-border); border-radius: 16px; padding: 32px; }}
        .testimonial-quote {{ font-size: 16px; font-style: italic; color: var(--text-secondary); margin-bottom: 20px; line-height: 1.7; }}
        .testimonial-author {{ display: flex; align-items: center; gap: 12px; }}
        .author-avatar {{ width: 48px; height: 48px; background: var(--accent-glow); border-radius: 50%; display: flex; align-items: center; justify-content: center; font-weight: 600; color: var(--accent); }}
        .author-info h4 {{ font-size: 15px; margin-bottom: 2px; }}
        .author-info span {{ font-size: 13px; color: var(--text-muted); }}
        .cta-section {{ text-align: center; padding: 120px 20px; background: linear-gradient(180deg, transparent 0%, rgba({accent_rgb}, 0.1) 100%); border-top: 1px solid var(--accent-border); }}
        .cta-section h2 {{ font-size: 48px; margin-bottom: 16px; }}
        .cta-section p {{ font-size: 18px; color: var(--text-secondary); margin-bottom: 32px; }}
        .store-badges {{ display: flex; justify-content: center; gap: 16px; margin-top: 24px; }}
        .store-badges img {{ height: 50px; }}
        footer {{ border-top: 1px solid rgba(255, 255, 255, 0.1); padding: 60px 20px; text-align: center; }}
        footer p {{ color: var(--text-muted); font-size: 14px; }}
        footer a {{ color: var(--accent); text-decoration: none; margin: 0 15px; }}
        footer a:hover {{ color: white; }}
        @media (max-width: 1024px) {{ .hero-grid {{ grid-template-columns: 1fr; text-align: center; }} .hero-content {{ text-align: center; }} .cta-group {{ justify-content: center; }} .benefits-grid {{ grid-template-columns: repeat(2, 1fr); }} .testimonials-grid {{ grid-template-columns: 1fr; }} }}
        @media (max-width: 768px) {{ h1 {{ font-size: 36px; }} .section-title {{ font-size: 32px; }} .benefits-grid {{ grid-template-columns: 1fr; }} .vision-strip {{ padding: 8px 10px; gap: 10px; }} .vision-strip .badge {{ font-size: 10px; }} nav ul {{ gap: 15px; }} }}
    </style>
</head>
<body>
    <div class="depth-layer depth-layer-1"></div>
    <div class="depth-layer depth-layer-2"></div>
    <div class="depth-layer depth-layer-3"></div>
    <div class="vision-strip">
        <span class="badge highlight">Apple Vision Pro</span>
        <span class="badge">Spatial Computing</span>
        <span class="badge">visionOS 2.0+</span>
        <span class="badge">Enterprise Ready</span>
        <span class="badge">{category}</span>
    </div>
    <nav>
        <div class="nav-content">
            <div class="logo">
                <div class="logo-icon">{icon}</div>
                {name}
            </div>
            <ul>
                <li><a href="#features">Features</a></li>
                <li><a href="#benefits">Benefits</a></li>
                <li><a href="support.html">Support</a></li>
            </ul>
        </div>
    </nav>
    <section class="hero">
        <div class="hero-grid">
            <div class="hero-content">
                <div class="hero-badge">{category}</div>
                <h1>{name}</h1>
                <p class="tagline">{tagline}</p>
                <p class="description">{description}</p>
                <div class="cta-group">
                    <a href="#download" class="cta-button">
                        <svg width="20" height="20" viewBox="0 0 24 24" fill="currentColor"><path d="M17.05 20.28c-.98.95-2.05.8-3.08.35-1.09-.46-2.09-.48-3.24 0-1.44.62-2.2.44-3.06-.35C2.79 15.25 3.51 7.59 9.05 7.31c1.35.07 2.29.74 3.08.8 1.18-.24 2.31-.93 3.57-.84 1.51.12 2.65.72 3.4 1.8-3.12 1.87-2.38 5.98.48 7.13-.57 1.5-1.31 2.99-2.54 4.09l.01-.01zM12.03 7.25c-.15-2.23 1.66-4.07 3.74-4.25.29 2.58-2.34 4.5-3.74 4.25z"/></svg>
                        Experience in Vision Pro
                    </a>
                    <a href="#demo" class="cta-button cta-secondary">Request Demo</a>
                </div>
            </div>
            <div class="hero-image">
                {hero_image}
            </div>
        </div>
    </section>
    <section class="section" id="features">
        <div class="container">
            <div class="section-header">
                <h2 class="section-title">Spatial Capabilities</h2>
                <p class="section-subtitle">Enterprise {category_lower} reimagined for immersive spatial computing</p>
            </div>
            <div class="pillars-grid">
                {features_html}
            </div>
        </div>
    </section>
    <section class="section" id="benefits" style="background: rgba({accent_rgb}, 0.03);">
        <div class="container">
            <div class="section-header">
                <h2 class="section-title">Enterprise Impact</h2>
                <p class="section-subtitle">Measurable results for forward-thinking organizations</p>
            </div>
            <div class="benefits-grid">
                {stats_html}
            </div>
        </div>
    </section>
    <section class="section">
        <div class="container">
            <div class="section-header">
                <h2 class="section-title">Trusted by Leaders</h2>
                <p class="section-subtitle">See why enterprises choose {name} for spatial computing</p>
            </div>
            <div class="testimonials-grid">
                {testimonials_html}
            </div>
        </div>
    </section>
    <section class="cta-section" id="download">
        <div class="container">
            <h2>Ready to Transform Your Workflow?</h2>
            <p>Experience the future of {category_lower} with Apple Vision Pro</p>
            <a href="#" class="cta-button">Get Started Today</a>
            <div class="store-badges">
                <img src="https://developer.apple.com/assets/elements/badges/download-on-the-app-store.svg" alt="Download on App Store">
            </div>
        </div>
    </section>
    <footer>
        <div class="container">
            <p>&copy; 2025 {name}. Designed for Apple Vision Pro spatial computing.</p>
            <div style="margin-top: 16px;">
                <a href="privacy.html">Privacy Policy</a>
                <a href="terms.html">Terms of Service</a>
                <a href="support.html">Support</a>
            </div>
        </div>
    </footer>
</body>
</html>'''

def generate_features_html(features):
    html = ""
    for icon, title, desc in features:
        html += f'''<div class="pillar-card">
                    <div class="pillar-icon">{icon}</div>
                    <h3>{title}</h3>
                    <p>{desc}</p>
                </div>\n'''
    return html

def generate_stats_html(stats):
    html = ""
    for stat, label in stats:
        html += f'''<div class="benefit-card">
                    <div class="benefit-stat">{stat}</div>
                    <div class="benefit-label">{label}</div>
                </div>\n'''
    return html

def generate_testimonials_html(category):
    testimonials = {
        "AI & Technology": [
            ("The spatial visualization completely changed how we manage our AI operations. Patterns we never noticed are now obvious.", "David M.", "CTO, Tech Enterprise"),
            ("Gesture controls make complex workflows intuitive. Our team adapted in hours, not weeks.", "Sarah K.", "VP Engineering"),
            ("SharePlay collaboration is a game-changer for distributed teams. We feel like we're in the same room.", "Michael R.", "AI Director")
        ],
        "Healthcare": [
            ("Spatial medical imaging transformed our diagnostic process. We catch things we used to miss.", "Dr. Emily C.", "Chief Radiologist"),
            ("Training residents in VR has accelerated their learning curve significantly.", "Dr. James W.", "Surgical Director"),
            ("Coordinating care across our hospital network is finally intuitive.", "Maria S.", "Healthcare Administrator")
        ],
        "Finance": [
            ("Seeing market data in 3D reveals patterns invisible in flat charts. Our returns improved immediately.", "Robert K.", "Portfolio Manager"),
            ("The trading cockpit gives me an edge I never had before. Information density is incredible.", "Jennifer L.", "Quantitative Trader"),
            ("Financial reporting in spatial reality makes board presentations actually engaging.", "Thomas H.", "CFO")
        ],
        "Enterprise": [
            ("Our enterprise operations are finally visible in one unified view. Decision-making is faster.", "Amanda B.", "COO"),
            ("The spatial ERP interface reduced training time by 60%. Users love it.", "Kevin T.", "IT Director"),
            ("Board meetings in Vision Pro have transformed stakeholder engagement.", "Patricia M.", "CEO")
        ],
        "Industrial": [
            ("BIM visualization on Vision Pro caught design conflicts we would have found during construction.", "Carlos R.", "Construction Manager"),
            ("Safety training in VR has reduced workplace incidents by 40%.", "Diana F.", "Safety Director"),
            ("Seeing the entire supply chain in 3D helped us optimize routes we thought were already efficient.", "Mark W.", "Supply Chain VP")
        ],
        "Smart Infrastructure": [
            ("Managing city infrastructure spatially gives us situational awareness we never had.", "James N.", "City Operations Director"),
            ("The energy grid visualization helped us prevent three potential outages last month.", "Susan M.", "Grid Operations"),
            ("Smart building management in 3D reduced our energy costs by 30%.", "Richard P.", "Facilities Manager")
        ],
        "Creative": [
            ("Client walkthroughs in VR close deals faster. They can actually feel the space.", "Lisa A.", "Principal Architect"),
            ("Screenplay visualization transformed how I block scenes. My writing improved.", "Chris D.", "Screenwriter"),
            ("Historical architecture in 3D made my research come alive.", "Prof. Anna L.", "Architecture Historian")
        ],
        "Education": [
            ("Language immersion in VR accelerated fluency timelines by months.", "Dr. Maria G.", "Language Program Director"),
            ("Corporate training engagement increased 300% with spatial learning.", "John B.", "L&D Director"),
            ("Military simulations in Vision Pro provide unprecedented realism.", "Col. William S.", "Training Command")
        ],
        "Legal": [
            ("Document review in 3D helped us find the key evidence in half the time.", "Rachel S.", "Litigation Partner"),
            ("Regulatory compliance visualization made audits almost enjoyable.", "Steven C.", "Compliance Director"),
            ("Our institutional knowledge is finally accessible and visual.", "Nancy W.", "Knowledge Manager")
        ],
        "Real Estate": [
            ("Virtual tours sell properties to international buyers who can't visit.", "Michael T.", "Real Estate Broker"),
            ("Retail space optimization in 3D increased our client's sales by 25%.", "Jessica H.", "Retail Consultant"),
            ("Property comparison in spatial reality helps clients decide faster.", "Brian K.", "Real Estate Developer")
        ],
        "Collaboration": [
            ("Spatial meetings feel like everyone's in the same room. Remote work finally works.", "Angela R.", "Remote Team Lead"),
            ("Innovation sessions in VR generate more ideas in less time.", "Daniel P.", "Innovation Director"),
            ("Research collaboration across continents feels natural now.", "Prof. Kim L.", "Research Director")
        ]
    }

    category_testimonials = testimonials.get(category, testimonials["Enterprise"])
    html = ""
    for quote, name, title in category_testimonials:
        initials = "".join([n[0] for n in name.split()])
        html += f'''<div class="testimonial-card">
                    <p class="testimonial-quote">"{quote}"</p>
                    <div class="testimonial-author">
                        <div class="author-avatar">{initials}</div>
                        <div class="author-info">
                            <h4>{name}</h4>
                            <span>{title}</span>
                        </div>
                    </div>
                </div>\n'''
    return html

def main():
    base_path = "/Users/aakashnigam/Axion/AxionApps/visionOS"
    generated = 0

    for app_dir, app_data in APPS_DATA.items():
        docs_path = os.path.join(base_path, app_dir, "docs")

        # Create docs directory if it doesn't exist
        os.makedirs(docs_path, exist_ok=True)

        # Check if hero image exists
        hero_image_path = os.path.join(docs_path, "hero-spatial.png")
        if os.path.exists(hero_image_path):
            hero_image = '<img src="hero-spatial.png" alt="{} spatial interface">'.format(app_data["name"])
        else:
            hero_image = '<div class="hero-placeholder">Spatial Experience Preview</div>'

        # Generate HTML
        features_html = generate_features_html(app_data["features"])
        stats_html = generate_stats_html(app_data["stats"])
        testimonials_html = generate_testimonials_html(app_data["category"])

        html = TEMPLATE.format(
            name=app_data["name"],
            icon=app_data["icon"],
            category=app_data["category"],
            category_lower=app_data["category"].lower(),
            accent=app_data["accent"],
            accent_rgb=app_data["accent_rgb"],
            tagline=app_data["tagline"],
            description=app_data["description"],
            features_html=features_html,
            stats_html=stats_html,
            testimonials_html=testimonials_html,
            hero_image=hero_image
        )

        # Write file
        output_path = os.path.join(docs_path, "index.html")
        with open(output_path, "w") as f:
            f.write(html)

        generated += 1
        print(f"Generated: {app_dir}")

    print(f"\n✅ Generated {generated} landing pages")

if __name__ == "__main__":
    main()
