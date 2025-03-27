from django.shortcuts import render
from rest_framework import viewsets, permissions, status
from rest_framework.decorators import action
from rest_framework.response import Response
from django.contrib.auth.models import User
from .models import (
    Client, Department, Category, Form, FormField, FormSubmission, 
    Item, Incidence, DashboardConfig, DataCollectionSession, DataCollectionEntry,
    MapLayer, MapFeature, SubscriptionPlan, ClientUser, ClientBilling, ClientUsage
)
from .serializers import (
    UserSerializer, ClientSerializer, DepartmentSerializer, CategorySerializer,
    FormSerializer, FormFieldSerializer, FormSubmissionSerializer, ItemSerializer, 
    IncidenceSerializer, DashboardConfigSerializer, DataCollectionSessionSerializer,
    DataCollectionEntrySerializer, MapLayerSerializer, MapFeatureSerializer,
    SubscriptionPlanSerializer, ClientUserSerializer, ClientBillingSerializer, ClientUsageSerializer
)
from django.utils import timezone
from datetime import timedelta

# Create your views here.

class UserViewSet(viewsets.ModelViewSet):
    queryset = User.objects.all()
    serializer_class = UserSerializer
    permission_classes = [permissions.IsAuthenticated]

class IsAdminUser(permissions.BasePermission):
    def has_permission(self, request, view):
        return request.user.is_staff

class SubscriptionPlanViewSet(viewsets.ModelViewSet):
    queryset = SubscriptionPlan.objects.all()
    serializer_class = SubscriptionPlanSerializer
    permission_classes = [permissions.IsAuthenticated, IsAdminUser]

class ClientViewSet(viewsets.ModelViewSet):
    queryset = Client.objects.all()
    serializer_class = ClientSerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_queryset(self):
        if self.request.user.is_staff:
            return Client.objects.all()
        return Client.objects.filter(users__user=self.request.user)

    @action(detail=True, methods=['post'])
    def add_user(self, request, pk=None):
        client = self.get_object()
        serializer = ClientUserSerializer(data={
            'client': client.id,
            'user_id': request.data.get('user_id'),
            'role': request.data.get('role', 'user')
        })
        
        if serializer.is_valid():
            serializer.save()
            return Response(serializer.data, status=status.HTTP_201_CREATED)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

    @action(detail=True, methods=['post'])
    def activate_subscription(self, request, pk=None):
        if not request.user.is_staff:
            return Response({'error': 'Admin access required'}, status=status.HTTP_403_FORBIDDEN)
        
        client = self.get_object()
        plan_id = request.data.get('plan_id')
        duration_months = request.data.get('duration_months', 1)
        
        try:
            plan = SubscriptionPlan.objects.get(id=plan_id)
            client.subscription_plan = plan
            client.status = 'active'
            client.subscription_start = timezone.now()
            client.subscription_end = timezone.now() + timedelta(days=30 * duration_months)
            client.save()
            
            # Create billing record
            ClientBilling.objects.create(
                client=client,
                amount=plan.price * duration_months,
                invoice_number=f"INV-{client.id}-{timezone.now().strftime('%Y%m%d')}",
                billing_period_start=client.subscription_start,
                billing_period_end=client.subscription_end
            )
            
            return Response({'status': 'subscription activated'})
        except SubscriptionPlan.DoesNotExist:
            return Response({'error': 'Invalid plan'}, status=status.HTTP_400_BAD_REQUEST)

    @action(detail=True, methods=['post'])
    def suspend_subscription(self, request, pk=None):
        if not request.user.is_staff:
            return Response({'error': 'Admin access required'}, status=status.HTTP_403_FORBIDDEN)
        
        client = self.get_object()
        client.status = 'suspended'
        client.save()
        return Response({'status': 'subscription suspended'})

    @action(detail=True, methods=['get'])
    def usage_stats(self, request, pk=None):
        client = self.get_object()
        today = timezone.now().date()
        
        # Get or create today's usage record
        usage, created = ClientUsage.objects.get_or_create(
            client=client,
            date=today,
            defaults={
                'users_count': client.users.count(),
                'forms_count': client.forms.count(),
                'items_count': sum(category.items.count() for category in client.categories.all()),
                'storage_used': 0  # Implement storage calculation
            }
        )
        
        serializer = ClientUsageSerializer(usage)
        return Response(serializer.data)

    @action(detail=True, methods=['get'])
    def billing_history(self, request, pk=None):
        client = self.get_object()
        billing = client.billing.all().order_by('-created_at')
        serializer = ClientBillingSerializer(billing, many=True)
        return Response(serializer.data)

    @action(detail=True, methods=['get'])
    def dashboard_data(self, request, pk=None):
        client = self.get_object()
        departments = client.departments.all()
        
        data = {
            'departments': [],
            'total_items': 0,
            'total_forms': 0,
            'total_incidences': 0,
            'map_layers': MapLayerSerializer(client.map_layers.all(), many=True).data
        }
        
        for dept in departments:
            dept_data = {
                'id': dept.id,
                'name': dept.name,
                'categories': []
            }
            
            for category in dept.categories.all():
                cat_data = {
                    'id': category.id,
                    'name': category.name,
                    'items_count': category.items.count(),
                    'forms_count': category.forms.count()
                }
                dept_data['categories'].append(cat_data)
                data['total_items'] += cat_data['items_count']
                data['total_forms'] += cat_data['forms_count']
                data['total_incidences'] += sum(item.incidences.count() for item in category.items.all())
            
            data['departments'].append(dept_data)
        
        return Response(data)

    @action(detail=True, methods=['get'])
    def preview(self, request, pk=None):
        dashboard = self.get_object()
        form = dashboard.form
        
        # Get form submissions
        submissions = form.submissions.all()
        
        # Process data based on visualization type
        if dashboard.visualization_type == 'map':
            data = [{
                'id': sub.id,
                'latitude': sub.data.get('latitude'),
                'longitude': sub.data.get('longitude'),
                'data': sub.data
            } for sub in submissions]
        elif dashboard.visualization_type == 'chart':
            # Process data for chart visualization
            field_name = dashboard.config.get('field')
            data = {}
            for sub in submissions:
                value = sub.data.get(field_name)
                if value:
                    data[value] = data.get(value, 0) + 1
        else:
            data = [sub.data for sub in submissions]
        
        return Response({
            'type': dashboard.visualization_type,
            'chart_type': dashboard.chart_type,
            'data': data
        })

