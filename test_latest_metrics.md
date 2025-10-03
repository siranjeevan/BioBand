# Testing Latest Health Metrics Implementation

## Test Scenarios

### 1. Device Login Flow
- Enter a valid device ID (e.g., BAND001, BAND002)
- Verify DeviceState stores both device name and device_id
- Navigate to dashboard and verify device ID is shown in app bar

### 2. API Integration
- Dashboard should call `/health-metrics/device/{device_id}/latest` endpoint
- Should fetch only the most recent entry for the logged-in device
- Should update every 10 seconds automatically
- Manual refresh button should trigger immediate update

### 3. Fallback Behavior
- If API call fails, should fall back to simulated data
- If no device is connected, should show connection dialog
- Should handle network errors gracefully

### 4. Data Display
- Heart rate, SpO2, steps, and calories should reflect real API data
- Last synced timestamp should update when new data is fetched
- Connection status indicator should show green dot + device ID

## Expected API Response Format
```json
{
  "success": true,
  "data": {
    "id": 123,
    "device_id": "BAND001",
    "heart_rate": 72,
    "spo2": 98,
    "steps": 5423,
    "calories": 210,
    "timestamp": "2024-01-15T10:30:00Z"
  }
}
```

## Backend Requirements
The backend needs to implement the `/health-metrics/device/{device_id}/latest` endpoint that:
1. Filters health metrics by device_id
2. Orders by timestamp/id in descending order
3. Returns only the first (most recent) record
4. Returns proper error responses for invalid device_ids