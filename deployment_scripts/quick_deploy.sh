#!/bin/bash

# ============================================================================
# KRAKEN ENERGY D0010 - QUICK DEPLOYMENT SCRIPT
# ============================================================================
# One-command deployment for extracted tarball
# Usage: bash deployment_scripts/quick_deploy.sh [options]
# ============================================================================

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m'

# Default configuration
DEPLOYMENT_MODE="interactive"
SKIP_SYSTEM_DEPS=false

echo -e "${PURPLE}"
echo "🦑🦑🦑🦑🦑🦑🦑🦑🦑🦑🦑🦑🦑🦑🦑🦑🦑🦑🦑🦑🦑🦑🦑🦑🦑🦑🦑🦑🦑🦑🦑🦑🦑🦑🦑🦑🦑🦑🦑🦑"
echo "🦑                    KRAKEN D0010 QUICK DEPLOY                       🦑"
echo "🦑🦑🦑🦑🦑🦑🦑🦑🦑🦑🦑🦑🦑🦑🦑🦑🦑🦑🦑🦑🦑🦑🦑🦑🦑🦑🦑🦑🦑🦑🦑🦑🦑🦑🦑🦑🦑🦑🦑🦑"
echo -e "${NC}"

# Check prerequisites
echo -e "${YELLOW}🔍 Checking prerequisites...${NC}"

if [[ ! -f "manage.py" ]]; then
    echo -e "${RED}❌ manage.py not found in current directory${NC}"
    echo -e "${YELLOW}💡 Run from Django project root (extracted tarball directory)${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Prerequisites check passed${NC}"

# Setup system dependencies
echo ""
read -p "Install system dependencies (Python, PostgreSQL)? [Y/n]: " install_deps
if [[ ! "$install_deps" =~ ^[Nn]$ ]]; then
    if [[ -f "deployment_scripts/setup_system_dependencies.sh" ]]; then
        bash deployment_scripts/setup_system_dependencies.sh
    fi
fi

# Setup Python environment
echo ""
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${YELLOW}📝 Python Environment Setup${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

python3 -m venv venv
source venv/bin/activate
pip install --upgrade pip -q
pip install -r requirements.txt

echo -e "${GREEN}✅ Python environment ready${NC}"

# Setup databases
echo ""
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${YELLOW}📝 Database Setup${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

if [[ -f "deployment_scripts/setup_databases.sh" ]]; then
    bash deployment_scripts/setup_databases.sh --sqlite-only
else
    python manage.py makemigrations
    python manage.py migrate
fi

echo -e "${GREEN}✅ Database ready${NC}"

# Create admin user
echo ""
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${YELLOW}📝 Admin User Creation${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

python manage.py shell << PYEOF
from django.contrib.auth.models import User
if not User.objects.filter(username='demo_admin').exists():
    User.objects.create_superuser('demo_admin', 'admin@kraken.energy', 'KrakenDemo123!')
    print('Admin user created: demo_admin')
else:
    print('Admin user already exists')
PYEOF

echo -e "${GREEN}✅ Admin user ready${NC}"

# Import sample data
echo ""
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${YELLOW}📝 Sample Data Import${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

if [[ -f "sample_data/sample_d0010.uff" ]]; then
    python manage.py import_d0010 sample_data/sample_d0010.uff
    echo -e "${GREEN}✅ Sample data imported${NC}"
fi

# Display success
echo ""
echo -e "${GREEN}"
echo "🎉🎉🎉🎉🎉🎉🎉🎉🎉🎉🎉🎉🎉🎉🎉🎉🎉🎉🎉🎉🎉🎉🎉🎉🎉🎉🎉🎉🎉🎉🎉🎉🎉🎉🎉🎉🎉🎉🎉🎉"
echo "🎉                    DEPLOYMENT SUCCESSFUL!                           🎉"
echo "🎉🎉🎉🎉🎉🎉🎉🎉🎉🎉🎉🎉🎉🎉🎉🎉🎉🎉🎉🎉🎉🎉🎉🎉🎉🎉🎉🎉🎉🎉🎉🎉🎉🎉🎉🎉🎉🎉🎉🎉"
echo -e "${NC}"

echo -e "${CYAN}🚀 Your Kraken D0010 system is ready!${NC}"
echo ""
echo -e "${YELLOW}🌐 Access:${NC}"
echo -e "   Web Interface: ${GREEN}http://localhost:8000/${NC}"
echo -e "   Admin Panel: ${GREEN}http://localhost:8000/admin/${NC}"
echo -e "   Username: ${GREEN}demo_admin${NC}"
echo -e "   Password: ${GREEN}KrakenDemo123!${NC}"
echo ""
echo -e "${YELLOW}🚀 Start Server:${NC}"
echo -e "   ${GREEN}source venv/bin/activate${NC}"
echo -e "   ${GREEN}python manage.py runserver${NC}"
echo ""
echo -e "${PURPLE}🦑 Kraken D0010${NC}"