class DepartmentViewSet(viewsets.ModelViewSet):
    queryset = Department.objects.all()
    serializer_class = DepartmentSerializer
    permission_classes = [permissions.IsAuthenticated]

    @action(detail=True, methods=['get'])
    def categories(self, request, pk=None):
        department = self.get_object()
        categories = department.categories.all()
        serializer = CategorySerializer(categories, many=True)
        return Response(serializer.data)

class CategoryViewSet(viewsets.ModelViewSet):
    queryset = Category.objects.all()
    serializer_class = CategorySerializer
    permission_classes = [permissions.IsAuthenticated]

    @action(detail=True, methods=['get'])
    def items_map(self, request, pk=None):
        category = self.get_object()
        items = category.items.all()
        serializer = ItemSerializer(items, many=True)
        return Response(serializer.data)

class MapLayerViewSet(viewsets.ModelViewSet):
    queryset = MapLayer.objects.all()
    serializer_class = MapLayerSerializer
    permission_classes = [permissions.IsAuthenticated]

    @action(detail=True, methods=['post'])
    def add_feature(self, request, pk=None):
        layer = self.get_object()
        serializer = MapFeatureSerializer(data=request.data)
        
        if serializer.is_valid():
            serializer.save(layer=layer)
            return Response(serializer.data, status=status.HTTP_201_CREATED)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

    @action(detail=True, methods=['get'])
    def features(self, request, pk=None):
        layer = self.get_object()
        features = layer.features.all()
        serializer = MapFeatureSerializer(features, many=True)
        return Response(serializer.data)

class MapFeatureViewSet(viewsets.ModelViewSet):
    queryset = MapFeature.objects.all()
    serializer_class = MapFeatureSerializer
    permission_classes = [permissions.IsAuthenticated]

class FormViewSet(viewsets.ModelViewSet):
    queryset = Form.objects.all()
    serializer_class = FormSerializer
    permission_classes = [permissions.IsAuthenticated]

    @action(detail=True, methods=['post'])
    def add_field(self, request, pk=None):
        form = self.get_object()
        serializer = FormFieldSerializer(data=request.data)
        
        if serializer.is_valid():
            serializer.save(form=form)
            return Response(serializer.data, status=status.HTTP_201_CREATED)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

    @action(detail=True, methods=['get'])
    def submissions(self, request, pk=None):
        form = self.get_object()
        submissions = form.submissions.all()
        serializer = FormSubmissionSerializer(submissions, many=True)
        return Response(serializer.data)

