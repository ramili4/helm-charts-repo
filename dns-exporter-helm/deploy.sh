#!/bin/bash

# Создание необходимых директорий и файлов
mkdir -p dns_exporter
cd dns_exporter

# Сохранение файлов проекта
cat > dns_exporter.py << 'EOF'
#!/usr/bin/env python3
import os
import time
import socket
import logging
from prometheus_client import start_http_server, Gauge

# Настройка логирования
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s',
)
logger = logging.getLogger('dns_exporter')

# Настройки экспортера
LISTEN_PORT = int(os.environ.get('LISTEN_PORT', 9369))
CHECK_INTERVAL = int(os.environ.get('CHECK_INTERVAL', 60))
DOMAINS_FILE = os.environ.get('DOMAINS_FILE', '/etc/dns_exporter/domains.txt')

# Создаем метрику для DNS-резолвинга
dns_resolution = Gauge(
    'dns_resolution_success',
    'DNS resolution status (1=success, 0=failure)',
    ['domain']
)

def load_domains():
    """Загрузка списка доменов из файла."""
    try:
        with open(DOMAINS_FILE, 'r') as f:
            domains = [line.strip() for line in f if line.strip() and not line.startswith('#')]
        logger.info(f"Loaded {len(domains)} domains from {DOMAINS_FILE}")
        return domains
    except Exception as e:
        logger.error(f"Failed to load domains from {DOMAINS_FILE}: {e}")
        # Возвращаем пустой список, чтобы экспортер мог продолжить работу
        return []

def check_dns(domain):
    """Проверка резолвинга домена."""
    try:
        socket.gethostbyname(domain)
        return True
    except socket.gaierror:
        return False
    except Exception as e:
        logger.error(f"Error checking DNS for {domain}: {e}")
        return False

def update_metrics():
    """Обновление метрик для всех доменов."""
    domains = load_domains()
    
    for domain in domains:
        success = check_dns(domain)
        metric_value = 1 if success else 0
        dns_resolution.labels(domain=domain).set(metric_value)
        
        status = "resolved" if success else "failed"
        logger.info(f"Domain {domain}: {status} ({metric_value})")

def main():
    """Основной цикл экспортера."""
    logger.info(f"Starting DNS Exporter on port {LISTEN_PORT}")
    start_http_server(LISTEN_PORT)
    
    logger.info(f"DNS check interval: {CHECK_INTERVAL} seconds")
    
    while True:
        logger.info("Starting DNS check cycle")
        update_metrics()
        logger.info(f"Sleeping for {CHECK_INTERVAL} seconds")
        time.sleep(CHECK_INTERVAL)

if __name__ == "__main__":
    main()
EOF

cat > requirements.txt << 'EOF'
prometheus-client>=0.14.1
EOF

cat > Dockerfile << 'EOF'
FROM python:3.9-slim

WORKDIR /app

# Установка зависимостей
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Копирование исходного кода
COPY dns_exporter.py .

# Создание директории для файла с доменами
RUN mkdir -p /etc/dns_exporter

# Порт для Prometheus
EXPOSE 9369

# Запуск экспортера
CMD ["python", "dns_exporter.py"]
EOF

cat > docker-compose.yml << 'EOF'
version: '3'

services:
  dns_exporter:
    build: .
    ports:
      - "9369:9369"
    volumes:
      - ./domains.txt:/etc/dns_exporter/domains.txt
    environment:
      - LISTEN_PORT=9369
      - CHECK_INTERVAL=60
    restart: always
EOF

# Создание файла со списком доменов
cat > domains.txt << 'EOF'
# Список доменов для проверки
# Каждый домен на отдельной строке
google.com
mail.com
amazon.com
EOF

# Выдача прав на исполнение
chmod +x dns_exporter.py

echo "Сборка и запуск Docker-контейнера..."
docker-compose up -d

echo "DNS Exporter успешно запущен!"
echo "Метрики доступны по адресу: http://localhost:9369/metrics"
