import os
import sys
from pathlib import Path

# Add the project root directory to the Python path
project_root = Path(__file__).resolve().parent.parent
sys.path.append(str(project_root))

# Add the Django project directory to the Python path
django_project_root = project_root / 'cute_profit_gis'
sys.path.append(str(django_project_root))

import django
from django.contrib.auth import get_user_model
import requests
import json
from datetime import datetime

# Set up Django environment
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'cute_profit_gis.settings')
django.setup()

User = get_user_model()

def create_users():
    # Create admin user
    if not User.objects.filter(username='admin').exists():
        User.objects.create_superuser(
            username='admin',
            email='admin@email.com',
            password='admin123'
        )
        print("Admin user created successfully")
    else:
        print("Admin user already exists")

    # Create client user
    if not User.objects.filter(username='demo@waterutility.com').exists():
        User.objects.create_user(
            username='demo@waterutility.com',
            email='demo@waterutility.com',
            password='demo123'
        )
        print("Client user created successfully")
    else:
        print("Client user already exists")

def create_test_data():
    # First create the users
    create_users()
    
    # Get admin token
    admin_token = login_user("admin", "admin123")
    
    if not admin_token:
        print("Failed to login as admin")
        return

    headers = {
        'Authorization': f'Bearer {admin_token}',
        'Content-Type': 'application/json'
    }

    # 2. Create a client
    print("\n=== Creating Client ===")
    client_data = {
        "name": "Water Utility Demo",
        "industry": "Utilities",
        "billing_email": "demo@waterutility.com",
        "billing_address": "123 Demo St",
        "billing_phone": "+1234567890"
    }
    
    client_response = requests.post(
        f'{BASE_URL}/clients/',
        headers=headers,
        json=client_data
    )
    print_response(client_response)
    client_id = client_response.json()['id']

    # 3. Create departments
    print("\n=== Creating Departments ===")
    departments = [
        {"name": "Water Distribution", "client": client_id},
        {"name": "Maintenance", "client": client_id}
    ]
    
    department_ids = []
    for dept in departments:
        dept_response = requests.post(
            f'{BASE_URL}/departments/',
            headers=headers,
            json=dept
        )
        print_response(dept_response)
        department_ids.append(dept_response.json()['id'])

    # 4. Create categories
    print("\n=== Creating Categories ===")
    categories = [
        {"name": "Water Meters", "department": department_ids[0]},
        {"name": "Pipelines", "department": department_ids[0]},
        {"name": "Equipment", "department": department_ids[1]}
    ]
    
    category_ids = []
    for cat in categories:
        cat_response = requests.post(
            f'{BASE_URL}/categories/',
            headers=headers,
            json=cat
        )
        print_response(cat_response)
        category_ids.append(cat_response.json()['id'])

    # 5. Create forms
    print("\n=== Creating Forms ===")
    forms = [
        {
            "name": "Meter Reading Form",
            "description": "Daily meter reading collection",
            "client": client_id,
            "category": category_ids[0]
        },
        {
            "name": "Pipeline Inspection",
            "description": "Pipeline condition assessment",
            "client": client_id,
            "category": category_ids[1]
        }
    ]
    
    form_ids = []
    for form in forms:
        form_response = requests.post(
            f'{BASE_URL}/forms/',
            headers=headers,
            json=form
        )
        print_response(form_response)
        form_ids.append(form_response.json()['id'])

    # 6. Add fields to forms
    print("\n=== Adding Form Fields ===")
    meter_fields = [
        {
            "name": "meter_number",
            "label": "Meter Number",
            "field_type": "text",
            "required": True,
            "order": 1
        },
        {
            "name": "reading_value",
            "label": "Meter Reading",
            "field_type": "number",
            "required": True,
            "order": 2
        },
        {
            "name": "meter_status",
            "label": "Meter Status",
            "field_type": "select",
            "required": True,
            "order": 3,
            "options": ["Active", "Inactive", "Maintenance"]
        }
    ]

    for field in meter_fields:
        field_response = requests.post(
            f'{BASE_URL}/forms/{form_ids[0]}/add_field/',
            headers=headers,
            json=field
        )
        print_response(field_response)

    # 7. Create test submissions
    print("\n=== Creating Test Submissions ===")
    submissions = [
        {
            "form": form_ids[0],
            "data": {
                "meter_number": "M001",
                "reading_value": 123.45,
                "meter_status": "Active",
                "latitude": -1.2921,
                "longitude": 36.8219
            }
        },
        {
            "form": form_ids[0],
            "data": {
                "meter_number": "M002",
                "reading_value": 234.56,
                "meter_status": "Active",
                "latitude": -1.2911,
                "longitude": 36.8229
            }
        }
    ]

    for submission in submissions:
        submission_response = requests.post(
            f'{BASE_URL}/submissions/',
            headers=headers,
            json=submission
        )
        print_response(submission_response)

    # 8. Create dashboard
    print("\n=== Creating Dashboard ===")
    dashboard_data = {
        "name": "Meter Reading Overview",
        "description": "Overview of meter readings",
        "client": client_id,
        "form": form_ids[0],
        "visualization_type": "chart",
        "chart_type": "bar",
        "config": {
            "group_by": "date",
            "aggregate": "sum",
            "field": "reading_value"
        }
    }

    dashboard_response = requests.post(
        f'{BASE_URL}/dashboards/',
        headers=headers,
        json=dashboard_data
    )
    print_response(dashboard_response)

def print_response(response):
    try:
        print(json.dumps(response.json(), indent=2))
    except:
        print(response.text)

def login_user(username, password):
    response = requests.post(
        f'{BASE_URL}/token/',
        json={
            "username": username,
            "password": password
        }
    )
    
    if response.status_code == 200:
        return response.json()['access']
    return None

BASE_URL = 'http://localhost:8000/api'

if __name__ == "__main__":
    create_test_data() 