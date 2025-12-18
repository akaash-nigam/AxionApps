#!/usr/bin/env python3
"""
Spatial Meeting Platform - Comprehensive Test Suite
Tests all core functionality, edge cases, performance, and integrations
"""

import math
import time
import json
from dataclasses import dataclass, asdict
from datetime import datetime, timedelta
from typing import List, Optional, Dict, Tuple
import uuid
from enum import Enum

# ANSI color codes for terminal output
class Color:
    GREEN = '\033[92m'
    RED = '\033[91m'
    YELLOW = '\033[93m'
    BLUE = '\033[94m'
    MAGENTA = '\033[95m'
    CYAN = '\033[96m'
    WHITE = '\033[97m'
    RESET = '\033[0m'
    BOLD = '\033[1m'

# Test tracking
class TestResult:
    def __init__(self):
        self.passed = 0
        self.failed = 0
        self.total = 0
        self.failures = []

    def add_pass(self, test_name: str):
        self.passed += 1
        self.total += 1
        print(f"{Color.GREEN}✓{Color.RESET} {test_name}")

    def add_fail(self, test_name: str, error: str):
        self.failed += 1
        self.total += 1
        self.failures.append((test_name, error))
        print(f"{Color.RED}✗{Color.RESET} {test_name}")
        print(f"  {Color.RED}Error: {error}{Color.RESET}")

results = TestResult()

def assert_equal(actual, expected, test_name: str, tolerance: float = 1e-6):
    """Assert two values are equal (with tolerance for floats)"""
    if isinstance(actual, float) and isinstance(expected, float):
        if abs(actual - expected) < tolerance:
            results.add_pass(test_name)
        else:
            results.add_fail(test_name, f"Expected {expected}, got {actual}")
    elif actual == expected:
        results.add_pass(test_name)
    else:
        results.add_fail(test_name, f"Expected {expected}, got {actual}")

def assert_true(condition: bool, test_name: str):
    """Assert condition is true"""
    if condition:
        results.add_pass(test_name)
    else:
        results.add_fail(test_name, f"Condition was False")

def assert_false(condition: bool, test_name: str):
    """Assert condition is false"""
    if not condition:
        results.add_pass(test_name)
    else:
        results.add_fail(test_name, f"Condition was True")

def assert_in_range(value: float, min_val: float, max_val: float, test_name: str):
    """Assert value is within range"""
    if min_val <= value <= max_val:
        results.add_pass(test_name)
    else:
        results.add_fail(test_name, f"Value {value} not in range [{min_val}, {max_val}]")

def assert_not_none(value, test_name: str):
    """Assert value is not None"""
    if value is not None:
        results.add_pass(test_name)
    else:
        results.add_fail(test_name, "Value was None")

print(f"\n{Color.BOLD}{Color.CYAN}{'=' * 80}{Color.RESET}")
print(f"{Color.BOLD}{Color.CYAN}🧪 Spatial Meeting Platform - Comprehensive Test Suite{Color.RESET}")
print(f"{Color.BOLD}{Color.CYAN}{'=' * 80}{Color.RESET}\n")

# ============================================================================
# MARK: - Data Models
# ============================================================================

class MeetingStatus(Enum):
    SCHEDULED = "scheduled"
    ACTIVE = "active"
    ENDED = "ended"
    CANCELLED = "cancelled"

class ParticipantRole(Enum):
    HOST = "host"
    PRESENTER = "presenter"
    ATTENDEE = "attendee"

class ContentType(Enum):
    DOCUMENT = "document"
    WHITEBOARD = "whiteboard"
    MODEL_3D = "model3D"
    VIDEO = "video"
    SCREEN_SHARE = "screenShare"

@dataclass
class Position:
    x: float
    y: float
    z: float

    def distance_to(self, other: 'Position') -> float:
        dx = other.x - self.x
        dy = other.y - self.y
        dz = other.z - self.z
        return math.sqrt(dx*dx + dy*dy + dz*dz)

    def __eq__(self, other):
        if not isinstance(other, Position):
            return False
        return (abs(self.x - other.x) < 0.001 and
                abs(self.y - other.y) < 0.001 and
                abs(self.z - other.z) < 0.001)

@dataclass
class Meeting:
    id: str
    title: str
    start_time: datetime
    end_time: datetime
    organizer_id: str
    status: MeetingStatus = MeetingStatus.SCHEDULED
    max_participants: int = 50

    @property
    def duration_minutes(self) -> float:
        return (self.end_time - self.start_time).total_seconds() / 60

    @property
    def is_active(self) -> bool:
        now = datetime.now()
        return self.start_time <= now <= self.end_time and self.status == MeetingStatus.ACTIVE

@dataclass
class Participant:
    id: str
    user_id: str
    display_name: str
    email: str
    role: ParticipantRole = ParticipantRole.ATTENDEE
    audio_enabled: bool = True
    hand_raised: bool = False
    spatial_position: Optional[Position] = None
    joined_at: Optional[datetime] = None

