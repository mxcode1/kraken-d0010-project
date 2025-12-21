"""
Utility functions for meter_readings app.
"""

from pathlib import Path
from django.conf import settings


def get_sample_files():
    """Get list of all .uff files in sample_data directory."""
    sample_dir = Path(settings.BASE_DIR) / "sample_data"
    if not sample_dir.exists():
        return []

    files = list(sample_dir.glob("*.uff"))
    return sorted([f.name for f in files])


def get_sample_file_path(filename):
    """Get full path to a sample file."""
    return Path(settings.BASE_DIR) / "sample_data" / filename
