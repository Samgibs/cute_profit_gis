# GIS Application API Documentation

## Authentication

### Login
```bash
curl -X POST http://localhost:8000/api/token/ \
  -H "Content-Type: application/json" \
  -d '{
    "username": "your_username",
    "password": "your_password"
  }'
```

Response:
```json
{
  "access": "your_access_token",
  "refresh": "your_refresh_token"
}
```

### Refresh Token
```bash
curl -X POST http://localhost:8000/api/token/refresh/ \
  -H "Content-Type: application/json" \
  -d '{
    "refresh": "your_refresh_token"
  }'
```

## Client Management

### Create New Client
```bash
curl -X POST http://localhost:8000/api/clients/ \
  -H "Authorization: Bearer your_access_token" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Water Utility Co",
    "industry": "Utilities",
    "billing_email": "billing@waterutility.com",
    "billing_address": "123 Main St",
    "billing_phone": "+1234567890"
  }'
```

### Get Client Details
```bash
curl -X GET http://localhost:8000/api/clients/1/ \
  -H "Authorization: Bearer your_access_token"
```

### Activate Client Subscription
```bash
curl -X POST http://localhost:8000/api/clients/1/activate_subscription/ \
  -H "Authorization: Bearer your_access_token" \
  -H "Content-Type: application/json" \
  -d '{
    "plan_id": 1,
    "duration_months": 12
  }'
```

### Add User to Client
```bash
curl -X POST http://localhost:8000/api/clients/1/add_user/ \
  -H "Authorization: Bearer your_access_token" \
  -H "Content-Type: application/json" \
  -d '{
    "user_id": 1,
    "role": "admin"
  }'
```

## Department Management

### Create Department
```bash
curl -X POST http://localhost:8000/api/departments/ \
  -H "Authorization: Bearer your_access_token" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Water Distribution",
    "client": 1
  }'
```

### Get Department Categories
```bash
curl -X GET http://localhost:8000/api/departments/1/categories/ \
  -H "Authorization: Bearer your_access_token"
```

## Category Management

### Create Category
```bash
curl -X POST http://localhost:8000/api/categories/ \
  -H "Authorization: Bearer your_access_token" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Water Meters",
    "department": 1
  }'
```

### Get Category Items Map
```bash
curl -X GET http://localhost:8000/api/categories/1/items_map/ \
  -H "Authorization: Bearer your_access_token"
```

## Form Management

### Create Form
```bash
curl -X POST http://localhost:8000/api/forms/ \
  -H "Authorization: Bearer your_access_token" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Meter Reading Form",
    "description": "Form for collecting meter readings",
    "client": 1,
    "category": 1
  }'
```

### Add Field to Form
```bash
curl -X POST http://localhost:8000/api/forms/1/add_field/ \
  -H "Authorization: Bearer your_access_token" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "reading_value",
    "label": "Meter Reading",
    "field_type": "number",
    "required": true,
    "order": 1
  }'
```

### Submit Form
```bash
curl -X POST http://localhost:8000/api/form-submissions/ \
  -H "Authorization: Bearer your_access_token" \
  -H "Content-Type: application/json" \
  -d '{
    "form": 1,
    "data": {
      "reading_value": "123.45",
      "latitude": 37.7749,
      "longitude": -122.4194
    }
  }'
```

## Map Layer Management

### Create Map Layer
```bash
curl -X POST http://localhost:8000/api/map-layers/ \
  -H "Authorization: Bearer your_access_token" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Sewer Lines",
    "description": "Underground sewer network",
    "client": 1,
    "layer_type": "line",
    "color": "#FF0000",
    "opacity": 0.8,
    "properties": {
      "line_width": 2,
      "dash_pattern": [5, 5]
    }
  }'
```

