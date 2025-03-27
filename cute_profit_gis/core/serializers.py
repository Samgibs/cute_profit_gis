from rest_framework import serializers
from .models import (
    Client, Department, Category, Form, FormField, FormSubmission, 
    Item, Incidence, DashboardConfig, DataCollectionSession, DataCollectionEntry,
    MapLayer, MapFeature, SubscriptionPlan, ClientUser, ClientBilling, ClientUsage
)
from django.contrib.auth.models import User

class UserSerializer(serializers.ModelSerializer):
    class Meta:
        model = User
        fields = ('id', 'username', 'email', 'first_name', 'last_name')

class SubscriptionPlanSerializer(serializers.ModelSerializer):
    class Meta:
        model = SubscriptionPlan
        fields = '__all__'

class ClientUserSerializer(serializers.ModelSerializer):
    user = UserSerializer(read_only=True)
    user_id = serializers.IntegerField(write_only=True)

    class Meta:
        model = ClientUser
        fields = ('id', 'user', 'user_id', 'client', 'role', 'department', 'is_active', 'created_at', 'updated_at')

class ClientBillingSerializer(serializers.ModelSerializer):
    class Meta:
        model = ClientBilling
        fields = '__all__'

class ClientUsageSerializer(serializers.ModelSerializer):
    class Meta:
        model = ClientUsage
        fields = '__all__'

class ClientSerializer(serializers.ModelSerializer):
    subscription_plan = SubscriptionPlanSerializer(read_only=True)
    subscription_plan_id = serializers.IntegerField(write_only=True, required=False)
    users = ClientUserSerializer(many=True, read_only=True)
    billing = ClientBillingSerializer(many=True, read_only=True)
    usage = ClientUsageSerializer(many=True, read_only=True)
    is_subscription_active = serializers.SerializerMethodField()

    class Meta:
        model = Client
        fields = (
            'id', 'name', 'industry', 'status', 'subscription_plan', 'subscription_plan_id',
            'subscription_start', 'subscription_end', 'billing_email', 'billing_address',
            'billing_phone', 'users', 'billing', 'usage', 'is_subscription_active',
            'created_at', 'updated_at'
        )

    def get_is_subscription_active(self, obj):
        return obj.is_subscription_active()

class DepartmentSerializer(serializers.ModelSerializer):
    class Meta:
        model = Department
        fields = '__all__'

class CategorySerializer(serializers.ModelSerializer):
    class Meta:
        model = Category
        fields = '__all__'

class MapFeatureSerializer(serializers.ModelSerializer):
    class Meta:
        model = MapFeature
        fields = ('id', 'name', 'description', 'geometry', 'properties', 'created_at', 'updated_at')

class MapLayerSerializer(serializers.ModelSerializer):
    features = MapFeatureSerializer(many=True, read_only=True)
    feature_count = serializers.SerializerMethodField()

    class Meta:
        model = MapLayer
        fields = ('id', 'name', 'description', 'client', 'layer_type', 'color', 'opacity', 'properties', 'features', 'feature_count', 'created_at', 'updated_at')

    def get_feature_count(self, obj):
        return obj.features.count()

class FormFieldSerializer(serializers.ModelSerializer):
    class Meta:
        model = FormField
        fields = ('id', 'name', 'label', 'field_type', 'required', 'options', 'order')

class FormSerializer(serializers.ModelSerializer):
    fields = FormFieldSerializer(many=True, read_only=True)

    class Meta:
        model = Form
        fields = ('id', 'name', 'description', 'client', 'category', 'fields', 'created_at', 'updated_at')

class FormSubmissionSerializer(serializers.ModelSerializer):
    submitted_by = UserSerializer(read_only=True)
    form_data = serializers.SerializerMethodField()

    class Meta:
        model = FormSubmission
        fields = ('id', 'form', 'data', 'form_data', 'submitted_by', 'created_at')

    def get_form_data(self, obj):
        form_fields = {field.name: field for field in obj.form.fields.all()}
        formatted_data = {}
        
        for field_name, value in obj.data.items():
            if field_name in form_fields:
                field = form_fields[field_name]
                formatted_data[field.label] = {
                    'type': field.field_type,
                    'value': value
                }
        
        return formatted_data

class ItemSerializer(serializers.ModelSerializer):
    form_data = serializers.SerializerMethodField()

    class Meta:
        model = Item
        fields = ('id', 'name', 'category', 'latitude', 'longitude', 'properties', 'form_data', 'created_at', 'updated_at')

    def get_form_data(self, obj):
        category_forms = obj.category.forms.all()
        if not category_forms:
            return obj.properties

        form = category_forms[0]  
        form_fields = {field.name: field for field in form.fields.all()}
        formatted_data = {}

        for field_name, value in obj.properties.items():
            if field_name in form_fields:
                field = form_fields[field_name]
                formatted_data[field.label] = {
                    'type': field.field_type,
                    'value': value
                }

        return formatted_data

class IncidenceSerializer(serializers.ModelSerializer):
    reported_by = UserSerializer(read_only=True)
    item_details = ItemSerializer(source='item', read_only=True)

    class Meta:
        model = Incidence
        fields = ('id', 'title', 'description', 'severity', 'status', 'item', 'item_details', 'reported_by', 'created_at', 'updated_at')

class DashboardConfigSerializer(serializers.ModelSerializer):
    class Meta:
        model = DashboardConfig
        fields = '__all__'

class DataCollectionEntrySerializer(serializers.ModelSerializer):
    field_label = serializers.CharField(source='form_field.label', read_only=True)
    field_type = serializers.CharField(source='form_field.field_type', read_only=True)

    class Meta:
        model = DataCollectionEntry
        fields = ('id', 'field_label', 'field_type', 'value', 'location', 'timestamp')

class DataCollectionSessionSerializer(serializers.ModelSerializer):
    entries = DataCollectionEntrySerializer(many=True, read_only=True)
    user = UserSerializer(read_only=True)
    form_name = serializers.CharField(source='form.name', read_only=True)

    class Meta:
        model = DataCollectionSession
        fields = ('id', 'user', 'form', 'form_name', 'start_time', 'end_time', 'current_location', 'is_active', 'entries') 