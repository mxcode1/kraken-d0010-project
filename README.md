# 🦑 Kraken D0010 - Electricity Meter Reading System

Django-based system for processing D0010 electricity meter reading files used in the UK energy industry.

[![Python 3.13+](https://img.shields.io/badge/python-3.13+-blue.svg)](https://www.python.org/downloads/)
[![Django 6.0](https://img.shields.io/badge/django-6.0-green.svg)](https://www.djangoproject.com/)

## Features

✅ **D0010 File Import** - Parse industry-standard meter reading files  
✅ **Normalized Database** - FlowFile → Reading → Meter → MeterPoint schema  
✅ **Admin Interface** - Full CRUD with search, filters, and inline editing  
✅ **Testing Dashboard** - Self-service data management for demos  
✅ **Dual Database** - SQLite (dev) / PostgreSQL (prod)  
✅ **Security Hardened** - HSTS, secure cookies, XSS protection (production)  
✅ **Automated Deployment** - Complete setup scripts  

## Quick Start

From the project root directory:

```bash
# 1. Install dependencies
pip install -r requirements.txt

# 2. Setup database
python manage.py migrate

# 3. Create admin user
python manage.py createsuperuser

# 4. Start server
python manage.py runserver 8001
```

**Or use the one-command demo launcher:**
```bash
./run_demo_server.sh
```

## Access Points

- **Home:** http://127.0.0.1:8001/
- **Admin:** http://127.0.0.1:8001/admin/
- **Testing Dashboard:** http://127.0.0.1:8001/admin/testing/

**Demo Credentials:**
- Username: `demo_admin`
- Password: `KrakenDemo123!`

## Documentation

- **[QUICKSTART.md](QUICKSTART.md)** - 2-minute setup guide
- **[documentation/FUNCTIONAL_SPEC.md](documentation/FUNCTIONAL_SPEC.md)** - Complete feature documentation
- **[documentation/TESTING_GUIDE.md](documentation/TESTING_GUIDE.md)** - Testing dashboard guide
- **[documentation/DEPLOYMENT_GUIDE.md](documentation/DEPLOYMENT_GUIDE.md)** - Production deployment

## Project Structure

```
kraken_d0010_project/
├── manage.py                    # Django management
├── requirements.txt             # Python dependencies
├── run_demo_server.sh          # Quick launcher
├── config/             # Django project
│   ├── settings.py             # Configuration
│   └── urls.py                 # Routing
├── meter_readings/             # Main application
│   ├── models.py               # Data models
│   ├── admin.py                # Admin config
│   ├── admin_views.py          # Testing dashboard
│   ├── views.py                # Public views
│   ├── management/
│   │   └── commands/
│   │       └── import_d0010.py # Import CLI
│   └── templates/              # HTML templates
├── sample_data/                # Test .uff files
├── deployment_scripts/         # Automation
│   ├── common.sh               # Shared utilities & colors
│   ├── quick_deploy.sh         # One-command orchestrator
│   ├── setup_system_dependencies.sh  # Install system packages
│   ├── setup_python_environment.sh   # Create venv & dependencies
│   ├── setup_databases.sh      # Configure SQLite/PostgreSQL
│   ├── validate_deployment.sh  # Verify system health
│   └── create_deployment_tarball.sh  # Package for distribution
└── documentation/              # Guides
```

## Data Model

```
FlowFile (Imported files)
    ↓
Reading (Meter readings)
    ↓
Meter (Physical devices)
    ↓
MeterPoint (MPAN - supply points)
```

## Usage Examples

### Import D0010 File

```bash
# Command line
python manage.py import_d0010 sample_data/commercial_properties.uff

# Dry-run (validation only)
python manage.py import_d0010 sample_data/test.uff --dry-run
```

### Testing Dashboard

1. Login to admin interface
2. Click "🧪 Testing & Debug" in sidebar
3. Use dashboard to:
   - Import all sample files
   - Clear database
   - View statistics

### Database Switching

```bash
# Development (SQLite)
python manage.py runserver 8001

# Production (PostgreSQL)
export USE_POSTGRESQL=1
export DB_NAME=kraken_d0010
export DB_USER=postgres
export DB_PASSWORD=yourpassword
python manage.py migrate
python manage.py runserver 8001
```

## Deployment

### Automated (Recommended)

```bash
./deployment_scripts/setup_system_dependencies.sh
./deployment_scripts/setup_python_environment.sh
./deployment_scripts/setup_databases.sh
./deployment_scripts/validate_deployment.sh
```

### Deployment

See **[documentation/DEPLOYMENT_GUIDE.md](documentation/DEPLOYMENT_GUIDE.md)** for:
- Complete deployment workflow
- Tarball creation & distribution
- Automated setup scripts
- Database configuration options
- System verification

## Development

### Run Tests

This project maintains **100% test coverage** across all modules with 12 comprehensive tests passing.

```bash
python manage.py test
```

### Coverage Report

All code achieves **100% coverage** with zero uncovered lines across models, views, admin, serializers, and management commands.

```bash
coverage run manage.py test
coverage html  # Open htmlcov/index.html
```

### Code Style

Code is formatted with **Black** (zero violations) and passes **Flake8** linting with zero errors or warnings.

```bash
black .
flake8
```

## Requirements

- **Python:** 3.13+
- **Django:** 6.0
- **Database:** SQLite (dev) / PostgreSQL 12+ (prod)
- **OS:** macOS, Linux, Windows

**Dependencies:**
- psycopg2-binary - PostgreSQL adapter
- djangorestframework - REST API framework
- django-filter - API filtering
- drf-spectacular - OpenAPI/Swagger docs
- django-cors-headers - CORS support
- coverage - Test coverage (dev only)

## Security

### Development (DEBUG=True)
- HTTP allowed on localhost
- Security features disabled
- Detailed error pages

### Production (DEBUG=False)
- HTTPS enforced (SECURE_SSL_REDIRECT)
- HSTS with 1-year max-age
- Secure cookies
- XSS protection
- Clickjacking prevention

**Always use environment variables for:**
- SECRET_KEY
- Database credentials
- DEBUG flag
- ALLOWED_HOSTS

## Support

For issues or questions, check documentation in `/documentation/`

## System Overview

See [SYSTEM_SUMMARY.md](SYSTEM_SUMMARY.md) for complete feature list and capabilities.

---

🦑 **Kraken D0010**