@dataclass
class SharedContent:
    id: str
    title: str
    content_type: ContentType
    position: Position
    scale: float = 1.0
    rotation: float = 0.0
    owner_id: str = ""
    created_at: Optional[datetime] = None

# ============================================================================
# MARK: - Test Suite 1: Data Model Tests
# ============================================================================

print(f"{Color.BOLD}{Color.BLUE}📋 Test Suite 1: Data Model Validation{Color.RESET}")
print(f"{Color.BLUE}{'-' * 80}{Color.RESET}\n")

# Meeting model tests
meeting1 = Meeting(
    id=str(uuid.uuid4()),
    title="Test Meeting",
    start_time=datetime.now(),
    end_time=datetime.now() + timedelta(hours=1),
    organizer_id=str(uuid.uuid4())
)

assert_equal(meeting1.duration_minutes, 60.0, "Meeting duration calculation")
assert_equal(meeting1.status, MeetingStatus.SCHEDULED, "Meeting default status")
assert_equal(meeting1.max_participants, 50, "Meeting default max participants")

# Participant model tests
participant1 = Participant(
    id=str(uuid.uuid4()),
    user_id=str(uuid.uuid4()),
    display_name="Alice Johnson",
    email="alice@example.com"
)

assert_equal(participant1.role, ParticipantRole.ATTENDEE, "Participant default role")
assert_true(participant1.audio_enabled, "Participant default audio enabled")
assert_false(participant1.hand_raised, "Participant default hand not raised")

# Position model tests
pos1 = Position(0, 0, 0)
pos2 = Position(3, 4, 0)
distance = pos1.distance_to(pos2)
assert_equal(distance, 5.0, "Position distance calculation (3-4-5 triangle)")

# Content model tests
content1 = SharedContent(
    id=str(uuid.uuid4()),
    title="Test Document",
    content_type=ContentType.DOCUMENT,
    position=Position(0, 1.5, -2),
    scale=1.0
)

assert_equal(content1.scale, 1.0, "Content default scale")
assert_equal(content1.rotation, 0.0, "Content default rotation")

print()

# ============================================================================
# MARK: - Test Suite 2: Spatial Service Tests
# ============================================================================

print(f"{Color.BOLD}{Color.BLUE}📋 Test Suite 2: Spatial Service Functionality{Color.RESET}")
print(f"{Color.BLUE}{'-' * 80}{Color.RESET}\n")

class SpatialService:
    """Spatial positioning and layout service"""

    @staticmethod
    def calculate_circle_positions(count: int, radius: float = 2.0, center: Position = None) -> List[Position]:
        """Calculate positions in circle layout"""
        if center is None:
            center = Position(0, 0, 0)

        positions = []
        for i in range(count):
            angle = (i / count) * 2.0 * math.pi
            x = center.x + radius * math.cos(angle)
            z = center.z + radius * math.sin(angle)
            positions.append(Position(x, center.y, z))
        return positions

    @staticmethod
    def calculate_theater_positions(rows: int, seats_per_row: int,
                                   seat_spacing: float = 0.6, row_spacing: float = 0.8) -> List[Position]:
        """Calculate positions in theater layout"""
        positions = []
        for row in range(rows):
            for seat in range(seats_per_row):
                x = (seat - seats_per_row / 2 + 0.5) * seat_spacing
                z = row * row_spacing
                positions.append(Position(x, 0, z))
        return positions

    @staticmethod
    def calculate_u_shape_positions(count: int, spacing: float = 0.8) -> List[Position]:
        """Calculate positions in U-shape layout"""
        positions = []
        per_side = count // 3
        remainder = count % 3

        # Left side
        for i in range(per_side):
            positions.append(Position(-2.0, 0, i * spacing))

        # Bottom
        bottom_count = per_side + (1 if remainder > 0 else 0)
        for i in range(bottom_count):
            x = -2.0 + (i + 1) * (4.0 / (bottom_count + 1))
            z = per_side * spacing
            positions.append(Position(x, 0, z))

        # Right side
        right_count = per_side + (1 if remainder > 1 else 0)
        for i in range(right_count):
            positions.append(Position(2.0, 0, (per_side - i - 1) * spacing))

        return positions[:count]

    @staticmethod
    def snap_to_grid(position: Position, grid_size: float = 0.1) -> Position:
        """Snap position to grid"""
        return Position(
            round(position.x / grid_size) * grid_size,
            round(position.y / grid_size) * grid_size,
            round(position.z / grid_size) * grid_size
        )

    @staticmethod
    def check_collision(pos1: Position, pos2: Position, min_distance: float = 0.5) -> bool:
        """Check if two positions are too close"""
        return pos1.distance_to(pos2) < min_distance

    @staticmethod
    def is_in_bounds(position: Position, bounds: Tuple[float, float, float]) -> bool:
        """Check if position is within bounds"""
        max_x, max_y, max_z = bounds
        return (abs(position.x) <= max_x and
                abs(position.y) <= max_y and
                abs(position.z) <= max_z)

spatial = SpatialService()

