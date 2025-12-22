# Kraken D0010 - Complete Deployment Guide

Here is the Django Admin Dashboard for Processing d0010.uff specification flow files with file import through CLI / UI - support for Postgres / SQLite DB & Development with documentation / test coverage and sample data / shell scripts for testing and system validation

## Complete Deployment Flow

### **Phase 1: Package Distribution**
```bash
# Create deployment package (from development workspace)
cd /path/to/kraken-project-integration
./deployment_scripts/create_deployment_tarball.sh

# This creates: kraken-d0010-system-YYYYMMDD-HHMMSS.tar.gz
```

### **Phase 2: System Deployment**
```bash
# Extract package
tar -xzf kraken-d0010-system-YYYYMMDD-HHMMSS.tar.gz

# Navigate to extracted directory
cd kraken-d0010-build

# One-command deployment (multiple options available)
./deployment_scripts/quick_deploy.sh --sqlite-only --extended-samples --skip-system-deps
```

### **Phase 3: Launch & Access**
```bash
# Activate environment and navigate to Django project
source kraken_d0010_project/venv/bin/activate
cd kraken_d0010_project

# Start web server
python manage.py runserver

# Access system:
# - Main Interface: http://localhost:8000/
# - Admin Portal: http://localhost:8000/admin/
# - Login: demo_admin / KrakenDemo123!
```

## 📋 Deployment Script Options

### **quick_deploy.sh** - Main Orchestrator

**Basic Deployment Modes:**
```bash
# SQLite-only (recommended for demos/testing)
./deployment_scripts/quick_deploy.sh --sqlite-only

# Dual database (SQLite + PostgreSQL)
./deployment_scripts/quick_deploy.sh --with-postgresql

# PostgreSQL primary (advanced)
./deployment_scripts/quick_deploy.sh --postgresql-primary
```

**Sample Data Options:**
```bash
# Minimal data (original samples only)
./deployment_scripts/quick_deploy.sh --sqlite-only

# Extended data (69+ readings across 10 scenarios)
./deployment_scripts/quick_deploy.sh --sqlite-only --extended-samples
```

**System Setup Options:**
```bash
# Full deployment (installs system dependencies)
./deployment_scripts/quick_deploy.sh --sqlite-only --extended-samples

# Skip system deps (if already installed)
./deployment_scripts/quick_deploy.sh --sqlite-only --extended-samples --skip-system-deps
```

## 🔧 Individual Script Components

If you need granular control, here are the individual scripts:

### **1. System Dependencies**
```bash
./deployment_scripts/setup_system_dependencies.sh
# Installs: Python 3.8+, PostgreSQL (if needed), system packages
```

### **2. Python Environment**
```bash
cd kraken_d0010_project
../deployment_scripts/setup_python_environment.sh
# Creates: venv, installs pip packages from requirements.txt
```

### **3. Database Setup**
```bash
cd kraken_d0010_project
../deployment_scripts/setup_databases.sh sqlite
# or
../deployment_scripts/setup_databases.sh postgresql
# or  
../deployment_scripts/setup_databases.sh both
```

### **4. Sample Data Import**
```bash
cd kraken_d0010_project
../deployment_scripts/import_sample_data.sh sqlite
# or
../deployment_scripts/import_sample_data.sh postgresql
# or
../deployment_scripts/import_sample_data.sh both
```

### **5. System Validation**
```bash
cd kraken_d0010_project
../deployment_scripts/validate_deployment.sh
# Runs comprehensive health checks
```

## 🎯 Complete One-Liner Deployment

For the fastest deployment experience:

```bash
# Extract, deploy, and get deployment instructions
tar -xzf kraken-d0010-system-*.tar.gz && \
cd kraken-d0010-build && \
./deployment_scripts/quick_deploy.sh --sqlite-only --extended-samples --skip-system-deps

# Then follow the displayed instructions to start the server
```

## 📊 What Gets Deployed

