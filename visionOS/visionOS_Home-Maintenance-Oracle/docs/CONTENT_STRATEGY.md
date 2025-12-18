# Content Acquisition & Management Strategy
## Home Maintenance Oracle

**Version**: 1.0
**Last Updated**: 2025-11-24
**Status**: Draft

---

## Overview

### Content Types

| Content | Volume Target | Sources | Update Frequency |
|---------|--------------|---------|------------------|
| Appliance Manuals | 100,000+ | Manufacturers, web scraping | Monthly |
| Tutorial Videos | 10,000+ | YouTube, partnerships | Weekly |
| Parts Database | 500,000+ parts | Supplier APIs | Daily |
| Product Specs | 50,000+ models | Manufacturers, retailers | Monthly |

---

## Manual Acquisition

### Phase 1: Manufacturer Partnerships

**Target Partners**:
- Whirlpool, GE, Samsung, LG, Bosch
- Lennox, Carrier, Trane (HVAC)
- Rheem, AO Smith (water heaters)

**Partnership Benefits**:
- Official manuals (PDF)
- Automatic updates
- Early access to new models
- Co-marketing opportunities

**Legal Agreement Template**:
```
MANUAL LICENSING AGREEMENT

1. Grant of License
   [Manufacturer] grants Home Maintenance Oracle non-exclusive
   right to display product manuals to end users.

2. Usage Rights
   - Display in app only
   - No redistribution
   - Attribution required

3. Updates
   [Manufacturer] will provide updates within 30 days of new releases

4. Fees
   No fees for non-commercial display to end users
```

### Phase 2: Web Scraping

**Legal Compliance**:
- Check robots.txt
- Respect rate limits
- Fair use for end-user benefit
- Remove on manufacturer request

**Scraping Script Example**:
```python
import requests
from bs4 import BeautifulSoup
import time

class ManualScraper:
    def __init__(self, base_url, rate_limit=1.0):
        self.base_url = base_url
        self.rate_limit = rate_limit
        self.session = requests.Session()

    def scrape_manufacturer(self, brand):
        # Find support/manuals page
        support_url = f"{self.base_url}/support"
        response = self.session.get(support_url)
        soup = BeautifulSoup(response.text, 'html.parser')

        # Find PDF links
        pdf_links = soup.find_all('a', href=re.compile(r'\.pdf$'))

        manuals = []
        for link in pdf_links:
            # Extract model number from link or text
            model = self.extract_model(link)

            manual = {
                'brand': brand,
                'model': model,
                'url': link['href'],
                'title': link.text.strip()
            }
            manuals.append(manual)

            time.sleep(self.rate_limit)  # Respect rate limit

        return manuals

    def download_pdf(self, url, destination):
        response = self.session.get(url, stream=True)
        with open(destination, 'wb') as f:
            for chunk in response.iter_content(chunk_size=8192):
                f.write(chunk)
```

### Phase 3: Crowdsourcing

**User Contributions**:
- Users upload missing manuals
- Moderation queue
- Rewards (premium features)

**Quality Control**:
1. OCR verification (readable)
2. Manual review (spot check)
3. User reports (flag incorrect)
4. Automated checks (file size, page count)

---

## Tutorial Content

### YouTube Integration

**Curated Channels**:
- RepairClinic
- AppliancePartsPros
- DIY Appliance Repair
- HVAC School
- This Old House

**API Integration**:
```swift
class YouTubeCurator {
    func searchTutorials(appliance: String, issue: String) async throws -> [Tutorial] {
        let query = "\(appliance) \(issue) repair"
        let params = [
            "part": "snippet",
            "q": query,
            "type": "video",
            "videoDuration": "medium",  // 4-20 minutes
            "relevanceLanguage": "en",
            "maxResults": "25"
        ]

        let response = try await youtubeAPI.search(params)

        // Filter by channel quality score
        return response.items
            .filter { channelScore[$0.channelId] ?? 0 > 0.7 }
            .map { Tutorial(from: $0) }
    }
}
```

**Content Quality Metrics**:
- View count > 1,000
- Like ratio > 80%
- Channel subscriber count > 10K
- Video duration: 4-20 minutes
- Published within 5 years

### Original Content (Phase 2)

