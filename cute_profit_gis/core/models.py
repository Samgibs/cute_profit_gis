from django.db import models
from django.contrib.auth.models import User
from django.core.validators import MinValueValidator
from decimal import Decimal
from django.utils import timezone

class SubscriptionPlan(models.Model):
    name = models.CharField(max_length=100)
    description = models.TextField()
    price = models.DecimalField(max_digits=10, decimal_places=2, validators=[MinValueValidator(Decimal('0.01'))])
    features = models.JSONField(default=dict)  # List of features included in the plan
    max_users = models.IntegerField(default=5)
    max_storage = models.BigIntegerField(default=5368709120)  # 5GB in bytes
    max_forms = models.IntegerField(default=10)
    max_items = models.IntegerField(default=1000)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    def __str__(self):
        return f"{self.name} - ${self.price}/month"

class Client(models.Model):
    STATUS_CHOICES = [
        ('active', 'Active'),
        ('suspended', 'Suspended'),
        ('cancelled', 'Cancelled'),
        ('trial', 'Trial'),
    ]

    name = models.CharField(max_length=200)
    industry = models.CharField(max_length=100)
    status = models.CharField(max_length=20, choices=STATUS_CHOICES, default='trial')
    subscription_plan = models.ForeignKey(SubscriptionPlan, on_delete=models.SET_NULL, null=True)
    subscription_start = models.DateTimeField(null=True, blank=True)
    subscription_end = models.DateTimeField(null=True, blank=True)
    billing_email = models.EmailField()
    billing_address = models.TextField(blank=True)
    billing_phone = models.CharField(max_length=20, blank=True)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    def __str__(self):
        return self.name

    def is_subscription_active(self):
        if not self.subscription_end:
            return False
        return self.status == 'active' and self.subscription_end > timezone.now()

class ClientUser(models.Model):
    ROLE_CHOICES = [
        ('admin', 'Administrator'),
        ('manager', 'Manager'),
        ('user', 'User'),
        ('viewer', 'Viewer'),
    ]

    user = models.OneToOneField(User, on_delete=models.CASCADE)
    client = models.ForeignKey(Client, on_delete=models.CASCADE, related_name='users')
    role = models.CharField(max_length=20, choices=ROLE_CHOICES, default='user')
    department = models.ForeignKey('Department', on_delete=models.SET_NULL, null=True, blank=True)
    is_active = models.BooleanField(default=True)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        unique_together = ['user', 'client']

    def __str__(self):
        return f"{self.user.username} - {self.client.name}"

class ClientBilling(models.Model):
    PAYMENT_STATUS = [
        ('pending', 'Pending'),
        ('paid', 'Paid'),
        ('failed', 'Failed'),
        ('refunded', 'Refunded'),
    ]

    client = models.ForeignKey(Client, on_delete=models.CASCADE, related_name='billing')
    amount = models.DecimalField(max_digits=10, decimal_places=2)
    payment_status = models.CharField(max_length=20, choices=PAYMENT_STATUS, default='pending')
    payment_date = models.DateTimeField(null=True, blank=True)
    invoice_number = models.CharField(max_length=50, unique=True)
    billing_period_start = models.DateTimeField()
    billing_period_end = models.DateTimeField()
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    def __str__(self):
        return f"{self.client.name} - {self.invoice_number}"

class ClientUsage(models.Model):
    client = models.ForeignKey(Client, on_delete=models.CASCADE, related_name='usage')
    date = models.DateField()
    users_count = models.IntegerField(default=0)
    forms_count = models.IntegerField(default=0)
    items_count = models.IntegerField(default=0)
    storage_used = models.BigIntegerField(default=0)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        unique_together = ['client', 'date']

    def __str__(self):
        return f"{self.client.name} - {self.date}"

class Department(models.Model):
    name = models.CharField(max_length=200)
    client = models.ForeignKey(Client, on_delete=models.CASCADE, related_name='departments')
    created_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return f"{self.name} - {self.client.name}"

class Category(models.Model):
    name = models.CharField(max_length=200)
    department = models.ForeignKey(Department, on_delete=models.CASCADE, related_name='categories')
    created_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return f"{self.name} - {self.department.name}"

class MapLayer(models.Model):
    LAYER_TYPES = [
        ('point', 'Point'),
        ('line', 'Line'),
        ('polygon', 'Polygon'),
        ('grid', 'Grid'),
        ('heatmap', 'Heatmap'),
    ]

    name = models.CharField(max_length=200)
    description = models.TextField(blank=True)
    client = models.ForeignKey(Client, on_delete=models.CASCADE, related_name='map_layers')
    layer_type = models.CharField(max_length=20, choices=LAYER_TYPES)
    color = models.CharField(max_length=7, default='#FF0000')  # Hex color code
    opacity = models.FloatField(default=0.8)
    properties = models.JSONField(default=dict)  # Additional layer properties
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    def __str__(self):
        return f"{self.name} - {self.client.name}"

class MapFeature(models.Model):
    layer = models.ForeignKey(MapLayer, on_delete=models.CASCADE, related_name='features')
    name = models.CharField(max_length=200)
    description = models.TextField(blank=True)
    geometry = models.JSONField()  # GeoJSON geometry
    properties = models.JSONField(default=dict)  # Feature properties
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    def __str__(self):
        return f"{self.name} - {self.layer.name}"

