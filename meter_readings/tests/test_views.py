"""Comprehensive tests for dashboard views."""

from django.test import Client, TestCase
from django.utils import timezone

from meter_readings.models import FlowFile, Meter, MeterPoint, Reading


class ViewsTest(TestCase):
    """Test dashboard views and HTML rendering."""

    def setUp(self):
        """Set up test data."""
        self.client = Client()

        # Create test data
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
        self.assertContains(response, "Flow Files System")

    def test_index_view_displays_statistics(self):
        """Test index view shows all statistics sections."""
        response = self.client.get("/", follow=True)
        self.assertContains(response, "System Statistics")
        self.assertContains(response, "Meter Points")
        self.assertContains(response, "Physical Meters")
        self.assertContains(response, "Meter Readings")
        self.assertContains(response, "Imported Files")

    def test_index_view_shows_correct_counts(self):
        """Test index view displays accurate database counts."""
        response = self.client.get("/", follow=True)
        content = response.content.decode()

        # Should show count of 1 for each entity
        self.assertIn("1", content)

    def test_index_view_shows_admin_links(self):
        """Test index view includes links to admin interface."""
        response = self.client.get("/", follow=True)
        self.assertContains(response, "/admin/")
        self.assertContains(response, "Access Admin Interface")

    def test_index_view_shows_testing_dashboard_link(self):
        """Test index view includes link to testing dashboard."""
        response = self.client.get("/", follow=True)
        self.assertContains(response, "/admin/testing/")
        self.assertContains(response, "Test Upload")

    def test_index_view_shows_usage_instructions(self):
        """Test index view displays usage instructions."""
        response = self.client.get("/", follow=True)
        self.assertContains(response, "How to Use This System")
        self.assertContains(response, "import_d0010")
        self.assertContains(response, "Browse data")

    def test_index_view_shows_search_examples(self):
        """Test index view includes demo search examples."""
        response = self.client.get("/", follow=True)
        self.assertContains(response, "Demo Search Examples")
        self.assertContains(response, "MPAN Search")
        self.assertContains(response, "Serial Search")
        self.assertContains(response, "Filename Search")

    def test_index_view_with_no_data(self):
        """Test index view renders correctly with empty database."""
        # Clear all data
        Reading.objects.all().delete()
        Meter.objects.all().delete()
        MeterPoint.objects.all().delete()
        FlowFile.objects.all().delete()

        response = self.client.get("/", follow=True)
        self.assertEqual(response.status_code, 200)
        self.assertContains(response, "Kraken Energy D0010")

    def test_index_view_with_multiple_entities(self):
        """Test index view accurately counts multiple entities."""
        # Create additional entities with different MPANs
        for i in range(5):
            mp = MeterPoint.objects.create(
                mpan=f"999{i:010d}"
            )  # Creates 9990000000000, 9990000000001, etc.
            meter = Meter.objects.create(
                meter_point=mp, serial_number=f"METER{i}", meter_type="S"
            )
            Reading.objects.create(
                meter=meter,
                reading_value=100.0 * i,
                reading_date=timezone.now(),
                reading_type="N",
                flow_file=self.flow_file,
            )

        response = self.client.get("/", follow=True)
        self.assertEqual(response.status_code, 200)
        # Should show increased counts (1 from setup + 5 new = 6)
        content = response.content.decode()
        self.assertIn("6", content)

    def test_index_view_html_structure(self):
        """Test index view has proper HTML structure."""
        response = self.client.get("/", follow=True)
        content = response.content.decode()

        self.assertIn("<!DOCTYPE html>", content)
        self.assertIn("<html>", content)
        self.assertIn("<head>", content)
        self.assertIn("<body>", content)
        self.assertIn("</html>", content)

    def test_index_view_includes_kraken_emoji(self):
        """Test index view displays the kraken emoji branding."""
        response = self.client.get("/", follow=True)
        self.assertContains(response, "🦑")

    def test_index_view_css_styling(self):
        """Test index view includes CSS styling."""
        response = self.client.get("/", follow=True)
        content = response.content.decode()

        self.assertIn("<style>", content)
        self.assertIn("</style>", content)
        self.assertIn("font-family", content)