**In-House Production**:
- Partner with repair professionals
- Film common repairs
- AR-optimized (spatial annotations)

**Production Pipeline**:
1. Script common repairs
2. Film in studio
3. Edit with AR markers
4. Add 3D annotations
5. Publish to app

---

## Parts Database

### Supplier APIs

**Primary Sources**:
- Amazon Product API
- eBay Finding API
- RepairClinic API
- PartSelect API

**Data Structure**:
```json
{
  "partNumber": "WR97X10006",
  "name": "GE Refrigerator Water Filter",
  "category": "water_filter",
  "compatibleModels": ["GFE28G", "GFE29H", "PFE28P"],
  "images": ["https://..."],
  "specifications": {
    "dimensions": "2.5 x 2.5 x 10 inches",
    "weight": "0.5 lbs",
    "material": "Activated carbon"
  },
  "listings": [
    {
      "supplier": "Amazon",
      "price": 39.99,
      "availability": "In Stock",
      "shipping": "Free (Prime)",
      "url": "https://amazon.com/..."
    }
  ]
}
```

### Data Update Strategy

**Real-Time Updates**:
- Price and availability: Check on user request
- Cache for 1 hour

**Batch Updates**:
- New parts: Weekly scrape
- Compatibility data: Monthly update
- Discontinued parts: Quarterly cleanup

---

## Content Storage & Delivery

### CDN Architecture

```
            [User Request]
                  │
                  ▼
         [CloudFront CDN]
         /       │       \
        /        │        \
   [US-East] [EU-West] [Asia-Pacific]
       │        │           │
       └────────┴───────────┘
                │
          [S3 Bucket]
        /      |      \
    Manuals  Videos  Images
```

**Storage Strategy**:
- Manuals: S3 + CloudFront
- Videos: YouTube (embedded) or S3
- Images: S3 + CloudFront
- Database: RDS (PostgreSQL)

**Cost Optimization**:
- S3 Intelligent-Tiering
- CloudFront compression
- Image optimization (WebP)
- Lazy loading

### Content Deduplication

```python
import hashlib

class ContentDeduplicator:
    def __init__(self, database):
        self.db = database
        self.hash_index = {}

    def add_manual(self, file_path, metadata):
        # Calculate file hash
        file_hash = self.calculate_hash(file_path)

        # Check if already exists
        if file_hash in self.hash_index:
            existing_id = self.hash_index[file_hash]
            # Link to existing file
            self.db.add_reference(metadata, existing_id)
            return existing_id

        # New file, upload
        file_id = self.upload_to_s3(file_path)
        self.hash_index[file_hash] = file_id
        self.db.add_manual(metadata, file_id)

        return file_id

    def calculate_hash(self, file_path):
        sha256 = hashlib.sha256()
        with open(file_path, 'rb') as f:
            for chunk in iter(lambda: f.read(4096), b''):
                sha256.update(chunk)
        return sha256.hexdigest()
```

---

## Content Moderation

### Automated Checks

```python
class ContentModerator:
    def validate_manual(self, pdf_path):
        checks = {
            'readable': self.check_readable(pdf_path),
            'valid_pdf': self.check_valid_pdf(pdf_path),
            'language': self.check_language(pdf_path),
            'page_count': self.check_page_count(pdf_path),
            'file_size': self.check_file_size(pdf_path)
        }

        return all(checks.values()), checks

    def check_readable(self, pdf_path):
        # OCR a sample page
        text = ocr_engine.extract_text(pdf_path, page=0)
        word_count = len(text.split())
        return word_count > 50  # Minimum text threshold

    def check_language(self, pdf_path):
        text = ocr_engine.extract_text(pdf_path, page=0)
        detected = langdetect.detect(text)
        return detected == 'en'  # English only for MVP
```

### Manual Review

**Review Queue**:
- User-uploaded content
- Low-confidence OCR
- Flagged by users

**Review Interface**:
```swift
struct ContentReviewView: View {
    let item: PendingContent

    var body: some View {
        VStack {
            PDFViewer(document: item.pdf)

            HStack {
                Button("Approve") {
                    approve(item)
                }
                .buttonStyle(.borderedProminent)

                Button("Reject") {
                    reject(item)
                }
                .buttonStyle(.bordered)

                Button("Edit Metadata") {
                    editMetadata(item)
                }
            }
        }
    }
}
```