### Add Feature to Layer
```bash
curl -X POST http://localhost:8000/api/map-layers/1/add_feature/ \
  -H "Authorization: Bearer your_access_token" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Main Sewer Line",
    "description": "Primary sewer line",
    "geometry": {
      "type": "LineString",
      "coordinates": [
        [-122.4194, 37.7749],
        [-122.4195, 37.7750]
      ]
    },
    "properties": {
      "diameter": "24in",
      "material": "PVC"
    }
  }'
```

## Dashboard Management

### Create Dashboard
```bash
curl -X POST http://localhost:8000/api/dashboards/ \
  -H "Authorization: Bearer your_access_token" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Meter Reading Overview",
    "description": "Overview of meter readings",
    "client": 1,
    "form": 1,
    "visualization_type": "chart",
    "chart_type": "bar",
    "config": {
      "group_by": "date",
      "aggregate": "sum",
      "field": "reading_value"
    }
  }'
```

### Get Dashboard Preview
```bash
curl -X GET http://localhost:8000/api/dashboards/1/preview/ \
  -H "Authorization: Bearer your_access_token"
```

## Data Collection

### Start Collection Session
```bash
curl -X POST http://localhost:8000/api/collection-sessions/ \
  -H "Authorization: Bearer your_access_token" \
  -H "Content-Type: application/json" \
  -d '{
    "form": 1
  }'
```

### Update Session Location
```bash
curl -X PATCH http://localhost:8000/api/collection-sessions/1/update_location/ \
  -H "Authorization: Bearer your_access_token" \
  -H "Content-Type: application/json" \
  -d '{
    "latitude": 37.7749,
    "longitude": -122.4194
  }'
```

### Add Entry to Session
```bash
curl -X POST http://localhost:8000/api/collection-sessions/1/add_entry/ \
  -H "Authorization: Bearer your_access_token" \
  -H "Content-Type: application/json" \
  -d '{
    "form_field": 1,
    "value": "123.45",
    "location": {
      "latitude": 37.7749,
      "longitude": -122.4194
    }
  }'
```

### End Collection Session
```bash
curl -X POST http://localhost:8000/api/collection-sessions/1/end_session/ \
  -H "Authorization: Bearer your_access_token"
```

## Incidence Management

### Create Incidence
```bash
curl -X POST http://localhost:8000/api/incidences/ \
  -H "Authorization: Bearer your_access_token" \
  -H "Content-Type: application/json" \
  -d '{
    "title": "Leaking Meter",
    "description": "Water meter is leaking",
    "severity": "high",
    "item": 1
  }'
```

### Get Incidence Dashboard
```bash
curl -X GET http://localhost:8000/api/incidences/dashboard/ \
  -H "Authorization: Bearer your_access_token"
```

## Usage Statistics

### Get Client Usage Stats
```bash
curl -X GET http://localhost:8000/api/clients/1/usage_stats/ \
  -H "Authorization: Bearer your_access_token"
```

### Get Client Billing History
```bash
curl -X GET http://localhost:8000/api/clients/1/billing_history/ \
  -H "Authorization: Bearer your_access_token"
```

## Response Formats

All API responses follow this general format:

### Success Response
```json
{
  "status": "success",
  "data": {
    // Response data specific to the endpoint
  }
}
```

### Error Response
```json
{
  "status": "error",
  "message": "Error description",
  "errors": {
    // Detailed error information if available
  }
}
```

## Authentication Headers

All authenticated requests must include the Authorization header:
```
Authorization: Bearer your_access_token
```

## Rate Limiting

The API implements rate limiting to prevent abuse. Limits are:
- 100 requests per minute per user
- 1000 requests per hour per user

## Error Codes

- 400: Bad Request
- 401: Unauthorized
- 403: Forbidden
- 404: Not Found
- 429: Too Many Requests
- 500: Internal Server Error

## Notes

1. All timestamps are in ISO 8601 format
2. All coordinates are in WGS84 (EPSG:4326)
3. File uploads should use multipart/form-data
4. Maximum file size is 10MB
5. Supported image formats: JPG, PNG, GIF 