class FormField(models.Model):
    FIELD_TYPES = [
        ('text', 'Text'),
        ('number', 'Number'),
        ('date', 'Date'),
        ('select', 'Select'),
        ('multiselect', 'Multi-Select'),
        ('checkbox', 'Checkbox'),
        ('radio', 'Radio'),
        ('file', 'File'),
        ('image', 'Image'),
        ('geometry', 'Geometry'),  # For drawing shapes on map
    ]

    form = models.ForeignKey('Form', on_delete=models.CASCADE, related_name='fields')
    name = models.CharField(max_length=100)
    label = models.CharField(max_length=200)
    field_type = models.CharField(max_length=20, choices=FIELD_TYPES)
    required = models.BooleanField(default=False)
    options = models.JSONField(null=True, blank=True)
    order = models.IntegerField(default=0)
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        ordering = ['order']

    def __str__(self):
        return f"{self.label} ({self.field_type})"

class Form(models.Model):
    name = models.CharField(max_length=200)
    description = models.TextField(blank=True)
    client = models.ForeignKey(Client, on_delete=models.CASCADE, related_name='forms')
    category = models.ForeignKey(Category, on_delete=models.CASCADE, related_name='forms')
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    def __str__(self):
        return f"{self.name} - {self.client.name}"

    def save(self, *args, **kwargs):
        is_new = self.pk is None
        super().save(*args, **kwargs)
        
        # Add default GIS fields for new forms
        if is_new:
            FormField.objects.create(
                form=self,
                name='latitude',
                label='Latitude',
                field_type='number',
                required=True,
                order=0
            )
            FormField.objects.create(
                form=self,
                name='longitude',
                label='Longitude',
                field_type='number',
                required=True,
                order=1
            )

class FormSubmission(models.Model):
    form = models.ForeignKey(Form, on_delete=models.CASCADE, related_name='submissions')
    data = models.JSONField()
    submitted_by = models.ForeignKey(User, on_delete=models.CASCADE)
    created_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return f"Submission for {self.form.name}"

class Item(models.Model):
    name = models.CharField(max_length=200)
    category = models.ForeignKey(Category, on_delete=models.CASCADE, related_name='items')
    latitude = models.FloatField()
    longitude = models.FloatField()
    properties = models.JSONField(default=dict)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    def __str__(self):
        return f"{self.name} ({self.latitude}, {self.longitude})"

class Incidence(models.Model):
    SEVERITY_CHOICES = [
        ('low', 'Low'),
        ('medium', 'Medium'),
        ('high', 'High'),
        ('critical', 'Critical'),
    ]

    STATUS_CHOICES = [
        ('open', 'Open'),
        ('in_progress', 'In Progress'),
        ('resolved', 'Resolved'),
    ]

    title = models.CharField(max_length=200)
    description = models.TextField()
    severity = models.CharField(max_length=20, choices=SEVERITY_CHOICES)
    status = models.CharField(max_length=20, choices=STATUS_CHOICES, default='open')
    item = models.ForeignKey(Item, on_delete=models.CASCADE, related_name='incidences')
    reported_by = models.ForeignKey(User, on_delete=models.CASCADE)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    def __str__(self):
        return f"{self.title} - {self.severity}"

class DashboardConfig(models.Model):
    VISUALIZATION_TYPES = [
        ('map', 'Map View'),
        ('chart', 'Chart'),
        ('table', 'Table'),
        ('list', 'List View'),
    ]

    CHART_TYPES = [
        ('bar', 'Bar Chart'),
        ('line', 'Line Chart'),
        ('pie', 'Pie Chart'),
        ('scatter', 'Scatter Plot'),
    ]

    name = models.CharField(max_length=200)
    description = models.TextField(blank=True)
    client = models.ForeignKey(Client, on_delete=models.CASCADE, related_name='dashboards')
    form = models.ForeignKey(Form, on_delete=models.CASCADE, related_name='dashboards')
    visualization_type = models.CharField(max_length=20, choices=VISUALIZATION_TYPES)
    chart_type = models.CharField(max_length=20, choices=CHART_TYPES, null=True, blank=True)
    config = models.JSONField()
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    def __str__(self):
        return f"{self.name} - {self.client.name}"

class DataCollectionSession(models.Model):
    user = models.ForeignKey(User, on_delete=models.CASCADE)
    form = models.ForeignKey(Form, on_delete=models.CASCADE)
    start_time = models.DateTimeField(auto_now_add=True)
    end_time = models.DateTimeField(null=True, blank=True)
    current_location = models.JSONField(null=True, blank=True)
    is_active = models.BooleanField(default=True)

    def __str__(self):
        return f"Session by {self.user.username} - {self.form.name}"

class DataCollectionEntry(models.Model):
    session = models.ForeignKey(DataCollectionSession, on_delete=models.CASCADE, related_name='entries')
    form_field = models.ForeignKey(FormField, on_delete=models.CASCADE)
    value = models.JSONField()
    location = models.JSONField()
    timestamp = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return f"Entry for {self.form_field.label} - {self.session.form.name}"