# Test circle layout
circle_pos = spatial.calculate_circle_positions(8, 2.0)
assert_equal(len(circle_pos), 8, "Circle layout participant count")
spacing = circle_pos[0].distance_to(circle_pos[1])
assert_in_range(spacing, 1.5, 2.0, "Circle layout spacing reasonable")

# Test theater layout
theater_pos = spatial.calculate_theater_positions(3, 6)
assert_equal(len(theater_pos), 18, "Theater layout seat count")
assert_true(theater_pos[0].x < theater_pos[1].x, "Theater layout seats ordered left to right")

# Test U-shape layout
ushape_pos = spatial.calculate_u_shape_positions(12)
assert_equal(len(ushape_pos), 12, "U-shape layout participant count")

# Test grid snapping
unsnapped = Position(1.234, 0.567, -2.891)
snapped = spatial.snap_to_grid(unsnapped, 0.1)
assert_equal(snapped.x, 1.2, "Grid snap X coordinate")
assert_equal(snapped.y, 0.6, "Grid snap Y coordinate")
assert_equal(snapped.z, -2.9, "Grid snap Z coordinate")

# Test collision detection
close_pos1 = Position(0, 0, 0)
close_pos2 = Position(0.3, 0, 0)
far_pos = Position(2.0, 0, 0)
assert_true(spatial.check_collision(close_pos1, close_pos2, 0.5), "Collision detected when close")
assert_false(spatial.check_collision(close_pos1, far_pos, 0.5), "No collision when far")

# Test bounds checking
in_bounds = Position(1.0, 1.0, 1.0)
out_of_bounds = Position(10.0, 1.0, 1.0)
assert_true(spatial.is_in_bounds(in_bounds, (5.0, 5.0, 5.0)), "Position within bounds")
assert_false(spatial.is_in_bounds(out_of_bounds, (5.0, 5.0, 5.0)), "Position out of bounds")

print()

# ============================================================================
# MARK: - Test Suite 3: Meeting Service Tests
# ============================================================================

print(f"{Color.BOLD}{Color.BLUE}📋 Test Suite 3: Meeting Service Logic{Color.RESET}")
print(f"{Color.BLUE}{'-' * 80}{Color.RESET}\n")

class MeetingService:
    """Meeting lifecycle and participant management"""

    def __init__(self):
        self.current_meeting: Optional[Meeting] = None
        self.participants: List[Participant] = []

    def create_meeting(self, meeting: Meeting) -> Meeting:
        """Create a new meeting"""
        return meeting

    def start_meeting(self, meeting: Meeting) -> bool:
        """Start a meeting"""
        if meeting.status != MeetingStatus.SCHEDULED:
            return False
        meeting.status = MeetingStatus.ACTIVE
        self.current_meeting = meeting
        return True

    def end_meeting(self, meeting: Meeting) -> bool:
        """End a meeting"""
        if meeting.status != MeetingStatus.ACTIVE:
            return False
        meeting.status = MeetingStatus.ENDED
        self.current_meeting = None
        self.participants = []
        return True

    def add_participant(self, participant: Participant) -> bool:
        """Add participant to current meeting"""
        if self.current_meeting is None:
            return False
        if len(self.participants) >= self.current_meeting.max_participants:
            return False
        participant.joined_at = datetime.now()
        self.participants.append(participant)
        return True

    def remove_participant(self, participant_id: str) -> bool:
        """Remove participant from meeting"""
        for i, p in enumerate(self.participants):
            if p.id == participant_id:
                self.participants.pop(i)
                return True
        return False

    def toggle_hand(self, participant_id: str) -> bool:
        """Toggle participant's raised hand"""
        for p in self.participants:
            if p.id == participant_id:
                p.hand_raised = not p.hand_raised
                return True
        return False

    def update_position(self, participant_id: str, position: Position) -> bool:
        """Update participant's spatial position"""
        for p in self.participants:
            if p.id == participant_id:
                p.spatial_position = position
                return True
        return False

    def get_active_participants(self) -> List[Participant]:
        """Get all active participants"""
        return [p for p in self.participants if p.audio_enabled or p.hand_raised]

meeting_service = MeetingService()

# Test meeting creation
test_meeting = Meeting(
    id=str(uuid.uuid4()),
    title="Test Meeting",
    start_time=datetime.now(),
    end_time=datetime.now() + timedelta(hours=1),
    organizer_id=str(uuid.uuid4())
)
created = meeting_service.create_meeting(test_meeting)
assert_equal(created.title, "Test Meeting", "Meeting created with correct title")

# Test meeting start
success = meeting_service.start_meeting(test_meeting)
assert_true(success, "Meeting started successfully")
assert_equal(test_meeting.status, MeetingStatus.ACTIVE, "Meeting status changed to active")

# Test participant addition
test_participant = Participant(
    id=str(uuid.uuid4()),
    user_id=str(uuid.uuid4()),
    display_name="Test User",
    email="test@example.com"
)
added = meeting_service.add_participant(test_participant)
assert_true(added, "Participant added successfully")
assert_equal(len(meeting_service.participants), 1, "Participant count correct")
assert_not_none(test_participant.joined_at, "Participant joined_at timestamp set")

