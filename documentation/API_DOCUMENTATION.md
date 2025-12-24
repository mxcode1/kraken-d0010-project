# Kraken D0010 REST API Documentation

## Base URL
```
http://localhost:8000/api/
```

## Endpoints

### Flow Files
- **List/Create**: `GET/POST /api/flow-files/`
- **Detail**: `GET /api/flow-files/{id}/`
- **Filters**: `?filename=`, `?ordering=`

### Meter Points
- **List/Create**: `GET/POST /api/meter-points/`
- **Detail**: `GET /api/meter-points/{id}/`
- **Nested meters**: Included in response
- **Search**: `?search=mpan`

### Meters
- **List/Create**: `GET/POST /api/meters/`
- **Detail**: `GET /api/meters/{id}/`
- **Filters**: `?meter_type=`, `?meter_point=`
- **Search**: `?search=serial_number`

### Readings
- **List/Create**: `GET/POST /api/readings/`
- **Detail**: `GET /api/readings/{id}/`
- **Filters**: `?reading_date=`, `?meter=`, `?flow_file=`
- **Date range**: `?reading_date__gte=2025-01-01&reading_date__lte=2025-12-31`

## Pagination
All list endpoints support pagination:
```json
{
  "count": 1000,
  "next": "http://localhost:8000/api/readings/?page=2",
  "previous": null,
  "results": [...]
}
```

## Browsable API
Visit any endpoint in a web browser to use the interactive API interface.

## Example Usage

### Get all flow files
```bash
curl http://localhost:8001/api/flow-files/
```

### Search meter points by MPAN
```bash
curl "http://localhost:8001/api/meter-points/?search=1234567890123"
```

### Filter readings by date
```bash
curl "http://localhost:8001/api/readings/?reading_date__gte=2025-01-01"
```

### Create a new meter point (requires authentication)
```bash
curl -X POST http://localhost:8001/api/meter-points/ \
  -H "Content-Type: application/json" \
  -d '{"mpan": "1234567890123", "meter_type": "domestic"}'
```