class FormSubmissionViewSet(viewsets.ModelViewSet):
    queryset = FormSubmission.objects.all()
    serializer_class = FormSubmissionSerializer
    permission_classes = [permissions.IsAuthenticated]

    def perform_create(self, serializer):
        serializer.save(submitted_by=self.request.user)

class ItemViewSet(viewsets.ModelViewSet):
    queryset = Item.objects.all()
    serializer_class = ItemSerializer
    permission_classes = [permissions.IsAuthenticated]

    @action(detail=False, methods=['get'])
    def map_data(self, request):
        # Filter by category if provided
        category_id = request.query_params.get('category')
        items = self.get_queryset()
        
        if category_id:
            items = items.filter(category_id=category_id)
        
        data = [{
            'id': item.id,
            'name': item.name,
            'category': item.category.name,
            'latitude': item.latitude,
            'longitude': item.longitude,
            'properties': item.properties,
            'incidences_count': item.incidences.count()
        } for item in items]
        
        return Response(data)

class IncidenceViewSet(viewsets.ModelViewSet):
    queryset = Incidence.objects.all()
    serializer_class = IncidenceSerializer
    permission_classes = [permissions.IsAuthenticated]

    def perform_create(self, serializer):
        serializer.save(reported_by=self.request.user)

    @action(detail=False, methods=['get'])
    def dashboard(self, request):
        # Get statistics for incidences
        total = self.get_queryset().count()
        by_severity = {
            severity: self.get_queryset().filter(severity=severity).count()
            for severity, _ in Incidence.SEVERITY_CHOICES
        }
        by_status = {
            status: self.get_queryset().filter(status=status).count()
            for status, _ in Incidence.STATUS_CHOICES
        }
        
        return Response({
            'total': total,
            'by_severity': by_severity,
            'by_status': by_status
        })