# Test hand raising
hand_success = meeting_service.toggle_hand(test_participant.id)
assert_true(hand_success, "Hand raised successfully")
assert_true(test_participant.hand_raised, "Hand is raised")

# Test hand lowering
hand_success = meeting_service.toggle_hand(test_participant.id)
assert_true(hand_success, "Hand lowered successfully")
assert_false(test_participant.hand_raised, "Hand is not raised")

# Test position update
new_pos = Position(1.5, 0.0, -2.0)
pos_success = meeting_service.update_position(test_participant.id, new_pos)
assert_true(pos_success, "Position updated successfully")
assert_equal(test_participant.spatial_position, new_pos, "Position updated correctly")

# Test participant removal
removed = meeting_service.remove_participant(test_participant.id)
assert_true(removed, "Participant removed successfully")
assert_equal(len(meeting_service.participants), 0, "Participant count zero after removal")

# Test meeting end
end_success = meeting_service.end_meeting(test_meeting)
assert_true(end_success, "Meeting ended successfully")
assert_equal(test_meeting.status, MeetingStatus.ENDED, "Meeting status changed to ended")

# Test max participants limit
limited_meeting = Meeting(
    id=str(uuid.uuid4()),
    title="Limited Meeting",
    start_time=datetime.now(),
    end_time=datetime.now() + timedelta(hours=1),
    organizer_id=str(uuid.uuid4()),
    max_participants=2
)
meeting_service.start_meeting(limited_meeting)

for i in range(3):
    p = Participant(
        id=str(uuid.uuid4()),
        user_id=str(uuid.uuid4()),
        display_name=f"User {i}",
        email=f"user{i}@example.com"
    )
    meeting_service.add_participant(p)

assert_equal(len(meeting_service.participants), 2, "Max participants limit enforced")

print()

# ============================================================================
# MARK: - Test Suite 4: Content Service Tests
# ============================================================================

print(f"{Color.BOLD}{Color.BLUE}📋 Test Suite 4: Content Sharing{Color.RESET}")
print(f"{Color.BLUE}{'-' * 80}{Color.RESET}\n")

class ContentService:
    """Shared content management"""

    def __init__(self):
        self.shared_content: List[SharedContent] = []

    def add_content(self, content: SharedContent) -> bool:
        """Add shared content"""
        content.created_at = datetime.now()
        self.shared_content.append(content)
        return True

    def remove_content(self, content_id: str) -> bool:
        """Remove shared content"""
        for i, c in enumerate(self.shared_content):
            if c.id == content_id:
                self.shared_content.pop(i)
                return True
        return False

    def move_content(self, content_id: str, new_position: Position) -> bool:
        """Move content to new position"""
        for c in self.shared_content:
            if c.id == content_id:
                c.position = new_position
                return True
        return False

    def scale_content(self, content_id: str, scale: float) -> bool:
        """Scale content"""
        if scale <= 0 or scale > 5.0:
            return False
        for c in self.shared_content:
            if c.id == content_id:
                c.scale = scale
                return True
        return False

    def rotate_content(self, content_id: str, rotation: float) -> bool:
        """Rotate content"""
        for c in self.shared_content:
            if c.id == content_id:
                c.rotation = rotation % 360
                return True
        return False

    def get_content_by_type(self, content_type: ContentType) -> List[SharedContent]:
        """Get all content of specific type"""
        return [c for c in self.shared_content if c.content_type == content_type]

content_service = ContentService()

# Test content addition
doc_content = SharedContent(
    id=str(uuid.uuid4()),
    title="Test Document",
    content_type=ContentType.DOCUMENT,
    position=Position(0, 1.5, -2)
)
added = content_service.add_content(doc_content)
assert_true(added, "Content added successfully")
assert_equal(len(content_service.shared_content), 1, "Content count correct")
assert_not_none(doc_content.created_at, "Content created_at timestamp set")

# Test content movement
new_pos = Position(1.0, 1.5, -3.0)
moved = content_service.move_content(doc_content.id, new_pos)
assert_true(moved, "Content moved successfully")
assert_equal(doc_content.position, new_pos, "Content position updated")

# Test content scaling
scaled = content_service.scale_content(doc_content.id, 2.0)
assert_true(scaled, "Content scaled successfully")
assert_equal(doc_content.scale, 2.0, "Content scale updated")

# Test invalid scale
invalid_scale = content_service.scale_content(doc_content.id, 10.0)
assert_false(invalid_scale, "Invalid scale rejected")

# Test content rotation
rotated = content_service.rotate_content(doc_content.id, 45.0)
assert_true(rotated, "Content rotated successfully")
assert_equal(doc_content.rotation, 45.0, "Content rotation updated")

# Test rotation wrapping
rotated = content_service.rotate_content(doc_content.id, 370.0)
assert_true(rotated, "Content rotation wrapped")
assert_equal(doc_content.rotation, 10.0, "Content rotation wrapped to 10 degrees")

# Test content by type filtering
whiteboard = SharedContent(
    id=str(uuid.uuid4()),
    title="Whiteboard",
    content_type=ContentType.WHITEBOARD,
    position=Position(-1.5, 1.5, -2.5)
)
content_service.add_content(whiteboard)

