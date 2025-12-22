#!/bin/bash

# ============================================================================
# KRAKEN D0010 - DEPLOYMENT VALIDATION
# ============================================================================
# Validates complete deployment and system health
# Usage: bash validate_deployment.sh [--database sqlite|postgresql|both]
# ============================================================================

set -e

# Source common utilities
source "$(dirname "$0")/common.sh"

# Default configuration
DATABASE_TARGET="both"

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --database)
            DATABASE_TARGET="$2"
            shift 2
            ;;
        --help)
            echo "Usage: $0 [--database sqlite|postgresql|both]"
            echo ""
            echo "Options:"
            echo "  --database TARGET      Validate specific database (sqlite|postgresql|both)"
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            exit 1
            ;;
    esac
done

echo -e "${PURPLE}"
echo "🦑🦑🦑🦑🦑🦑🦑🦑🦑🦑🦑🦑🦑🦑🦑🦑🦑🦑🦑🦑🦑🦑🦑🦑🦑🦑🦑🦑🦑🦑🦑🦑🦑🦑🦑🦑🦑🦑🦑🦑"
echo "🦑                    KRAKEN D0010 DEPLOYMENT VALIDATION              🦑"
echo "🦑🦑🦑🦑🦑🦑🦑🦑🦑🦑🦑🦑🦑🦑🦑🦑🦑🦑🦑🦑🦑🦑🦑🦑🦑🦑🦑🦑🦑🦑🦑🦑🦑🦑🦑🦑🦑🦑🦑🦑"
echo -e "${NC}"

# Check if we're in the right directory
if [[ ! -f "manage.py" ]]; then
    echo -e "${RED}❌ Not in Django project directory. Please run from kraken_d0010_project/${NC}"
    exit 1
fi

# Activate virtual environment
if [[ ! -d "venv" ]]; then
    echo -e "${RED}❌ Virtual environment not found${NC}"
    exit 1
fi

source venv/bin/activate

# Validation results
VALIDATION_RESULTS=()
TOTAL_TESTS=0
PASSED_TESTS=0

# Add validation result
add_result() {
    local test_name="$1"
    local status="$2"
    local details="$3"
    
    TOTAL_TESTS=$((TOTAL_TESTS + 1))
    
    if [[ "$status" == "PASS" ]]; then
        PASSED_TESTS=$((PASSED_TESTS + 1))
        VALIDATION_RESULTS+=("✅ $test_name: $details")
    else
        VALIDATION_RESULTS+=("❌ $test_name: $details")
    fi
}

# Validate Python environment
validate_python_environment() {
    echo -e "${YELLOW}🐍 Validating Python environment...${NC}"
    
    # Check Django
    if python -c "import django; print(f'Django {django.get_version()}')" 2>/dev/null; then
        local django_version=$(python -c "import django; print(django.get_version())")
        add_result "Django Installation" "PASS" "Version $django_version"
    else
        add_result "Django Installation" "FAIL" "Import failed"
    fi
    
    # Check psycopg2
    if python -c "import psycopg2" 2>/dev/null; then
        add_result "PostgreSQL Adapter" "PASS" "psycopg2 available"
    else
        add_result "PostgreSQL Adapter" "FAIL" "psycopg2 not available"
    fi
    
    # Check dateutil
    if python -c "from dateutil import parser" 2>/dev/null; then
        add_result "Date Utilities" "PASS" "dateutil available"
    else
        add_result "Date Utilities" "FAIL" "dateutil not available"
    fi
}

# Validate database connections
validate_database_connections() {
    echo -e "${YELLOW}🗄️ Validating database connections...${NC}"
    
    if [[ "$DATABASE_TARGET" == "sqlite" || "$DATABASE_TARGET" == "both" ]]; then
        if python manage.py check --database=default &>/dev/null; then
            add_result "SQLite3 Connection" "PASS" "Database accessible"
        else
            add_result "SQLite3 Connection" "FAIL" "Connection failed"
        fi
    fi
    
    if [[ "$DATABASE_TARGET" == "postgresql" || "$DATABASE_TARGET" == "both" ]]; then
        if USE_POSTGRESQL=1 python manage.py check --database=default &>/dev/null; then
            add_result "PostgreSQL Connection" "PASS" "Database accessible"
        else
            add_result "PostgreSQL Connection" "FAIL" "Connection failed"
        fi
    fi
}

