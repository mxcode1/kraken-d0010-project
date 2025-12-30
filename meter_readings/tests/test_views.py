"""Comprehensive tests for dashboard views."""

from django.test import Client, TestCase
from django.utils import timezone

from meter_readings.models import FlowFile, Meter, MeterPoint, Reading


class ViewsTest(TestCase):
    """Test dashboard views and HTML rendering."""

    def setUp(self):
        """Set up test data."""
        self.client = Client()
        self.flow_file = FlowFile.objects.create(
            filename="test.uff", file_reference="TEST001", record_count=1
        )
        self.meter_point = MeterPoint.objects.create(mpan="1234567890123")
        self.meter = Meter.objects.create(
            meter_point=self.meter_point, serial_number="SN123", meter_type="S"
        )
        self.reading = Reading.objects.create(
            meter=self.meter,
            reading_value=100.5,
            reading_date=timezone.now(),
            reading_type="N",
            flow_file=self.flow_file,
        )

    def test_index_view_renders_successfully(self):
        """Test index view renders with correct HTTP 200 status."""
        response = self.client.get("/", follow=True)
        self.assertEqual(response.status_code, 200)

    def test_index_view_shows_title(self):
        """Test index view displays correct page title."""
        response = self.client.get("/", follow=True)
        self.assertContains(response, "Kraken Energy D0010")

    def test_index_view_displays_statistics(self):
        """Test index view shows all statistics sections."""
        response = self.client.get("/", follow=True)
        self.assertContains(response, "System Statistics")
        self.assertContains(response, "Meter Points")