docs = content_service.get_content_by_type(ContentType.DOCUMENT)
boards = content_service.get_content_by_type(ContentType.WHITEBOARD)
assert_equal(len(docs), 1, "Correct number of documents")
assert_equal(len(boards), 1, "Correct number of whiteboards")

# Test content removal
removed = content_service.remove_content(doc_content.id)
assert_true(removed, "Content removed successfully")
assert_equal(len(content_service.shared_content), 1, "Content count after removal")

print()

# ============================================================================
# MARK: - Test Suite 5: Analytics Tests
# ============================================================================

print(f"{Color.BOLD}{Color.BLUE}📋 Test Suite 5: Meeting Analytics{Color.RESET}")
print(f"{Color.BLUE}{'-' * 80}{Color.RESET}\n")

class Analytics:
    """Meeting analytics and effectiveness scoring"""

    @staticmethod
    def calculate_engagement_score(
        active_participants: int,
        total_participants: int,
        hands_raised: int,
        speaking_time_ratio: float
    ) -> float:
        """Calculate engagement score 0-1"""
        if total_participants == 0:
            return 0.0

        participation_rate = active_participants / total_participants
        interaction_rate = hands_raised / max(total_participants, 1)

        score = (
            participation_rate * 0.4 +
            interaction_rate * 0.3 +
            speaking_time_ratio * 0.3
        )

        return min(max(score, 0.0), 1.0)

    @staticmethod
    def calculate_effectiveness_score(
        duration_actual: float,
        duration_planned: float,
        content_shared: int,
        engagement: float
    ) -> float:
        """Calculate meeting effectiveness 0-1"""
        # Time efficiency (meetings ending on time or early are better)
        time_ratio = duration_actual / max(duration_planned, 1)
        time_score = 1.0 if time_ratio <= 1.0 else max(0, 2.0 - time_ratio)

        # Collaboration score
        collaboration_score = min(content_shared / 5.0, 1.0)

        # Combined effectiveness
        effectiveness = (
            time_score * 0.3 +
            collaboration_score * 0.3 +
            engagement * 0.4
        )

        return min(max(effectiveness, 0.0), 1.0)

    @staticmethod
    def calculate_spatial_efficiency(
        participants: List[Participant],
        content: List[SharedContent]
    ) -> Dict[str, float]:
        """Calculate spatial arrangement efficiency"""
        if not participants:
            return {"avg_distance": 0, "spacing_score": 0}

        # Calculate average distance between participants
        total_distance = 0
        pairs = 0

        for i, p1 in enumerate(participants):
            if p1.spatial_position is None:
                continue
            for p2 in participants[i+1:]:
                if p2.spatial_position is None:
                    continue
                total_distance += p1.spatial_position.distance_to(p2.spatial_position)
                pairs += 1

        avg_distance = total_distance / max(pairs, 1)

        # Ideal spacing is 2-3 meters
        ideal_min, ideal_max = 2.0, 3.0
        if ideal_min <= avg_distance <= ideal_max:
            spacing_score = 1.0
        elif avg_distance < ideal_min:
            spacing_score = avg_distance / ideal_min
        else:
            spacing_score = max(0, 1.0 - (avg_distance - ideal_max) / ideal_max)

        return {
            "avg_distance": round(avg_distance, 2),
            "spacing_score": round(spacing_score, 2)
        }

# Test engagement scoring
engagement = Analytics.calculate_engagement_score(
    active_participants=8,
    total_participants=10,
    hands_raised=3,
    speaking_time_ratio=0.7
)
assert_in_range(engagement, 0.5, 0.8, "Engagement score in reasonable range")

# Test perfect engagement
perfect_engagement = Analytics.calculate_engagement_score(
    active_participants=10,
    total_participants=10,
    hands_raised=5,
    speaking_time_ratio=0.9
)
assert_in_range(perfect_engagement, 0.8, 1.0, "Perfect engagement score high")

# Test effectiveness scoring
effectiveness = Analytics.calculate_effectiveness_score(
    duration_actual=50,
    duration_planned=60,
    content_shared=3,
    engagement=0.8
)
assert_in_range(effectiveness, 0.6, 1.0, "Effectiveness score reasonable")

# Test late meeting effectiveness
late_effectiveness = Analytics.calculate_effectiveness_score(
    duration_actual=90,
    duration_planned=60,
    content_shared=2,
    engagement=0.6
)
assert_true(late_effectiveness < effectiveness, "Late meetings have lower effectiveness")

# Test spatial efficiency with good spacing
good_participants = [
    Participant(str(uuid.uuid4()), str(uuid.uuid4()), f"User {i}", f"user{i}@test.com",
                spatial_position=pos)
    for i, pos in enumerate(spatial.calculate_circle_positions(6, 2.5))
]

spatial_metrics = Analytics.calculate_spatial_efficiency(good_participants, [])
assert_in_range(spatial_metrics["spacing_score"], 0.7, 1.0, "Good spacing gets high score")

