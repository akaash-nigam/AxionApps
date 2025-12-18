# Mystery Investigation Cases

## Overview

This directory contains case files for the Mystery Investigation app. Each case is defined in JSON format and contains all the information needed to present a complete mystery investigation scenario.

## Directory Structure

```
cases/
├── tutorial-case-01.json       # Tutorial case for new players
├── beginner-case-01.json       # Beginner difficulty cases
├── beginner-case-02.json
├── intermediate-case-01.json   # Intermediate difficulty cases
├── intermediate-case-02.json
├── advanced-case-01.json       # Advanced difficulty cases
├── advanced-case-02.json
├── expert-case-01.json         # Expert difficulty cases
├── expert-case-02.json
└── README.md                   # This file
```

## Case JSON Schema

Each case file follows a standardized JSON schema. Below is the complete specification:

### Root Object

```json
{
  "id": "string",
  "title": "string",
  "description": "string",
  "difficulty": "string",
  "caseType": "string",
  "version": "string",
  "created": "ISO 8601 date string",
  "author": "string",
  "estimatedPlayTime": "number (minutes)",
  "metadata": { /* ... */ },
  "location": { /* ... */ },
  "timeline": { /* ... */ },
  "evidence": [ /* ... */ ],
  "suspects": [ /* ... */ ],
  "solution": { /* ... */ },
  "dialogue": { /* ... */ },
  "achievements": [ /* ... */ ]
}
```

### Property Definitions

#### Root Level Properties

| Property | Type | Required | Description |
|----------|------|----------|-------------|
| `id` | string | Yes | Unique identifier for the case (e.g., "tutorial-case-01"). Must be unique across all cases. |
| `title` | string | Yes | Display title of the case (e.g., "The Missing Diamond"). |
| `description` | string | Yes | Short description of the case premise (50-200 characters). |
| `difficulty` | string | Yes | Difficulty level: "tutorial", "beginner", "intermediate", "advanced", "expert" |
| `caseType` | string | Yes | Type of mystery: "murder", "theft", "fraud", "disappearance", "sabotage", "blackmail" |
| `version` | string | Yes | Case version (e.g., "1.0", "1.1"). Used for updates. |
| `created` | string | Yes | ISO 8601 date when the case was created (e.g., "2024-01-15T10:30:00Z") |
| `author` | string | Yes | Author/creator name or company |
| `estimatedPlayTime` | number | Yes | Estimated play time in minutes |

#### metadata Object

```json
"metadata": {
  "tags": ["string"],
  "language": "string",
  "region": "string",
  "rating": "string",
  "contentWarnings": ["string"]
}
```

| Property | Type | Description |
|----------|------|-------------|
| `tags` | array | Searchable tags (e.g., ["corporate", "mystery", "detective"]) |
| `language` | string | Primary language (e.g., "en", "es", "fr") |
| `region` | string | Recommended region (e.g., "US", "EU", "GLOBAL") |
| `rating` | string | Age rating: "E" (Everyone), "T" (Teen), "M" (Mature) |
| `contentWarnings` | array | Content warnings if any (e.g., ["violence", "death"]) |

#### location Object

```json
"location": {
  "name": "string",
  "description": "string",
  "type": "string",
  "areas": [
    {
      "id": "string",
      "name": "string",
      "description": "string",
      "evidenceItems": ["string (evidence ids)"]
    }
  ],
  "layout": {
    "dimensions": {
      "width": "number (meters)",
      "depth": "number (meters)",
      "height": "number (meters)"
    },
    "orientation": "string"
  }
}
```

| Property | Type | Description |
|----------|------|-------------|
| `name` | string | Name of the location (e.g., "Gallery") |
| `description` | string | Detailed description of the location |
| `type` | string | Location type: "office", "home", "museum", "hotel", "street", "store", "restaurant", "warehouse" |
| `areas` | array | List of distinct areas within the location |
| `layout` | object | Physical dimensions and orientation data |

#### timeline Object

```json
"timeline": {
  "incidentDate": "ISO 8601 date string",
  "incidentTime": "HH:MM format",
  "discoveryDate": "ISO 8601 date string",
  "discoveryTime": "HH:MM format",
  "events": [
    {
      "time": "HH:MM format",
      "description": "string",
      "visibility": "string (visible|hidden)"
    }
  ],
  "deductionTimeline": "string"
}
```

