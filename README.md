# Tellix — Sistema de gestión comercial

Stack: **Java 21 + Spring Boot 3.3** · **Vue 3 + Vite + TypeScript** · **SQL Server 2019+**

---

## Requisitos

| Herramienta | Versión mínima |
|---|---|
| Java (JDK) | 21 |
| Maven | 3.9 |
| Node.js | 20 |
| SQL Server | 2019 |
| Docker (opcional) | 24 |

---

## Configuración inicial

### 1. Base de datos

Ejecutar `TellixDB_SQLServer.sql` en SQL Server Management Studio o Azure Data Studio.

Crear el archivo `.env` en `/backend` copiando `.env.example`:

```bash
cp backend/.env.example backend/.env
# Editar con los datos reales de la BD y el JWT secret
```

### 2. Backend

```bash
cd backend
mvn spring-boot:run -Dspring-boot.run.profiles=dev
# API disponible en http://localhost:8080
# Swagger UI en http://localhost:8080/swagger-ui
```

### 3. Frontend

```bash
cd frontend
npm install
cp .env.example .env
npm run dev
# App disponible en http://localhost:5173
```

---

## Con Docker Compose

```bash
cp backend/.env.example .env
# Editar .env con credenciales reales
docker compose up --build
# App en http://localhost:80
# API en http://localhost:8080
```

---

## Estructura del proyecto

```
tellix/
├── backend/          Spring Boot 3 + Java 21
│   └── src/main/java/com/tellix/
│       ├── config/   Seguridad, JWT, CORS, OpenAPI
│       ├── security/ JwtService, JwtAuthFilter, UserDetails
│       ├── shared/   DTOs, excepciones, utils
│       └── modules/  auth, venta, compra, inventario…
│
├── frontend/         Vue 3 + Vite + TypeScript
│   └── src/
│       ├── router/   Rutas + guards por rol
│       ├── stores/   auth.store, ui.store (Pinia)
│       ├── services/ api.ts (Axios + interceptores JWT)
│       ├── composables/ useAuth, useToast
│       ├── components/  layout (Sidebar, Topbar, AppLayout)
│       └── views/    LoginView + 21 vistas por módulo
│
└── docker-compose.yml
```

---

## Flujo de autenticación

1. Usuario ingresa credenciales en `LoginView.vue`
2. Frontend hashea la contraseña con **SHA-256** (`js-sha256`)
3. `POST /api/auth/login` → `sp_login` en SQL Server valida el hash
4. Backend genera **JWT** (8h) + **refresh token** (24h)
5. `authStore` (Pinia) guarda tokens en `sessionStorage`
6. `api.ts` inyecta `Bearer <token>` en cada petición via interceptor
7. Al expirar (401), el interceptor intenta renovar con el refresh token
8. `guards.ts` en Vue Router verifica rol y nivel antes de cada ruta

---

## Roles disponibles

| Rol | Nivel | Acceso |
|---|---|---|
| ADMINISTRADOR | 1 | Todo el sistema |
| VENDEDOR | 2 | Ventas, clientes, catálogos |
| BODEGUERO | 3 | Compras, inventario, catálogos |
| CONTADOR | 4 | CXC, CXP, reportes, catálogos |

---

## Variables de entorno requeridas

### Backend (`.env`)
```
DB_URL=jdbc:sqlserver://localhost:1433;databaseName=TellixDB;...
DB_USER=tellix_app
DB_PASS=tu_password
JWT_SECRET=clave-de-al-menos-256-bits
CORS_ORIGINS=http://localhost:5173
```

### Frontend (`.env`)
```
VITE_API_BASE_URL=http://localhost:8080/api
```
