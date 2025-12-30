"""API endpoint tests for meter readings."""

from datetime import datetime, timezone

from django.test import TestCase
from rest_framework import status
from rest_framework.test import APIClient

from meter_readings.models import FlowFile, Meter, MeterPoint, Reading


class APITestCase(TestCase):
    """Test REST API endpoints."""

    def setUp(self):
        """Create test data."""
        self.client = APIClient()
        self.flow_file = FlowFile.objects.create(
            filename="test.uff", file_reference="TEST001", record_count=2
        )
        self.meter_point = MeterPoint.objects.create(mpan="1234567890123")
        self.meter = Meter.objects.create(
            meter_point=self.meter_point, serial_number="TEST001", meter_type="S"
        )
        self.reading = Reading.objects.create(
            meter=self.meter,
            register_id="S",
            reading_date=datetime(2025, 1, 15, 12, 0, tzinfo=timezone.utc),
            reading_value=12345.67,
            reading_type="ACTUAL",
            flow_file=self.flow_file,
        )

    def test_list_meter_points(self):
        """Test listing meter points."""
        response = self.client.get("/api/meter-points/", follow=True)
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(len(response.data["results"]), 1)

    def test_list_readings(self):
        """Test listing readings."""
        response = self.client.get("/api/readings/", follow=True)
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(len(response.data["results"]), 1)

    def test_readings_summary(self):
        """Test readings summary endpoint."""
        response = self.client.get("/api/readings/summary/", follow=True)
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(response.data["total_readings"], 1)
