# Backend Implementation for Latest Health Metrics

## API Endpoint: `/health-metrics/device/{device_id}/latest`

This endpoint should return only the most recent health metrics entry for a given device_id.

### Implementation Logic:

```javascript
// Example implementation for the backend
app.get('/health-metrics/device/:deviceId/latest', async (req, res) => {
  try {
    const { deviceId } = req.params;
    
    // Query to get the most recent entry for the device
    // This assumes you have a timestamp or id field to order by
    const latestMetrics = await HealthMetrics.findOne({
      device_id: deviceId
    }).sort({ 
      timestamp: -1  // or created_at: -1, or id: -1 depending on your schema
    }).limit(1);
    
    if (!latestMetrics) {
      return res.status(404).json({
        success: false,
        message: 'No health metrics found for this device'
      });
    }
    
    res.json({
      success: true,
      data: latestMetrics
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Server error',
      error: error.message
    });
  }
});
```

### SQL Alternative:
```sql
SELECT * FROM health_metrics 
WHERE device_id = ? 
ORDER BY timestamp DESC 
LIMIT 1;
```

### MongoDB Alternative:
```javascript
db.health_metrics.findOne(
  { device_id: deviceId },
  { sort: { timestamp: -1 } }
)
```

This ensures only the most recent entry is returned instead of all records for the device.