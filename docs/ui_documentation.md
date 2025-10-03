# UI Documentation

## Design System

### Color Palette
- **Primary**: Dark theme with gradient backgrounds
- **Secondary**: Light accents for highlights
- **Success**: Green for positive health indicators
- **Warning**: Orange for alerts
- **Error**: Red for critical values

### Components

#### GlassContainer
Reusable glassmorphism container with blur effects.

**Usage:**
```dart
GlassContainer(
  padding: EdgeInsets.all(16),
  child: Widget(),
)
```

#### Theme Configuration
- Material 3 design system
- Dark theme optimized
- Custom button styles with rounded corners
- Glass-effect cards with blur backgrounds

## Screens

### 1. SplashScreen
**Purpose**: App initialization and loading
**Features**:
- Animated logo
- Firebase initialization
- Route to onboarding/login

### 2. OnboardingScreen
**Purpose**: First-time user introduction
**Features**:
- Feature highlights
- Swipeable pages
- Skip/Next navigation

### 3. LoginScreen
**Purpose**: User authentication
**Features**:
- Google Sign-In integration
- Email/password login
- Registration flow

### 4. DeviceConnectScreen
**Purpose**: Bluetooth device pairing
**Features**:
- Device scanning
- Connection status
- Pairing instructions

### 5. DeviceLoginScreen
**Purpose**: Device-specific authentication
**Features**:
- Device ID input
- Connection validation
- Error handling

### 6. DashboardScreen
**Purpose**: Main health monitoring interface
**Features**:
- Real-time vital cards (Heart Rate, SpO2, Steps, Calories)
- Animated health indicators
- Connection status display
- Health insights panel

**Vital Cards**:
- Heart Rate: Animated heartbeat icon
- Blood Oxygen: Bubble animation
- Calories: Fire particle effects
- Steps: Bounce animation

### 7. AIAnalyticsScreen
**Purpose**: AI-powered health analysis
**Features**:
- Health trend analysis
- Predictive insights
- Recommendation engine

### 8. ReportsScreen
**Purpose**: Historical health data
**Features**:
- Data visualization
- Export functionality
- Date range selection

### 9. HealthReportScreen
**Purpose**: Detailed health reports
**Features**:
- Comprehensive metrics
- PDF generation
- Sharing options

### 10. ProfileScreen
**Purpose**: User settings and preferences
**Features**:
- User information
- App settings
- Device management

### 11. MainNavigationScreen
**Purpose**: Bottom navigation container
**Features**:
- Tab-based navigation
- Badge notifications
- Smooth transitions

## Animations

### Custom Painters
- **BubblePainter**: Floating bubble effects for SpO2
- **FlamePainter**: Fire particles for calorie display
- **HealthParticlesPainter**: Background health particles

### Animation Controllers
- Heartbeat pulse animation
- Bounce effects for step counter
- Rotation animations for temperature
- Slide and fade transitions

## Responsive Design

### Breakpoints
- Mobile: < 600px
- Tablet: 600px - 1024px
- Desktop: > 1024px

### Adaptive Layouts
- Grid layouts adjust to screen size
- Flexible spacing and padding
- Scalable typography

## Accessibility

### Features
- Semantic labels for screen readers
- High contrast color ratios
- Touch target sizing (44px minimum)
- Keyboard navigation support

### Implementation
```dart
Semantics(
  label: 'Heart rate: 72 BPM',
  child: VitalCard(),
)
```

## State Management

### UI State
- Loading states with shimmer effects
- Error states with retry options
- Empty states with call-to-action

### Animation State
- Controller lifecycle management
- Performance optimization
- Memory cleanup

## Custom Widgets

### VitalCard
Displays individual health metrics with animations.

### GlassContainer
Glassmorphism effect container for modern UI.

### AnimatedIcon
Custom animated icons for different health metrics.

## Performance Optimization

### Rendering
- Efficient CustomPainter usage
- Animation frame optimization
- Widget rebuilding minimization

### Memory Management
- Proper disposal of controllers
- Image caching strategies
- Timer cleanup