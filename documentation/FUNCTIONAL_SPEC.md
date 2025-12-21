# Kraken D0010 - Functional Specification

Complete requirements and feature documentation.

## System Overview

Django-based system for importing and managing D0010 electricity meter reading files.

## Features

### 1. D0010 File Import

**Format:** Industry-standard UK electricity meter reading format

**Components:**
- ZHF (Header) record parsing
- 030 (Reading) record extraction
- ZPT (Trailer) validation

**Capabilities:**
- Duplicate file detection
- Automatic MPAN/Meter creation
- Batch processing
- Error handling

### 2. Data Model

**FlowFile**
- Imported file tracking
- Duplicate prevention
- Processing metadata

**MeterPoint**
- MPAN (13-digit identifier)
- Meter type classification
- Supply point tracking

**Meter**
- Physical device records
- Serial number tracking
- Installation history

**Reading**
- Consumption data
- Multi-register support
- MD (Market Domain) flag
- Timestamp tracking

### 3. Admin Interface

**Features:**
- Full CRUD operations
- Advanced filtering
- Search across relationships
- Date-based navigation
- Inline editing

**Models:**
- FlowFile list with import dates
- MeterPoint with meter inlines
- Meter with reading history
- Reading with date hierarchy

### 4. Testing Dashboard

**Purpose:** Self-service data management for demos and testing

**Features:**
- Clear all data (reset database)
- Import individual files
- Bulk import all samples
- Real-time statistics
- File status tracking

**Access:** Admin users only at /admin/testing/

### 5. Database Support

**Development:** SQLite (default)
**Production:** PostgreSQL

**Switching:**
```bash
export USE_POSTGRESQL=1
export DB_NAME=kraken_d0010
export DB_USER=postgres
export DB_PASSWORD=yourpassword
```

## Security

### Production Settings (DEBUG=False)

- HTTPS redirect enforced
- Secure cookies (SECURE_SSL_REDIRECT)
- HSTS with 1-year max-age
- XSS protection
- Clickjacking prevention

### Development Settings (DEBUG=True)

- HTTP allowed (localhost only)
- Security features disabled
- Debug toolbar available

## API Endpoints

### Admin

- `/admin/` - Django admin interface
- `/admin/testing/` - Testing dashboard

### Public

- `/` - Home page with statistics

## Command Line Interface

### Import Command

```bash
python manage.py import_d0010 <file_path> [--dry-run]
```

**Options:**
- `file_path` - Path to .uff file
- `--dry-run` - Validate without database changes

## Testing

### Unit Tests

```bash
python manage.py test
```

### Coverage

```bash
coverage run manage.py test
coverage html
```

## Requirements

**Python:** 3.13+  
**Django:** 6.0  
**Database:** SQLite/PostgreSQL  

**Dependencies:**
- psycopg2-binary (PostgreSQL)
- python-dateutil (date parsing)
- coverage (testing)

## File Format Specification

### D0010 Structure

```
ZHF<flow_id><date>...           # Header
030<mpan><serial><data>...      # Reading records
ZPT<record_count>               # Trailer
```

### Example

```
ZHF0000120231201
030S1234567890123M001234567202312011000012345001N
ZPT00002
```

---

**Complete feature documentation** ✅
