# MySpatial Life - Quick Start Guide

**Want to run the app in 10 minutes?** Follow this guide.

---

## ⚡ Super Quick Start (10 Minutes)

### 1️⃣ Check Prerequisites (1 minute)

```bash
# Do you have these?
xcodebuild -version  # Need 16.0+
xcodebuild -showsdks | grep visionOS  # Need visionOS 2.0+
```

✅ Have Mac with Apple Silicon (M1/M2/M3)
✅ Have macOS Sonoma or later
✅ Have Xcode 16.0+ installed

**Don't have Xcode?** Install from Mac App Store first (this takes a while).

---

### 2️⃣ Get the Code (1 minute)

```bash
git clone https://github.com/akaash-nigam/visionOS_Gaming_myspatial-life.git
cd visionOS_Gaming_myspatial-life
```

---

### 3️⃣ Create Xcode Project (8 minutes)

**Option A: Follow the detailed guide** (recommended)
```bash
open SETUP_XCODE_PROJECT.md
# Follow the step-by-step instructions
```

**Option B: Quick version** (if you know Xcode well)

1. **Create Project**
   - Xcode → New Project → visionOS → App
   - Name: `MySpatialLife`
   - Save OUTSIDE this repo folder

2. **Add Source Files**
   - Delete Xcode's auto-generated files
   - Right-click project → Add Files
   - Select `MySpatialLife/MySpatialLife/` folder
   - ✅ Copy items, ✅ Create groups, ✅ Add to target

3. **Add Capabilities**
   - Target → Signing & Capabilities
   - Add: ARKit, World Sensing, Hand Tracking

4. **Add Packages**
   - File → Add Package Dependencies
   - Add:
     - `https://github.com/apple/swift-algorithms`
     - `https://github.com/apple/swift-collections`
     - `https://github.com/apple/swift-numerics`

5. **Build & Run**
   - Select "Apple Vision Pro" simulator
   - Press `Cmd+R`

---

### 4️⃣ Verify It Works

```bash
# In Xcode:
Cmd+B  # Build - should succeed
Cmd+U  # Test - 75+ tests should pass
Cmd+R  # Run - app should launch
```

**You should see:**
- Main menu with "New Family" button
- Can create a family
- Basic game view appears

---

## 🆘 Troubleshooting

### "Build Failed"
```bash
# Clean and rebuild
Cmd+Shift+K  # Clean
Cmd+B        # Build again
```

### "Module not found"
- Make sure you added files with "Create groups" (not folder references)
- Check target membership in File Inspector

### "Signing error"
- Select your team in Signing & Capabilities
- Enable "Automatically manage signing"

### "Tests fail"
- Make sure test files added to test target
- Clean build folder and retry

---

## 📖 What to Read Next

**After it runs:**
1. Play with the app (5 min)
2. Read [PROJECT_SUMMARY.md](PROJECT_SUMMARY.md) (10 min)
3. Skim [ARCHITECTURE.md](ARCHITECTURE.md) (20 min)
4. Plan your first feature (use [IMPLEMENTATION_PLAN.md](IMPLEMENTATION_PLAN.md))

---

## 🎯 What You'll See

**Main Menu:**
- Title: "MySpatial Life"
- Buttons: Continue, **New Family** ✅, Load Game, Settings

**Family Creation:**
- Enter family name
- Select size (2-4 members)
- **Start Game** button

**Game View:**
- Blue placeholder cube (future character)
- Family name and info
- HUD overlay

**What's Working Under the Hood:**
- ✅ All personality calculations
- ✅ Relationship progression
- ✅ Career system
- ✅ Memory formation
- ✅ 75+ unit tests passing

---

## 🚀 Next Steps

**Once running:**

1. **Explore the Code** (30 min)
   - Open `Character.swift` - See the data model
   - Open `Personality.swift` - See AI calculations
   - Open `CharacterRelationship.swift` - See social dynamics
   - Run tests and see them pass

2. **Read Documentation** (2-4 hours)
   - [ARCHITECTURE.md](ARCHITECTURE.md) - How it's built
   - [TECHNICAL_SPEC.md](TECHNICAL_SPEC.md) - Implementation details
   - [DESIGN.md](DESIGN.md) - Game design
   - [IMPLEMENTATION_PLAN.md](IMPLEMENTATION_PLAN.md) - What's next

3. **Start Coding** (Week 2+)
   - Implement Needs System (see Phase 2 in plan)
   - Build AI Decision Making
   - Add Spatial Features
   - Create 3D characters

---

## 💡 Pro Tips

**Development:**
- Use `Cmd+B` frequently to catch errors early
- Run tests (`Cmd+U`) before committing
- Use breakpoints to understand the code
- Check Instruments for performance

**Learning:**
- Start with test files - they show how systems work
- Read inline code comments
- Follow the architecture patterns
- Reference Apple's visionOS docs

**Building Features:**
- Follow the IMPLEMENTATION_PLAN.md phases
- Write tests first (TDD)
- Keep 60 FPS target in mind
- Test on device, not just simulator

---

## 📊 Success Metrics

**You've succeeded when:**
- ✅ Project builds without errors
- ✅ All 75+ tests pass
- ✅ App launches in simulator
- ✅ Can create a family
- ✅ Understand the architecture (after reading docs)

---

## 🎓 Learning Path

**Day 1:** Setup + Run + Explore code (1-2 hours)
**Day 2-3:** Read all documentation (4-6 hours)
**Week 2:** Implement first feature (Needs System)
**Week 3-4:** Build AI Decision Making
**Week 5-6:** Add Spatial Integration
**Week 7+:** Continue with roadmap

---

## ❓ Common Questions

**Q: Can I run this on my iPhone/iPad?**
A: No, it's visionOS only. But you can use the Vision Pro simulator.

**Q: Do I need a Vision Pro device?**
A: No! Simulator works great for development. Device testing comes later.

**Q: Is this open source?**
A: Check the repository license. Currently proprietary.

**Q: How much is complete?**
A: ~60% of MVP. All hard work done. Core systems ready.

**Q: Can I modify it?**
A: Yes! That's the point. Build on this foundation.

**Q: Where's the 3D models?**
A: Not included. You'll add them in Phase 3. For now, placeholders work.

---

## 📞 Get Help

**Issues running?**
1. Check [SETUP_XCODE_PROJECT.md](SETUP_XCODE_PROJECT.md) troubleshooting
2. Check [TODO_visionOS_env.md](TODO_visionOS_env.md) for environment issues
3. Search Apple Developer Forums
4. Check project GitHub issues

**Architecture questions?**
1. Read [ARCHITECTURE.md](ARCHITECTURE.md)
2. Read [TECHNICAL_SPEC.md](TECHNICAL_SPEC.md)
3. Look at test files for examples

**Design questions?**
1. Read [DESIGN.md](DESIGN.md)
2. Check [MySpatial-Life-PRD.md](MySpatial-Life-PRD.md)

---

## 🎯 Your Goal Today

**By end of today:**
- [x] Xcode project created
- [x] App builds successfully
- [x] Tests pass
- [x] App runs in simulator
- [x] Understand what's built vs what's TODO

**Tomorrow:**
- [ ] Read documentation
- [ ] Understand architecture
- [ ] Plan first feature

---

**Time to create Xcode project: 10 minutes**
**Time to first build: 11 minutes**
**Time to understand basics: 1 hour**
**Time to start coding features: Day 2**

---

# Ready? Let's Go! 🚀

**Your first command:**
```bash
open SETUP_XCODE_PROJECT.md
```

**Then follow the guide. You've got this!** 💪
