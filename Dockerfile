# Etapa 1: Construcción del frontend
FROM node:18 AS frontend-builder
WORKDIR /app/frontend
COPY frontend/package*.json ./
RUN npm install
COPY frontend/ ./
RUN npm run build

# Etapa 2: Construcción del backend
FROM python:3.10-slim AS backend-builder
WORKDIR /app/backend
COPY backend/Pipfile ./
RUN pip install pipenv && pipenv install --deploy --ignore-pipfile
COPY backend/ ./

# Etapa 3: Imagen final
FROM python:3.10-slim
WORKDIR /app

# Copiar el backend
COPY --from=backend-builder /app/backend /app/backend
# Copiar el frontend construido
COPY --from=frontend-builder /app/frontend/.next /app/frontend/.next
COPY --from=frontend-builder /app/frontend/public /app/frontend/public

# Variables de entorno
ENV PYTHONUNBUFFERED=1

# Configuración del entorno (puedes ajustarlo según tu configuración)
ENV DATABASE_URL=postgresql://user:password@hostname:port/database

# Comando para iniciar la aplicación
CMD ["./run.sh"]
