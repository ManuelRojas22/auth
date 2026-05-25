from django.urls import path
from . import views

urlpatterns = [
    path('', views.login_view, name='home'),
    path('register/', views.register_view, name='register'),
    path('login/', views.login_view, name='login'),
    path('logout/', views.logout_view, name='logout'),
    path('update-password/', views.update_password_view, name='update_password'),
    path('reset-password/', views.reset_password_request_view, name='reset_password'),
    path('reset-password/<uuid:token>/', views.reset_password_confirm_view, name='reset_password_confirm'),
]