**Database Content:**
- **78 meter readings** (13 original + 65 extended)
- **51 unique MPANs** across multiple scenarios
- **13 data files** processed
- **Complete admin interface** with search functionality

**System Features:**
- Dual database support (SQLite3 + PostgreSQL)
- Advanced search capabilities (MPAN, serial, filename)
- Admin interface with comprehensive filtering
- Sample data across residential, commercial, industrial scenarios
- Date range filtering and export capabilities

**Access Credentials:**
- **Username:** `demo_admin`
- **Password:** `KrakenDemo123!`

This process deploys the full D0010 processing system with full sample data from gzipped tarball.

## 🔍 Demo Search Examples

Once deployed, you can test these search scenarios in the admin interface:

### **Original Sample Data**
- **MPAN:** `1200023305967`
- **Serial:** `F75A 00802`
- **Filename:** `sample_d0010.uff`

### **Extended Sample Data**
- **Smart Meter MPAN:** `1400056789012`
- **Commercial MPAN:** `2100098765432`
- **Industrial MPAN:** `3000012345678`
- **Prepayment MPAN:** `1500011111111`

### **Meter Serials**
- **Smart Serial:** `SM1A 12345`
- **Commercial Serial:** `C01A 98765`
- **Industrial Serial:** `IND1 54321`
- **Prepayment Serial:** `PP01 11111`

## 🚨 Troubleshooting

### **Permission Issues**
```bash
# If scripts aren't executable after extraction
chmod +x deployment_scripts/*.sh
```

### **Directory Issues**
```bash
# Ensure you're in the correct directory
pwd
ls -la  # Should see: deployment_scripts/, kraken_d0010_project/, README.md
```

### **Python Environment Issues**
```bash
# Check Python version
python3 --version  # Should be 3.8+ (Built on 3.13.3)

# Manual venv activation if needed
cd kraken_d0010_project
source venv/bin/activate
```

### **Database Connection Issues**
```bash
# Test SQLite connection
cd kraken_d0010_project
python manage.py shell -c "from meter_readings.models import Reading; print(f'Readings: {Reading.objects.count()}')"

# Test PostgreSQL connection (if using)
USE_POSTGRESQL=1 python manage.py shell -c "from meter_readings.models import Reading; print(f'Readings: {Reading.objects.count()}')"
```

## 📦 Package Contents

When you extract the deployment tarball, you'll find:

```
kraken-d0010-build/
├── deployment_scripts/           # All deployment automation
│   ├── common.sh                 # Shared utilities & colors
│   ├── quick_deploy.sh           # Main orchestrator
│   ├── create_deployment_tarball.sh  # Package for distribution
│   ├── setup_system_dependencies.sh  # Install system packages
│   ├── setup_python_environment.sh   # Create venv & dependencies
│   ├── setup_databases.sh        # Configure SQLite/PostgreSQL
│   ├── import_sample_data.sh     # Load sample UFF files
│   ├── validate_deployment.sh    # Verify system health
│   ├── .env.template             # Environment configuration
│   └── Brewfile                  # macOS dependencies
├── kraken_d0010_project/         # Django application
│   ├── manage.py                 # Django CLI
│   ├── requirements.txt          # Python dependencies
│   ├── sample_files_generator.sh # Generate test data
│   ├── config/                   # Django Project Config
│   ├── meter_readings/           # Main app
│   └── sample_data/              # Sample UFF files
├── documentation/                # Additional docs
├── README.md                     # Quick reference
├── QUICK_REFERENCE.md            # Command cheatsheet
└── VERSION                       # Build information
```

## 🎉 Success Indicators

Your deployment is successful when you see:

1. ✅ All deployment steps complete without errors
2. ✅ Web server starts on `http://localhost:8000`
3. ✅ Admin login works with demo credentials
4. ✅ Search functionality returns results
5. ✅ Database shows expected record counts (78+ readings)

---

**Ready to deploy your Kraken D0010 system!** 🚀