| Property | Type | Description |
|----------|------|-------------|
| `incidentDate` | string | Date when the incident occurred |
| `incidentTime` | string | Time of the incident |
| `discoveryDate` | string | Date when the incident was discovered |
| `discoveryTime` | string | Time of discovery |
| `events` | array | Chronological events of the case |
| `deductionTimeline` | string | Guide showing how to piece together the timeline |

#### evidence Array

```json
"evidence": [
  {
    "id": "string",
    "name": "string",
    "description": "string",
    "type": "string",
    "category": "string",
    "location": "string (area id)",
    "position": {
      "x": "number",
      "y": "number",
      "z": "number"
    },
    "scale": "number",
    "discoveryHint": "string",
    "forensicAnalysis": {
      "findings": "string",
      "tools": ["string"],
      "significance": "string"
    },
    "relatedSuspects": ["string (suspect ids)"],
    "relatedEvidence": ["string (evidence ids)"],
    "visibility": "string (visible|hidden)"
  }
]
```

| Property | Type | Description |
|----------|------|-------------|
| `id` | string | Unique identifier for evidence |
| `name` | string | Display name of the evidence |
| `description` | string | Detailed description |
| `type` | string | Physical type: "physical", "digital", "document", "biological", "trace", "audio", "video" |
| `category` | string | Evidence category: "weapon", "document", "dna", "fingerprint", "fiber", "fluid", "tool", "device" |
| `location` | string | Area ID where evidence is located |
| `position` | object | 3D position (x, y, z coordinates in meters) |
| `scale` | number | Scale factor for 3D rendering (1.0 = normal size) |
| `discoveryHint` | string | Hint for finding the evidence |
| `forensicAnalysis` | object | Analysis results and methodology |
| `relatedSuspects` | array | Suspect IDs connected to this evidence |
| `relatedEvidence` | array | Other evidence IDs that connect to this item |
| `visibility` | string | "visible" for immediately findable, "hidden" for special tools needed |

#### suspects Array

```json
"suspects": [
  {
    "id": "string",
    "name": "string",
    "title": "string",
    "age": "number",
    "description": "string",
    "motive": "string",
    "opportunity": "string",
    "alibi": {
      "claim": "string",
      "verified": "boolean",
      "verificationEvidence": "string (evidence id)"
    },
    "appearance": {
      "height": "string",
      "build": "string",
      "distinguishingFeatures": ["string"]
    },
    "relationshipToVictim": "string",
    "behavioral": {
      "stressIndicators": ["string"],
      "inconsistencies": ["string"],
      "microExpressions": ["string"]
    },
    "background": "string",
    "secrets": "string",
    "dialogue": {
      "initialApproach": "string",
      "keyQuestions": ["string"],
      "responses": {
        "question": "response"
      }
    },
    "isCulprit": "boolean",
    "culpritEvidence": ["string (evidence ids)"]
  }
]
```

| Property | Type | Description |
|----------|------|-------------|
| `id` | string | Unique identifier for suspect |
| `name` | string | Full name of suspect |
| `title` | string | Job title or role |
| `age` | number | Age of suspect |
| `description` | string | Physical and personality description |
| `motive` | string | Potential motive for the crime |
| `opportunity` | string | Whether they had opportunity to commit the crime |
| `alibi` | object | Alibi details and verification |
| `appearance` | object | Physical appearance details |
| `relationshipToVictim` | string | How they relate to the victim |
| `behavioral` | object | Behavioral analysis indicators |
| `background` | string | Background information |
| `secrets` | string | Hidden secrets that may be revealed |
| `dialogue` | object | Dialogue responses and key questions |
| `isCulprit` | boolean | Whether this suspect is the actual culprit |
| `culpritEvidence` | array | Evidence that proves guilt (if culprit) |

#### solution Object

```json
"solution": {
  "culprit": "string (suspect id)",
  "culpritIdentity": "string",
  "motive": "string",
  "weapon": "string (evidence id)",
  "method": "string",
  "timeline": "string",
  "evidence": ["string (evidence ids)"],
  "keyDeductions": [
    {
      "question": "string",
      "answer": "string",
      "relatedEvidence": ["string"]
    }
  ],
  "alternate": {
    "theoryCriminal": "string",
    "whyWrong": "string",
    "correctEvidence": "string (evidence id)"
  }
}
```

