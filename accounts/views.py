from django.shortcuts import render, redirect, get_object_or_404
from django.contrib.auth import login, logout, authenticate, update_session_auth_hash
from django.contrib.auth.decorators import login_required
from django.contrib import messages
from django.contrib.auth.models import User
from .forms import (
    RegisterForm, LoginForm, UpdatePasswordForm,
    PasswordResetRequestForm, PasswordResetConfirmForm
)
from .models import PasswordResetToken

def register_view(request):
    if request.method == 'POST':
        form = RegisterForm(request.POST)
        if form.is_valid():
            user = form.save()
            login(request, user)
            messages.success(request, 'Registro exitoso. Bienvenido!')
            return redirect('home')
    else:
        form = RegisterForm()
    return render(request, 'accounts/register.html', {'form': form})

def login_view(request):
    if request.method == 'POST':
        form = LoginForm(request, data=request.POST)
        if form.is_valid():
            user = form.get_user()
            login(request, user)
            messages.success(request, f'Bienvenido de nuevo, {user.username}!')
            return redirect('home')
        else:
            messages.error(request, 'Usuario o contraseña incorrectos')
    else:
        form = LoginForm()
    return render(request, 'accounts/login.html', {'form': form})

def logout_view(request):
    logout(request)
    messages.success(request, 'Sesión cerrada correctamente')
    return redirect('login')

@login_required
def update_password_view(request):
    if request.method == 'POST':
        form = UpdatePasswordForm(request.POST)
        if form.is_valid():
            user = request.user
            if not user.check_password(form.cleaned_data['old_password']):
                messages.error(request, 'La contraseña actual es incorrecta')
            else:
                user.set_password(form.cleaned_data['new_password'])
                user.save()
                update_session_auth_hash(request, user)
                messages.success(request, 'Contraseña actualizada correctamente')
                return redirect('home')
    else:
        form = UpdatePasswordForm()
    return render(request, 'accounts/update_password.html', {'form': form})

def reset_password_request_view(request):
    if request.method == 'POST':
        form = PasswordResetRequestForm(request.POST)
        if form.is_valid():
            email = form.cleaned_data['email']
            try:
                user = User.objects.get(email=email)
                token = PasswordResetToken.objects.create(user=user)
                # En producción, enviar email con el token
                messages.success(
                    request,
                    f'Se ha enviado un enlace de recuperación a {email}. '
                    f'Token: {token.token} (modo desarrollo)'
                )
                return redirect('login')
            except User.DoesNotExist:
                messages.error(request, 'No existe una cuenta con ese correo electrónico')
    else:
        form = PasswordResetRequestForm()
    return render(request, 'accounts/reset_password.html', {'form': form, 'step': 'request'})

def reset_password_confirm_view(request, token):
    token_obj = get_object_or_404(PasswordResetToken, token=token, is_used=False)

    if request.method == 'POST':
        form = PasswordResetConfirmForm(request.POST)
        if form.is_valid():
            user = token_obj.user
            user.set_password(form.cleaned_data['new_password'])
            user.save()
            token_obj.is_used = True
            token_obj.save()
            messages.success(request, 'Contraseña restablecida correctamente. Inicia sesión.')
            return redirect('login')
    else:
        form = PasswordResetConfirmForm()
    return render(request, 'accounts/reset_password.html', {'form': form, 'step': 'confirm'})

def home_view(request):
    return render(request, 'accounts/home.html')