class DashboardConfigViewSet(viewsets.ModelViewSet):
    queryset = DashboardConfig.objects.all()
    serializer_class = DashboardConfigSerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_queryset(self):
        """
        Filter dashboards to only show those belonging to the user's client
        """
        try:
            client = self.request.user.clientuser.client
            return DashboardConfig.objects.filter(client=client)
        except (AttributeError, ClientUser.DoesNotExist):
            return DashboardConfig.objects.none()

    @action(detail=True, methods=['get'], url_path='stats', url_name='dashboard-stats')
    def stats(self, request):
        print("Stats endpoint called")  # Debug log
        try:
            # Get the client for the current user
            try:
                client = request.user.clientuser.client
            except (AttributeError, ClientUser.DoesNotExist):
                return Response(
                    {'error': 'User is not associated with any client'},
                    status=status.HTTP_404_NOT_FOUND
                )

            print(f"Found client: {client.name}")  # Debug log

            # Get total forms and submissions
            total_forms = Form.objects.filter(client=client).count()
            total_submissions = FormSubmission.objects.filter(form__client=client).count()
            
            print(f"Forms: {total_forms}, Submissions: {total_submissions}")  # Debug log
            
            # Get open incidences and active users
            open_incidences = Incidence.objects.filter(
                item__category__department__client=client,
                status='open'
            ).count()
            active_users = ClientUser.objects.filter(client=client, is_active=True).count()

            # Calculate trends based on last month's data
            now = timezone.now()
            last_month_start = now - timedelta(days=30)
            
            # This month's submissions (last 30 days)
            this_month_submissions = FormSubmission.objects.filter(
                form__client=client,
                created_at__gte=last_month_start
            ).count()
            
            # Last month's submissions (30-60 days ago)
            last_month_submissions = FormSubmission.objects.filter(
                form__client=client,
                created_at__lt=last_month_start,
                created_at__gte=last_month_start - timedelta(days=30)
            ).count()
            
            # This month's incidences
            this_month_incidences = Incidence.objects.filter(
                item__category__department__client=client,
                created_at__gte=last_month_start,
                status='open'
            ).count()
            
            # Last month's incidences
            last_month_incidences = Incidence.objects.filter(
                item__category__department__client=client,
                created_at__lt=last_month_start,
                created_at__gte=last_month_start - timedelta(days=30),
                status='open'
            ).count()

            # Calculate trend percentages and directions
            trends = {
                'total_forms': {
                    'value': total_forms,
                    'direction': 'up',
                    'percentage': 0  # Forms don't have created_at
                },
                'total_submissions': {
                    'value': total_submissions,
                    'direction': 'up' if this_month_submissions >= last_month_submissions else 'down',
                    'percentage': self._calculate_percentage_change(last_month_submissions, this_month_submissions)
                },
                'open_incidences': {
                    'value': open_incidences,
                    'direction': 'up' if this_month_incidences >= last_month_incidences else 'down',
                    'percentage': self._calculate_percentage_change(last_month_incidences, this_month_incidences)
                },
                'active_users': {
                    'value': active_users,
                    'direction': 'up',
                    'percentage': 0  # Simplified for now
                }
            }

            # Form statistics
            form_stats = {
                'completion_rate': self._calculate_completion_rate(client),
                'by_category': self._get_stats_by_category(client),
                'by_department': self._get_stats_by_department(client)
            }

            # Get recent activity (last 5 form submissions)
            recent_submissions = FormSubmission.objects.filter(
                form__client=client
            ).select_related('form', 'submitted_by').order_by('-created_at')[:5]
            
            recent_activity = []
            for submission in recent_submissions:
                recent_activity.append({
                    'title': submission.form.name,
                    'description': f'New submission by {submission.submitted_by.username}',
                    'timestamp': submission.created_at.isoformat()
                })

            response_data = {
                'total_forms': total_forms,
                'total_submissions': total_submissions,
                'open_incidences': open_incidences,
                'active_users': active_users,
                'trends': trends,
                'form_stats': form_stats,
                'recent_activity': recent_activity
            }
            print("Returning response data")  # Debug log
            return Response(response_data)
        except Exception as e:
            import traceback
            print(f"Error in stats endpoint: {str(e)}")
            print(traceback.format_exc())
            return Response(
                {
                    'error': str(e),
                    'traceback': traceback.format_exc()
                },
                status=status.HTTP_500_INTERNAL_SERVER_ERROR
            )

    def _calculate_percentage_change(self, old_value, new_value):
        if old_value == 0:
            return 100 if new_value > 0 else 0
        return round(((new_value - old_value) / old_value) * 100)

    def _calculate_completion_rate(self, client):
        total_forms = Form.objects.filter(client=client).count()
        if total_forms == 0:
            return 0
        
        # Consider a form "completed" if it has at least one submission
        completed_forms = Form.objects.filter(
            client=client,
            submissions__isnull=False
        ).distinct().count()
        
        return round((completed_forms / total_forms) * 100)

    def _get_stats_by_category(self, client):
        stats = {}
        categories = Category.objects.filter(department__client=client)
        for category in categories:
            forms = Form.objects.filter(client=client, category=category)
            forms_count = forms.count()
            submissions_count = FormSubmission.objects.filter(
                form__in=forms
            ).count()
            stats[category.name] = {
                'forms_count': forms_count,
                'submissions_count': submissions_count
            }
        return stats

    def _get_stats_by_department(self, client):
        stats = {}
        departments = Department.objects.filter(client=client)
        for department in departments:
            forms = Form.objects.filter(client=client, category__department=department)
            forms_count = forms.count()
            submissions_count = FormSubmission.objects.filter(
                form__in=forms
            ).count()
            stats[department.name] = {
                'forms_count': forms_count,
                'submissions_count': submissions_count
            }
        return stats

class DataCollectionSessionViewSet(viewsets.ModelViewSet):
    queryset = DataCollectionSession.objects.all()
    serializer_class = DataCollectionSessionSerializer
    permission_classes = [permissions.IsAuthenticated]

    def perform_create(self, serializer):
        serializer.save(user=self.request.user)

    @action(detail=True, methods=['post'])
    def update_location(self, request, pk=None):
        session = self.get_object()
        location = request.data.get('location')
        if location:
            session.current_location = location
            session.save()
            return Response({'status': 'location updated'})
        return Response({'error': 'location data required'}, status=status.HTTP_400_BAD_REQUEST)

    @action(detail=True, methods=['post'])
    def add_entry(self, request, pk=None):
        session = self.get_object()
        field_id = request.data.get('field_id')
        value = request.data.get('value')
        
        if not field_id or not value:
            return Response({'error': 'field_id and value required'}, status=status.HTTP_400_BAD_REQUEST)
        
        try:
            field = FormField.objects.get(id=field_id, form=session.form)
            entry = DataCollectionEntry.objects.create(
                session=session,
                form_field=field,
                value=value,
                location=session.current_location or {}
            )
            serializer = DataCollectionEntrySerializer(entry)
            return Response(serializer.data)
        except FormField.DoesNotExist:
            return Response({'error': 'invalid field'}, status=status.HTTP_400_BAD_REQUEST)

    @action(detail=True, methods=['post'])
    def end_session(self, request, pk=None):
        session = self.get_object()
        session.is_active = False
        session.end_time = timezone.now()
        session.save()
        return Response({'status': 'session ended'})