| Property | Type | Description |
|----------|------|-------------|
| `culprit` | string | ID of the actual culprit |
| `culpritIdentity` | string | Full name and details of the culprit |
| `motive` | string | The actual motive for the crime |
| `weapon` | string | Evidence ID of the weapon used |
| `method` | string | Description of how the crime was committed |
| `timeline` | string | Detailed timeline of events |
| `evidence` | array | All evidence that points to the solution |
| `keyDeductions` | array | Critical deductions needed to solve the case |
| `alternate` | object | Information about misleading clues |

#### dialogue Object

```json
"dialogue": {
  "narratorOpening": "string",
  "narratorClosing": "string",
  "caseDescription": "string",
  "victimDescription": "string",
  "crimeDescription": "string"
}
```

| Property | Type | Description |
|----------|------|-------------|
| `narratorOpening` | string | Opening narration presented to player |
| `narratorClosing` | string | Closing narration after case conclusion |
| `caseDescription` | string | Background information about the case |
| `victimDescription` | string | Details about the victim |
| `crimeDescription` | string | Description of the crime |

#### achievements Array

```json
"achievements": [
  {
    "id": "string",
    "name": "string",
    "description": "string",
    "condition": "string",
    "points": "number"
  }
]
```

| Property | Type | Description |
|----------|------|-------------|
| `id` | string | Unique identifier for achievement |
| `name` | string | Display name of achievement |
| `description` | string | What the achievement requires |
| `condition` | string | Technical condition for unlocking |
| `points` | number | Points awarded for achievement |

## Creating a New Case

### Step 1: Define Basic Information

Start with the case ID, title, and basic metadata:

```json
{
  "id": "your-case-id",
  "title": "Case Title",
  "description": "Brief case description",
  "difficulty": "beginner",
  "caseType": "theft",
  "version": "1.0",
  "created": "2024-01-15T10:30:00Z",
  "author": "Your Name",
  "estimatedPlayTime": 45
}
```

### Step 2: Add Metadata

Include tags, language, and content information:

```json
"metadata": {
  "tags": ["corporate", "mystery", "detective"],
  "language": "en",
  "region": "GLOBAL",
  "rating": "T",
  "contentWarnings": []
}
```

### Step 3: Define the Location

Create the crime scene with distinct areas:

```json
"location": {
  "name": "Corporate Office",
  "description": "A high-tech office building",
  "type": "office",
  "areas": [
    {
      "id": "main-floor",
      "name": "Main Floor",
      "description": "The main office area",
      "evidenceItems": ["evidence-id-1", "evidence-id-2"]
    }
  ]
}
```

### Step 4: Create Evidence

Define all pieces of evidence with 3D positions:

```json
"evidence": [
  {
    "id": "fingerprint-knife",
    "name": "Fingerprints on Knife",
    "description": "Latent fingerprints found on the murder weapon",
    "type": "biological",
    "category": "fingerprint",
    "location": "main-floor",
    "position": { "x": 2.5, "y": 1.0, "z": 0.0 },
    "scale": 1.0,
    "discoveryHint": "Search near the table",
    "forensicAnalysis": {
      "findings": "Matches suspect #2",
      "tools": ["fingerprint-scanner"],
      "significance": "Primary evidence linking suspect"
    },
    "relatedSuspects": ["suspect-2"],
    "relatedEvidence": ["knife-weapon"],
    "visibility": "hidden"
  }
]
```

### Step 5: Create Suspects

Define suspects with dialogue and behavioral cues:

