#!/usr/bin/env python3
"""
ENHANCED Gaming Landing Pages - First Principles Design
- Genre-specific badges and identity
- More vibrant colors and dramatic effects
- Action-focused language ("BATTLE", "CONQUER")
- Game metadata (players, intensity, modes)
- Gaming-specific sections (modes, progression, competitive)
"""

import os

def hex_to_rgba(hex_color, alpha):
    """Convert hex color to rgba tuple string"""
    hex_color = hex_color.lstrip('#')
    r = int(hex_color[0:2], 16)
    g = int(hex_color[2:4], 16)
    b = int(hex_color[4:6], 16)
    return f"({r}, {g}, {b}, {alpha})"

# Enhanced Gaming Apps with genre identity and metadata
GAMING_APPS = [
    # ACTION & COMBAT GAMES
    {
        "dir": "visionOS_Gaming_shadow-boxing-champions",
        "title": "Shadow Boxing Champions",
        "logo": "🥊",
        "genre": "ACTION SPORTS",
        "color_primary": "#ef4444",
        "tagline": "TRAIN LIKE A CHAMPION IN YOUR LIVING ROOM",
        "hero_message": "Transform your space into a professional boxing ring. AI tracks every punch, dodge, and combination with precision. Feel the burn as you unleash devastating combos in 360° spatial combat.",
        "player_count": "25K+",
        "rating": "4.8",
        "intensity": "High Intensity",
        "space_needed": "Standing Space",
        "modes": ["Story Campaign", "Quick Training", "AI Sparring", "Time Attack", "Daily Challenges"],
        "features": [
            ("🥊", "360° Combat Zone", "Your room becomes the ring with spatial boundary detection"),
            ("🎯", "AI Precision Tracking", "Real-time analysis of punch speed, accuracy, and form"),
            ("🏆", "Championship Training", "Professional programs from beginner to elite fighter"),
            ("👤", "Adaptive AI Opponents", "Spar against fighters that learn your style"),
            ("💪", "Fitness Analytics", "Track calories burned, combos landed, and skill progression"),
        ]
    },
    {
        "dir": "visionOS_Gaming_tactical-team-shooters",
        "title": "Tactical Team Shooters",
        "logo": "🎮",
        "genre": "TACTICAL FPS",
        "color_primary": "#dc2626",
        "tagline": "COMMAND YOUR SPACE IN TACTICAL WARFARE",
        "hero_message": "Turn your room into dynamic battlegrounds. Use real furniture as cover, coordinate with teammates through spatial audio, and dominate in competitive 5v5 tactical combat.",
        "player_count": "150K+",
        "rating": "4.9",
        "intensity": "Moderate",
        "space_needed": "Room-Scale",
        "modes": ["Ranked 5v5", "Casual Match", "Team Deathmatch", "Bomb Defusal", "Custom Games"],
        "features": [
            ("🎯", "Room-Scale Battlegrounds", "Your furniture becomes tactical cover positions"),
            ("👥", "Team Coordination", "Spatial audio and gesture-based team communication"),
            ("🗺️", "Adaptive Maps", "Procedural battlegrounds that fit your space perfectly"),
            ("⚔️", "Realistic Arsenal", "30+ weapons with spatial reloading mechanics"),
            ("🏅", "Competitive Ranks", "Climb from Bronze to Champion with skill-based matching"),
        ]
    },
    {
        "dir": "visionOS_Gaming_home-defense-strategy",
        "title": "Home Defense Strategy",
        "logo": "🏠",
        "genre": "TOWER DEFENSE",
        "color_primary": "#f97316",
        "tagline": "DEFEND YOUR ACTUAL HOME FROM VIRTUAL INVASION",
        "hero_message": "Place towers on your real furniture. Deploy traps using your actual room layout. Watch enemies navigate through YOUR doorways and around YOUR couch in this revolutionary spatial tower defense.",
        "player_count": "80K+",
        "rating": "4.7",
        "intensity": "Light",
        "space_needed": "Room-Scale",
        "modes": ["Campaign", "Endless Waves", "Challenge Mode", "Co-op Defense", "Custom Maps"],
        "features": [
            ("🏰", "Real Room Defense", "Your furniture becomes strategic defense positions"),
            ("🗼", "Spatial Tower Placement", "Deploy 40+ tower types on any surface"),
            ("👾", "Dynamic Enemy AI", "Waves that adapt to your room's layout"),
            ("⚡", "Power-Up Arsenal", "Spatial abilities and traps throughout your space"),
            ("📈", "Base Progression", "Unlock and upgrade defenses with each victory"),
        ]
    },
    {
        "dir": "visionOS_Gaming_spatial-arena-championship",
        "title": "Spatial Arena Championship",
        "logo": "⚔️",
        "genre": "COMPETITIVE SPORTS",
        "color_primary": "#ea580c",
        "tagline": "COMPETE IN SPATIAL SPORTS WORLDWIDE",
        "hero_message": "Master spatial accuracy in competitive championships. From disc golf to precision archery, compete globally in tournaments that test your physical skill and spatial awareness.",
        "player_count": "60K+",
        "rating": "4.6",
        "intensity": "Moderate",
        "space_needed": "Standing Space",
        "modes": ["Ranked Tournaments", "Quick Match", "Practice Range", "Daily Challenges", "Championships"],
        "features": [
            ("🎯", "Precision Sports Collection", "10+ spatial sports from disc golf to axe throwing"),
            ("🏆", "Global Tournaments", "Compete in weekly championships with cash prizes"),
            ("🎮", "Natural Gesture Controls", "Realistic throwing, swinging, and aiming physics"),
            ("📊", "Live Leaderboards", "Real-time global and regional rankings"),
            ("🌍", "Cross-Platform Competition", "Challenge players worldwide in spatial accuracy"),
        ]
    },

    # RPG & ADVENTURE GAMES
    {
        "dir": "visionOS_Gaming_reality-realms-rpg",
        "title": "Reality Realms RPG",
        "logo": "🗡️",
        "genre": "FANTASY RPG",
        "color_primary": "#8b5cf6",
        "tagline": "YOUR WORLD BECOMES A MAGICAL KINGDOM",
        "hero_message": "Explore epic fantasy realms layered over reality. Your neighborhood transforms into enchanted lands, furniture becomes treasure chests, and mystical creatures inhabit your space in this immersive RPG.",
        "player_count": "200K+",
        "rating": "4.9",
        "intensity": "Moderate",
        "space_needed": "Room-Scale",
        "modes": ["Story Campaign", "Free Roam", "Dungeons", "PvP Arena", "Guild Raids"],
        "features": [
            ("🗺️", "World Transformation", "Your environment becomes a living fantasy realm"),
            ("⚔️", "Gesture Combat System", "Cast spells and swing swords with natural movements"),
            ("🎒", "Spatial Loot System", "Discover legendary items hidden in your real space"),
            ("🧙", "Deep Progression", "Level up across 12 classes with 200+ abilities"),
            ("🐉", "Epic Quest Lines", "60+ hour story-driven campaign in your world"),
        ]
    },
    {
        "dir": "visionOS_Gaming_time-machine-adventures",
        "title": "Time Machine Adventures",
        "logo": "⏰",
        "genre": "ADVENTURE PUZZLE",
        "color_primary": "#7c3aed",
        "tagline": "TRAVEL THROUGH TIME IN YOUR ROOM",
        "hero_message": "Watch your room transform across historical eras. Solve temporal puzzles spanning ancient Egypt to distant futures. Experience history come alive in your physical space.",
        "player_count": "45K+",
        "rating": "4.8",
        "intensity": "Light",
        "space_needed": "Room-Scale",
        "modes": ["Story Mode", "Free Exploration", "Puzzle Challenges", "Educational Mode", "Time Trials"],
        "features": [
            ("⏳", "Era Transformation", "Experience 15 historical periods in your space"),
            ("🔍", "Temporal Puzzles", "Solve mysteries that span across time periods"),
            ("🏛️", "Living History", "Interactive historical figures and events"),
            ("📜", "Branching Narratives", "Your choices alter the timeline"),
            ("🎓", "Educational Content", "Learn history through immersive gameplay"),
        ]
    },
    {
        "dir": "visionOS_Gaming_mystery-investigation",
        "title": "Mystery Investigation",
        "logo": "🔍",
        "genre": "DETECTIVE MYSTERY",
        "color_primary": "#6366f1",
        "tagline": "SOLVE CRIMES IN YOUR OWN SPACE",
        "hero_message": "Your room becomes an interactive crime scene. Examine spatial clues, interrogate virtual suspects positioned around you, and piece together evidence to solve intricate mysteries.",
        "player_count": "70K+",
        "rating": "4.7",
        "intensity": "Light",
        "space_needed": "Room-Scale",
        "modes": ["Case Files", "Quick Solve", "Multiplayer Detective", "Custom Cases", "Daily Mystery"],
        "features": [
            ("🔎", "Crime Scene Analysis", "Your space transforms into interactive investigations"),
            ("🗂️", "Spatial Evidence Board", "Organize clues on your walls with gesture controls"),
            ("👤", "Virtual Interrogations", "Question suspects positioned in your room"),
            ("🧩", "Complex Cases", "50+ mysteries from simple theft to murder"),
            ("📚", "Detective Progression", "Unlock new investigation tools and abilities"),
        ]
    },
    {
        "dir": "visionOS_Gaming_escape-room-network",
        "title": "Escape Room Network",
        "logo": "🔐",
        "genre": "PUZZLE ESCAPE",
        "color_primary": "#3b82f6",
        "tagline": "TRANSFORM ANY ROOM INTO AN ESCAPE CHALLENGE",
        "hero_message": "Convert your physical space into intricate escape rooms. Solve spatial puzzles using your real environment, collaborate with friends, and race the clock to freedom.",
        "player_count": "120K+",
        "rating": "4.8",
        "intensity": "Light",
        "space_needed": "Room-Scale",
        "modes": ["Solo Escape", "Co-op 2-4 Players", "Competitive Race", "Daily Challenge", "Custom Rooms"],
        "features": [
            ("🗝️", "Room Transformation", "100+ themed escape rooms overlay your space"),
            ("🧩", "Spatial Puzzle Mechanics", "Interact with virtual objects on real surfaces"),
            ("👥", "Multiplayer Co-op", "Solve complex rooms with friends in shared space"),
            ("⏱️", "Timed Challenges", "Beat the clock with varying difficulty levels"),
            ("🎨", "Room Creator", "Design and share your own escape room challenges"),
        ]
    },

    # SIMULATION & BUILDING GAMES
    {
        "dir": "visionOS_Gaming_city-builder-tabletop",
        "title": "City Builder Tabletop",
        "logo": "🏙️",
        "genre": "CITY SIMULATION",
        "color_primary": "#10b981",
        "tagline": "BUILD LIVING CITIES ON YOUR TABLE",
        "hero_message": "Construct miniature metropolises on any flat surface. Watch tiny citizens live their lives, traffic flow through streets, and buildings rise from your table in stunning spatial 3D.",
        "player_count": "90K+",
        "rating": "4.9",
        "intensity": "Light",
        "space_needed": "Tabletop",
        "modes": ["Sandbox Mode", "Scenario Challenges", "Campaign", "Multiplayer Cities", "Disaster Mode"],
        "features": [
            ("🏗️", "Tabletop Construction", "Build massive cities on your desk or floor"),
            ("👥", "Living Citizens", "Watch 10,000+ AI citizens live and work"),
            ("💰", "Deep Economy", "Manage budgets, taxes, and resource chains"),
            ("🌆", "Dynamic Simulation", "Day/night cycles with realistic lighting"),
            ("📊", "City Analytics", "Track growth, happiness, traffic, and pollution"),
        ]
    },
    {
        "dir": "visionOS_Gaming_reality-minecraft",
        "title": "Reality Minecraft",
        "logo": "⛏️",
        "genre": "SANDBOX BUILDING",
        "color_primary": "#059669",
        "tagline": "MINE YOUR WALLS, BUILD IN YOUR SPACE",
        "hero_message": "Minecraft reimagined for spatial reality. Extract blocks from your environment, construct elaborate structures on furniture, and watch creations materialize in your actual room.",
        "player_count": "300K+",
        "rating": "4.9",
        "intensity": "Light",
        "space_needed": "Room-Scale",
        "modes": ["Survival", "Creative", "Adventure Maps", "Multiplayer Realms", "Mini-Games"],
        "features": [
            ("⛏️", "Spatial Mining", "Break and collect blocks from your real environment"),
            ("🏗️", "3D Building", "Construct on any surface with gesture controls"),
            ("🎒", "Full Inventory System", "Manage resources in spatial 3D interface"),
            ("🌍", "Infinite Worlds", "Generate endless terrain within your space"),
            ("👥", "Multiplayer Building", "Create together in shared physical spaces"),
        ]
    },
    {
        "dir": "visionOS_Gaming_virtual-pet-ecosystem",
        "title": "Virtual Pet Ecosystem",
        "logo": "🐾",
        "genre": "LIFE SIMULATION",
        "color_primary": "#14b8a6",
        "tagline": "RAISE CREATURES THAT LIVE IN YOUR ROOM",
        "hero_message": "Adopt virtual pets that truly inhabit your space. Watch them play on your furniture, sleep in corners, and interact with your environment as if they were really there.",
        "player_count": "180K+",
        "rating": "4.8",
        "intensity": "Light",
        "space_needed": "Room-Scale",
        "modes": ["Free Play", "Pet Challenges", "Breeding Lab", "Mini-Games", "Social Visits"],
        "features": [
            ("🐕", "Realistic Pet Care", "Feed, play, train, and bond with virtual creatures"),
            ("🏠", "Room Integration", "Pets interact naturally with your real furniture"),
            ("🧬", "Genetic Breeding", "Discover 500+ species through genetics"),
            ("🎮", "Interactive Games", "Fetch, hide-and-seek, agility training"),
            ("👥", "Social Pet Network", "Visit friends with your pets in their spaces"),
        ]
    },
    {
        "dir": "visionOS_Gaming_science-lab-sandbox",
        "title": "Science Lab Sandbox",
        "logo": "🔬",
        "genre": "EDUCATIONAL SANDBOX",
        "color_primary": "#0d9488",
        "tagline": "EXPERIMENT WITH PHYSICS IN YOUR SPACE",
        "hero_message": "Transform your room into a physics playground. Build Rube Goldberg machines on real surfaces, conduct chemistry experiments, and watch realistic simulations unfold in your environment.",
        "player_count": "55K+",
        "rating": "4.7",
        "intensity": "Light",
        "space_needed": "Room-Scale",
        "modes": ["Free Experiment", "Guided Labs", "Challenges", "Educational Curriculum", "Creative Mode"],
        "features": [
            ("⚗️", "Realistic Physics", "Accurate gravity, momentum, and collision simulation"),
            ("🧪", "Safe Experiments", "Chemistry and physics labs without real danger"),
            ("🛠️", "Building Tools", "Construct complex machines on your furniture"),
            ("📚", "STEM Learning", "Aligned with educational standards"),
            ("🎨", "Creative Sandbox", "Unlimited resources for experimentation"),
        ]
    },

    # RHYTHM & MUSIC GAMES
    {
        "dir": "visionOS_Gaming_rhythm-flow",
        "title": "Rhythm Flow",
        "logo": "🎵",
        "genre": "RHYTHM ACTION",
        "color_primary": "#ec4899",
        "tagline": "MUSIC FLOWS THROUGH YOUR SPACE",
        "hero_message": "Feel the music surround you in 360°. Notes cascade from all directions as you tap, slice, and dodge to the beat. Master rhythm in full spatial audio precision.",
        "player_count": "220K+",
        "rating": "4.9",
        "intensity": "Moderate",
        "space_needed": "Standing Space",
        "modes": ["Song Library", "Ranked Play", "Party Mode", "Daily Challenges", "Custom Songs"],
        "features": [
            ("🎶", "360° Rhythm Gameplay", "Notes flow from all directions around you"),
            ("🎯", "Precision Tracking", "Millimeter-accurate hand tracking for rhythm"),
            ("🎼", "Massive Song Library", "1,000+ licensed tracks across all genres"),
            ("🎨", "Reactive Visuals", "Stunning particle effects sync to every beat"),
            ("🏆", "Global Competition", "Compete on worldwide leaderboards"),
        ]
    },
    {
        "dir": "visionOS_Gaming_spatial-music-studio",
        "title": "Spatial Music Studio",
        "logo": "🎹",
        "genre": "MUSIC CREATION",
        "color_primary": "#db2777",
        "tagline": "PRODUCE MUSIC IN 3D SPACE",
        "hero_message": "Arrange instruments in 3D around you. Create music by positioning sounds spatially and conducting with natural gestures. The future of music production is spatial.",
        "player_count": "35K+",
        "rating": "4.8",
        "intensity": "Light",
        "space_needed": "Room-Scale",
        "modes": ["Free Jam", "Beat Making", "Live Performance", "Tutorial Lessons", "Collaboration"],
        "features": [
            ("🎹", "Spatial Instruments", "50+ instruments positioned in your room"),
            ("🎚️", "3D Audio Mixing", "Mix by arranging sounds spatially"),
            ("👋", "Gesture Conducting", "Control tempo and dynamics with movements"),
            ("🎵", "Loop Stations", "Layer compositions in real-time"),
            ("💾", "Export & Share", "Professional audio export and community"),
        ]
    },
    {
        "dir": "visionOS_Gaming_spatial-pictionary",
        "title": "Spatial Pictionary",
        "logo": "🎨",
        "genre": "PARTY GAME",
        "color_primary": "#a855f7",
        "tagline": "DRAW IN 3D FOR FRIENDS TO GUESS",
        "hero_message": "Sculpt in mid-air while friends guess your creation. Rotate, scale, and shape 3D drawings using gestures in this hilarious spatial party game.",
        "player_count": "75K+",
        "rating": "4.7",
        "intensity": "Light",
        "space_needed": "Standing Space",
        "modes": ["Quick Play", "Team Battle", "Custom Prompts", "Kids Mode", "Time Attack"],
        "features": [
            ("✏️", "3D Air Sculpting", "Draw in three dimensions with hand tracking"),
            ("👥", "Local & Remote Play", "8 players locally or globally"),
            ("🎭", "Thousands of Prompts", "Animals, objects, movies, and custom lists"),
            ("⏱️", "Fast-Paced Rounds", "30-90 second drawing challenges"),
            ("🏆", "Team Scoring", "Compete for points and laughs"),
        ]
    },

    # STORY & THEATER GAMES
    {
        "dir": "visionOS_Gaming_narrative-story-worlds",
        "title": "Narrative Story Worlds",
        "logo": "📖",
        "genre": "INTERACTIVE STORY",
        "color_primary": "#f59e0b",
        "tagline": "LIVE INSIDE INTERACTIVE STORIES",
        "hero_message": "Stories unfold around you in spatial 3D. Make choices that shape narratives, interact with characters positioned in your space, and experience branching storylines.",
        "player_count": "65K+",
        "rating": "4.8",
        "intensity": "Light",
        "space_needed": "Room-Scale",
        "modes": ["Story Campaigns", "Free Choice", "Quick Tales", "Community Stories", "Creator Mode"],
        "features": [
            ("📚", "Branching Narratives", "Your choices create unique story paths"),
            ("👤", "Lifelike Characters", "AI-driven characters positioned in your room"),
            ("🎭", "Multiple Genres", "Fantasy, sci-fi, mystery, romance, and more"),
            ("🗣️", "Voice Interaction", "Speak naturally to characters"),
            ("🎬", "Story Creator Tools", "Write and publish your own interactive tales"),
        ]
    },
    {
        "dir": "visionOS_Gaming_interactive-theater",
        "title": "Interactive Theater",
        "logo": "🎭",
        "genre": "THEATRICAL EXPERIENCE",
        "color_primary": "#d97706",
        "tagline": "BE PART OF THE PERFORMANCE",
        "hero_message": "Theatrical performances happen around you. Participate in plays, influence outcomes, and experience stories where you're both audience and actor in spatial theater.",
        "player_count": "40K+",
        "rating": "4.9",
        "intensity": "Light",
        "space_needed": "Room-Scale",
        "modes": ["Classic Plays", "Original Works", "Improv Sessions", "Kids Theater", "Social Watch"],
        "features": [
            ("🎬", "AI-Driven Performances", "Characters perform dynamically around you"),
            ("🗣️", "Audience Participation", "Influence the story through interaction"),
            ("🎨", "Set Transformations", "Your room becomes elaborate theatrical sets"),
            ("📜", "Extensive Library", "Shakespeare to Broadway to original works"),
            ("👥", "Social Viewing", "Watch performances together with friends"),
        ]
    },
    {
        "dir": "visionOS_Gaming_myspatial-life",
        "title": "MySpatial Life",
        "logo": "🌟",
        "genre": "LIFE SIMULATION",
        "color_primary": "#eab308",
        "tagline": "LIVE A VIRTUAL LIFE IN YOUR REAL SPACE",
        "hero_message": "Your room becomes your character's home. Develop skills, build relationships, pursue careers, and live a virtual life overlaid on your real world in this spatial life sim.",
        "player_count": "140K+",
        "rating": "4.8",
        "intensity": "Light",
        "space_needed": "Room-Scale",
        "modes": ["Free Life", "Career Mode", "Relationship Focus", "Social Visits", "Challenges"],
        "features": [
            ("🏠", "Home Living", "Your real room is your character's living space"),
            ("👤", "Deep Character Development", "Skills, careers, hobbies, relationships"),
            ("🛋️", "Furniture Interactions", "Real furniture becomes functional objects"),
            ("👥", "Social Network", "Friends visit your space with their characters"),
            ("🎯", "Life Achievements", "Complete milestones and life goals"),
        ]
    },

    # BOARD & TABLETOP GAMES
    {
        "dir": "visionOS_Gaming_holographic-board-games",
        "title": "Holographic Board Games",
        "logo": "🎲",
        "genre": "BOARD GAMES",
        "color_primary": "#22c55e",
        "tagline": "CLASSIC BOARD GAMES COME TO LIFE",
        "hero_message": "Play on any surface with 3D animated pieces. Chess knights battle in slow-motion, Monopoly buildings rise from the board, and cards float in mid-air in spectacular 3D.",
        "player_count": "95K+",
        "rating": "4.7",
        "intensity": "Light",
        "space_needed": "Tabletop",
        "modes": ["Local Play", "Online Match", "AI Opponents", "Tournaments", "Custom Rules"],
        "features": [
            ("♟️", "Animated Game Pieces", "3D animated pieces with spectacular effects"),
            ("🎮", "50+ Classic Games", "Chess, Monopoly, Scrabble, and more"),
            ("👥", "Cross-Platform Play", "Local or worldwide opponents"),
            ("🎨", "Premium Themes", "Unlock beautiful visual themes for each game"),
            ("🏆", "Competitive Ladder", "Ranked matches and tournaments"),
        ]
    },
    {
        "dir": "visionOS_Gaming_arena-esports",
        "title": "Arena eSports",
        "logo": "🏆",
        "genre": "COMPETITIVE ESPORTS",
        "color_primary": "#16a34a",
        "tagline": "COMPETE IN SPATIAL ESPORTS TOURNAMENTS",
        "hero_message": "Master spatial skills in competitive tournaments. From precision aiming to strategic puzzles, climb the ranks and compete for cash prizes in the future of eSports.",
        "player_count": "175K+",
        "rating": "4.9",
        "intensity": "High",
        "space_needed": "Room-Scale",
        "modes": ["Ranked Match", "Tournament Brackets", "Practice Mode", "Scrims", "Championships"],
        "features": [
            ("⚔️", "Multiple Game Modes", "10+ competitive spatial game types"),
            ("🏅", "Global Rankings", "ELO-based ranking system"),
            ("🎮", "Professional Tournaments", "Weekly events with prize pools"),
            ("📊", "Advanced Analytics", "Replay system and performance stats"),
            ("👥", "Team Management", "Form teams and compete in leagues"),
        ]
    },
    {
        "dir": "visionOS_Gaming_hide-and-seek-evolved",
        "title": "Hide and Seek Evolved",
        "logo": "👁️",
        "genre": "CASUAL MULTIPLAYER",
        "color_primary": "#84cc16",
        "tagline": "HIDE AND SEEK WITH AR OBJECTS",
        "hero_message": "Virtual objects hide throughout your real space. Use spatial awareness to find hidden items or hide your own for others to discover in this addictive AR game.",
        "player_count": "110K+",
        "rating": "4.6",
        "intensity": "Light",
        "space_needed": "Room-Scale",
        "modes": ["Quick Hunt", "Competitive Race", "Hide Mode", "Daily Challenge", "Community Maps"],
        "features": [
            ("🔍", "Spatial Object Hiding", "Hide virtual items anywhere in your space"),
            ("👥", "Async Multiplayer", "Create hunts for friends to find later"),
            ("🎯", "Difficulty Tiers", "From obvious to expertly camouflaged"),
            ("⏱️", "Timed Races", "Compete for fastest find times"),
            ("🏆", "Daily Hunts", "New community challenges every day"),
        ]
    },

    # EXPLORATION & PARKOUR GAMES
    {
        "dir": "visionOS_Gaming_parkour-pathways",
        "title": "Parkour Pathways",
        "logo": "🏃",
        "genre": "PARKOUR ACTION",
        "color_primary": "#06b6d4",
        "tagline": "NAVIGATE OBSTACLE COURSES IN YOUR ROOM",
        "hero_message": "Your room transforms into death-defying parkour courses. Jump virtual platforms, dodge obstacles, and pull off acrobatic moves as you race through 3D paths.",
        "player_count": "85K+",
        "rating": "4.7",
        "intensity": "High",
        "space_needed": "Room-Scale",
        "modes": ["Time Trials", "Endless Run", "Challenge Courses", "Multiplayer Race", "Course Creator"],
        "features": [
            ("🏃", "Dynamic Course Generation", "Courses adapt to your room layout"),
            ("🎯", "Precision Movement", "Jump, climb, slide with gesture controls"),
            ("⏱️", "Global Time Trials", "Compete for world record times"),
            ("🏆", "Course Sharing", "Create and share custom parkour challenges"),
            ("👥", "Ghost Racing", "Race against friends' ghost recordings"),
        ]
    },
    {
        "dir": "visionOS_Gaming_reality-mmo-layer",
        "title": "Reality MMO Layer",
        "logo": "🌍",
        "genre": "SPATIAL MMO",
        "color_primary": "#0891b2",
        "tagline": "PERSISTENT MMO OVERLAID ON REALITY",
        "hero_message": "Join a persistent MMO world layered over the real world. See other players in shared spaces, collect resources from locations, and build in the spatial metaverse.",
        "player_count": "250K+",
        "rating": "4.8",
        "intensity": "Moderate",
        "space_needed": "Room-Scale",
        "modes": ["Open World", "Dungeons", "PvP Zones", "Guild Wars", "Events"],
        "features": [
            ("🌐", "Persistent World", "Shared MMO across real-world locations"),
            ("👥", "See Other Players", "Real-time multiplayer in physical spaces"),
            ("🎒", "Resource Gathering", "Collect items from real-world locations"),
            ("🏰", "Territory Control", "Guilds claim and defend real areas"),
            ("⚔️", "PvP & PvE Combat", "Battle players and monsters in your space"),
        ]
    },
    {
        "dir": "visionOS_Gaming_mindfulness-meditation-realms",
        "title": "Mindfulness Meditation Realms",
        "logo": "🧘",
        "genre": "WELLNESS EXPERIENCE",
        "color_primary": "#0e7490",
        "tagline": "MEDITATE IN TRANSFORMATIVE ENVIRONMENTS",
        "hero_message": "Transform your space into peaceful meditation realms. From zen gardens to cosmic voids, practice mindfulness in immersive 3D environments with guided sessions.",
        "player_count": "130K+",
        "rating": "4.9",
        "intensity": "Light",
        "space_needed": "Seated/Standing",
        "modes": ["Guided Meditation", "Free Meditation", "Breathing Exercises", "Sleep Mode", "Mindful Movement"],
        "features": [
            ("🌸", "Beautiful Realms", "20+ peaceful environments for meditation"),
            ("🎵", "Spatial Audio", "Calming 3D soundscapes"),
            ("🧘", "Expert Guidance", "Programs from meditation masters"),
            ("📊", "Mindfulness Tracking", "Monitor streaks and progress"),
            ("🎨", "Custom Environments", "Create your own peaceful spaces"),
        ]
    },
]

