# DNS Resolution Exporter

Экспортер для Prometheus, который проверяет доступность доменов через DNS-резолвинг и экспортирует метрики для Grafana.

## Описание

Данный экспортер выполняет следующие функции:
- Периодически проверяет список доменов через DNS-резолвинг (nslookup)
- Возвращает метрику True/False (1/0) для каждого домена
- Предоставляет данные в формате, совместимом с Prometheus
- Визуализирует результаты в Grafana

## Файлы проекта

- `dns_exporter.py` - основной код экспортера
- `Dockerfile` - файл для сборки Docker-образа
- `docker-compose.yml` - конфигурация для запуска контейнера
- `requirements.txt` - зависимости Python
- `domains.txt` - список доменов для проверки
- `dns_dashboard.json` - готовый дашборд для Grafana
- `deploy.sh` - скрипт для быстрого развертывания

## Быстрый старт

### Вариант 1: Использование скрипта развертывания

```bash
chmod +x deploy.sh
./deploy.sh
```

### Вариант 2: Ручное развертывание

1. Создайте все необходимые файлы (см. список выше)
2. Настройте список доменов в файле `domains.txt`
3. Запустите контейнер:

```bash
docker-compose up -d
```

## Доступ к метрикам

Метрики доступны по адресу: http://localhost:9369/metrics

## Настройка Prometheus

Добавьте в конфигурацию Prometheus:

```yaml
scrape_configs:
  - job_name: 'dns_exporter'
    static_configs:
      - targets: ['dns_exporter:9369']
```

## Настройка Grafana

1. Импортируйте файл `dns_dashboard.json` в Grafana
2. Выберите источник данных Prometheus

## Параметры настройки

Экспортер поддерживает следующие переменные окружения:
- `LISTEN_PORT` - порт для экспорта метрик (по умолчанию 9369)
- `CHECK_INTERVAL` - интервал проверки в секундах (по умолчанию 60)
- `DOMAINS_FILE` - путь к файлу со списком доменов (по умолчанию /etc/dns_exporter/domains.txt)

## Формат файла domains.txt

Файл должен содержать список доменов, по одному на строку:

```
# Это комментарий
example.com
test.example.org
```

## Интеграция с OverallVision в Grafana

URL для импорта в Grafana OverallVision:
```
http://corpappmonitor1/grafana/d/overallvision/overall-vision?orgId=1&refresh=10s
```
