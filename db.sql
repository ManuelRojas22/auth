CREATE DATABASE IF NOT EXISTS auth_db
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_unicode_ci;

USE auth_db;

-- ============================================
-- Tabla 1: Usuarios (register, login, passwords)
-- ============================================
DROP TABLE IF EXISTS auth_user;
CREATE TABLE auth_user (
    id INT AUTO_INCREMENT PRIMARY KEY,
    password VARCHAR(128) NOT NULL,
    last_login DATETIME(6) NULL,
    is_superuser TINYINT NOT NULL DEFAULT 0,
    username VARCHAR(150) NOT NULL UNIQUE,
    first_name VARCHAR(150) NOT NULL DEFAULT '',
    last_name VARCHAR(150) NOT NULL DEFAULT '',
    email VARCHAR(254) NOT NULL DEFAULT '',
    is_staff TINYINT NOT NULL DEFAULT 0,
    is_active TINYINT NOT NULL DEFAULT 1,
    date_joined DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================
-- Tabla 2: Tokens de recuperación (reset password)
-- ============================================
DROP TABLE IF EXISTS accounts_passwordresettoken;
CREATE TABLE accounts_passwordresettoken (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    token CHAR(36) NOT NULL UNIQUE,
    created_at DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
    is_used TINYINT NOT NULL DEFAULT 0,
    CONSTRAINT fk_reset_token_user FOREIGN KEY (user_id)
        REFERENCES auth_user(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================
-- Vistas
-- ============================================

-- Vista: usuarios activos (para login)
CREATE OR REPLACE VIEW vw_active_users AS
SELECT id, username, email, password, is_active, date_joined
FROM auth_user
WHERE is_active = 1;

-- Vista: tokens válidos (no usados, < 24h)
CREATE OR REPLACE VIEW vw_valid_reset_tokens AS
SELECT t.id, t.user_id, t.token, t.created_at,
       u.username, u.email
FROM accounts_passwordresettoken t
JOIN auth_user u ON u.id = t.user_id
WHERE t.is_used = 0
  AND t.created_at >= NOW() - INTERVAL 24 HOUR;

-- ============================================
-- Triggers
-- ============================================

DROP TRIGGER IF EXISTS trg_user_before_insert;
CREATE TRIGGER trg_user_before_insert
BEFORE INSERT ON auth_user
FOR EACH ROW
SET NEW.email = LOWER(TRIM(NEW.email)),
    NEW.username = LOWER(TRIM(NEW.username));

DROP TRIGGER IF EXISTS trg_user_before_update;
CREATE TRIGGER trg_user_before_update
BEFORE UPDATE ON auth_user
FOR EACH ROW
SET NEW.last_login = COALESCE(OLD.last_login, NEW.last_login);

DROP TRIGGER IF EXISTS trg_token_before_insert;
CREATE TRIGGER trg_token_before_insert
BEFORE INSERT ON accounts_passwordresettoken
FOR EACH ROW
SET NEW.created_at = NOW();