def generate_enhanced_html(app):
    """Generate enhanced gaming HTML with dramatic effects"""
    # More saturated color values for gaming
    color_rgb_30 = hex_to_rgba(app['color_primary'], 0.3)
    color_rgb_40 = hex_to_rgba(app['color_primary'], 0.4)
    color_rgb_50 = hex_to_rgba(app['color_primary'], 0.5)

    # Build features HTML
    features_html = ""
    for icon, title, description in app['features']:
        features_html += f"""                <div class="feature-card">
                    <div class="feature-icon">{icon}</div>
                    <h3>{title}</h3>
                    <p>{description}</p>
                </div>
"""

    # Build modes HTML
    modes_html = ""
    for mode in app['modes']:
        modes_html += f'                <div class="mode-badge">{mode}</div>\n'

    html = f"""<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>{app['title']} - {app['genre']} for Vision Pro</title>
    <style>
        * {{
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }}

        body {{
            font-family: -apple-system, BlinkMacSystemFont, 'SF Pro Display', 'Segoe UI', sans-serif;
            background: #000000;
            color: #ffffff;
            overflow-x: hidden;
        }}

        /* Enhanced 3D Depth Layers - More dramatic */
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
            background: radial-gradient(circle at 20% 30%, rgba{color_rgb_40} 0%, transparent 40%);
            animation: dramaticFloat 15s ease-in-out infinite;
        }}

        .depth-layer-2 {{
            background: radial-gradient(circle at 80% 70%, rgba{color_rgb_50} 0%, transparent 40%);
            animation: dramaticFloat 18s ease-in-out infinite reverse;
        }}

        .depth-layer-3 {{
            background: radial-gradient(circle at 50% 50%, rgba{color_rgb_30} 0%, transparent 50%);
            animation: dramaticFloat 22s ease-in-out infinite;
        }}

        @keyframes dramaticFloat {{
            0%, 100% {{ transform: translate(0, 0) rotate(0deg) scale(1); }}
            33% {{ transform: translate(40px, -40px) rotate(8deg) scale(1.05); }}
            66% {{ transform: translate(-30px, 30px) rotate(-8deg) scale(0.95); }}
        }}

        /* Pulsing glow effect */
        @keyframes pulseGlow {{
            0%, 100% {{ box-shadow: 0 0 30px rgba{color_rgb_40}, 0 0 60px rgba{color_rgb_30}; }}
            50% {{ box-shadow: 0 0 50px rgba{color_rgb_50}, 0 0 100px rgba{color_rgb_40}; }}
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
            padding: 60px 20px 60px;
            position: relative;
        }}

        .genre-badge {{
            display: inline-block;
            background: linear-gradient(135deg, {app['color_primary']} 0%, {app['color_primary']}cc 100%);
            padding: 10px 24px;
            border-radius: 24px;
            font-size: 13px;
            font-weight: 800;
            letter-spacing: 2px;
            margin-bottom: 30px;
            text-transform: uppercase;
            box-shadow: 0 8px 32px rgba{color_rgb_50};
            animation: pulseGlow 3s ease-in-out infinite;
        }}

        .logo-container {{
            margin-bottom: 30px;
            perspective: 1200px;
        }}

        .logo-icon {{
            display: inline-flex;
            align-items: center;
            justify-content: center;
            width: 140px;
            height: 140px;
            background: rgba(15, 15, 30, 0.6);
            backdrop-filter: blur(20px);
            -webkit-backdrop-filter: blur(20px);
            border: 3px solid {app['color_primary']};
            border-radius: 32px;
            font-size: 72px;
            box-shadow:
                0 25px 70px rgba(0, 0, 0, 0.5),
                0 0 40px rgba{color_rgb_40},
                inset 0 1px 0 rgba(255, 255, 255, 0.15);
            transform-style: preserve-3d;
            animation: logoFloat 4s ease-in-out infinite;
        }}

        @keyframes logoFloat {{
            0%, 100% {{ transform: rotateY(0deg) rotateX(0deg) translateY(0); }}
            50% {{ transform: rotateY(15deg) rotateX(8deg) translateY(-10px); }}
        }}

        h1 {{
            font-size: 72px;
            font-weight: 900;
            margin-bottom: 20px;
            background: linear-gradient(135deg, #ffffff 0%, {app['color_primary']} 100%);
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
            background-clip: text;
            line-height: 1.1;
            text-transform: uppercase;
            letter-spacing: -2px;
        }}

        .tagline {{
            font-size: 32px;
            color: {app['color_primary']};
            margin-bottom: 30px;
            font-weight: 700;
            text-transform: uppercase;
            letter-spacing: 1px;
            text-shadow: 0 0 20px rgba{color_rgb_40};
        }}

        .hero-message {{
            font-size: 19px;
            color: rgba(255, 255, 255, 0.85);
            max-width: 900px;
            margin: 0 auto 50px;
            line-height: 1.7;
        }}

        /* Game Metadata Bar */
        .game-metadata {{
            display: flex;
            justify-content: center;
            gap: 40px;
            flex-wrap: wrap;
            padding: 30px;
            background: rgba(15, 15, 30, 0.4);
            border: 1px solid rgba{color_rgb_30};
            border-radius: 20px;
            margin-bottom: 50px;
            backdrop-filter: blur(10px);
        }}

        .metadata-item {{
            text-align: center;
        }}

        .metadata-value {{
            font-size: 28px;
            font-weight: 800;
            color: {app['color_primary']};
            display: block;
        }}

        .metadata-label {{
            font-size: 13px;
            color: rgba(255, 255, 255, 0.6);
            text-transform: uppercase;
            letter-spacing: 1px;
        }}

        /* CTA Buttons */
        .cta-buttons {{
            display: flex;
            gap: 20px;
            justify-content: center;
            margin-bottom: 40px;
        }}

        .cta-primary {{
            background: {app['color_primary']};
            color: #ffffff;
            padding: 20px 60px;
            border-radius: 14px;
            text-decoration: none;
            font-size: 20px;
            font-weight: 700;
            transition: all 0.3s ease;
            box-shadow: 0 15px 50px rgba{color_rgb_50};
            border: 2px solid {app['color_primary']};
            text-transform: uppercase;
            letter-spacing: 1px;
        }}

        .cta-primary:hover {{
            transform: translateY(-3px) scale(1.02);
            box-shadow: 0 20px 60px rgba{color_rgb_50};
        }}

        .cta-secondary {{
            background: transparent;
            color: {app['color_primary']};
            padding: 20px 60px;
            border-radius: 14px;
            text-decoration: none;
            font-size: 20px;
            font-weight: 700;
            border: 2px solid {app['color_primary']};
            transition: all 0.3s ease;
        }}

        .cta-secondary:hover {{
            background: rgba{color_rgb_30};
            transform: translateY(-3px);
        }}

        /* Section Styling */
        .section {{
            margin: 100px 0;
        }}

        .section-title {{
            font-size: 48px;
            font-weight: 800;
            text-align: center;
            margin-bottom: 60px;
            text-transform: uppercase;
            letter-spacing: -1px;
            background: linear-gradient(135deg, #ffffff 0%, {app['color_primary']} 100%);
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
            background-clip: text;
        }}

        /* Game Modes */
        .modes-grid {{
            display: flex;
            gap: 15px;
            justify-content: center;
            flex-wrap: wrap;
            margin-bottom: 60px;
        }}

        .mode-badge {{
            background: rgba(15, 15, 30, 0.5);
            border: 2px solid rgba{color_rgb_30};
            padding: 12px 28px;
            border-radius: 30px;
            font-size: 16px;
            font-weight: 600;
            color: rgba(255, 255, 255, 0.9);
            transition: all 0.3s ease;
        }}

        .mode-badge:hover {{
            background: rgba{color_rgb_30};
            border-color: {app['color_primary']};
            transform: translateY(-2px);
        }}

        /* Features Grid */
        .features-grid {{
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(350px, 1fr));
            gap: 30px;
            margin-bottom: 60px;
        }}

        .feature-card {{
            background: rgba(15, 15, 30, 0.5);
            backdrop-filter: blur(20px);
            -webkit-backdrop-filter: blur(20px);
            border: 2px solid rgba{color_rgb_30};
            border-radius: 24px;
            padding: 45px;
            transition: all 0.3s ease;
            position: relative;
            overflow: hidden;
        }}

        .feature-card::before {{
            content: '';
            position: absolute;
            top: 0;
            left: 0;
            right: 0;
            height: 4px;
            background: linear-gradient(90deg, transparent, {app['color_primary']}, transparent);
            opacity: 0;
            transition: opacity 0.3s ease;
        }}

        .feature-card:hover {{
            transform: translateY(-8px);
            border-color: {app['color_primary']};
            box-shadow: 0 15px 60px rgba{color_rgb_40};
        }}

        .feature-card:hover::before {{
            opacity: 1;
        }}

        .feature-icon {{
            font-size: 56px;
            margin-bottom: 20px;
        }}

        .feature-card h3 {{
            font-size: 26px;
            margin-bottom: 15px;
            color: {app['color_primary']};
            font-weight: 700;
        }}

        .feature-card p {{
            font-size: 17px;
            line-height: 1.6;
            color: rgba(255, 255, 255, 0.75);
        }}

        /* Screenshots */
        .screenshots-grid {{
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(450px, 1fr));
            gap: 30px;
            margin-bottom: 60px;
        }}

        .screenshot-card {{
            background: rgba(15, 15, 30, 0.4);
            border: 2px solid rgba{color_rgb_30};
            border-radius: 20px;
            padding: 25px;
            backdrop-filter: blur(10px);
            transition: all 0.3s ease;
        }}

        .screenshot-card:hover {{
            border-color: {app['color_primary']};
            transform: scale(1.02);
        }}

        .screenshot-placeholder {{
            width: 100%;
            aspect-ratio: 16 / 9;
            background: linear-gradient(135deg, rgba{color_rgb_30} 0%, rgba(15, 15, 30, 0.8) 100%);
            border-radius: 16px;
            display: flex;
            align-items: center;
            justify-content: center;
            color: rgba(255, 255, 255, 0.5);
            font-size: 20px;
            font-weight: 600;
            border: 2px dashed rgba{color_rgb_40};
        }}

        /* Footer */
        footer {{
            text-align: center;
            padding: 80px 20px;
            border-top: 1px solid rgba{color_rgb_30};
            margin-top: 120px;
        }}

        footer p {{
            color: rgba(255, 255, 255, 0.5);
            font-size: 15px;
        }}

        /* Responsive */
        @media (max-width: 768px) {{
            h1 {{
                font-size: 48px;
            }}

            .tagline {{
                font-size: 24px;
            }}

            .section-title {{
                font-size: 36px;
            }}

            .features-grid,
            .screenshots-grid {{
                grid-template-columns: 1fr;
            }}

            .cta-buttons {{
                flex-direction: column;
                align-items: center;
            }}

            .game-metadata {{
                gap: 20px;
            }}
        }}
    </style>
</head>
<body>
    <!-- Enhanced 3D Depth Layers -->
    <div class="depth-layer depth-layer-1"></div>
    <div class="depth-layer depth-layer-2"></div>
    <div class="depth-layer depth-layer-3"></div>

    <div class="container">
        <!-- Hero Section -->
        <section class="hero">
            <div class="genre-badge">{app['genre']}</div>

            <div class="logo-container">
                <div class="logo-icon">{app['logo']}</div>
            </div>

            <h1>{app['title']}</h1>
            <p class="tagline">{app['tagline']}</p>
            <p class="hero-message">
                {app['hero_message']}
            </p>

            <div class="cta-buttons">
                <a href="#" class="cta-primary">START PLAYING</a>
                <a href="#" class="cta-secondary">Watch Trailer</a>
            </div>
        </section>

        <!-- Game Metadata -->
        <section class="game-metadata">
            <div class="metadata-item">
                <span class="metadata-value">{app['player_count']}</span>
                <span class="metadata-label">Players</span>
            </div>
            <div class="metadata-item">
                <span class="metadata-value">⭐ {app['rating']}</span>
                <span class="metadata-label">Rating</span>
            </div>
            <div class="metadata-item">
                <span class="metadata-value">{app['intensity']}</span>
                <span class="metadata-label">Intensity</span>
            </div>
            <div class="metadata-item">
                <span class="metadata-value">{app['space_needed']}</span>
                <span class="metadata-label">Space</span>
            </div>
        </section>

        <!-- Game Modes -->
        <section class="section">
            <h2 class="section-title">GAME MODES</h2>
            <div class="modes-grid">
{modes_html}            </div>
        </section>

        <!-- Gameplay Features -->
        <section class="section">
            <h2 class="section-title">EPIC GAMEPLAY FEATURES</h2>
            <div class="features-grid">
{features_html}            </div>
        </section>

        <!-- Screenshots -->
        <section class="section">
            <h2 class="section-title">GAMEPLAY GALLERY</h2>
            <div class="screenshots-grid">
                <div class="screenshot-card">
                    <div class="screenshot-placeholder">ACTION SCREENSHOT</div>
                </div>
                <div class="screenshot-card">
                    <div class="screenshot-placeholder">COMBAT MOMENT</div>
                </div>
                <div class="screenshot-card">
                    <div class="screenshot-placeholder">SPECIAL ABILITY</div>
                </div>
                <div class="screenshot-card">
                    <div class="screenshot-placeholder">MULTIPLAYER ACTION</div>
                </div>
            </div>
        </section>
    </div>

    <footer>
        <p>&copy; 2024 {app['title']}. Experience the future of spatial gaming on Apple Vision Pro.</p>
    </footer>
</body>
</html>"""

    return html