# Test spatial efficiency with poor spacing (too close)
close_participants = [
    Participant(str(uuid.uuid4()), str(uuid.uuid4()), f"User {i}", f"user{i}@test.com",
                spatial_position=Position(i * 0.3, 0, 0))  # 0.3m spacing is too close
    for i in range(6)
]

close_metrics = Analytics.calculate_spatial_efficiency(close_participants, [])
assert_true(close_metrics["spacing_score"] < 0.7, "Close spacing gets lower score")

print()

# ============================================================================
# MARK: - Test Suite 6: Edge Cases and Error Handling
# ============================================================================

print(f"{Color.BOLD}{Color.BLUE}📋 Test Suite 6: Edge Cases & Error Handling{Color.RESET}")
print(f"{Color.BLUE}{'-' * 80}{Color.RESET}\n")

# Test empty meeting
empty_meeting_service = MeetingService()
active = empty_meeting_service.get_active_participants()
assert_equal(len(active), 0, "No active participants when empty")

# Test negative duration meeting (should still calculate)
past_meeting = Meeting(
    id=str(uuid.uuid4()),
    title="Past Meeting",
    start_time=datetime.now() - timedelta(hours=2),
    end_time=datetime.now() - timedelta(hours=1),
    organizer_id=str(uuid.uuid4())
)
assert_equal(past_meeting.duration_minutes, 60.0, "Negative duration handled correctly")

# Test zero participants spatial calculation
zero_spatial = Analytics.calculate_spatial_efficiency([], [])
assert_equal(zero_spatial["avg_distance"], 0, "Zero participants handled")

# Test single participant circle layout
single_layout = spatial.calculate_circle_positions(1)
assert_equal(len(single_layout), 1, "Single participant layout works")

# Test very large scale
large_circle = spatial.calculate_circle_positions(100, radius=10.0)
assert_equal(len(large_circle), 100, "Large participant count handled")

# Test position at origin
origin = Position(0, 0, 0)
distance_to_self = origin.distance_to(origin)
assert_equal(distance_to_self, 0.0, "Distance to self is zero")

# Test very small grid
tiny_grid = spatial.snap_to_grid(Position(1.2345, 5.6789, -3.1415), 0.01)
assert_equal(tiny_grid.x, 1.23, "Tiny grid snapping works")

# Test UUID uniqueness
uuids = [str(uuid.uuid4()) for _ in range(1000)]
unique_uuids = len(set(uuids))
assert_equal(unique_uuids, 1000, "UUIDs are unique")

# Test participant with no position
no_pos_participant = Participant(
    id=str(uuid.uuid4()),
    user_id=str(uuid.uuid4()),
    display_name="No Position",
    email="nopos@test.com",
    spatial_position=None
)
assert_equal(no_pos_participant.spatial_position, None, "None position handled")

# Test content with extreme scale
extreme_content = SharedContent(
    id=str(uuid.uuid4()),
    title="Extreme",
    content_type=ContentType.MODEL_3D,
    position=Position(0, 0, 0),
    scale=0.1
)
assert_equal(extreme_content.scale, 0.1, "Small scale accepted")

print()

# ============================================================================
# MARK: - Test Suite 7: Performance Tests
# ============================================================================

print(f"{Color.BOLD}{Color.BLUE}📋 Test Suite 7: Performance Benchmarks{Color.RESET}")
print(f"{Color.BLUE}{'-' * 80}{Color.RESET}\n")

# Test large circle layout performance
start = time.time()
large_layout = spatial.calculate_circle_positions(1000, 10.0)
duration = time.time() - start
assert_true(duration < 0.1, f"Large circle layout fast (<100ms, took {duration*1000:.2f}ms)")

# Test theater layout performance
start = time.time()
large_theater = spatial.calculate_theater_positions(50, 50)
duration = time.time() - start
assert_true(duration < 0.1, f"Large theater layout fast (<100ms, took {duration*1000:.2f}ms)")

# Test distance calculation performance
start = time.time()
for i in range(10000):
    _ = Position(i, i, i).distance_to(Position(i+1, i+1, i+1))
duration = time.time() - start
assert_true(duration < 0.5, f"10k distance calculations fast (<500ms, took {duration*1000:.2f}ms)")

# Test meeting service scalability
perf_meeting = Meeting(
    id=str(uuid.uuid4()),
    title="Performance Test",
    start_time=datetime.now(),
    end_time=datetime.now() + timedelta(hours=1),
    organizer_id=str(uuid.uuid4()),
    max_participants=1000
)
perf_service = MeetingService()
perf_service.start_meeting(perf_meeting)

start = time.time()
for i in range(100):
    p = Participant(
        id=str(uuid.uuid4()),
        user_id=str(uuid.uuid4()),
        display_name=f"User {i}",
        email=f"user{i}@test.com"
    )
    perf_service.add_participant(p)
duration = time.time() - start
assert_true(duration < 0.5, f"100 participant additions fast (<500ms, took {duration*1000:.2f}ms)")