```json
"suspects": [
  {
    "id": "suspect-1",
    "name": "John Smith",
    "title": "Manager",
    "age": 45,
    "description": "Stern manager with a hidden gambling problem",
    "motive": "Needed money quickly",
    "opportunity": "Had access to the office",
    "alibi": {
      "claim": "Was at home with family",
      "verified": true,
      "verificationEvidence": "phone-records"
    },
    "appearance": {
      "height": "5'11\"",
      "build": "Athletic",
      "distinguishingFeatures": ["Scar on left hand"]
    },
    "relationshipToVictim": "Employer",
    "behavioral": {
      "stressIndicators": ["Fidgeting", "Avoiding eye contact"],
      "inconsistencies": ["Claims not to know victim well"],
      "microExpressions": ["Brief fear when asked about finances"]
    },
    "background": "30 years in business",
    "secrets": "Has gambling debts",
    "dialogue": {
      "initialApproach": "I didn't do anything wrong!",
      "keyQuestions": [
        "Where were you on the night of the crime?",
        "Do you know anything about the victim's valuables?"
      ],
      "responses": {
        "Where were you on the night of the crime?": "I was home with my family watching TV.",
        "Do you know anything about the victim's valuables?": "No, that's not my concern."
      }
    },
    "isCulprit": false
  }
]
```

### Step 6: Define the Solution

Specify the culprit and how to solve the case:

```json
"solution": {
  "culprit": "suspect-2",
  "culpritIdentity": "Jane Doe, Employee",
  "motive": "Jealousy over promotion",
  "weapon": "evidence-knife",
  "method": "Confrontation that turned physical",
  "timeline": "10 PM on January 15th",
  "evidence": ["fingerprint-knife", "dna-blood", "security-footage"],
  "keyDeductions": [
    {
      "question": "Whose fingerprints are on the knife?",
      "answer": "Jane Doe's fingerprints match the weapon",
      "relatedEvidence": ["fingerprint-knife"]
    }
  ],
  "alternate": {
    "theoryCriminal": "John Smith seems suspicious due to gambling debts",
    "whyWrong": "His alibi is verified by phone records",
    "correctEvidence": "phone-records"
  }
}
```

### Step 7: Add Dialogue

Include opening and closing narration:

```json
"dialogue": {
  "narratorOpening": "A prominent CEO has been found dead in their office...",
  "narratorClosing": "Justice has been served. The real culprit is now in custody.",
  "caseDescription": "The victim was a successful business leader",
  "victimDescription": "Well-respected but had enemies in the business world",
  "crimeDescription": "Stabbed multiple times in the office"
}
```

### Step 8: Add Achievements

Define unlockable achievements:

```json
"achievements": [
  {
    "id": "solved-under-30min",
    "name": "Speed Investigator",
    "description": "Solve the case in under 30 minutes",
    "condition": "completionTime < 1800",
    "points": 50
  },
  {
    "id": "found-all-evidence",
    "name": "Thorough Detective",
    "description": "Find all pieces of evidence",
    "condition": "evidenceFound === evidenceTotal",
    "points": 100
  }
]
```

## Validation

Before submitting a case, ensure:

1. **All IDs are unique** - No duplicate IDs within the case
2. **References are valid** - All ID references exist (suspects, evidence)
3. **Timeline is consistent** - Events happen in logical order
4. **Solution is valid** - Culprit has sufficient evidence
5. **Dialogue is complete** - No missing narrative text
6. **Positions are realistic** - 3D coordinates make sense
7. **Evidence chain works** - Evidence points logically to solution
8. **Names are appropriate** - No real names or offensive content

## File Naming Convention

Case files should follow this naming convention:

```
{difficulty}-case-{number}.json
```

Examples:
- `tutorial-case-01.json`
- `beginner-case-01.json`
- `intermediate-case-01.json`
- `advanced-case-01.json`
- `expert-case-01.json`

## Adding Cases to the App

1. Create your case JSON file in this directory
2. Test the JSON for validity using a JSON validator
3. Load the case in the app and playtest thoroughly
4. Submit for review before public release
5. Once approved, case will be added to the app in the next update

## Testing Checklist

- [ ] Case loads without errors
- [ ] All evidence is discoverable
- [ ] All dialogue displays correctly
- [ ] Forensic tools work on evidence
- [ ] Suspects can be interrogated
- [ ] Solution can be discovered through evidence
- [ ] Achievements unlock properly
- [ ] Case can be completed in estimated time
- [ ] No game-breaking bugs or exploits
- [ ] Difficulty matches rating

## Support

For questions about case creation or the JSON schema, contact:
- **Email:** cases@mysteryinvestigation.app
- **Documentation:** [Full Documentation Wiki]
- **Community Forum:** [Detective's Guild Forum]

## License

All case files must follow the project's licensing terms. User-created cases may be shared with the community with proper attribution.
