-- ============================================
-- Crear la Base de Datos
-- ============================================
CREATE DATABASE IF NOT EXISTS auth_db
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_unicode_ci;

USE auth_db;

-- ============================================
-- Tablas de Django Auth (generadas por migrate)
-- ============================================
-- django_content_type
-- auth_permission
-- auth_group
-- auth_group_permissions
-- auth_user
-- auth_user_groups
-- auth_user_user_permissions
-- django_session
-- django_admin_log
-- accounts_passwordresettoken

-- ============================================
-- Tabla: PasswordResetToken (personalizada)
-- ============================================
CREATE TABLE IF NOT EXISTS accounts_passwordresettoken (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    token CHAR(36) NOT NULL UNIQUE,
    created_at DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
    is_used TINYINT(1) NOT NULL DEFAULT 0,
    CONSTRAINT fk_reset_token_user FOREIGN KEY (user_id)
        REFERENCES auth_user(id)
        ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================
-- Comandos útiles
-- ============================================
-- Para migrar: python manage.py makemigrations && python manage.py migrate
-- Para crear superusuario: python manage.py createsuperuser