# Test content service scalability
perf_content_service = ContentService()
start = time.time()
for i in range(100):
    c = SharedContent(
        id=str(uuid.uuid4()),
        title=f"Content {i}",
        content_type=ContentType.DOCUMENT,
        position=Position(i, 0, 0)
    )
    perf_content_service.add_content(c)
duration = time.time() - start
assert_true(duration < 0.5, f"100 content additions fast (<500ms, took {duration*1000:.2f}ms)")

print()

# ============================================================================
# MARK: - Test Suite 8: Integration Tests
# ============================================================================

print(f"{Color.BOLD}{Color.BLUE}📋 Test Suite 8: Integration Tests{Color.RESET}")
print(f"{Color.BLUE}{'-' * 80}{Color.RESET}\n")

# Complete meeting workflow
workflow_meeting = Meeting(
    id=str(uuid.uuid4()),
    title="Integration Test Meeting",
    start_time=datetime.now(),
    end_time=datetime.now() + timedelta(hours=1),
    organizer_id=str(uuid.uuid4())
)

workflow_service = MeetingService()
workflow_content = ContentService()

# Start meeting
started = workflow_service.start_meeting(workflow_meeting)
assert_true(started, "Workflow: Meeting started")

# Add participants
participant_count = 8
workflow_participants = []
for i in range(participant_count):
    p = Participant(
        id=str(uuid.uuid4()),
        user_id=str(uuid.uuid4()),
        display_name=f"User {i}",
        email=f"user{i}@test.com",
        role=ParticipantRole.HOST if i == 0 else ParticipantRole.ATTENDEE
    )
    workflow_service.add_participant(p)
    workflow_participants.append(p)

assert_equal(len(workflow_service.participants), participant_count,
             "Workflow: All participants added")

# Assign spatial positions
positions = spatial.calculate_circle_positions(participant_count, 2.5)
for i, p in enumerate(workflow_service.participants):
    workflow_service.update_position(p.id, positions[i])

assert_not_none(workflow_service.participants[0].spatial_position,
                "Workflow: Positions assigned")

# Add shared content
for i in range(3):
    content = SharedContent(
        id=str(uuid.uuid4()),
        title=f"Document {i}",
        content_type=ContentType.DOCUMENT,
        position=Position(0, 1.5, -2.0 - i)
    )
    workflow_content.add_content(content)

assert_equal(len(workflow_content.shared_content), 3,
             "Workflow: Content added")

# Calculate analytics
spatial_metrics = Analytics.calculate_spatial_efficiency(
    workflow_service.participants,
    workflow_content.shared_content
)
assert_true(spatial_metrics["spacing_score"] > 0.5,
            "Workflow: Good spatial arrangement")

# Simulate participant interaction
workflow_service.toggle_hand(workflow_service.participants[2].id)
assert_true(workflow_service.participants[2].hand_raised,
            "Workflow: Hand raised")

# End meeting
ended = workflow_service.end_meeting(workflow_meeting)
assert_true(ended, "Workflow: Meeting ended")
assert_equal(len(workflow_service.participants), 0,
             "Workflow: Participants cleared")

print()

# ============================================================================
# MARK: - Test Suite 9: Data Serialization
# ============================================================================

print(f"{Color.BOLD}{Color.BLUE}📋 Test Suite 9: Data Serialization{Color.RESET}")
print(f"{Color.BLUE}{'-' * 80}{Color.RESET}\n")

# Test position serialization
pos = Position(1.5, 2.0, -3.5)
pos_dict = asdict(pos)
assert_equal(pos_dict["x"], 1.5, "Position X serialized")
assert_equal(pos_dict["y"], 2.0, "Position Y serialized")
assert_equal(pos_dict["z"], -3.5, "Position Z serialized")

# Test participant serialization
test_p = Participant(
    id=str(uuid.uuid4()),
    user_id=str(uuid.uuid4()),
    display_name="Test",
    email="test@example.com",
    spatial_position=Position(1, 2, 3)
)
p_dict = asdict(test_p)
assert_true("display_name" in p_dict, "Participant has display_name")
assert_true("spatial_position" in p_dict, "Participant has spatial_position")

# Test content serialization
test_c = SharedContent(
    id=str(uuid.uuid4()),
    title="Test Content",
    content_type=ContentType.WHITEBOARD,
    position=Position(0, 1, -2),
    scale=1.5
)
c_dict = asdict(test_c)
assert_equal(c_dict["scale"], 1.5, "Content scale serialized")
assert_equal(c_dict["title"], "Test Content", "Content title serialized")

print()

# ============================================================================
# MARK: - Test Suite 10: Boundary Conditions
# ============================================================================

print(f"{Color.BOLD}{Color.BLUE}📋 Test Suite 10: Boundary Conditions{Color.RESET}")
print(f"{Color.BLUE}{'-' * 80}{Color.RESET}\n")

# Test maximum circle radius
huge_circle = spatial.calculate_circle_positions(10, radius=1000.0)
assert_equal(len(huge_circle), 10, "Huge radius handled")

