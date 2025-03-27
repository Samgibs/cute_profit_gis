# Cute Profit GIS Application

A GIS application for data collection and visualization.

## Setup Instructions

1. Create and activate a virtual environment:
```bash
python -m venv env
source env/bin/activate  # On Windows: env\Scripts\activate
```

2. Install dependencies:
```bash
pip install -r requirements.txt
```

3. Run database migrations:
```bash
python manage.py migrate
```

4. Create test users:
```bash
python manage.py shell < scripts/create_users.py
```

5. Start the Django development server:
```bash
python manage.py runserver
```

6. In a new terminal, create test data:
```bash
python scripts/create_test_data.py
```

## Test Users

The following test users are available:

1. Admin User
   - Username: admin
   - Password: admin123
   - Role: Administrator
   - Full access to all features

2. Manager User
   - Username: manager
   - Password: manager123
   - Role: Manager
   - Can manage forms, submissions, and view analytics

3. Regular User
   - Username: user
   - Password: user123
   - Role: User
   - Can submit forms and view own submissions

4. Viewer User
   - Username: viewer
   - Password: viewer123
   - Role: Viewer
   - Can only view data and reports

## API Documentation

The complete API documentation is available in the `API_DOCUMENTATION.md` file. Here are some key endpoints:

1. Authentication:
```bash
# Login
curl -X POST http://localhost:8000/api/token/ \
  -H "Content-Type: application/json" \
  -d '{
    "username": "your_username",
    "password": "your_password"
  }'
```

2. Form Management:
```bash
# Get forms
curl -X GET http://localhost:8000/api/forms/ \
  -H "Authorization: Bearer your_access_token"

# Submit form
curl -X POST http://localhost:8000/api/form-submissions/ \
  -H "Authorization: Bearer your_access_token" \
  -H "Content-Type: application/json" \
  -d '{
    "form": 1,
    "data": {
      "field_name": "value",
      "latitude": 37.7749,
      "longitude": -122.4194
    }
  }'
```

3. Dashboard:
```bash
# Get dashboard data
curl -X GET http://localhost:8000/api/dashboards/1/preview/ \
  -H "Authorization: Bearer your_access_token"
```

## Testing the Application

1. Login with different user roles to test access levels
2. Create and submit forms
3. View submissions on the map
4. Generate charts and reports
5. Test geolocation features
6. Try different visualization options

## Development

The application uses:
- Django for the backend
- Flutter for the frontend
- MySQL for the database
- OpenStreetMap for base maps
- fl_chart for data visualization

## Folder Structure

```
cute_profit_gis/
├── lib/
│   ├── constants/
│   ├── models/
│   ├── screens/
│   │   ├── auth/
│   │   ├── dashboard/
│   │   └── forms/
│   └── services/
├── scripts/
│   ├── create_test_data.py
│   └── create_users.py
└── API_DOCUMENTATION.md
``` 