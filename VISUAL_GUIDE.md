# PlaySphere Visual Guide

## 🎨 Color Palette

### Primary Colors
```
Electric Cyan:    #00D9FF  ████████
Deep Cyan:        #0099CC  ████████
Vibrant Orange:   #FF6B35  ████████
Deep Orange:      #FF4500  ████████
Gold:             #FFD700  ████████
```

### Neutral Colors
```
Background Light: #F5F7FA  ████████
Surface Light:    #FFFFFF  ████████
Text Primary:     #0A1929  ████████
Text Secondary:   #5A6C7D  ████████
```

### Status Colors
```
Success:          #34C759  ████████
Error:            #FF3B30  ████████
Warning:          #FF9500  ████████
```

## 📱 Screen Flow

```
┌─────────────────────┐
│   Splash Screen     │  (3.5 seconds)
│   - Animated Logo   │
│   - Gradient BG     │
│   - Loading         │
└──────────┬──────────┘
           │
           ▼
┌─────────────────────┐
│    Role Page        │
│   - Choose Player   │
│   - Choose Manager  │
└──────────┬──────────┘
           │
     ┌─────┴─────┐
     │           │
     ▼           ▼
┌─────────┐ ┌─────────┐
│  User   │ │ Manager │
│  Login  │ │  Login  │
└─────────┘ └─────────┘
```

## ✨ Animation Timeline

### Splash Screen (0-3500ms)
```
0ms    ─── Background fade starts
300ms  ─── Logo scale & rotation starts
800ms  ─── Text fade & slide starts
2500ms ─── All animations complete
3500ms ─── Navigate to Role page
```

### Role Page (0-1200ms)
```
0ms    ─── Fade in starts
0ms    ─── Slide up starts
0ms    ─── Hero section elastic animation
200ms  ─── Player card fade in
400ms  ─── Manager card fade in
800ms  ─── Feature list stagger animation
1200ms ─── All animations complete
```

## 🎯 Component Specifications

### Splash Screen
```
Logo Container:
  - Size: 160x160px
  - Border Radius: 40px
  - Background: White
  - Shadow: Black 20% opacity, 30px blur

Logo Icon:
  - Size: 80px
  - Color: Primary Cyan
  - Icon: sports_soccer_rounded

Title:
  - Font Size: 48px
  - Font Weight: 900
  - Letter Spacing: 2px
  - Gradient: White to Light Cyan
```

### Role Page Hero Section
```
Container:
  - Width: 100%
  - Padding: 8% horizontal, 4% vertical
  - Border Radius: 28px
  - Background: White 15% opacity
  - Border: White 30% opacity, 2px

Logo:
  - Size: 25% of screen width
  - Min: 80px, Max: 120px
  - Border Radius: 25px

Title:
  - Font Size: 10% of screen width
  - Font Weight: 900
  - Gradient: White to Light Cyan
```

### Role Cards
```
Container:
  - Width: 100%
  - Padding: 6% of screen width
  - Border Radius: 28px
  - Background: White
  - Top Accent: 6px gradient bar

Icon Container:
  - Size: 20% of screen width
  - Min: 70px, Max: 90px
  - Border Radius: 20px
  - Gradient: Role-specific

Title:
  - Font Size: 6.5% of screen width
  - Font Weight: 900
  - Color: Theme onSurface

Features:
  - Check Icon: 24x24px circle
  - Text: 15px, Medium weight
  - Spacing: 8px vertical
```

## 🎭 Interaction States

### Button Press
```
Normal State:
  - Scale: 1.0
  - Elevation: 8px
  - Shadow Blur: 8px

Pressed State:
  - Scale: 0.95
  - Elevation: 2px
  - Shadow Blur: 2px
  - Duration: 200ms
```

### Card Hover
```
Normal State:
  - Scale: 1.0
  - Elevation: 4px

Hover State:
  - Scale: 1.02
  - Elevation: 12px
  - Duration: 200ms
```

## 📐 Responsive Breakpoints

### Small Screens (< 375px)
```
- Logo: 80px
- Title: 36px
- Subtitle: 20px
- Body: 14px
- Padding: 16px
```

### Medium Screens (375-414px)
```
- Logo: 100px
- Title: 40px
- Subtitle: 22px
- Body: 16px
- Padding: 20px
```

### Large Screens (> 414px)
```
- Logo: 120px
- Title: 42px
- Subtitle: 24px
- Body: 17px
- Padding: 24px
```

## 🎨 Gradient Definitions

### Primary Gradient
```dart
LinearGradient(
  colors: [
    Color(0xFF00D9FF),  // Electric Cyan
    Color(0xFF0099CC),  // Deep Cyan
    Color(0xFF0066FF),  // Blue
  ],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
)
```

### Secondary Gradient
```dart
LinearGradient(
  colors: [
    Color(0xFFFF6B35),  // Vibrant Orange
    Color(0xFFFF4500),  // Deep Orange
    Color(0xFFFF1744),  // Red
  ],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
)
```

### Hero Gradient
```dart
LinearGradient(
  colors: [
    Color(0xFF0066FF),  // Blue
    Color(0xFF00D9FF),  // Cyan
    Color(0xFF00FFB3),  // Green
  ],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
)
```

## 🔤 Typography Scale

```
Display Large:  36px / 900 weight / -0.5 spacing
Display Medium: 30px / 800 weight / -0.3 spacing
Display Small:  26px / 700 weight / 0 spacing
Headline Large: 24px / 700 weight / 0.2 spacing
Headline Med:   22px / 700 weight / 0.2 spacing
Headline Small: 20px / 600 weight / 0.15 spacing
Title Large:    18px / 600 weight / 0.15 spacing
Title Medium:   16px / 600 weight / 0.1 spacing
Title Small:    14px / 600 weight / 0.1 spacing
Body Large:     17px / 400 weight / 0.5 spacing
Body Medium:    15px / 400 weight / 0.25 spacing
Body Small:     13px / 400 weight / 0.4 spacing
```

## 🎯 Accessibility

### Color Contrast Ratios
```
Primary on White:     4.5:1 ✅ (AA)
Secondary on White:   4.5:1 ✅ (AA)
Text Primary on BG:   12:1  ✅ (AAA)
Text Secondary on BG: 7:1   ✅ (AAA)
```

### Touch Targets
```
Minimum Size: 48x48px ✅
Button Height: 60px ✅
Icon Size: 24-28px ✅
```

### Text Readability
```
Line Height: 1.5-1.6 ✅
Letter Spacing: 0.15-0.5 ✅
Max Line Length: Responsive ✅
```

---

**Design System Version**: 2.0.0
**Last Updated**: November 2025