def main():
    """Generate enhanced gaming landing pages"""
    print("=" * 80)
    print("GENERATING ENHANCED GAMING LANDING PAGES")
    print("First Principles Design: Vibrant, Action-Focused, Gaming-Specific")
    print("=" * 80)
    print()

    for i, app in enumerate(GAMING_APPS, 1):
        app_dir = app['dir']

        # Create directories
        docs_dir = os.path.join(app_dir, 'docs')
        landing_dir = os.path.join(app_dir, 'landing-page')
        os.makedirs(docs_dir, exist_ok=True)
        os.makedirs(landing_dir, exist_ok=True)

        # Generate HTML
        html_content = generate_enhanced_html(app)

        # Write files
        with open(os.path.join(docs_dir, 'index.html'), 'w', encoding='utf-8') as f:
            f.write(html_content)
        with open(os.path.join(landing_dir, 'index.html'), 'w', encoding='utf-8') as f:
            f.write(html_content)

        print(f"{i:2d}. ✅ {app['title']}")
        print(f"    {app['genre']} | {app['color_primary']} | {app['player_count']} players | ⭐{app['rating']}")
        print()

    print("=" * 80)
    print(f"✅ Successfully generated {len(GAMING_APPS)} ENHANCED gaming landing pages!")
    print()
    print("KEY ENHANCEMENTS:")
    print("  ✓ Genre-specific badges (ACTION, RPG, RHYTHM, etc.)")
    print("  ✓ More vibrant colors (30-50% opacity vs 15-20%)")
    print("  ✓ Dramatic animations (pulsing glow, faster movements)")
    print("  ✓ Action-focused language (BATTLE, CONQUER, DOMINATE)")
    print("  ✓ Game metadata (player count, rating, intensity, space)")
    print("  ✓ Game modes section (5+ modes per game)")
    print("  ✓ Dual CTAs (START PLAYING + Watch Trailer)")
    print("  ✓ Gaming-specific sections (not corporate 'pillars')")
    print("=" * 80)

if __name__ == "__main__":
    main()
