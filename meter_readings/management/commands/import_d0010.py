"""Django management command to import D0010 flow files."""

import logging
import os
from datetime import datetime
from decimal import Decimal, InvalidOperation

import pytz
from django.core.management.base import BaseCommand, CommandError
from django.db import transaction

from meter_readings.models import FlowFile, Meter, MeterPoint, Reading

logger = logging.getLogger("meter_readings")

# Timezone for reading dates (UK energy industry standard)
LONDON_TZ = pytz.timezone("Europe/London")


class Command(BaseCommand):
    help = "Import D0010 flow files containing meter readings"

    def add_arguments(self, parser):
        parser.add_argument(
            "files", nargs="+", type=str, help="Path(s) to D0010 file(s) to import"
        )
        parser.add_argument(
            "--dry-run",
            action="store_true",
            help="Parse files but do not save to database",
        )

    def handle(self, *args, **options):
        files = options["files"]
        dry_run = options["dry_run"]

        self.stdout.write(f"Starting import of {len(files)} file(s)...")
        if dry_run:
            self.stdout.write(
                self.style.WARNING("DRY RUN MODE - No data will be saved")
            )

        total_imported = 0

        for file_path in files:
            try:
                imported_count = self.import_file(file_path, dry_run)
                total_imported += imported_count
                self.stdout.write(
                    self.style.SUCCESS(
                        f"✓ {file_path}: {imported_count} readings imported"
                    )
                )
            except Exception as e:
                self.stdout.write(self.style.ERROR(f"✗ {file_path}: {str(e)}"))

        self.stdout.write(
            self.style.SUCCESS(f"Import completed. Total readings: {total_imported}")
        )

    def import_file(self, file_path, dry_run=False):
        if not os.path.exists(file_path):
            raise CommandError(f"File not found: {file_path}")

        filename = os.path.basename(file_path)

        if FlowFile.objects.filter(filename=filename).exists():
            raise CommandError(f"File {filename} has already been imported")

        file_data = self.parse_d0010_file(file_path)

        if dry_run:
            return len(file_data["readings"])

        with transaction.atomic():
            return self.save_file_data(file_data, filename)

    def parse_d0010_file(self, file_path):
        file_data = {"header": None, "readings": [], "trailer": None}
        current_mpan = None
        current_meter_serial = None
        current_meter_type = None

        with open(file_path, "r", encoding="utf-8") as file:
            for line_num, line in enumerate(file, 1):
                line = line.strip()
                if not line:
                    continue

                try:
                    parts = line.split("|")
                    record_type = parts[0]

                    if record_type == "ZHV":
                        file_data["header"] = self.parse_header(parts)
                    elif record_type == "026":
                        current_mpan = self.parse_mpan_record(parts)
                        current_meter_serial = None
                        current_meter_type = None
                    elif record_type == "028":
                        current_meter_serial, current_meter_type = (
                            self.parse_meter_record(parts)
                        )
                    elif record_type == "030":
                        if not current_mpan or not current_meter_serial:
                            raise ValueError(
                                "Reading record without preceding MPAN/meter data"
                            )

                        reading_data = self.parse_reading_record(
                            parts,
                            current_mpan,
                            current_meter_serial,
                            current_meter_type,
                        )
                        file_data["readings"].append(reading_data)
                    elif record_type == "ZPT":
                        file_data["trailer"] = self.parse_trailer(parts)

                except Exception as e:
                    raise CommandError(
                        f"Error parsing line {line_num}: {str(e)}\nLine: {line}"
                    )

        if not file_data["readings"]:
            raise CommandError("No readings found in file")

        return file_data

    def parse_header(self, parts):
        return {
            "record_type": parts[0],
            "file_reference": parts[1] if len(parts) > 1 else "",
            "flow_reference": parts[2] if len(parts) > 2 else "",
        }

    def parse_mpan_record(self, parts):
        if len(parts) < 2:
            raise ValueError("Invalid 026 MPAN record format")

        mpan = parts[1].strip()
        if not mpan.isdigit() or len(mpan) != 13:
            raise ValueError(f"Invalid MPAN format: {mpan}")

        return mpan

    def parse_meter_record(self, parts):
        if len(parts) < 3:
            raise ValueError("Invalid 028 meter record format")

        serial_number = parts[1].strip()
        meter_type = parts[2].strip() if len(parts) > 2 else "S"

        if not serial_number:
            raise ValueError("Empty meter serial number")

        return serial_number, meter_type

    def parse_reading_record(self, parts, mpan, meter_serial, meter_type):
        if len(parts) < 4:
            raise ValueError("Invalid 030 reading record format")

        register_id = parts[1].strip()
        date_str = parts[2].strip()
        value_str = parts[3].strip()

        try:
            if len(date_str) == 14:
                # Parse as naive datetime first
                naive_dt = datetime.strptime(date_str, "%Y%m%d%H%M%S")
                # Make timezone-aware in Europe/London timezone
                reading_date = LONDON_TZ.localize(naive_dt)
            else:
                raise ValueError(f"Invalid date format: {date_str}")
        except ValueError:
            raise ValueError(f"Could not parse reading date: {date_str}")

        try:
            reading_value = Decimal(value_str)
        except (InvalidOperation, ValueError):
            raise ValueError(f"Invalid reading value: {value_str}")

        return {
            "mpan": mpan,
            "meter_serial": meter_serial,
            "meter_type": meter_type,
            "register_id": register_id,
            "reading_date": reading_date,
            "reading_value": reading_value,
            "reading_type": "ACTUAL",
        }

    def parse_trailer(self, parts):
        return {
            "record_type": parts[0],
            "file_reference": parts[1] if len(parts) > 1 else None,
            "record_count": (
                int(parts[2]) if len(parts) > 2 and parts[2].isdigit() else 0
            ),
        }

    def save_file_data(self, file_data, filename):
        flow_file = FlowFile.objects.create(
            filename=filename,
            file_reference=(
                file_data["header"]["file_reference"] if file_data["header"] else ""
            ),
            record_count=0,
        )

        imported_count = 0

        for reading_data in file_data["readings"]:
            try:
                meter_point, _ = MeterPoint.objects.get_or_create(
                    mpan=reading_data["mpan"]
                )

                meter, _ = Meter.objects.get_or_create(
                    meter_point=meter_point,
                    serial_number=reading_data["meter_serial"],
                    defaults={"meter_type": reading_data["meter_type"]},
                )

                reading, created = Reading.objects.get_or_create(
                    meter=meter,
                    register_id=reading_data["register_id"],
                    reading_date=reading_data["reading_date"],
                    defaults={
                        "flow_file": flow_file,
                        "reading_value": reading_data["reading_value"],
                        "reading_type": reading_data["reading_type"],
                    },
                )

                if created:
                    imported_count += 1

            except Exception as e:
                logger.error(f"Error saving reading: {str(e)}")
                raise CommandError(f"Database error: {str(e)}")

        flow_file.record_count = imported_count
        flow_file.save()

        return imported_count


# Timezone-aware datetime handling
# All reading dates stored in Europe/London timezone
