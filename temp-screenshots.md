# Dharma App Store Screenshots - Progress Log

## Project Overview
- **App:** Dharma - Spirituality app for Buddhism & Hinduism
- **Platform:** iOS (iPhone 6.7" - 1290x2796px)
- **Brand Color:** #EA580C (Orange-Coral)

## Benefits (Reordered per user request)
1. **BUILD DAILY RITUALS** → Today tab (Screenshot 1) ✅
2. **CHAT AI GUIDANCE** → Chat tab (Screenshot 2) ⏳
3. **STRENGTHEN YOUR PRACTICE** → Daily Verse (Screenshot 3) ⏳
4. **DISCOVER SACRED WISDOM** → Scriptures tab (Screenshot 4) ⏳

## Completed Work

### 1. Screenshot Analysis
- Reviewed 4 simulator screenshots
- Status bars need cleanup but content is usable
- Reordered per user preference (Today #1, Scriptures #4)

### 2. Scaffolds Generated
All 4 scaffolds created at:
- `screenshots/01-build-daily-rituals/scaffold.png`
- `screenshots/02-chat-ai-guidance/scaffold.png`
- `screenshots/03-strengthen-practice/scaffold.png`
- `screenshots/04-discover-wisdom/scaffold.png`

### 3. Screenshot 1 - COMPLETE ✅
**Benefit:** BUILD DAILY RITUALS
**Selected:** v3 (with floating lotus elements)

**Location:**
- Working: `screenshots/01-build-daily-rituals/v3.png`
- Final: `screenshots/final/01-build-daily-rituals.png`

**Visual Elements:**
- Bold white headline: "BUILD DAILY RITUALS"
- Photorealistic iPhone 15 Pro mockup
- Today tab showing Dharma's Journey with tasks
- Floating lotus/spiritual decorative elements
- Solid orange #EA580C background

## Code for Successful Generation

### Prerequisites
```bash
# Ensure Python 3 and curl are available
python3 --version
curl --version
```

### Scaffold Generation (compose.py)
```bash
SKILL_DIR="/Users/brandon/Coding/dharma-app/.agents/skills/aso-appstore-screenshots"

python3 "$SKILL_DIR/compose.py" \
  --bg "#EA580C" --verb "BUILD" --desc "DAILY RITUALS" \
  --screenshot simulator-screenshots/03-today.png \
  --output screenshots/01-build-daily-rituals/scaffold.png
```

### Image Enhancement (Gemini API)
```bash
GEMINI_API_KEY="AIzaSyDjFlnsLq6KeGkzA7mT14Lb4jwSanoedTE"
SCAFFOLD_PATH="screenshots/01-build-daily-rituals/scaffold.png"

# Convert image to base64
BASE64_IMG=$(python3 -c "
import base64
with open('$SCAFFOLD_PATH', 'rb') as f:
    print(base64.b64encode(f.read()).decode('utf-8'))
")

# Generate with Gemini
curl -s -X POST "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash-image:generateContent?key=$GEMINI_API_KEY" \
  -H "Content-Type: application/json" \
  -d "{
    \"contents\": [{
      \"parts\": [
        {\"inline_data\": {\"mime_type\": \"image/png\", \"data\": \"$BASE64_IMG\"}},
        {\"text\": \"Transform this App Store screenshot scaffold into a polished, professional marketing image. Keep the headline text BUILD DAILY RITUALS in the same position. Replace the device frame with a photorealistic iPhone 15 Pro mockup with sleek black frame, dynamic island, subtle shadows and reflections. The background is solid orange #EA580C. Add floating lotus/spiritual decorative elements around the device. Make it look high-converting and App Store ready.\"}
      ]
    }],
    \"generationConfig\": {\"responseModalities\": [\"Text\", \"Image\"]}
  }"
```

### Crop & Resize to App Store Dimensions
```bash
TARGET_W=1290
TARGET_H=2796
INPUT="screenshots/01-build-daily-rituals/v3.png"
OUTPUT="screenshots/01-build-daily-rituals/v3-resized.jpg"

# Copy and process
cp "$INPUT" "$OUTPUT"
W=$(sips -g pixelWidth "$OUTPUT" | tail -1 | awk '{print $2}')
H=$(sips -g pixelHeight "$OUTPUT" | tail -1 | awk '{print $2}')
CROP_W=$(python3 -c "print(round($H * $TARGET_W / $TARGET_H))")
OFFSET_X=$(python3 -c "print(round(($W - $CROP_W) / 2))")
sips --cropOffset 0 $OFFSET_X --cropToHeightWidth $H $CROP_W "$OUTPUT"
sips -z $TARGET_H $TARGET_W "$OUTPUT"
echo "Resized to: $TARGET_W x $TARGET_H"
```

## Remaining Tasks

### Screenshot 2: CHAT AI GUIDANCE
- **Scaffold:** `screenshots/02-chat-ai-guidance/scaffold.png`
- **Style Template:** `screenshots/final/01-build-daily-rituals.png`
- **App Screen:** Chat tab with Spiritual Guidance showing Four Noble Truths
- **Breakout:** Chat message panel extending beyond device edges
- **Status:** ⏳ PENDING

### Screenshot 3: STRENGTHEN YOUR PRACTICE
- **Scaffold:** `screenshots/03-strengthen-practice/scaffold.png`
- **Style Template:** Use Screenshot 1 or 2 as reference
- **App Screen:** Daily Verse detail with lotus icon
- **Breakout:** Verse text panel or reflection options card
- **Status:** ⏳ PENDING

### Screenshot 4: DISCOVER SACRED WISDOM
- **Scaffold:** `screenshots/04-discover-wisdom/scaffold.png`
- **Style Template:** Use previous screenshots as reference
- **App Screen:** Scriptures tab with Bhagavad Gita verses
- **Breakout:** Scripture text panel or chapter navigation
- **Status:** ⏳ PENDING

## Notes
- All screenshots target iPhone 6.7" (1290x2796px)
- Brand color consistently: #EA580C (Orange-Coral)
- Style template ensures visual consistency across all 4 screenshots
- Final images saved to `screenshots/final/` directory

## Files Created
```
screenshots/
├── 01-build-daily-rituals/
│   ├── scaffold.png
│   ├── v1.png
│   ├── v2.png
│   └── v3.png (approved) ⭐
├── 02-chat-ai-guidance/
│   └── scaffold.png
├── 03-strengthen-practice/
│   └── scaffold.png
├── 04-discover-wisdom/
│   └── scaffold.png
└── final/
    └── 01-build-daily-rituals.png ⭐
```

---

**Last Updated:** 2026-04-02
**Status:** 1 of 4 screenshots complete, 3 pending