# Validate database content
validate_database_content() {
    echo -e "${YELLOW}📊 Validating database content...${NC}"
    
    if [[ "$DATABASE_TARGET" == "sqlite" || "$DATABASE_TARGET" == "both" ]]; then
        local sqlite_stats=$(python manage.py shell -c "
from meter_readings.models import *
readings = Reading.objects.count()
mpoints = MeterPoint.objects.count()
meters = Meter.objects.count()
files = FlowFile.objects.count()
print(f'{readings}|{mpoints}|{meters}|{files}')
" 2>/dev/null || echo "0|0|0|0")
        
        IFS='|' read -r readings mpoints meters files <<< "$sqlite_stats"
        if [[ "$readings" -gt 0 ]]; then
            add_result "SQLite3 Data" "PASS" "$readings readings, $mpoints MPANs, $files files"
        else
            add_result "SQLite3 Data" "FAIL" "No data found"
        fi
    fi
    
    if [[ "$DATABASE_TARGET" == "postgresql" || "$DATABASE_TARGET" == "both" ]]; then
        local pg_stats=$(USE_POSTGRESQL=1 python manage.py shell -c "
from meter_readings.models import *
readings = Reading.objects.count()
mpoints = MeterPoint.objects.count()
meters = Meter.objects.count()
files = FlowFile.objects.count()
print(f'{readings}|{mpoints}|{meters}|{files}')
" 2>/dev/null || echo "0|0|0|0")
        
        IFS='|' read -r readings mpoints meters files <<< "$pg_stats"
        if [[ "$readings" -gt 0 ]]; then
            add_result "PostgreSQL Data" "PASS" "$readings readings, $mpoints MPANs, $files files"
        else
            add_result "PostgreSQL Data" "FAIL" "No data found"
        fi
    fi
}

# Validate Django admin
validate_django_admin() {
    echo -e "${YELLOW}🛠️ Validating Django admin...${NC}"
    
    # Check if admin user exists
    local admin_exists=$(python manage.py shell -c "
from django.contrib.auth.models import User
print('yes' if User.objects.filter(is_superuser=True).exists() else 'no')
" 2>/dev/null || echo "no")
    
    if [[ "$admin_exists" == "yes" ]]; then
        add_result "Admin User" "PASS" "Superuser exists"
    else
        add_result "Admin User" "FAIL" "No superuser found"
    fi
    
    # Test Django check
    if python manage.py check &>/dev/null; then
        add_result "Django System Check" "PASS" "All checks passed"
    else
        add_result "Django System Check" "FAIL" "System check failed"
    fi
}

# Validate search functionality
validate_search_functionality() {
    echo -e "${YELLOW}🔍 Validating search functionality...${NC}"
    
    # Test MPAN search
    local test_mpan="1200023305967"
    if [[ "$DATABASE_TARGET" == "sqlite" || "$DATABASE_TARGET" == "both" ]]; then
        local mpan_results=$(python manage.py shell -c "
from meter_readings.models import Reading
results = Reading.objects.filter(meter__meter_point__mpan='$test_mpan').count()
print(results)
" 2>/dev/null || echo "0")
        
        if [[ "$mpan_results" -gt 0 ]]; then
            add_result "SQLite3 MPAN Search" "PASS" "$mpan_results results for MPAN $test_mpan"
        else
            add_result "SQLite3 MPAN Search" "FAIL" "No results for MPAN $test_mpan"
        fi
    fi
    
    if [[ "$DATABASE_TARGET" == "postgresql" || "$DATABASE_TARGET" == "both" ]]; then
        local mpan_results_pg=$(USE_POSTGRESQL=1 python manage.py shell -c "
from meter_readings.models import Reading
results = Reading.objects.filter(meter__meter_point__mpan='$test_mpan').count()
print(results)
" 2>/dev/null || echo "0")
        
        if [[ "$mpan_results_pg" -gt 0 ]]; then
            add_result "PostgreSQL MPAN Search" "PASS" "$mpan_results_pg results for MPAN $test_mpan"
        else
            add_result "PostgreSQL MPAN Search" "FAIL" "No results for MPAN $test_mpan"
        fi
    fi
}

# Validate import functionality
validate_import_functionality() {
    echo -e "${YELLOW}📥 Validating import functionality...${NC}"
    
    # Check if management command exists
    if python manage.py help import_d0010 &>/dev/null; then
        add_result "Import Command" "PASS" "import_d0010 command available"
    else
        add_result "Import Command" "FAIL" "import_d0010 command not found"
    fi
    
    # Check if sample files exist
    if [[ -d "sample_data" && $(ls sample_data/*.uff 2>/dev/null | wc -l) -gt 0 ]]; then
        local file_count=$(ls sample_data/*.uff 2>/dev/null | wc -l)
        add_result "Sample Data Files" "PASS" "$file_count D0010 files available"
    else
        add_result "Sample Data Files" "FAIL" "No sample D0010 files found"
    fi
}

# Display results
display_results() {
    echo ""
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${CYAN}📋 VALIDATION RESULTS${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    
    for result in "${VALIDATION_RESULTS[@]}"; do
        echo -e "   $result"
    done
    
    echo ""
    echo -e "${CYAN}📊 Summary: ${GREEN}$PASSED_TESTS/$TOTAL_TESTS${NC} tests passed"
    
    if [[ $PASSED_TESTS -eq $TOTAL_TESTS ]]; then
        echo -e "${GREEN}🎉 All validations passed! System is ready for use.${NC}"
        return 0
    else
        local failed_tests=$((TOTAL_TESTS - PASSED_TESTS))
        echo -e "${YELLOW}⚠️ $failed_tests validation(s) failed. System may have issues.${NC}"
        return 1
    fi
}

# Main execution
main() {
    echo -e "${CYAN}🔍 Running comprehensive deployment validation...${NC}"
    echo -e "${YELLOW}Target: $DATABASE_TARGET database(s)${NC}"
    echo ""
    
    validate_python_environment
    validate_database_connections
    validate_database_content
    validate_django_admin
    validate_search_functionality
    validate_import_functionality
    
    if display_results; then
        echo ""
        echo -e "${GREEN}✅ Deployment validation successful!${NC}"
        echo ""
        echo -e "${YELLOW}🚀 Ready to use:${NC}"
        if [[ "$DATABASE_TARGET" != "postgresql" ]]; then
            echo -e "   SQLite3: ${GREEN}python manage.py runserver${NC}"
        fi
        if [[ "$DATABASE_TARGET" == "both" || "$DATABASE_TARGET" == "postgresql" ]]; then
            echo -e "   PostgreSQL: ${GREEN}USE_POSTGRESQL=1 python manage.py runserver 8001${NC}"
        fi
        echo -e "   Admin: ${GREEN}http://localhost:8000/admin/${NC}"
        exit 0
    else
        echo ""
        echo -e "${RED}❌ Deployment validation failed. Please check the issues above.${NC}"
        exit 1
    fi
}

# Run main function
main "$@"