---

## Content Licensing

### Copyright Compliance

**Fair Use Assessment**:
- ✅ Transformative use (search and discovery)
- ✅ Non-commercial (end users)
- ✅ Limited distribution (app only)
- ✅ No market harm (increases product value)

**DMCA Safe Harbor**:
- Designated agent registered
- Takedown process implemented
- Repeat infringer policy

**Takedown Process**:
```swift
class DMCACompliance {
    func handleTakedownNotice(_ notice: DMCANotice) async {
        // 1. Verify legitimacy
        guard verify(notice) else { return }

        // 2. Remove content within 24 hours
        try await removeContent(notice.contentId)

        // 3. Notify uploader (if user-generated)
        if let uploaderId = getUploader(notice.contentId) {
            notify(uploaderId, about: notice)
        }

        // 4. Log for compliance
        logTakedown(notice, timestamp: Date())

        // 5. Respond to complainant
        sendConfirmation(to: notice.complainant)
    }
}
```

---

## Content Quality Metrics

### Manual Quality Score

```python
def calculate_quality_score(manual):
    score = 0

    # Source (0-30 points)
    if manual.source == 'manufacturer':
        score += 30
    elif manual.source == 'verified_user':
        score += 20
    else:
        score += 10

    # Completeness (0-25 points)
    if manual.page_count > 20:
        score += 25
    elif manual.page_count > 10:
        score += 15
    else:
        score += 5

    # Readability (0-25 points)
    ocr_quality = check_ocr_quality(manual)
    score += ocr_quality * 25

    # Recency (0-20 points)
    age_years = (datetime.now() - manual.publish_date).days / 365
    if age_years < 2:
        score += 20
    elif age_years < 5:
        score += 15
    elif age_years < 10:
        score += 10
    else:
        score += 5

    return score
```

### Tutorial Quality Score

```python
def calculate_tutorial_score(tutorial):
    score = 0

    # View count (0-20 points)
    if tutorial.views > 100000:
        score += 20
    elif tutorial.views > 10000:
        score += 15
    elif tutorial.views > 1000:
        score += 10

    # Engagement (0-30 points)
    like_ratio = tutorial.likes / (tutorial.likes + tutorial.dislikes)
    score += like_ratio * 30

    # Channel quality (0-25 points)
    channel_score = get_channel_score(tutorial.channel_id)
    score += channel_score * 25

    # Recency (0-15 points)
    age_years = (datetime.now() - tutorial.published).days / 365
    if age_years < 1:
        score += 15
    elif age_years < 3:
        score += 10
    elif age_years < 5:
        score += 5

    # Duration (0-10 points)
    if 4 <= tutorial.duration_minutes <= 20:
        score += 10
    elif 2 <= tutorial.duration_minutes <= 30:
        score += 5

    return score
```

---

## Search & Discovery

### Search Algorithm

```python
class ContentSearch:
    def search(self, query, content_type='all'):
        # Parse query
        appliance_type = extract_appliance(query)
        brand = extract_brand(query)
        model = extract_model(query)
        issue = extract_issue(query)

        # Build search
        results = []

        if content_type in ['manual', 'all']:
            manuals = self.search_manuals(brand, model)
            results.extend(manuals)

        if content_type in ['tutorial', 'all']:
            tutorials = self.search_tutorials(appliance_type, issue)
            results.extend(tutorials)

        if content_type in ['part', 'all']:
            parts = self.search_parts(model, issue)
            results.extend(parts)

        # Rank by relevance and quality
        ranked = self.rank_results(results, query)

        return ranked

    def rank_results(self, results, query):
        for result in results:
            # Relevance score (TF-IDF)
            relevance = calculate_relevance(result, query)

            # Quality score
            quality = result.quality_score / 100

            # Recency bonus
            recency = calculate_recency_bonus(result)

            # Combined score
            result.score = (relevance * 0.5) + (quality * 0.3) + (recency * 0.2)

        return sorted(results, key=lambda x: x.score, reverse=True)
```

---

**Document Status**: Ready for Review
**Next Steps**: Begin content acquisition, set up CDN, implement scraping pipeline
