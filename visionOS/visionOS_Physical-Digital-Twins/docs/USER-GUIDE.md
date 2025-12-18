# Physical-Digital Twins User Guide

Welcome to Physical-Digital Twins! This guide will help you get the most out of your inventory management experience on Apple Vision Pro.

---

## Table of Contents

1. [Getting Started](#getting-started)
2. [Home Dashboard](#home-dashboard)
3. [Adding Items](#adding-items)
   - [Barcode Scanning](#barcode-scanning)
   - [Manual Entry](#manual-entry)
4. [Managing Your Inventory](#managing-your-inventory)
   - [Viewing Your List](#viewing-your-list)
   - [Searching and Filtering](#searching-and-filtering)
   - [Sorting](#sorting)
5. [Item Details](#item-details)
6. [Editing Items](#editing-items)
7. [Photo Management](#photo-management)
8. [Deleting Items](#deleting-items)
9. [Tips & Tricks](#tips--tricks)
10. [Troubleshooting](#troubleshooting)

---

## Getting Started

### First Launch

When you first open Physical-Digital Twins, you'll see:

1. **Welcome Screen** - Brief introduction to the app
2. **Permission Requests** - The app will request:
   - **Camera Access** - Required for barcode scanning
   - **Photo Library Access** - Optional, for adding photos to items

**Tip:** You can always change these permissions later in Settings → Privacy.

### Quick Tour

The app has three main sections accessible via the tab bar:

- **🏠 Home** - Dashboard with stats and quick actions
- **📦 Inventory** - Your complete item list
- **⚙️ Settings** - App preferences (coming in future updates)

---

## Home Dashboard

Your control center for inventory management.

### What You'll See

1. **Welcome Message** - Personalized greeting
2. **Statistics Cards**
   - **Total Items** - Number of items in your inventory
   - **Total Value** - Combined purchase price of all items
   - **Recent Count** - Items added in the last 7 days

3. **Quick Actions**
   - **Scan Barcode** - Jump straight to camera scanner
   - **Add Manually** - Create new item with form
   - **Browse Inventory** - View all items

4. **Recent Items** - Last 5 items you added

**Tip:** Tap any statistic card to view related items in your inventory.

---

## Adding Items

### Barcode Scanning

The fastest way to add items to your inventory.

#### Supported Barcode Types

- ✅ **ISBN** (EAN-13, EAN-8) - Books
- ✅ **UPC-A** - Most retail products
- ✅ **UPC-E** - Compact UPC codes
- ✅ **QR Codes** - Quick Response codes
- ✅ **Code 128** - Common barcode standard
- ✅ **Code 39** - Industrial barcodes
- ✅ **ITF14** - Shipping containers

#### How to Scan

1. **Open Scanner**
   - Tap "Scan Barcode" on Home
   - Or tap "+" → "Scan Barcode" in Inventory

2. **Position the Barcode**
   - Hold the item steady
   - Ensure good lighting
   - Keep barcode 6-12 inches from Vision Pro
   - Wait for the scanning frame to turn green

3. **Automatic Recognition**
   - The app detects the barcode automatically
   - For books (ISBN), product details are fetched from Google Books
   - You'll see a preview of the item

4. **Save**
   - Review the details
   - Tap "Add to Inventory"
   - The item appears in your list instantly!

#### Scanning Tips

✨ **Best Practices:**
- Use adequate lighting (natural light is best)
- Keep the barcode flat (not curved or crumpled)
- Clean the barcode if dirty
- Try different distances if not detecting

❌ **Common Issues:**
- Too close/far → Adjust distance to 6-12 inches
- Poor lighting → Move to brighter location
- Damaged barcode → Try manual entry instead
- No internet → API lookup won't work (add manually)

### Manual Entry

Add items without barcodes or when you want complete control.

#### How to Add Manually

1. **Open Form**
   - Tap "Add Manually" on Home
   - Or tap "+" → "Add Manually" in Inventory

2. **Fill in Details**

   **Required Fields:**
   - **Title** - Item name (e.g., "Atomic Habits")

   **Optional Fields:**
   - **Author** - Creator or brand
   - **ISBN** - If known (will trigger API lookup)
   - **Purchase Price** - How much you paid
   - **Purchase Date** - When you bought it
   - **Purchase Location** - Where you bought it
   - **Location** - Where it's stored now
   - **Condition** - Select from dropdown
     - Mint
     - Like New
     - Very Good
     - Good
     - Acceptable
     - Poor
   - **Notes** - Any additional information

3. **Optional: API Enrichment**
   - If you enter an ISBN, tap "Fetch from API"
   - The app will retrieve book details automatically
   - Fields will be populated with API data

4. **Save**
   - Tap "Save" when done
   - The item appears in your inventory!

#### Manual Entry Tips

- **ISBN Lookup:** Enter ISBN and tap "Fetch from API" before filling other fields
- **Photos:** You can add photos after creating the item (see Photo Management)
- **Location Hierarchy:** Use consistent location names (e.g., "Living Room → Bookshelf A")
- **Notes:** Great for serial numbers, warranty info, or sentimental value

---

## Managing Your Inventory

### Viewing Your List

Your inventory list shows all your items in one place.

#### What You'll See

Each item displays:
- **Cover Image** (if available) or placeholder icon
- **Title** - Item name
- **Subtitle** - Author or brand
- **Additional Info** - Location, purchase date, etc.

#### Navigation

- **Tap an item** - View full details
- **Swipe to delete** - Remove items quickly
- **Pull down** - Refresh the list (with smooth animation!)

### Searching and Filtering

Find exactly what you're looking for.

#### Search Bar

Located at the top of the Inventory screen.

**What You Can Search:**
- Item titles
- Authors/creators
- ISBN codes
- Locations
- Notes
- Any text field

**How to Search:**
1. Tap the search bar
2. Type your query
3. Results filter instantly as you type
4. Tap "Cancel" or clear text to show all items

#### Category Filter

Filter by predefined categories:

- **All Items** - Show everything
- **Books** - Book-type items
- **Recently Added** - Items from last 7 days
- **High Value** - Items over $50 (coming soon)
- **Custom Categories** - Create your own (coming soon)

**How to Filter:**
1. Tap the filter icon (coming in future update)
2. Select a category
3. View filtered results

### Sorting

Organize your list the way you want.

**Sort Options:** (Coming in future update)
- Date Added (Newest First)
- Date Added (Oldest First)
- Title (A-Z)
- Title (Z-A)
- Value (High to Low)
- Value (Low to High)

---

## Item Details

View comprehensive information about any item.

### Information Displayed

**Header Section:**
- Cover image or placeholder
- Title and author
- ISBN (if applicable)
- Recognition method badge

**Metadata Section:**
- **Purchase Info**
  - Price
  - Date
  - Location
- **Physical Info**
  - Condition
  - Current location
- **Book-Specific** (for books)
  - Publisher
  - Publish date
  - Page count
  - Categories

**Notes Section:**
- Your custom notes

**Photos Section:**
- Preview of attached photos (up to 5 thumbnails)
- "View Gallery" button if photos exist

**Actions:**
- **Edit Item** - Modify any field
- **Delete Item** - Remove from inventory (with confirmation)

### Gestures

- **Scroll** - See all information
- **Tap Edit** - Modify the item
- **Tap photo preview** - Open full gallery
- **Back button** - Return to inventory list

---

## Editing Items

Update item details anytime.

### How to Edit

1. **Open Item Details**
   - Tap an item in your inventory

2. **Tap Edit Item**
   - Button at the top of detail view

3. **Modify Fields**
   - All fields are editable
   - Changes are auto-saved as you type
   - Or tap "Save" when done

4. **Save Changes**
   - Tap "Save" to confirm
   - Or "Cancel" to discard changes

### What You Can Edit

✅ Everything! Including:
- Title, author, ISBN
- Purchase info (price, date, location)
- Current location
- Condition
- Notes
- Reading status (for books)

❌ What You Can't Change:
- Item ID (internal identifier)
- Creation date
- Recognition method (manual vs. scanned)

---

## Photo Management

Document your items visually.

### Adding Photos

#### Method 1: From Item Details

1. Open item details
2. Tap "View Gallery" (or "Add Photos" if none yet)
3. Tap "+" button
4. Select up to 5 photos from your library
5. Photos are added instantly!

#### Method 2: During Editing

1. Edit an item
2. Scroll to Photos section (coming soon)
3. Add photos inline

### Photo Gallery

View and manage all photos for an item.

**Features:**
- **Grid Layout** - 3 columns
- **Fullscreen View** - Tap any photo to enlarge
- **Zoom** - Pinch to zoom in fullscreen mode
- **Delete** - Trash icon to remove photos
- **Multi-Select** - Add up to 5 photos at once

### Photo Tips

📸 **Best Practices:**
- **Front Cover** - Main product image
- **Back Cover** - Additional details
- **Serial Numbers** - For warranty purposes
- **Condition** - Document wear and tear
- **Receipts** - Keep purchase records

💾 **Storage:**
- Photos are stored locally on your device
- JPEG format at 80% quality (good balance of quality/size)
- Each photo: ~500KB-2MB depending on content

🗑️ **Deletion:**
- When you delete an item, all photos are deleted automatically
- When you delete individual photos, they're removed permanently

---

## Deleting Items

Remove items you no longer need.

### Method 1: Swipe to Delete (Quick)

1. In Inventory list
2. Swipe left on any item
3. Tap red "Delete" button
4. Confirm deletion

### Method 2: From Item Details

1. Open item details
2. Scroll to bottom
3. Tap "Delete Item"
4. Confirm deletion

### What Gets Deleted

When you delete an item:
- ✅ Item record is removed
- ✅ All photos are deleted
- ✅ All metadata is erased
- ❌ Action cannot be undone!

**Tip:** Consider exporting data before deleting if you might need it later (export feature coming soon).

---

## Tips & Tricks

### Pro User Tips

#### 1. Batch Scanning
- Scan multiple items in one session
- After each scan, tap "Scan Another"
- Fastest way to catalog a large collection

#### 2. Consistent Naming
- Use consistent location names:
  - Good: "Living Room → Bookshelf A → Shelf 3"
  - Avoid: Sometimes "living rm", sometimes "Living Room"
- Makes searching easier later

#### 3. Use Notes Effectively
- Serial numbers for electronics
- Warranty expiration dates
- Gift-giving history ("Given to John on 12/25/23")
- Lending status ("Loaned to Sarah")

#### 4. Purchase Tracking
- Always enter purchase price and date
- Use consistent location format
- Helps with insurance claims and resale value

#### 5. Photo Strategy
- Photo 1: Front/main view
- Photo 2: Back/details
- Photo 3: Serial number/barcode
- Photo 4: Condition issues
- Photo 5: Receipt or packaging

### Keyboard Shortcuts (Coming Soon)

- **⌘ + N** - New item (manual entry)
- **⌘ + S** - Scan barcode
- **⌘ + F** - Focus search bar
- **⌘ + E** - Edit selected item
- **⌘ + Delete** - Delete selected item

### Haptic Feedback

Physical-Digital Twins uses haptic feedback for:
- ✅ Item added successfully (success vibration)
- ✅ Barcode detected (light tap)
- ✅ Photo added (light tap)
- 📸 Scan in progress (subtle feedback)
- ❌ Error occurred (error vibration)
- 🗑️ Item deleted (medium tap)

**Tip:** If you prefer no haptics, you can disable them in Settings (coming soon).

---

## Troubleshooting

### Common Issues and Solutions

#### Barcode Won't Scan

**Problem:** Camera doesn't detect the barcode

**Solutions:**
1. **Check Lighting**
   - Move to brighter location
   - Avoid direct sunlight (causes glare)
   - Use indirect natural light

2. **Check Distance**
   - Hold 6-12 inches from Vision Pro
   - Try moving closer/farther

3. **Check Barcode Condition**
   - Flatten curved barcodes
   - Clean dirty barcodes
   - If damaged, try manual entry

4. **Check Permissions**
   - Settings → Privacy → Camera
   - Ensure Physical-Digital Twins has access

5. **Restart**
   - Close and reopen the app
   - Restart Vision Pro if issue persists

#### "No Internet Connection" Warning

**Problem:** Can't fetch API data

**Solutions:**
- Check Wi-Fi connection
- Google Books API might be down (try again later)
- Use manual entry as fallback
- Most features work offline anyway!

#### Photos Won't Load

**Problem:** Photos show as blank or missing

**Solutions:**
1. **Check Photo Library Permission**
   - Settings → Privacy → Photos
   - Grant Physical-Digital Twins access

2. **Check Storage**
   - Ensure device has available storage
   - Delete unnecessary photos/apps

3. **Re-add Photos**
   - Delete the problematic photo
   - Add it again from library

#### App is Slow

**Problem:** App feels laggy or unresponsive

**Solutions:**
1. **Close Background Apps**
   - Too many apps open can slow performance

2. **Restart App**
   - Completely quit and reopen

3. **Restart Device**
   - Turn Vision Pro off and on

4. **Check Inventory Size**
   - Very large inventories (1000+ items) may be slower
   - Consider archiving old items (coming soon)

#### Items Disappeared

**Problem:** Can't find items in inventory

**Solutions:**
1. **Check Search/Filter**
   - Clear any active search text
   - Reset category filters to "All Items"

2. **Pull to Refresh**
   - Swipe down on inventory list
   - Reloads data from storage

3. **Check iCloud Backup**
   - If you recently restored device
   - Check if backup is recent

#### Can't Delete Item

**Problem:** Delete button doesn't work

**Solutions:**
1. **Confirm Deletion**
   - Ensure you tap "Confirm" in dialog

2. **Check for Errors**
   - Look for error message
   - Note the error and contact support

3. **Force Close App**
   - Quit app completely
   - Reopen and try again

### Still Need Help?

If you can't resolve an issue:

1. **Check FAQ** - See [FAQ.md](FAQ.md)
2. **GitHub Issues** - Report bugs at [github.com/your-repo/issues]
3. **Email Support** - [your-email@example.com]
4. **Community Forum** - [coming soon]

### Reporting Bugs

When reporting a bug, include:
- Device model (Apple Vision Pro)
- visionOS version
- App version (Settings → About)
- Steps to reproduce
- Screenshots if possible
- What you expected vs. what happened

---

## Frequently Asked Questions

See [FAQ.md](FAQ.md) for common questions about:
- Pricing and subscriptions
- Data privacy and security
- Feature requests
- Platform availability
- And more!

---

## What's Next?

### Coming Soon

🔮 **AR Visualization** - See items in 3D space
🤖 **ML Object Recognition** - Scan without barcodes
☁️ **iCloud Sync** - Access across devices
🔔 **Expiration Tracking** - Notifications for food items
📦 **Bulk Import/Export** - CSV and PDF exports
🏷️ **Custom Categories** - Organize your way

### Stay Updated

- **Follow on Twitter** - [@yourhandle]
- **Join Newsletter** - [your-site.com/newsletter]
- **Watch GitHub** - Get notified of new releases

---

## Feedback

We'd love to hear from you!

**What do you love?** Tell us what's working well.
**What can we improve?** Share your suggestions.
**Found a bug?** Report it on GitHub.

**Contact:** [your-email@example.com]

---

**Version:** 1.0
**Last Updated:** December 1, 2024

Thank you for using Physical-Digital Twins! 📦✨