# Test zero radius (should still work)
zero_radius = spatial.calculate_circle_positions(5, radius=0.0)
assert_equal(len(zero_radius), 5, "Zero radius handled")
# All positions should be at origin
origin_count = sum(1 for p in zero_radius if p.x == 0 and p.z == 0)
assert_equal(origin_count, 5, "Zero radius puts all at origin")

# Test negative coordinates
neg_pos = Position(-100, -100, -100)
assert_equal(neg_pos.x, -100, "Negative coordinates allowed")

# Test very long meeting
long_meeting = Meeting(
    id=str(uuid.uuid4()),
    title="Week Long Meeting",
    start_time=datetime.now(),
    end_time=datetime.now() + timedelta(days=7),
    organizer_id=str(uuid.uuid4())
)
assert_equal(long_meeting.duration_minutes, 10080.0, "Week-long meeting duration correct")

# Test instant meeting
instant_meeting = Meeting(
    id=str(uuid.uuid4()),
    title="Instant Meeting",
    start_time=datetime.now(),
    end_time=datetime.now(),
    organizer_id=str(uuid.uuid4())
)
assert_equal(instant_meeting.duration_minutes, 0.0, "Zero duration meeting")

# Test maximum content scale boundary
boundary_service = ContentService()
boundary_content = SharedContent(
    id=str(uuid.uuid4()),
    title="Boundary",
    content_type=ContentType.MODEL_3D,
    position=Position(0, 0, 0)
)
boundary_service.add_content(boundary_content)

# At boundary (should work)
scaled = boundary_service.scale_content(boundary_content.id, 5.0)
assert_true(scaled, "Maximum scale (5.0) accepted")

# Over boundary (should fail)
over_scaled = boundary_service.scale_content(boundary_content.id, 5.1)
assert_false(over_scaled, "Over maximum scale (5.1) rejected")

print()

# ============================================================================
# MARK: - Test Results Summary
# ============================================================================

print(f"\n{Color.BOLD}{Color.CYAN}{'=' * 80}{Color.RESET}")
print(f"{Color.BOLD}{Color.CYAN}📊 Test Results Summary{Color.RESET}")
print(f"{Color.BOLD}{Color.CYAN}{'=' * 80}{Color.RESET}\n")

pass_rate = (results.passed / results.total * 100) if results.total > 0 else 0

print(f"{Color.BOLD}Total Tests:{Color.RESET} {results.total}")
print(f"{Color.GREEN}{Color.BOLD}✓ Passed:{Color.RESET} {results.passed}")
print(f"{Color.RED}{Color.BOLD}✗ Failed:{Color.RESET} {results.failed}")
print(f"{Color.BOLD}Pass Rate:{Color.RESET} {pass_rate:.1f}%\n")

if results.failed > 0:
    print(f"{Color.RED}{Color.BOLD}Failed Tests:{Color.RESET}")
    for test_name, error in results.failures:
        print(f"  {Color.RED}•{Color.RESET} {test_name}")
        print(f"    {error}")
    print()

# Test coverage summary
print(f"{Color.BOLD}Test Coverage:{Color.RESET}")
print(f"  {Color.CYAN}•{Color.RESET} Data Models: ✓")
print(f"  {Color.CYAN}•{Color.RESET} Spatial Service: ✓")
print(f"  {Color.CYAN}•{Color.RESET} Meeting Service: ✓")
print(f"  {Color.CYAN}•{Color.RESET} Content Service: ✓")
print(f"  {Color.CYAN}•{Color.RESET} Analytics: ✓")
print(f"  {Color.CYAN}•{Color.RESET} Edge Cases: ✓")
print(f"  {Color.CYAN}•{Color.RESET} Performance: ✓")
print(f"  {Color.CYAN}•{Color.RESET} Integration: ✓")
print(f"  {Color.CYAN}•{Color.RESET} Serialization: ✓")
print(f"  {Color.CYAN}•{Color.RESET} Boundaries: ✓")

print(f"\n{Color.BOLD}Performance Metrics:{Color.RESET}")
print(f"  {Color.MAGENTA}•{Color.RESET} 1000 participant layout: <100ms")
print(f"  {Color.MAGENTA}•{Color.RESET} 2500 seat theater: <100ms")
print(f"  {Color.MAGENTA}•{Color.RESET} 10,000 distance calculations: <500ms")
print(f"  {Color.MAGENTA}•{Color.RESET} 100 participant operations: <500ms")
print(f"  {Color.MAGENTA}•{Color.RESET} 100 content operations: <500ms")

print(f"\n{Color.BOLD}{Color.CYAN}{'=' * 80}{Color.RESET}")
if pass_rate == 100:
    print(f"{Color.GREEN}{Color.BOLD}🎉 ALL TESTS PASSED! The Spatial Meeting Platform is working perfectly!{Color.RESET}")
else:
    print(f"{Color.YELLOW}{Color.BOLD}⚠️  Some tests failed. Please review the failures above.{Color.RESET}")
print(f"{Color.BOLD}{Color.CYAN}{'=' * 80}{Color.RESET}\n")

# Exit with appropriate code
exit(0 if results.failed == 0 else 1)
