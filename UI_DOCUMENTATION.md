# Nadi Pariksha - UI Documentation

## Overview
Nadi Pariksha is a Flutter-based health monitoring application featuring a modern dark theme with glassmorphism design elements. The app provides real-time health vitals tracking, AI-powered analytics, and comprehensive health reporting.

## Design System

### Color Palette
The app uses an **Obsidian Plum** color scheme with deep blues and purples:

```dart
// Primary Colors
primary: #000428 (Deep Navy)
primaryLight: #1729CB (Electric Blue)
primaryDark: #000428 (Deep Navy)

// Secondary Colors
secondary: #000428 (Deep Navy)
secondaryLight: #0B135E (Dark Blue)

// Status Colors
success: #4CAF50 (Green)
warning: #FF9800 (Orange)
error: #F44336 (Red)

// Surface Colors
surface: #0B135E (Dark Blue)
surfaceCard: #000428 (Deep Navy)

// Text Colors
textPrimary: #FFFFFF (White)
textSecondary: #FFFFFF (White)
textMuted: #FFFFFF (White)
```

### Gradients
- **Background Gradient**: Vertical gradient from `#000428` to `#0B135E`
- **Primary Gradient**: Diagonal gradient from `primary` to `primaryLight`

### Typography
- **Headline Large**: 32px, Bold, White
- **Headline Medium**: 24px, Semi-bold, White
- **Body Large**: 16px, Regular, White
- **Body Medium**: 14px, Regular, Secondary White
- **Body Small**: 12px, Regular, Muted White

## Core Components

### 1. GlassContainer
A reusable glassmorphism container component with blur effects.

**Features:**
- Backdrop blur filter (configurable blur intensity)
- Semi-transparent background with gradient overlay
- Rounded corners (default 16px radius)
- Subtle border and shadow effects
- Customizable padding and margins

**Usage:**
```dart
GlassContainer(
  padding: EdgeInsets.all(20),
  blur: 10,
  opacity: 0.1,
  child: YourWidget(),
)
```

### 2. Animated Vital Cards
Interactive cards displaying health metrics with custom animations.

**Animation Types:**
- **Heartbeat**: Pulsing scale animation for heart rate
- **Bubble**: Floating bubble particles for oxygen levels
- **Fire**: Flame particles for calorie tracking
- **Bounce**: Vertical bounce for step counter

**Features:**
- Real-time data updates
- Color-coded metrics
- Gradient backgrounds
- Glass morphism styling

## Screen Architecture

### 1. Splash Screen (`splash_screen.dart`)
**Purpose**: App initialization and branding

**Features:**
- Pulsing logo animation
- Brand name display
- Auto-navigation to onboarding (3-second delay)
- Full-screen gradient background

**Animations:**
- Scale animation (0.8 to 1.2) with ease-in-out curve
- Glowing shadow effect on logo

### 2. Onboarding Screen (`onboarding_screen.dart`)
**Purpose**: Feature introduction and user guidance

**Features:**
- 4-page horizontal swipe navigation
- Animated page indicators
- Skip functionality
- Progressive disclosure of app features

**Pages:**
1. **Track Vitals**: Heart rate and vital signs monitoring
2. **Store & Share**: Health data management
3. **AI Assistance**: Personalized health insights
4. **Get Started**: Call-to-action page

**Interactions:**
- Swipe gestures for navigation
- Skip button (available on first 3 pages)
- Next button with smooth transitions
- Get Started button on final page

### 3. Dashboard Screen (`dashboard_screen.dart`)
**Purpose**: Main health vitals display and monitoring

**Layout Structure:**
```
AppBar (Transparent)
├── Health Insights Card
├── Vital Cards Grid (2x2)
│   ├── Heart Rate (Heartbeat animation)
│   ├── Blood Oxygen (Bubble animation)
│   ├── Calories (Fire animation)
│   └── Steps (Bounce animation)
└── Quick Stats Row
    ├── Temperature Card
    └── Activity Status Card
```

**Key Features:**
- Real-time data simulation (3-second intervals)
- Device connection status monitoring
- Animated background particles
- Glass morphism card design
- No-device connection dialog

**Animations:**
- Continuous vital card pulsing
- Custom particle systems for each metric
- Floating health particles background
- Smooth scale transitions

### 4. AI Analytics Screen (`ai_analytics_screen.dart`)
**Purpose**: AI-powered health chat and insights

**Features:**
- Chat interface with AI health assistant
- Animated floating particles background
- Watch logo animations
- Real-time message exchange
- Loading states for API calls

**Layout:**
- Animated header with pulsing AI icon
- Scrollable chat message list
- Input field with send functionality
- Particle animation overlay

### 5. Main Navigation Screen (`main_navigation_screen.dart`)
**Purpose**: Bottom tab navigation container

