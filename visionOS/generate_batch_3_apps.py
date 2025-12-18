#!/usr/bin/env python3
"""
Generate Batch 3 visionOS landing pages with spatial computing design
Apps: AI Agent Coordinator, Retail Space Optimizer, Surgical Training Universe,
      Supply Chain Control Tower, Smart Agriculture
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
        "dir": "visionOS_ai-agent-coordinator",
        "title": "AI Agent Coordinator",
        "logo": "AC",
        "color_primary": "#a855f7",  # Purple for AI orchestration
        "tagline": "Orchestrate AI Agents in Spatial 3D",
        "spatial_message": "Visualize and control multiple AI agents working together in a spatial command center. See task flows, agent interactions, and workflow orchestration in immersive 3D space designed for Apple Vision Pro.",
        "pillars": [
            ("🤖", "Spatial Agent Map", "Visualize all AI agents and their relationships in 3D space with real-time status and task assignment"),
            ("🔄", "Workflow Orchestration", "Design and manage complex multi-agent workflows with spatial drag-and-drop interface"),
            ("📊", "Real-Time Monitoring", "Track agent performance, task completion, and resource usage across spatial dashboards"),
            ("🎯", "Gesture Control", "Direct agents and assign tasks using natural hand gestures in Vision Pro's spatial interface"),
            ("🔗", "Agent Collaboration", "Visualize how agents communicate and share data in immersive collaborative networks")
        ]
    },
    {
        "dir": "visionOS_retail-space-optimizer",
        "title": "Retail Space Optimizer",
        "logo": "RS",
        "color_primary": "#ec4899",  # Pink for retail
        "tagline": "Design Retail Layouts in Spatial Reality",
        "spatial_message": "Plan and optimize retail store layouts in true-to-scale 3D space. Walk through virtual store designs, test product placements, and analyze customer flow patterns before physical implementation.",
        "pillars": [
            ("🏪", "1:1 Store Layouts", "Create and walk through full-scale retail environments with accurate product placement and fixtures"),
            ("📍", "Product Placement", "Test different merchandising strategies by moving products in 3D space with spatial precision"),
            ("🚶", "Customer Flow Analysis", "Visualize heat maps and traffic patterns in 3D to optimize store navigation and conversions"),
            ("💡", "Lighting Simulation", "Preview how different lighting schemes affect product displays in realistic spatial environments"),
            ("📐", "Space Utilization", "Maximize revenue per square foot with spatial analytics and real-time optimization tools")
        ]
    },
    {
        "dir": "visionOS_surgical-training-universe",
        "title": "Surgical Training Universe",
        "logo": "ST",
        "color_primary": "#ef4444",  # Red for medical training
        "tagline": "Master Surgery in Immersive 3D Reality",
        "spatial_message": "Learn surgical procedures in a risk-free spatial environment. Practice techniques on anatomically accurate 3D models with haptic feedback and expert guidance in Vision Pro's immersive space.",
        "pillars": [
            ("🏥", "Realistic Anatomy", "Study and practice on photorealistic 3D anatomical models with accurate tissue properties and responses"),
            ("✂️", "Procedure Simulation", "Perform complete surgical procedures step-by-step with realistic instrument interaction and feedback"),
            ("👨‍⚕️", "Expert Mentorship", "Learn from recorded expert surgeons or collaborate live with mentors in shared spatial environments"),
            ("📹", "Record & Review", "Capture your procedures from multiple angles and review with AI-powered performance analysis"),
            ("🎯", "Skill Progression", "Track your surgical skills with detailed metrics and personalized training recommendations")
        ]
    },
    {
        "dir": "visionOS_supply-chain-control-tower",
        "title": "Supply Chain Control Tower",
        "logo": "SC",
        "color_primary": "#3b82f6",  # Blue for logistics
        "tagline": "Command Global Supply Chains in 3D Space",
        "spatial_message": "Monitor and manage your entire supply chain network in an immersive spatial control center. See shipments, inventory, and logistics flowing through a 3D global map with real-time updates.",
        "pillars": [
            ("🌍", "Global Network View", "Visualize your entire supply chain network across a 3D globe with real-time shipment tracking"),
            ("📦", "Inventory Management", "Monitor stock levels across warehouses with spatial inventory visualization and predictive analytics"),
            ("🚚", "Shipment Tracking", "Track all shipments in real-time with route optimization and delay prediction in 3D space"),
            ("⚠️", "Risk Monitoring", "Identify and respond to supply chain disruptions with spatial alert systems and contingency planning"),
            ("📊", "Performance Analytics", "Analyze KPIs across your network with immersive data visualization and trend analysis")
        ]
    },
    {
        "dir": "visionOS_smart-agriculture",
        "title": "Smart Agriculture Platform",
        "logo": "SA",
        "color_primary": "#84cc16",  # Lime green for agriculture
        "tagline": "Farm Management in Spatial Reality",
        "spatial_message": "Manage your entire farming operation in immersive 3D space. Visualize crop health, soil conditions, and equipment status across your fields with real-time IoT data and AI-powered insights.",
        "pillars": [
            ("🌾", "Field Mapping", "View detailed 3D maps of your fields with crop health, soil moisture, and growth stage visualization"),
            ("🚜", "Equipment Tracking", "Monitor all farm machinery in real-time with spatial positioning and maintenance scheduling"),
            ("💧", "Smart Irrigation", "Optimize water usage with 3D visualization of soil moisture and automated irrigation control"),
            ("🌡️", "Weather Integration", "Visualize weather patterns and forecasts spatially to plan farming operations effectively"),
            ("📈", "Yield Prediction", "Analyze historical data and current conditions to predict crop yields with AI-powered spatial analytics")
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
    """Generate landing pages for all apps in batch 3"""
    base_path = Path(__file__).parent

    for app_config in APPS:
        app_dir = base_path / app_config["dir"]

        print(f"Generating landing page for {app_config['title']}...")

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

    print(f"\nSuccessfully generated {len(APPS)} landing pages!")

if __name__ == "__main__":
    main()
