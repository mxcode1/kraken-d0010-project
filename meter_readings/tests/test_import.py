from decimal import Decimal

from django.core.management import call_command
from django.test import TestCase
from pathlib import Path
import tempfile

from meter_readings.models import FlowFile, Reading


class ImportCommandTest(TestCase):
    def test_import_basic_file(self):
        """Test importing a simple D0010 file."""
        content = """ZHV|0000123456|D0010002|D|UDMS|X|MRCY|20231201120000||||OPER| | |
026|1234567890123|V| | |
028|M00123456|S| | |
030|01|20231201100000|12345.000|||T|N| | |
ZPT|00002|
"""
        with tempfile.NamedTemporaryFile(mode="w", suffix=".uff", delete=False) as f:
            f.write(content)
            temp_path = f.name

        try:
            call_command("import_d0010", temp_path)
            self.assertEqual(FlowFile.objects.count(), 1)
            self.assertEqual(Reading.objects.count(), 1)
            reading = Reading.objects.first()
            self.assertEqual(reading.reading_value, Decimal("12345.000"))
        finally:
            Path(temp_path).unlink()
