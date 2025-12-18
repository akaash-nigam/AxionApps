#!/usr/bin/env python3
"""
Generate landing pages for 34 remaining non-gaming visionOS apps with spatial computing design
Enterprise, Business, Research, Healthcare, Industrial, Consumer, and Productivity apps
"""

import os
from pathlib import Path

def hex_to_rgba(hex_color, alpha):
    """Convert hex color to rgba tuple string"""
    hex_color = hex_color.lstrip('#')
    r = int(hex_color[0:2], 16)
    g = int(hex_color[2:4], 16)
    b = int(hex_color[4:6], 16)
    return f"({r}, {g}, {b}, {alpha})"

APPS = [
    {
        "dir": "visionOS_business-operating-system",
        "title": "Business Operating System",
        "logo": "BO",
        "color_primary": "#1e3a8a",  # Navy
        "tagline": "Run Your Entire Business in Spatial 3D",
        "spatial_message": "Transform how you run your business with a comprehensive spatial operating system. Manage all departments, workflows, and operations in an immersive 3D environment designed for Apple Vision Pro.",
        "pillars": [
            ("🏢", "Unified Dashboard", "Monitor all business functions from finance to operations in a single spatial command center"),
            ("📊", "Real-Time Analytics", "Visualize KPIs, metrics, and business intelligence across immersive 3D dashboards"),
            ("🔄", "Workflow Automation", "Design and orchestrate business processes with spatial drag-and-drop workflow builder"),
            ("👥", "Team Coordination", "Connect departments and teams in shared spatial workspaces for seamless collaboration"),
            ("🎯", "Strategic Planning", "Plan business strategy with spatial mind maps, roadmaps, and scenario modeling tools")
        ]
    },
    {
        "dir": "visionOS_corporate-university-platform",
        "title": "Corporate University Platform",
        "logo": "CU",
        "color_primary": "#7c3aed",  # Purple
        "tagline": "Train Teams in Immersive Learning Spaces",
        "spatial_message": "Build your corporate learning ecosystem in spatial reality. Deliver training, onboarding, and professional development through immersive 3D courses designed for Apple Vision Pro.",
        "pillars": [
            ("🎓", "Spatial Classrooms", "Host live training sessions in immersive 3D environments with virtual whiteboards and interactive content"),
            ("📚", "Course Library", "Access comprehensive training materials organized in spatial libraries with 3D navigation"),
            ("🎮", "Interactive Simulations", "Practice real-world scenarios in risk-free spatial simulations with instant feedback"),
            ("📈", "Progress Tracking", "Monitor employee learning paths and skill development with visual spatial analytics"),
            ("🏆", "Certification Programs", "Award credentials and track competencies through gamified spatial learning journeys")
        ]
    },
    {
        "dir": "visionOS_enterprise-apps",
        "title": "Enterprise App Suite",
        "logo": "EA",
        "color_primary": "#2563eb",  # Blue
        "tagline": "Unified Workspace in Spatial Reality",
        "spatial_message": "Access all your enterprise applications in a unified spatial workspace. Email, calendar, documents, communication, and productivity tools seamlessly integrated in Vision Pro's immersive environment.",
        "pillars": [
            ("📧", "Spatial Email", "Manage email with 3D organization, priority visualization, and gesture-based quick actions"),
            ("📅", "Calendar Command", "View schedules across teams spatially with timeline visualization and meeting coordination"),
            ("📄", "Document Universe", "Browse and edit documents in immersive 3D space with collaborative real-time editing"),
            ("💬", "Team Communication", "Chat, video calls, and collaboration tools integrated in spatial interface"),
            ("🔐", "Enterprise Security", "Bank-grade security with biometric authentication and encrypted spatial workspaces")
        ]
    },
    {
        "dir": "visionOS_executive-briefing",
        "title": "Executive Briefing Room",
        "logo": "EB",
        "color_primary": "#4f46e5",  # Indigo
        "tagline": "Strategic Decisions in Immersive 3D",
        "spatial_message": "Make critical business decisions in a dedicated spatial briefing environment. Present data, analyze scenarios, and collaborate with leadership in an immersive 3D boardroom powered by Vision Pro.",
        "pillars": [
            ("📊", "Executive Dashboard", "Monitor company performance with spatial KPI visualization and real-time business intelligence"),
            ("🎯", "Strategic Analysis", "Evaluate business scenarios with 3D data models and interactive what-if simulations"),
            ("👔", "Board Presentations", "Deliver impactful presentations with spatial charts, 3D models, and immersive storytelling"),
            ("🌍", "Market Intelligence", "Track competitive landscape and market trends in spatial geographic and network views"),
            ("⚡", "Decision Theater", "Collaborate with leadership team in shared spatial environment for critical strategic choices")
        ]
    },
    {
        "dir": "visionOS_financial-operations-platform",
        "title": "Financial Operations Platform",
        "logo": "FO",
        "color_primary": "#059669",  # Green
        "tagline": "Manage Finance in Spatial Command Center",
        "spatial_message": "Transform financial operations with spatial computing. Monitor cash flow, analyze budgets, track expenses, and manage financial planning in an immersive 3D environment built for Vision Pro.",
        "pillars": [
            ("💰", "Cash Flow Visualization", "See money flowing through your business in real-time spatial diagrams with trend analysis"),
            ("📊", "Budget Management", "Allocate and track departmental budgets with interactive 3D breakdown and variance analysis"),
            ("🧾", "Expense Tracking", "Monitor spending patterns across categories with spatial heat maps and anomaly detection"),
            ("📈", "Financial Forecasting", "Model future scenarios with AI-powered predictions in immersive data visualizations"),
            ("🔍", "Audit & Compliance", "Ensure regulatory compliance with spatial document tracking and automated audit trails")
        ]
    },
    {
        "dir": "visionOS_global-war-room",
        "title": "Global War Room",
        "logo": "GW",
        "color_primary": "#dc2626",  # Red
        "tagline": "Crisis Management in Spatial Reality",
        "spatial_message": "Manage global operations and crisis response in an immersive command center. Coordinate teams, monitor situations, and make critical decisions in real-time spatial environment powered by Vision Pro.",
        "pillars": [
            ("🌍", "Global Situation Map", "Monitor worldwide operations on an interactive 3D globe with real-time incident tracking"),
            ("⚠️", "Alert Management", "Receive and respond to critical alerts with spatial prioritization and automated escalation"),
            ("👥", "Team Coordination", "Connect distributed teams across time zones in shared spatial crisis response environment"),
            ("📹", "Live Intelligence", "Integrate video feeds, sensor data, and communications in unified spatial dashboard"),
            ("📋", "Action Planning", "Develop and execute response plans with spatial task assignment and progress tracking")
        ]
    },
    {
        "dir": "visionOS_innovation-laboratory",
        "title": "Innovation Laboratory",
        "logo": "IL",
        "color_primary": "#06b6d4",  # Cyan
        "tagline": "Ideate and Prototype in 3D Space",
        "spatial_message": "Accelerate innovation with a spatial laboratory for ideation and prototyping. Brainstorm, design, and test new concepts in an immersive 3D workspace designed for Apple Vision Pro.",
        "pillars": [
            ("💡", "Spatial Brainstorming", "Generate ideas collaboratively with 3D mind maps, sticky notes, and infinite canvas"),
            ("🎨", "Rapid Prototyping", "Build and iterate on product concepts with spatial design tools and 3D modeling"),
            ("🔬", "Experimentation Hub", "Test hypotheses with virtual simulations and A/B testing in spatial environments"),
            ("📊", "Innovation Metrics", "Track idea pipeline from concept to launch with visual funnel and success analytics"),
            ("🤝", "Cross-Team Collaboration", "Connect innovators across departments in shared spatial ideation sessions")
        ]
    },
    {
        "dir": "visionOS_institutional-memory-vault",
        "title": "Institutional Memory Vault",
        "logo": "IM",
        "color_primary": "#d97706",  # Amber
        "tagline": "Preserve Knowledge in Spatial Archives",
        "spatial_message": "Capture and preserve organizational knowledge in an immersive spatial archive. Document processes, decisions, and lessons learned in a 3D knowledge vault powered by Vision Pro.",
        "pillars": [
            ("📚", "Knowledge Repository", "Store documents, videos, and artifacts in spatially organized 3D library with smart search"),
            ("🗺️", "Decision Archives", "Document key decisions with context, rationale, and outcomes in spatial timeline views"),
            ("👥", "Expert Networks", "Map organizational expertise and connect knowledge seekers with subject matter experts"),
            ("🔄", "Process Documentation", "Capture workflows and procedures with spatial diagrams and step-by-step guides"),
            ("🎓", "Onboarding Portal", "Accelerate new hire learning with immersive tours through institutional knowledge")
        ]
    },
    {
        "dir": "visionOS_spatial-crm",
        "title": "Spatial CRM",
        "logo": "SC",
        "color_primary": "#db2777",  # Pink
        "tagline": "Customer Relationships in 3D Space",
        "spatial_message": "Manage customer relationships in an immersive spatial environment. Visualize customer journeys, track interactions, and optimize sales pipelines in 3D dashboards built for Vision Pro.",
        "pillars": [
            ("👥", "Customer Universe", "Visualize all customers in 3D space organized by segments, value, and engagement level"),
            ("🛤️", "Journey Mapping", "Track customer journeys from awareness to advocacy with spatial funnel visualization"),
            ("📊", "Pipeline Management", "Manage sales opportunities with 3D pipeline view and AI-powered forecasting"),
            ("💬", "Interaction History", "Access complete customer communication history in chronological spatial timeline"),
            ("🎯", "Relationship Intelligence", "Get AI insights on customer health, churn risk, and upsell opportunities")
        ]
    },
    {
        "dir": "visionOS_spatial-erp",
        "title": "Spatial ERP",
        "logo": "SE",
        "color_primary": "#3b82f6",  # Blue
        "tagline": "Enterprise Resource Planning in 3D",
        "spatial_message": "Transform ERP with spatial computing. Manage inventory, production, supply chain, and resources in an immersive 3D environment designed for Apple Vision Pro.",
        "pillars": [
            ("📦", "Inventory Visualization", "Monitor stock levels across warehouses with 3D bin visualization and predictive restocking"),
            ("🏭", "Production Planning", "Schedule manufacturing with spatial capacity planning and bottleneck identification"),
            ("🚚", "Supply Chain View", "Track materials and products through supply chain with real-time 3D flow diagrams"),
            ("💼", "Resource Allocation", "Optimize human and material resources with spatial scheduling and utilization analytics"),
            ("📈", "Performance Analytics", "Analyze operational efficiency with immersive dashboards and trend visualization")
        ]
    },
    {
        "dir": "visionOS_spatial-hcm",
        "title": "Spatial HCM",
        "logo": "SH",
        "color_primary": "#9333ea",  # Purple
        "tagline": "Human Capital Management in Spatial Reality",
        "spatial_message": "Manage your workforce in spatial 3D. Handle recruiting, onboarding, performance, and development through immersive tools designed for Apple Vision Pro.",
        "pillars": [
            ("👤", "Talent Visualization", "View organizational structure and talent distribution in interactive 3D org charts"),
            ("🎯", "Performance Management", "Track goals, reviews, and development plans with spatial progress visualization"),
            ("📊", "Workforce Analytics", "Analyze headcount, turnover, and engagement metrics in immersive dashboards"),
            ("🎓", "Learning & Development", "Manage training programs and skill development with spatial learning paths"),
            ("💰", "Compensation Planning", "Design and analyze compensation structures with 3D market comparison tools")
        ]
    },
    {
        "dir": "visionOS_culture-architecture-system",
        "title": "Culture Architecture System",
        "logo": "CA",
        "color_primary": "#e11d48",  # Rose
        "tagline": "Build Company Culture in 3D Space",
        "spatial_message": "Design and nurture organizational culture in spatial reality. Visualize values, track engagement, and build community through immersive experiences powered by Vision Pro.",
        "pillars": [
            ("🎯", "Values Visualization", "Bring company values to life with immersive 3D stories and interactive experiences"),
            ("📊", "Culture Metrics", "Measure engagement, satisfaction, and culture health with spatial survey analytics"),
            ("🤝", "Community Building", "Connect employees across locations in shared spatial social experiences"),
            ("🏆", "Recognition Programs", "Celebrate achievements with spatial awards and peer-to-peer recognition walls"),
            ("📚", "Culture Onboarding", "Immerse new hires in company culture with spatial tours and value-based scenarios")
        ]
    },
    {
        "dir": "visionOS_Reality-Annotation-Platform",
        "title": "Reality Annotation Platform",
        "logo": "RA",
        "color_primary": "#ea580c",  # Orange
        "tagline": "Annotate the Physical World in AR",
        "spatial_message": "Add persistent digital annotations to physical spaces and objects. Create AR notes, instructions, and markers that stay anchored to real-world locations using Vision Pro's spatial mapping.",
        "pillars": [
            ("📍", "Spatial Anchoring", "Place digital notes that persist in exact physical locations with centimeter accuracy"),
            ("✏️", "Rich Annotations", "Create text, voice, 3D models, and video annotations attached to real-world objects"),
            ("👥", "Team Collaboration", "Share annotations with colleagues who see the same spatial notes in AR"),
            ("🔍", "Smart Discovery", "Find and filter annotations by location, author, date, or content with spatial search"),
            ("📊", "Usage Analytics", "Track annotation engagement and identify frequently annotated locations")
        ]
    },
    {
        "dir": "visionOS_Research-Web-Crawler",
        "title": "Research Web Crawler",
        "logo": "RW",
        "color_primary": "#0d9488",  # Teal
        "tagline": "Navigate Research in Spatial Knowledge Graphs",
        "spatial_message": "Explore academic research and web content in spatial 3D knowledge graphs. Discover connections, track citations, and navigate information networks in immersive space powered by Vision Pro.",
        "pillars": [
            ("🕸️", "Knowledge Graph", "Visualize research papers and web content as interconnected 3D network graphs"),
            ("🔗", "Citation Networks", "Explore citation relationships spatially to discover foundational and derivative works"),
            ("🔍", "Smart Crawling", "Automatically discover related content with AI-powered crawling and categorization"),
            ("📊", "Research Analytics", "Analyze publication trends, author networks, and topic evolution in 3D visualizations"),
            ("💾", "Personal Library", "Organize discoveries in spatial collections with tags, notes, and reading lists")
        ]
    },
    {
        "dir": "visionOS_research-collaboration-space",
        "title": "Research Collaboration Space",
        "logo": "RC",
        "color_primary": "#0284c7",  # Sky
        "tagline": "Collaborate on Research in Immersive 3D",
        "spatial_message": "Work together on research projects in shared spatial environments. Co-author papers, analyze data, and discuss findings in immersive collaborative workspaces designed for Vision Pro.",
        "pillars": [
            ("👥", "Shared Workspaces", "Collaborate in real-time with remote researchers in synchronized spatial environments"),
            ("📊", "Data Visualization", "Explore datasets together with interactive 3D charts and statistical visualizations"),
            ("📝", "Co-Authoring", "Write papers collaboratively with spatial document editing and version control"),
            ("🎤", "Virtual Seminars", "Host and attend research presentations in immersive 3D auditoriums"),
            ("🔬", "Experiment Design", "Plan and design studies together with spatial experiment builders and protocols")
        ]
    },
    {
        "dir": "visionOS_Spatial-Code-Reviewer",
        "title": "Spatial Code Reviewer",
        "logo": "CR",
        "color_primary": "#475569",  # Slate
        "tagline": "Review Code in 3D Spatial Environment",
        "spatial_message": "Transform code review with spatial computing. Navigate codebases in 3D, visualize dependencies, and collaborate on improvements in immersive environments built for Vision Pro.",
        "pillars": [
            ("🌳", "Code Architecture", "Visualize code structure as 3D tree with modules, classes, and dependencies"),
            ("🔍", "Spatial Navigation", "Browse files and functions in 3D space with gesture-based code exploration"),
            ("💬", "Review Annotations", "Add comments and suggestions spatially anchored to specific code locations"),
            ("📊", "Quality Metrics", "View code complexity, coverage, and quality metrics in immersive dashboards"),
            ("👥", "Pair Programming", "Collaborate with remote developers in shared spatial code environments")
        ]
    },
    {
        "dir": "visionOS_healthcare-ecosystem-orchestrator",
        "title": "Healthcare Ecosystem Orchestrator",
        "logo": "HE",
        "color_primary": "#14b8a6",  # Teal
        "tagline": "Coordinate Healthcare Systems in 3D",
        "spatial_message": "Manage complex healthcare operations in spatial reality. Coordinate patient care, resources, and workflows across hospitals and clinics in an immersive command center for Vision Pro.",
        "pillars": [
            ("🏥", "Hospital Operations", "Monitor bed capacity, ER flow, and resource utilization across facilities in 3D dashboards"),
            ("👨‍⚕️", "Care Coordination", "Track patient journeys across departments with spatial care pathway visualization"),
            ("📊", "Resource Management", "Optimize staff scheduling, equipment, and supplies with spatial allocation tools"),
            ("🚑", "Emergency Response", "Coordinate emergency services with real-time spatial incident tracking and routing"),
            ("📈", "Health Analytics", "Analyze population health, outcomes, and quality metrics in immersive visualizations")
        ]
    },
    {
        "dir": "visionOS_molecular-design-platform",
        "title": "Molecular Design Platform",
        "logo": "MD",
        "color_primary": "#8b5cf6",  # Violet
        "tagline": "Design Molecules in True 3D Space",
        "spatial_message": "Accelerate drug discovery and materials science by designing molecules in true 3D space. Manipulate atoms, simulate reactions, and analyze structures in immersive environments powered by Vision Pro.",
        "pillars": [
            ("🧬", "3D Molecular Editor", "Build and modify molecules by directly manipulating atoms and bonds in spatial 3D"),
            ("⚛️", "Reaction Simulation", "Visualize chemical reactions and molecular dynamics in real-time spatial animations"),
            ("🔬", "Structure Analysis", "Analyze molecular properties, binding sites, and energy states with 3D visualization tools"),
            ("📚", "Compound Library", "Browse and search molecular databases in spatially organized 3D collections"),
            ("🤝", "Research Collaboration", "Share molecular designs and collaborate with chemists in shared spatial labs")
        ]
    },
    {
        "dir": "visionOS_spatial-wellness-platform",
        "title": "Spatial Wellness Platform",
        "logo": "SW",
        "color_primary": "#10b981",  # Emerald
        "tagline": "Holistic Health in Immersive Environments",
        "spatial_message": "Transform wellness with spatial computing. Track fitness, practice mindfulness, and manage health in immersive 3D experiences designed for Apple Vision Pro.",
        "pillars": [
            ("🏃", "Fitness Tracking", "Visualize workouts, progress, and health metrics in interactive 3D body models"),
            ("🧘", "Mindfulness Spaces", "Practice meditation and relaxation in immersive calming environments"),
            ("📊", "Health Analytics", "Monitor sleep, nutrition, and vitals with spatial dashboards and trend analysis"),
            ("🎯", "Goal Setting", "Set and track wellness goals with spatial progress visualization and coaching"),
            ("👥", "Community Support", "Connect with wellness communities in shared spatial group experiences")
        ]
    },
    {
        "dir": "visionOS_field-service-ar",
        "title": "Field Service AR",
        "logo": "FS",
        "color_primary": "#eab308",  # Yellow
        "tagline": "Service Equipment with Spatial AR Guidance",
        "spatial_message": "Transform field service operations with AR-guided repairs and maintenance. See step-by-step instructions overlaid on equipment in real-world locations using Vision Pro's spatial mapping.",
        "pillars": [
            ("🔧", "AR Work Instructions", "See repair procedures overlaid on actual equipment with spatial step-by-step guidance"),
            ("📋", "Service Scheduling", "Manage work orders and dispatch with spatial routing and time optimization"),
            ("🎥", "Remote Expert Support", "Connect with specialists who see what you see and provide spatial annotations"),
            ("📊", "Equipment History", "Access maintenance records and diagnostics anchored to physical equipment in AR"),
            ("✅", "Quality Assurance", "Verify work completion with AR checklists and photo documentation")
        ]
    },
    {
        "dir": "visionOS_industrial-cad-cam-suite",
        "title": "Industrial CAD/CAM Suite",
        "logo": "IC",
        "color_primary": "#64748b",  # Steel
        "tagline": "Design Manufacturing in Spatial 3D",
        "spatial_message": "Design and manufacture products in true-to-scale spatial 3D. Create CAD models, simulate machining, and optimize production in immersive environments built for Vision Pro.",
        "pillars": [
            ("📐", "Spatial CAD Design", "Create precise 3D models with gesture-based modeling tools and parametric design"),
            ("🏭", "CAM Programming", "Generate toolpaths and simulate machining operations in spatial 3D previews"),
            ("🔍", "Quality Inspection", "Overlay CAD models on physical parts for dimensional verification in AR"),
            ("⚙️", "Assembly Planning", "Design and verify product assembly with spatial sequence simulation"),
            ("📊", "Manufacturing Analytics", "Optimize production with spatial analysis of cycle times and efficiency")
        ]
    },
    {
        "dir": "visionOS_industrial-safety-simulator",
        "title": "Industrial Safety Simulator",
        "logo": "IS",
        "color_primary": "#f97316",  # Orange
        "tagline": "Train Safety in Risk-Free 3D Environments",
        "spatial_message": "Train workers for hazardous scenarios in safe immersive simulations. Practice emergency response, equipment operation, and safety procedures in realistic 3D environments powered by Vision Pro.",
        "pillars": [
            ("⚠️", "Hazard Scenarios", "Experience realistic workplace hazards in safe spatial simulations with proper responses"),
            ("🏭", "Equipment Training", "Practice operating dangerous machinery in risk-free immersive 3D environments"),
            ("🚨", "Emergency Response", "Train for fires, spills, and accidents with spatial scenario-based drills"),
            ("📋", "Safety Protocols", "Learn and practice safety procedures with interactive spatial checklists"),
            ("📊", "Performance Analytics", "Track safety training completion and competency with detailed assessment metrics")
        ]
    },
    {
        "dir": "visionOS_smart-city-command-platform",
        "title": "Smart City Command Platform",
        "logo": "SM",
        "color_primary": "#0ea5e9",  # Blue
        "tagline": "Manage Cities in Spatial Control Centers",
        "spatial_message": "Operate smart cities from immersive spatial command centers. Monitor traffic, utilities, public safety, and services in real-time 3D city models powered by Vision Pro.",
        "pillars": [
            ("🏙️", "City Digital Twin", "View real-time 3D model of entire city with live data from sensors and systems"),
            ("🚦", "Traffic Management", "Monitor and optimize traffic flow with spatial intersection and route visualization"),
            ("💡", "Utilities Control", "Manage power, water, and waste systems with spatial network visualization"),
            ("🚓", "Public Safety", "Coordinate emergency services with spatial incident tracking and resource deployment"),
            ("📊", "City Analytics", "Analyze urban trends and optimize city operations with immersive data dashboards")
        ]
    },
    {
        "dir": "visionOS_legal-discovery-universe",
        "title": "Legal Discovery Universe",
        "logo": "LD",
        "color_primary": "#1e40af",  # Navy
        "tagline": "Navigate Legal Data in Spatial 3D",
        "spatial_message": "Transform legal discovery with spatial computing. Explore documents, evidence, and case relationships in immersive 3D knowledge graphs designed for Apple Vision Pro.",
        "pillars": [
            ("📚", "Document Universe", "Navigate thousands of legal documents organized in spatial 3D with smart search"),
            ("🔗", "Relationship Mapping", "Visualize connections between people, entities, and events in 3D network graphs"),
            ("🔍", "Evidence Analysis", "Review and annotate evidence spatially with timeline visualization and tagging"),
            ("📊", "Case Strategy", "Build legal arguments with spatial storyboarding and evidence organization tools"),
            ("👥", "Team Collaboration", "Work with legal teams in shared spatial war rooms for case preparation")
        ]
    },
    {
        "dir": "visionOS_military-defense-training",
        "title": "Military Defense Training",
        "logo": "MT",
        "color_primary": "#84cc16",  # Olive
        "tagline": "Military Training in Spatial Simulations",
        "spatial_message": "Train military personnel in realistic spatial combat simulations. Practice tactics, operations, and decision-making in immersive 3D scenarios designed for Vision Pro.",
        "pillars": [
            ("🎯", "Tactical Scenarios", "Experience realistic combat situations in immersive 3D environments with mission objectives"),
            ("🗺️", "Terrain Analysis", "Study battlefields and plan operations on true-to-scale 3D terrain models"),
            ("👥", "Squad Coordination", "Practice team tactics and communication in multi-user spatial training exercises"),
            ("🚁", "Vehicle Operations", "Train on aircraft, vehicles, and equipment in realistic spatial simulators"),
            ("📊", "Performance Review", "Analyze tactical decisions and mission outcomes with spatial after-action reviews")
        ]
    },
    {
        "dir": "visionOS_real-estate-spatial",
        "title": "Real Estate Spatial",
        "logo": "RE",
        "color_primary": "#22c55e",  # Green
        "tagline": "Tour Properties in Immersive 3D Reality",
        "spatial_message": "Transform real estate with spatial property tours. View homes, commercial spaces, and developments in immersive 3D, measure rooms, and visualize renovations using Vision Pro.",
        "pillars": [
            ("🏠", "Virtual Property Tours", "Walk through properties in photorealistic 3D from anywhere in the world"),
            ("📏", "Spatial Measurements", "Measure rooms, walls, and spaces accurately with AR measurement tools"),
            ("🎨", "Renovation Visualization", "Preview renovations and design changes overlaid on real properties in AR"),
            ("📊", "Market Analytics", "Analyze property values and market trends with spatial comparative data"),
            ("🤝", "Client Collaboration", "Tour properties together with remote clients in synchronized spatial experiences")
        ]
    },
    {
        "dir": "visionOS_Living-Building-System",
        "title": "Living Building System",
        "logo": "LB",
        "color_primary": "#84cc16",  # Lime
        "tagline": "Smart Buildings in Spatial Reality",
        "spatial_message": "Manage smart buildings with spatial computing. Monitor HVAC, lighting, security, and energy in immersive 3D building models powered by Apple Vision Pro.",
        "pillars": [
            ("🏢", "Building Digital Twin", "View real-time 3D model of building with live sensor data from all systems"),
            ("🌡️", "Climate Control", "Monitor and adjust HVAC across floors with spatial temperature visualization"),
            ("💡", "Energy Management", "Optimize power usage with spatial energy flow diagrams and efficiency analytics"),
            ("🔒", "Security Systems", "Monitor access control, cameras, and alarms in spatial security dashboards"),
            ("📊", "Facility Analytics", "Analyze occupancy, utilization, and operational efficiency with 3D building metrics")
        ]
    },
    {
        "dir": "visionOS_Home-Maintenance-Oracle",
        "title": "Home Maintenance Oracle",
        "logo": "HM",
        "color_primary": "#b45309",  # Brown
        "tagline": "Home Care Guidance in Spatial AR",
        "spatial_message": "Get expert home maintenance guidance in AR. See repair instructions overlaid on appliances and systems, schedule maintenance, and learn DIY repairs using Vision Pro's spatial capabilities.",
        "pillars": [
            ("🔧", "AR Repair Guides", "See step-by-step repair instructions overlaid on actual appliances and fixtures"),
            ("📅", "Maintenance Scheduler", "Track and schedule regular home maintenance with spatial calendar and reminders"),
            ("🏠", "Home Systems Map", "Document and locate plumbing, electrical, and HVAC systems in spatial 3D home model"),
            ("💰", "Cost Estimator", "Get repair cost estimates and find local contractors with spatial comparison tools"),
            ("📚", "DIY Learning", "Learn home improvement skills with immersive video tutorials and AR demonstrations")
        ]
    },
    {
        "dir": "visionOS_Language-Immersion-Rooms",
        "title": "Language Immersion Rooms",
        "logo": "LI",
        "color_primary": "#3b82f6",  # Blue
        "tagline": "Learn Languages in Spatial Environments",
        "spatial_message": "Master new languages through immersive spatial environments. Practice conversations, explore cultural contexts, and learn vocabulary in realistic 3D scenarios designed for Vision Pro.",
        "pillars": [
            ("🗣️", "Conversation Practice", "Speak with AI tutors and native speakers in immersive 3D conversation scenarios"),
            ("🌍", "Cultural Immersion", "Explore authentic locations and cultural contexts in photorealistic spatial environments"),
            ("📚", "Vocabulary Learning", "Learn words spatially by interacting with labeled 3D objects in context"),
            ("🎯", "Gamified Lessons", "Progress through language skills with spatial games and interactive challenges"),
            ("📊", "Progress Tracking", "Monitor fluency development with spatial proficiency dashboards and assessments")
        ]
    },
    {
        "dir": "visionOS_Personal-Finance-Navigator",
        "title": "Personal Finance Navigator",
        "logo": "PF",
        "color_primary": "#16a34a",  # Green
        "tagline": "Manage Money in Spatial 3D Dashboards",
        "spatial_message": "Transform personal finance management with spatial computing. Track spending, plan budgets, and grow wealth in immersive 3D financial dashboards built for Vision Pro.",
        "pillars": [
            ("💰", "Spending Visualization", "See money flowing through categories in real-time 3D Sankey diagrams"),
            ("📊", "Budget Planning", "Allocate and track budgets with interactive spatial envelope system"),
            ("📈", "Investment Portfolio", "Monitor investments with 3D portfolio visualization and performance analytics"),
            ("🎯", "Financial Goals", "Set and track savings goals with spatial progress visualization and forecasting"),
            ("🔔", "Smart Alerts", "Receive spatial notifications for bills, unusual spending, and investment opportunities")
        ]
    },
    {
        "dir": "visionOS_Spatial-Screenplay-Workshop",
        "title": "Spatial Screenplay Workshop",
        "logo": "SS",
        "color_primary": "#a855f7",  # Purple
        "tagline": "Write Scripts in Immersive 3D Spaces",
        "spatial_message": "Write screenplays in immersive spatial environments. Visualize scenes in 3D, organize story beats spatially, and collaborate with writers in shared creative spaces powered by Vision Pro.",
        "pillars": [
            ("📝", "Spatial Script Editor", "Write screenplays with 3D scene visualization and character positioning tools"),
            ("🎬", "Scene Preview", "See your written scenes come to life in spatial 3D previsualization"),
            ("📚", "Story Structure", "Organize acts, sequences, and beats on spatial story boards and timelines"),
            ("👥", "Writer Collaboration", "Co-write with partners in shared spatial writing rooms with real-time editing"),
            ("🎯", "Character Development", "Build character profiles and relationships with spatial network mapping")
        ]
    },
    {
        "dir": "visionOS_Wardrobe-Consultant",
        "title": "Wardrobe Consultant",
        "logo": "WC",
        "color_primary": "#ec4899",  # Pink
        "tagline": "Style Guidance in Spatial AR Mirror",
        "spatial_message": "Get personalized style advice with spatial AR fashion assistant. Try on outfits virtually, plan wardrobe combinations, and receive styling suggestions using Vision Pro's spatial capabilities.",
        "pillars": [
            ("👔", "Virtual Try-On", "See clothing on yourself in AR with realistic fit and draping simulation"),
            ("🎨", "Outfit Planning", "Create and save outfit combinations with spatial wardrobe organization"),
            ("💡", "Style Suggestions", "Get AI-powered styling advice based on occasion, weather, and personal preferences"),
            ("📊", "Wardrobe Analytics", "Analyze clothing usage patterns and identify gaps in your wardrobe"),
            ("🛍️", "Shopping Assistant", "Find similar items or complete looks with spatial product recommendations")
        ]
    },
    {
        "dir": "visionOS_Physical-Digital-Twins",
        "title": "Physical Digital Twins",
        "logo": "PD",
        "color_primary": "#22d3ee",  # Cyan
        "tagline": "Mirror Reality in Spatial Digital Twins",
        "spatial_message": "Create living digital replicas of physical objects and spaces. Monitor, simulate, and optimize real-world systems through synchronized spatial twins powered by Vision Pro.",
        "pillars": [
            ("🏭", "Asset Mirroring", "Create precise 3D digital twins of equipment, buildings, and infrastructure"),
            ("📊", "Real-Time Sync", "See live sensor data flowing into digital twins with synchronized state updates"),
            ("🔮", "Predictive Simulation", "Test scenarios and predict failures by simulating conditions on digital twins"),
            ("📈", "Performance Optimization", "Analyze twin data to optimize efficiency and prevent downtime"),
            ("🤝", "Remote Collaboration", "Share digital twins with teams for collaborative monitoring and planning")
        ]
    },
    {
        "dir": "visionOS_sustainability-command",
        "title": "Sustainability Command",
        "logo": "SU",
        "color_primary": "#15803d",  # Green
        "tagline": "Environmental Impact in Spatial Dashboards",
        "spatial_message": "Manage sustainability initiatives with spatial computing. Track carbon footprint, monitor environmental metrics, and optimize resource usage in immersive 3D dashboards for Vision Pro.",
        "pillars": [
            ("🌍", "Carbon Tracking", "Visualize carbon emissions across operations with spatial flow diagrams and reduction paths"),
            ("♻️", "Resource Efficiency", "Monitor water, energy, and material usage with 3D efficiency dashboards"),
            ("📊", "ESG Reporting", "Generate sustainability reports with spatial data visualization and compliance tracking"),
            ("🎯", "Goal Management", "Set and track environmental targets with spatial progress indicators and forecasting"),
            ("🔍", "Impact Analysis", "Analyze environmental impact of decisions with spatial scenario modeling tools")
        ]
    }
]

