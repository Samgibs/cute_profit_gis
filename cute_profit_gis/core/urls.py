from django.urls import path, include
from rest_framework.routers import DefaultRouter
from . import views

router = DefaultRouter()
router.register(r'users', views.UserViewSet)
router.register(r'clients', views.ClientViewSet)
router.register(r'departments', views.DepartmentViewSet)
router.register(r'categories', views.CategoryViewSet)
router.register(r'forms', views.FormViewSet)
router.register(r'submissions', views.FormSubmissionViewSet)
router.register(r'items', views.ItemViewSet)
router.register(r'incidences', views.IncidenceViewSet)
router.register(r'dashboards', views.DashboardConfigViewSet)
router.register(r'collection-sessions', views.DataCollectionSessionViewSet)
router.register(r'map-layers', views.MapLayerViewSet)
router.register(r'map-features', views.MapFeatureViewSet)
router.register(r'subscription-plans', views.SubscriptionPlanViewSet)

urlpatterns = [
    path('', include(router.urls)),
] 