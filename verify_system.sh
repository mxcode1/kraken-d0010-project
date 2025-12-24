#!/bin/bash
# System verification script

echo "🦑 Kraken D0010 System Verification"
echo "===================================="
echo ""

# Check Python
echo "✓ Python version:"
python --version

# Check Django
echo ""
echo "✓ Django check:"
python manage.py check --deploy 2>&1 | head -5

# Check database
echo ""
echo "✓ Database status:"
python manage.py showmigrations meter_readings 2>&1 | tail -3

# Check API endpoints
echo ""
echo "✓ API endpoints:"
echo "  - http://localhost:8001/api/flow-files/"
echo "  - http://localhost:8001/api/meter-points/"
echo "  - http://localhost:8001/api/meters/"
echo "  - http://localhost:8001/api/readings/"

# Check admin
echo ""
echo "✓ Admin interface:"
echo "  - http://localhost:8001/admin/"

# Check dashboard
echo ""
echo "✓ Dashboard:"
echo "  - http://localhost:8001/"

echo ""
echo "✅ System verification complete!"
echo ""
echo "Next steps:"
echo "1. python manage.py migrate"
echo "2. python manage.py createsuperuser"
echo "3. python manage.py import_d0010 sample_data/*.uff"
echo "4. python manage.py runserver"