**Navigation Structure:**
- **Dashboard**: Health vitals overview
- **AI Analytics**: Chat with AI assistant
- **Reports**: Health data reports
- **Profile**: User settings and profile

**Features:**
- IndexedStack for screen persistence
- Glass morphism bottom navigation bar
- Device connection dialog management
- Route-aware dialog handling

## Animation System

### 1. Particle Systems
**Health Particles**: Floating dots with sine wave motion
**Bubble Animation**: Rising bubbles with random properties
**Flame Animation**: Fire particles with life cycle management
**Watch Logos**: Rotating brand elements

### 2. Micro-Interactions
- **Pulse Animations**: Heartbeat-style scaling
- **Rotation Effects**: Subtle icon rotations
- **Bounce Effects**: Vertical movement for activity indicators
- **Scale Transitions**: Hover and focus states

### 3. Page Transitions
- **Slide Animations**: Smooth page transitions
- **Fade Effects**: Content appearance animations
- **Staggered Animations**: Sequential element reveals

## Responsive Design

### Breakpoints
- **Mobile**: Default layout (< 600px)
- **Tablet**: Adaptive grid layouts (600px - 1200px)
- **Desktop**: Extended layouts (> 1200px)

### Adaptive Elements
- Grid layouts adjust column count based on screen width
- Text sizes scale with device pixel ratio
- Touch targets maintain minimum 44px size
- Safe area handling for notched devices

## Accessibility Features

### Visual Accessibility
- High contrast color ratios (WCAG AA compliant)
- Scalable text with system font size support
- Clear visual hierarchy with proper spacing
- Color-blind friendly status indicators

### Interaction Accessibility
- Semantic labels for screen readers
- Keyboard navigation support
- Touch target size compliance (44px minimum)
- Focus indicators for interactive elements

## Performance Optimizations

### Animation Performance
- Hardware-accelerated animations using Transform widgets
- Efficient CustomPainter implementations
- Animation controller lifecycle management
- Frame rate optimization (60fps target)

### Memory Management
- Proper disposal of animation controllers
- Timer cleanup in widget disposal
- Efficient particle system updates
- Image caching for static assets

## Theme Configuration

### Dark Theme Implementation
```dart
ThemeData.dark(
  colorScheme: ColorScheme.dark(
    primary: AppColors.primary,
    surface: AppColors.surface,
    // ... other colors
  ),
  // Component themes
  appBarTheme: AppBarTheme(...),
  cardTheme: CardTheme(...),
  elevatedButtonTheme: ElevatedButtonThemeData(...),
)
```

### Component Styling
- **Cards**: Glass morphism with blur effects
- **Buttons**: Rounded corners with gradient backgrounds
- **Input Fields**: Transparent backgrounds with colored borders
- **Navigation**: Semi-transparent with blur effects

## State Management

### Local State
- AnimationController for micro-interactions
- Timer management for real-time updates
- Page controllers for navigation
- Form state for user inputs

### Global State
- Device connection status (DeviceState)
- Sensor data simulation (SensorData)
- Theme preferences (ThemeProvider)
- User authentication state

## API Integration

### Health Data Endpoints
- Real-time vital signs streaming
- Historical data retrieval
- AI chat functionality
- User profile management

### Error Handling
- Network connectivity checks
- Graceful degradation for offline mode
- User-friendly error messages
- Retry mechanisms for failed requests

## Testing Considerations

### Widget Testing
- Animation controller testing
- User interaction simulation
- State change verification
- Navigation flow testing

### Integration Testing
- End-to-end user journeys
- API integration testing
- Device connection scenarios
- Performance benchmarking

## Future Enhancements

### Planned Features
- Haptic feedback integration
- Voice command support
- Wearable device connectivity
- Advanced data visualization
- Multi-language support

### Performance Improvements
- Code splitting for faster load times
- Image optimization and lazy loading
- Background processing for data sync
- Caching strategies for offline support

---

## Component Reference

### Quick Component Guide

| Component | Purpose | Key Features |
|-----------|---------|--------------|
| `GlassContainer` | Glassmorphism wrapper | Blur effects, transparency |
| `VitalCard` | Health metric display | Animations, real-time data |
| `ParticlesPainter` | Background animations | Custom paint, performance |
| `HealthInsights` | Status overview | Dynamic content, animations |
| `NavigationBar` | Tab navigation | Glass styling, state management |

### Animation Controllers

| Controller | Duration | Purpose |
|------------|----------|---------|
| `_animationController` | 1200ms | Main card animations |
| `_pulseController` | 2000ms | Heartbeat effects |
| `_rotateController` | 15000ms | Background rotations |
| `_floatingController` | 20000ms | Particle movements |

This documentation provides a comprehensive overview of the Nadi Pariksha UI system, covering design principles, component architecture, and implementation details for maintaining and extending the application.