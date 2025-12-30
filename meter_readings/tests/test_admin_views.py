"""
Comprehensive tests for admin custom views.
Tests admin dashboard, file import, and testing utilities.
"""

import os
import tempfile
from pathlib import Path
from unittest.mock import patch

from django.contrib.auth.models import User
from django.test import Client, TestCase

from meter_readings.models import FlowFile, Meter, MeterPoint, Reading


class AdminViewsTest(TestCase):
    """Test custom admin views and testing dashboard."""

    def setUp(self):
        """Set up test environment."""
        self.client = Client()

        # Create admin user
        self.admin_user = User.objects.create_superuser(
            username="admin", email="admin@test.com", password="testpass123"
        )

        # Create test data
        self.flow_file = FlowFile.objects.create(
            filename="test.uff", file_reference="TEST001", record_count=1
        )
        self.meter_point = MeterPoint.objects.create(mpan="1234567890123")
        self.meter = Meter.objects.create(
            meter_point=self.meter_point, serial_number="SN123", meter_type="S"
        )

    def test_testing_dashboard_requires_staff(self):
        """Test testing dashboard requires staff privileges."""
        response = self.client.get("/admin/testing/")
        self.assertEqual(response.status_code, 302)
        self.assertIn("/admin/login/", response.url)

    def test_testing_dashboard_get_request(self):
        """Test GET request to testing dashboard."""
        self.client.force_login(self.admin_user)
        response = self.client.get("/admin/testing/")
        self.assertEqual(response.status_code, 200)

    def test_clear_all_action(self):
        """Test clear_all action deletes all data."""
        self.client.force_login(self.admin_user)
        Reading.objects.create(
            meter=self.meter,
            reading_value=100.0,
            reading_date="2025-01-01 00:00:00",
            reading_type="N",
            flow_file=self.flow_file,
        )
        self.assertEqual(Reading.objects.count(), 1)
        response = self.client.post("/admin/testing/", {"action": "clear_all"})
        self.assertEqual(response.status_code, 302)
        self.assertEqual(Reading.objects.count(), 0)
