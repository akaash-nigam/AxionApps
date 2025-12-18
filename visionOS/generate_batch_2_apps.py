#!/usr/bin/env python3
"""Generate next 5 visionOS landing pages - Batch 2"""

import os
import shutil

def hex_to_rgba(hex_color, alpha):
    """Convert hex color to rgba tuple string"""
    hex_color = hex_color.lstrip('#')
    r = int(hex_color[0:2], 16)
    g = int(hex_color[2:4], 16)
    b = int(hex_color[4:6], 16)
    return f"({r}, {g}, {b}, {alpha})"

APPS = [
    {
        "dir": "visionOS_Financial-Trading-Cockpit",
        "title": "Financial Trading Cockpit",
        "tagline": "Trade Markets in Immersive 3D Reality",
        "spatial_message": "Surround yourself with live market data in unlimited 3D space. Track portfolios room-scale, execute trades with gestures, and make split-second decisions from your personal trading command center.",
        "logo": "FT",
        "color_primary": "#10b981",  # Green for finance/money/growth
        "color_secondary": "#34d399",
        "pillars": [
            ("📈", "Spatial Market Walls", "Arrange unlimited charts, tickers, and indicators across room-scale 3D. Organize by asset class, sector, or strategy."),
            ("⚡", "Gesture Trading", "Execute trades with pinch gestures. Swipe to rebalance portfolios. Natural hand control for lightning-fast execution."),
            ("🌐", "Multi-Market Monitoring", "Watch stocks, crypto, forex, commodities simultaneously. All markets visible at once in spatial arrangement."),
            ("📊", "Live Data Streams", "Real-time Level 2 quotes, order books, news feeds float around you. Every data point accessible with a glance."),
            ("🔔", "Spatial Alerts", "Price alerts appear as 3D notifications at relevant charts. Size and color indicate urgency and direction."),
        ]
    },
    {
        "dir": "visionOS_digital-twin-orchestrator",
        "title": "Digital Twin Orchestrator",
        "tagline": "Manage IoT Ecosystems in Spatial 3D",
        "spatial_message": "Visualize your entire IoT infrastructure in immersive 3D. Monitor thousands of devices room-scale, control systems with gestures, and orchestrate digital twins from a spatial command center.",
        "logo": "DT",
        "color_primary": "#f97316",  # Orange for industry/IoT/energy
        "color_secondary": "#fb923c",
        "pillars": [
            ("🏭", "3D Infrastructure Map", "See your entire IoT ecosystem in spatial 3D. Factories, warehouses, fleets—all devices mapped to physical locations."),
            ("📡", "Real-Time Device Status", "Live sensor data visualized as floating metrics. Temperature, pressure, location—all updating in real-time."),
            ("🔧", "Gesture-Based Control", "Pinch to adjust settings, swipe to restart devices, voice commands for emergency shutdowns. Intuitive spatial control."),
            ("🤖", "Twin Synchronization", "Watch digital twins mirror physical assets in real-time. Predictive maintenance alerts appear before failures."),
            ("👥", "Multi-User Operations", "Coordinate with teams in shared 3D space. Everyone sees same infrastructure, responds to incidents together."),
        ]
    },
    {
        "dir": "visionOS_Medical-Imaging-Suite",
        "title": "Medical Imaging Suite",
        "tagline": "Analyze Medical Scans in Spatial 3D",
        "spatial_message": "Step inside MRI, CT, and PET scans at true scale. Examine anatomy from every angle, collaborate with specialists in shared space, and revolutionize medical imaging analysis.",
        "logo": "MI",
        "color_primary": "#14b8a6",  # Teal for medical/healthcare
        "color_secondary": "#2dd4bf",
        "pillars": [
            ("🫀", "True 3D Anatomy", "View organs, vessels, tumors in full spatial 3D. Walk around, zoom in, see from angles impossible on flat screens."),
            ("📏", "Precise Measurements", "Measure lesions, distances, volumes with spatial precision. Hand gestures for sub-millimeter accuracy."),
            ("👥", "Specialist Collaboration", "Multiple doctors examine same scan together in shared 3D space. Point, annotate, discuss in real-time."),
            ("🔬", "Layer Isolation", "Toggle MRI sequences, CT phases, PET overlays with gestures. See specific tissues or pathology isolated in 3D."),
            ("📊", "Integrated Patient Data", "Historical scans, lab results, vitals float beside current imaging. Complete patient picture in spatial view."),
        ]
    },
    {
        "dir": "visionOS_construction-site-manager",
        "title": "Construction Site Manager",
        "tagline": "Manage Construction in Spatial Reality",
        "spatial_message": "Overlay BIM models on actual construction sites at 1:1 scale. Track progress room-scale, coordinate crews with spatial visualization, and manage builds from an immersive site office.",
        "logo": "CS",
        "color_primary": "#eab308",  # Yellow for construction/safety
        "color_secondary": "#facc15",
        "pillars": [
            ("🏗️", "1:1 BIM Overlay", "See building plans overlaid on actual site at true scale. Compare as-built vs as-designed in real-time passthrough."),
            ("📋", "Spatial Task Tracking", "Tasks and issues appear as 3D markers at exact locations. See punch list items floating where work is needed."),
            ("👷", "Crew Coordination", "Track worker locations, equipment placement in spatial 3D. Optimize logistics with room-scale site visualization."),
            ("📸", "Progress Documentation", "Capture 360° site photos with spatial metadata. Compare timeline snapshots in immersive before/after view."),
            ("⚠️", "Safety Zone Visualization", "Hazard zones, exclusion areas, scaffold safety displayed in spatial AR. Walk site with safety overlay visible."),
        ]
    },
    {
        "dir": "visionOS_spatial-meeting-platform",
        "title": "Spatial Meeting Platform",
        "tagline": "Virtual Meetings in Shared 3D Space",
        "spatial_message": "Transform video calls into spatial experiences. Sit around virtual tables with lifesize participants, share 3D content, and collaborate as if everyone's in the same room.",
        "logo": "SM",
        "color_primary": "#6366f1",  # Indigo for virtual meetings/collaboration
        "color_secondary": "#818cf8",
        "pillars": [
            ("🪑", "Spatial Seating", "Participants appear lifesize around virtual conference tables. Spatial audio makes it feel like same room."),
            ("📱", "3D Content Sharing", "Share screens, 3D models, presentations floating in shared space. Everyone sees same content positioned perfectly."),
            ("✏️", "Collaborative Whiteboard", "Draw, sketch, brainstorm on infinite 3D whiteboards. All participants contribute simultaneously in space."),
            ("🎯", "Focus Modes", "Spotlight speakers, create breakout rooms, arrange attendees dynamically. Spatial meeting flow control."),
            ("🌍", "Cross-Platform Join", "Vision Pro users in 3D, others via video feeds. Hybrid meetings that include everyone."),
        ]
    },
]