def create_landing_page(app_config):
    """Generate landing page HTML for a visionOS app"""

    # Calculate RGBA values
    primary_015 = hex_to_rgba(app_config["color_primary"], 0.15)
    primary_02 = hex_to_rgba(app_config["color_primary"], 0.2)
    primary_03 = hex_to_rgba(app_config["color_primary"], 0.3)
    primary_05 = hex_to_rgba(app_config["color_primary"], 0.5)

    # Build pillars HTML
    pillars_html = ""
    for emoji, title, description in app_config["pillars"]:
        pillars_html += f"""
                <div class="pillar-card">
                    <div class="pillar-icon">{emoji}</div>
                    <h3>{title}</h3>
                    <p>{description}</p>
                </div>"""

    html_content = f"""<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>{app_config['title']} - Spatial Computing for Vision Pro</title>
    <style>
        * {{
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }}

        body {{
            font-family: -apple-system, BlinkMacSystemFont, 'SF Pro Display', 'Segoe UI', sans-serif;
            background: #0a0a0f;
            color: #ffffff;
            overflow-x: hidden;
        }}

        /* 3D Depth Layers */
        .depth-layer {{
            position: fixed;
            width: 200%;
            height: 200%;
            top: -50%;
            left: -50%;
            pointer-events: none;
            z-index: 0;
        }}

        .depth-layer-1 {{
            background: radial-gradient(circle at 20% 30%, rgba{primary_015} 0%, transparent 50%);
            animation: float 20s ease-in-out infinite;
        }}

        .depth-layer-2 {{
            background: radial-gradient(circle at 80% 70%, rgba{primary_02} 0%, transparent 50%);
            animation: float 25s ease-in-out infinite reverse;
        }}

        .depth-layer-3 {{
            background: radial-gradient(circle at 50% 50%, rgba{primary_03} 0%, transparent 60%);
            animation: float 30s ease-in-out infinite;
        }}

        @keyframes float {{
            0%, 100% {{ transform: translate(0, 0) rotate(0deg); }}
            33% {{ transform: translate(30px, -30px) rotate(5deg); }}
            66% {{ transform: translate(-20px, 20px) rotate(-5deg); }}
        }}

        /* Container */
        .container {{
            max-width: 1400px;
            margin: 0 auto;
            padding: 40px 20px;
            position: relative;
            z-index: 1;
        }}

        /* Hero Section */
        .hero {{
            text-align: center;
            padding: 80px 20px 60px;
            position: relative;
        }}

        .hero-badge {{
            display: inline-block;
            background: rgba{primary_03};
            backdrop-filter: blur(20px);
            -webkit-backdrop-filter: blur(20px);
            border: 1px solid rgba{primary_05};
            padding: 8px 20px;
            border-radius: 20px;
            font-size: 14px;
            font-weight: 600;
            margin-bottom: 30px;
            box-shadow: 0 8px 32px rgba(0, 0, 0, 0.3);
        }}

        .logo-container {{
            margin-bottom: 30px;
            perspective: 1000px;
        }}

        .logo-icon {{
            display: inline-flex;
            align-items: center;
            justify-content: center;
            width: 120px;
            height: 120px;
            background: rgba(30, 27, 75, 0.4);
            backdrop-filter: blur(20px);
            -webkit-backdrop-filter: blur(20px);
            border: 2px solid rgba{primary_03};
            border-radius: 28px;
            font-size: 48px;
            font-weight: 700;
            color: {app_config['color_primary']};
            box-shadow:
                0 20px 60px rgba(0, 0, 0, 0.4),
                inset 0 1px 0 rgba(255, 255, 255, 0.1);
            transform-style: preserve-3d;
            animation: logoFloat 6s ease-in-out infinite;
        }}

        @keyframes logoFloat {{
            0%, 100% {{ transform: rotateY(0deg) rotateX(0deg); }}
            50% {{ transform: rotateY(10deg) rotateX(5deg); }}
        }}

        h1 {{
            font-size: 64px;
            font-weight: 700;
            margin-bottom: 20px;
            background: linear-gradient(135deg, #ffffff 0%, {app_config['color_primary']} 100%);
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
            background-clip: text;
            line-height: 1.2;
        }}

        .tagline {{
            font-size: 28px;
            color: rgba(255, 255, 255, 0.9);
            margin-bottom: 30px;
            font-weight: 500;
        }}

        .spatial-message {{
            font-size: 18px;
            color: rgba(255, 255, 255, 0.7);
            max-width: 800px;
            margin: 0 auto 40px;
            line-height: 1.6;
        }}

        /* CTA Button */
        .cta-button {{
            display: inline-block;
            background: {app_config['color_primary']};
            color: #ffffff;
            padding: 18px 48px;
            border-radius: 12px;
            text-decoration: none;
            font-size: 18px;
            font-weight: 600;
            transition: all 0.3s ease;
            box-shadow: 0 10px 40px rgba{primary_03};
            border: 1px solid rgba(255, 255, 255, 0.1);
        }}

        .cta-button:hover {{
            transform: translateY(-2px);
            box-shadow: 0 15px 50px rgba{primary_05};
        }}

        /* Section Titles */
        .section {{
            margin: 80px 0;
        }}

        .section-title {{
            font-size: 42px;
            font-weight: 700;
            text-align: center;
            margin-bottom: 50px;
            color: #ffffff;
        }}

        /* Spatial Pillars Grid */
        .pillars-grid {{
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(320px, 1fr));
            gap: 30px;
            margin-bottom: 60px;
        }}

        .pillar-card {{
            background: rgba(30, 27, 75, 0.4);
            backdrop-filter: blur(20px);
            -webkit-backdrop-filter: blur(20px);
            border: 1px solid rgba{primary_02};
            border-radius: 20px;
            padding: 40px;
            transition: all 0.3s ease;
            box-shadow:
                0 8px 32px rgba(0, 0, 0, 0.3),
                inset 0 1px 0 rgba(255, 255, 255, 0.05);
        }}

        .pillar-card:hover {{
            transform: translateY(-5px);
            border-color: rgba{primary_05};
            box-shadow:
                0 12px 48px rgba(0, 0, 0, 0.4),
                0 0 0 1px rgba{primary_03};
        }}

        .pillar-icon {{
            font-size: 48px;
            margin-bottom: 20px;
        }}

        .pillar-card h3 {{
            font-size: 24px;
            margin-bottom: 15px;
            color: {app_config['color_primary']};
        }}

        .pillar-card p {{
            font-size: 16px;
            line-height: 1.6;
            color: rgba(255, 255, 255, 0.7);
        }}

        /* Screenshots Section */
        .screenshots-grid {{
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(400px, 1fr));
            gap: 30px;
            margin-bottom: 60px;
        }}

        .screenshot-card {{
            background: rgba(30, 27, 75, 0.3);
            border: 1px solid rgba{primary_02};
            border-radius: 16px;
            padding: 20px;
            backdrop-filter: blur(10px);
            -webkit-backdrop-filter: blur(10px);
        }}

        .screenshot-placeholder {{
            width: 100%;
            aspect-ratio: 16 / 9;
            background: linear-gradient(135deg, rgba{primary_015} 0%, rgba(30, 27, 75, 0.6) 100%);
            border-radius: 12px;
            display: flex;
            align-items: center;
            justify-content: center;
            color: rgba(255, 255, 255, 0.4);
            font-size: 18px;
            border: 1px dashed rgba{primary_03};
        }}

        /* Footer */
        footer {{
            text-align: center;
            padding: 60px 20px;
            border-top: 1px solid rgba(255, 255, 255, 0.1);
            margin-top: 100px;
        }}

        footer p {{
            color: rgba(255, 255, 255, 0.5);
            font-size: 14px;
        }}

        /* Responsive */
        @media (max-width: 768px) {{
            h1 {{
                font-size: 42px;
            }}

            .tagline {{
                font-size: 22px;
            }}

            .section-title {{
                font-size: 32px;
            }}

            .pillars-grid,
            .screenshots-grid {{
                grid-template-columns: 1fr;
            }}
        }}
    </style>
</head>
<body>
    <!-- 3D Depth Layers -->
    <div class="depth-layer depth-layer-1"></div>
    <div class="depth-layer depth-layer-2"></div>
    <div class="depth-layer depth-layer-3"></div>

    <div class="container">
        <!-- Hero Section -->
        <section class="hero">
            <div class="hero-badge">Build for Apple Vision Pro</div>

            <div class="logo-container">
                <div class="logo-icon">{app_config['logo']}</div>
            </div>

            <h1>{app_config['title']}</h1>
            <p class="tagline">{app_config['tagline']}</p>
            <p class="spatial-message">
                {app_config['spatial_message']}
            </p>

            <a href="#" class="cta-button">Experience in Vision Pro</a>
        </section>

        <!-- Spatial Pillars -->
        <section class="section">
            <h2 class="section-title">5 Spatial Pillars</h2>
            <div class="pillars-grid">{pillars_html}
            </div>
        </section>

        <!-- Screenshots -->
        <section class="section">
            <h2 class="section-title">Spatial Experience Gallery</h2>
            <div class="screenshots-grid">
                <div class="screenshot-card">
                    <div class="screenshot-placeholder">16:9 Spatial Screenshot</div>
                </div>
                <div class="screenshot-card">
                    <div class="screenshot-placeholder">16:9 Spatial Screenshot</div>
                </div>
                <div class="screenshot-card">
                    <div class="screenshot-placeholder">16:9 Spatial Screenshot</div>
                </div>
                <div class="screenshot-card">
                    <div class="screenshot-placeholder">16:9 Spatial Screenshot</div>
                </div>
            </div>
        </section>
    </div>

    <footer>
        <p>&copy; 2024 {app_config['title']}. Designed for Apple Vision Pro spatial computing.</p>
    </footer>
</body>
</html>"""

    return html_content

