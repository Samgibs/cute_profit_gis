import os
import django
from django.contrib.auth import get_user_model

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

if __name__ == '__main__':
    create_users() 