def generate_landing_page(app_config):
    pillars_html = ""
    for icon, title, desc in app_config["pillars"]:
        pillars_html += f'''
                <div class="pillar-card">
                    <div class="pillar-icon">{icon}</div>
                    <h3>{title}</h3>
                    <p>{desc}</p>
                </div>
'''

    html = f'''<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>{app_config["title"]} - Spatial Computing for Vision Pro</title>
    <meta name="description" content="{app_config["spatial_message"]}">
    <meta name="keywords" content="visionOS, Vision Pro, Spatial Computing, {app_config["title"]}, 3D Interface, Mixed Reality">
    <style>
        * {{
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }}

        body {{
            font-family: -apple-system, BlinkMacSystemFont, 'SF Pro Display', 'Segoe UI', Roboto, sans-serif;
            line-height: 1.6;
            color: #f0f0f0;
            background: #0a0a0f;
            min-height: 100vh;
            overflow-x: hidden;
            position: relative;
        }}

        .bg-layer {{
            position: fixed;
            width: 100%;
            height: 100%;
            top: 0;
            left: 0;
            pointer-events: none;
        }}

        .bg-layer-1 {{
            background: radial-gradient(circle at 20% 30%, rgba{hex_to_rgba(app_config["color_primary"], 0.15)} 0%, transparent 50%);
            z-index: 1;
        }}

        .bg-layer-2 {{
            background: radial-gradient(circle at 80% 70%, rgba{hex_to_rgba(app_config["color_secondary"], 0.1)} 0%, transparent 50%);
            z-index: 2;
        }}

        .bg-layer-3 {{
            background: linear-gradient(180deg, transparent 0%, rgba{hex_to_rgba(app_config["color_primary"], 0.05)} 100%);
            z-index: 3;
        }}

        .container {{
            max-width: 1400px;
            margin: 0 auto;
            padding: 40px 20px;
            position: relative;
            z-index: 10;
        }}

        header {{
            text-align: center;
            padding: 80px 20px;
            position: relative;
        }}

        .hero-badge {{
            display: inline-block;
            padding: 8px 20px;
            background: rgba{hex_to_rgba(app_config["color_primary"], 0.15)};
            backdrop-filter: blur(10px);
            border: 1px solid rgba{hex_to_rgba(app_config["color_primary"], 0.3)};
            border-radius: 20px;
            font-size: 14px;
            color: {app_config["color_secondary"]};
            font-weight: 500;
            letter-spacing: 1px;
            text-transform: uppercase;
            margin-bottom: 30px;
            animation: float 3s ease-in-out infinite;
        }}

        @keyframes float {{
            0%, 100% {{ transform: translateY(0px); }}
            50% {{ transform: translateY(-10px); }}
        }}

        .logo-container {{
            perspective: 1000px;
            margin-bottom: 40px;
        }}

        .logo-icon {{
            width: 120px;
            height: 120px;
            background: linear-gradient(135deg, rgba{hex_to_rgba(app_config["color_primary"], 0.8)} 0%, rgba{hex_to_rgba(app_config["color_secondary"], 0.6)} 100%);
            backdrop-filter: blur(20px);
            border: 2px solid rgba{hex_to_rgba(app_config["color_secondary"], 0.2)};
            border-radius: 30px;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 54px;
            font-weight: 800;
            color: #ffffff;
            margin: 0 auto;
            box-shadow:
                0 20px 60px rgba{hex_to_rgba(app_config["color_primary"], 0.4)},
                0 0 80px rgba{hex_to_rgba(app_config["color_primary"], 0.2)},
                inset 0 1px 0 rgba(255, 255, 255, 0.1);
            letter-spacing: -3px;
            transform-style: preserve-3d;
            animation: rotateY 8s ease-in-out infinite;
        }}

        @keyframes rotateY {{
            0%, 100% {{ transform: rotateY(-5deg) rotateX(2deg); }}
            50% {{ transform: rotateY(5deg) rotateX(-2deg); }}
        }}

        h1 {{
            font-size: 68px;
            font-weight: 800;
            background: linear-gradient(135deg, #ffffff 0%, {app_config["color_secondary"]} 50%, {app_config["color_primary"]} 100%);
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
            background-clip: text;
            margin-bottom: 24px;
            line-height: 1.1;
            letter-spacing: -2px;
        }}

        .tagline {{
            font-size: 28px;
            color: #b5a3e8;
            margin-bottom: 20px;
            font-weight: 400;
            max-width: 800px;
            margin-left: auto;
            margin-right: auto;
        }}

        .spatial-message {{
            font-size: 18px;
            color: #9388db;
            font-weight: 300;
            max-width: 700px;
            margin: 0 auto 50px;
            line-height: 1.8;
        }}

        .cta-buttons {{
            display: flex;
            gap: 20px;
            justify-content: center;
            flex-wrap: wrap;
            margin-bottom: 80px;
        }}

        .btn {{
            padding: 20px 48px;
            font-size: 18px;
            font-weight: 600;
            border: none;
            border-radius: 16px;
            cursor: pointer;
            text-decoration: none;
            display: inline-flex;
            align-items: center;
            gap: 10px;
            transition: all 0.4s cubic-bezier(0.4, 0, 0.2, 1);
            position: relative;
            overflow: hidden;
        }}

        .btn::before {{
            content: '';
            position: absolute;
            top: 0;
            left: -100%;
            width: 100%;
            height: 100%;
            background: linear-gradient(90deg, transparent, rgba(255, 255, 255, 0.2), transparent);
            transition: left 0.5s;
        }}

        .btn:hover::before {{
            left: 100%;
        }}

        .btn-primary {{
            background: linear-gradient(135deg, {app_config["color_primary"]} 0%, {app_config["color_secondary"]} 100%);
            color: #ffffff;
            box-shadow:
                0 8px 30px rgba{hex_to_rgba(app_config["color_primary"], 0.4)},
                0 0 60px rgba{hex_to_rgba(app_config["color_primary"], 0.2)};
        }}

        .btn-primary:hover {{
            transform: translateY(-3px);
            box-shadow:
                0 12px 40px rgba{hex_to_rgba(app_config["color_primary"], 0.6)},
                0 0 80px rgba{hex_to_rgba(app_config["color_primary"], 0.3)};
        }}

        .btn-secondary {{
            background: rgba{hex_to_rgba(app_config["color_primary"], 0.1)};
            backdrop-filter: blur(10px);
            color: {app_config["color_secondary"]};
            border: 2px solid rgba{hex_to_rgba(app_config["color_primary"], 0.3)};
        }}

        .btn-secondary:hover {{
            background: rgba{hex_to_rgba(app_config["color_primary"], 0.2)};
            border-color: rgba{hex_to_rgba(app_config["color_primary"], 0.5)};
            transform: translateY(-3px);
        }}

        .spatial-pillars {{
            padding: 100px 20px;
            position: relative;
        }}

        .spatial-pillars h2 {{
            text-align: center;
            font-size: 52px;
            font-weight: 800;
            color: #ffffff;
            margin-bottom: 20px;
            letter-spacing: -1px;
        }}

        .spatial-subtitle {{
            text-align: center;
            font-size: 22px;
            color: #9388db;
            margin-bottom: 80px;
            font-weight: 300;
        }}

        .pillars-grid {{
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(320px, 1fr));
            gap: 40px;
            margin-bottom: 80px;
        }}

        .pillar-card {{
            background: rgba(30, 27, 75, 0.4);
            backdrop-filter: blur(20px);
            padding: 48px;
            border-radius: 24px;
            border: 1px solid rgba{hex_to_rgba(app_config["color_primary"], 0.2)};
            box-shadow:
                0 8px 32px rgba(0, 0, 0, 0.3),
                inset 0 1px 0 rgba(255, 255, 255, 0.05);
            transition: all 0.4s cubic-bezier(0.4, 0, 0.2, 1);
            position: relative;
            overflow: hidden;
        }}

        .pillar-card::before {{
            content: '';
            position: absolute;
            top: -50%;
            left: -50%;
            width: 200%;
            height: 200%;
            background: radial-gradient(circle, rgba{hex_to_rgba(app_config["color_primary"], 0.1)} 0%, transparent 70%);
            opacity: 0;
            transition: opacity 0.4s;
        }}

        .pillar-card:hover {{
            transform: translateY(-8px) scale(1.02);
            border-color: rgba{hex_to_rgba(app_config["color_primary"], 0.4)};
            box-shadow:
                0 16px 48px rgba{hex_to_rgba(app_config["color_primary"], 0.3)},
                inset 0 1px 0 rgba(255, 255, 255, 0.1);
        }}

        .pillar-card:hover::before {{
            opacity: 1;
        }}

        .pillar-icon {{
            width: 70px;
            height: 70px;
            background: linear-gradient(135deg, rgba{hex_to_rgba(app_config["color_primary"], 0.3)} 0%, rgba{hex_to_rgba(app_config["color_secondary"], 0.2)} 100%);
            backdrop-filter: blur(10px);
            border: 1px solid rgba{hex_to_rgba(app_config["color_primary"], 0.3)};
            border-radius: 18px;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 32px;
            margin-bottom: 28px;
            box-shadow: 0 8px 24px rgba{hex_to_rgba(app_config["color_primary"], 0.2)};
        }}

        .pillar-card h3 {{
            font-size: 26px;
            margin-bottom: 16px;
            color: {app_config["color_secondary"]};
            font-weight: 700;
            letter-spacing: -0.5px;
        }}

        .pillar-card p {{
            color: #b5a3e8;
            line-height: 1.8;
            font-size: 17px;
            font-weight: 300;
        }}

        .experience-section {{
            padding: 100px 20px;
            background: linear-gradient(135deg, rgba(30, 27, 75, 0.3) 0%, rgba(76, 29, 149, 0.2) 100%);
            backdrop-filter: blur(20px);
            border-radius: 32px;
            margin: 60px 0;
            border: 1px solid rgba{hex_to_rgba(app_config["color_primary"], 0.2)};
        }}

        .experience-section h2 {{
            text-align: center;
            font-size: 52px;
            font-weight: 800;
            color: #ffffff;
            margin-bottom: 80px;
            letter-spacing: -1px;
        }}

        .experience-grid {{
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(280px, 1fr));
            gap: 36px;
            max-width: 1200px;
            margin: 0 auto;
        }}

        .experience-item {{
            text-align: center;
        }}

        .experience-frame {{
            background: rgba(55, 48, 163, 0.3);
            backdrop-filter: blur(15px);
            border-radius: 24px;
            padding: 24px;
            aspect-ratio: 16 / 9;
            display: flex;
            align-items: center;
            justify-content: center;
            box-shadow:
                0 12px 40px rgba(0, 0, 0, 0.4),
                inset 0 1px 0 rgba(255, 255, 255, 0.1);
            margin-bottom: 20px;
            border: 2px solid rgba{hex_to_rgba(app_config["color_primary"], 0.25)};
            transition: all 0.4s cubic-bezier(0.4, 0, 0.2, 1);
        }}

        .experience-frame:hover {{
            transform: translateY(-6px);
            border-color: rgba{hex_to_rgba(app_config["color_primary"], 0.5)};
            box-shadow:
                0 20px 60px rgba{hex_to_rgba(app_config["color_primary"], 0.3)},
                inset 0 1px 0 rgba(255, 255, 255, 0.15);
        }}

        .experience-placeholder {{
            width: 100%;
            height: 100%;
            background: linear-gradient(135deg, rgba(30, 27, 75, 0.6) 0%, rgba(49, 46, 129, 0.4) 100%);
            border-radius: 16px;
            display: flex;
            align-items: center;
            justify-content: center;
            color: {app_config["color_primary"]};
            font-size: 56px;
            font-weight: 200;
        }}

        .experience-label {{
            color: #ddd6fe;
            font-size: 18px;
            font-weight: 600;
            letter-spacing: -0.3px;
        }}

        footer {{
            text-align: center;
            padding: 80px 20px 60px;
            color: #9388db;
        }}

        footer p {{
            margin-bottom: 24px;
            font-size: 17px;
            font-weight: 300;
        }}

        .footer-links {{
            display: flex;
            gap: 40px;
            justify-content: center;
            flex-wrap: wrap;
            margin-top: 40px;
        }}

        .footer-links a {{
            color: {app_config["color_secondary"]};
            text-decoration: none;
            font-size: 17px;
            font-weight: 500;
            transition: all 0.3s;
        }}

        .footer-links a:hover {{
            color: #ffffff;
        }}

        @media (max-width: 768px) {{
            h1 {{
                font-size: 44px;
            }}

            .tagline {{
                font-size: 22px;
            }}

            .spatial-pillars h2,
            .experience-section h2 {{
                font-size: 36px;
            }}

            .btn {{
                padding: 16px 36px;
                font-size: 16px;
            }}

            .pillar-card {{
                padding: 36px;
            }}
        }}
    </style>
</head>
<body>
    <div class="bg-layer bg-layer-1"></div>
    <div class="bg-layer bg-layer-2"></div>
    <div class="bg-layer bg-layer-3"></div>

    <div class="container">
        <header>
            <div class="hero-badge">Build for Apple Vision Pro</div>
            <div class="logo-container">
                <div class="logo-icon">{app_config["logo"]}</div>
            </div>
            <h1>{app_config["title"]}</h1>
            <p class="tagline">{app_config["tagline"]}</p>
            <p class="spatial-message">
                {app_config["spatial_message"]}
            </p>
            <div class="cta-buttons">
                <a href="#" class="btn btn-primary">
                    <span>Download for Vision Pro</span>
                </a>
                <a href="#features" class="btn btn-secondary">
                    <span>Explore Spatial Features</span>
                </a>
            </div>
        </header>

        <section class="spatial-pillars" id="features">
            <h2>Spatial Computing Reimagined</h2>
            <p class="spatial-subtitle">Five pillars of immersive spatial experience</p>

            <div class="pillars-grid">{pillars_html}
            </div>
        </section>

        <section class="experience-section">
            <h2>Experience in Spatial Reality</h2>
            <div class="experience-grid">
                <div class="experience-item">
                    <div class="experience-frame">
                        <div class="experience-placeholder">∞</div>
                    </div>
                    <div class="experience-label">Spatial View</div>
                </div>

                <div class="experience-item">
                    <div class="experience-frame">
                        <div class="experience-placeholder">◇</div>
                    </div>
                    <div class="experience-label">Gesture Control</div>
                </div>

                <div class="experience-item">
                    <div class="experience-frame">
                        <div class="experience-placeholder">⚡</div>
                    </div>
                    <div class="experience-label">Real-Time</div>
                </div>

                <div class="experience-item">
                    <div class="experience-frame">
                        <div class="experience-placeholder">🌊</div>
                    </div>
                    <div class="experience-label">Immersive Mode</div>
                </div>
            </div>
        </section>

        <footer>
            <p>{app_config["title"]} — Spatial Computing for Vision Pro</p>
            <p>&copy; 2024 {app_config["title"]}. Designed for the spatial computing era.</p>
            <div class="footer-links">
                <a href="#">Privacy Policy</a>
                <a href="#">Documentation</a>
                <a href="#">Developer API</a>
                <a href="#">Support</a>
            </div>
        </footer>
    </div>
</body>
</html>'''

    return html

def main():
    base_dir = "/Users/aakashnigam/Axion/AxionApps/visionOS"

    for app in APPS:
        print(f"Generating landing page for {app['title']}...")

        # Generate HTML
        html_content = generate_landing_page(app)

        # Write to docs/index.html
        docs_path = os.path.join(base_dir, app["dir"], "docs", "index.html")
        os.makedirs(os.path.dirname(docs_path), exist_ok=True)
        with open(docs_path, 'w') as f:
            f.write(html_content)

        # Copy to landing-page/index.html
        landing_path = os.path.join(base_dir, app["dir"], "landing-page", "index.html")
        os.makedirs(os.path.dirname(landing_path), exist_ok=True)
        shutil.copy(docs_path, landing_path)

        print(f"  ✓ Created {docs_path}")
        print(f"  ✓ Created {landing_path}")

    print(f"\nSuccessfully generated {len(APPS)} landing pages!")

if __name__ == "__main__":
    main()