def main():
    """Generate landing pages for all 34 remaining non-gaming visionOS apps"""
    base_path = Path(__file__).parent

    print(f"Starting generation of {len(APPS)} non-gaming visionOS app landing pages...\n")

    for i, app_config in enumerate(APPS, 1):
        app_dir = base_path / app_config["dir"]

        print(f"[{i}/{len(APPS)}] Generating landing page for {app_config['title']}...")

        # Create directories
        docs_dir = app_dir / "docs"
        landing_dir = app_dir / "landing-page"
        docs_dir.mkdir(parents=True, exist_ok=True)
        landing_dir.mkdir(parents=True, exist_ok=True)

        # Generate HTML
        html_content = create_landing_page(app_config)

        # Write to both locations
        docs_index = docs_dir / "index.html"
        landing_index = landing_dir / "index.html"

        docs_index.write_text(html_content)
        landing_index.write_text(html_content)

        print(f"  ✓ Created {docs_index}")
        print(f"  ✓ Created {landing_index}")

    print(f"\n{'='*80}")
    print(f"Successfully generated {len(APPS)} landing pages!")
    print(f"{'='*80}")
    print("\nCategories generated:")
    print("  - Enterprise & Business (12 apps)")
    print("  - Research & Development (4 apps)")
    print("  - Healthcare & Wellness (3 apps)")
    print("  - Industrial & Manufacturing (3 apps)")
    print("  - Smart City & Infrastructure (2 apps)")
    print("  - Legal & Defense (2 apps)")
    print("  - Real Estate & Buildings (2 apps)")
    print("  - Consumer & Lifestyle (6 apps)")

if __name__ == "__main__":
    main()
