# ActivityWatch - Agent Guide

## Overview

ActivityWatch is a privacy-focused, open-source automated time tracker. It records what you do (active window, AFK status, browser activity) and stores it locally on your machine.

## Architecture

### Component Categories

**Core Libraries:**
- `aw-core/` - Data models (Event, Bucket), schemas, query engine, datastore
- `aw-client/` - Client library for server API communication

**Server Implementations (choose one):**
- `aw-server/` - Python/Flask server (**CURRENT DEFAULT**)
- `aw-server-rust/` - Rust/Rocket server (FUTURE DEFAULT)

**Process Managers:**
- `aw-qt/` - PyQt tray icon, manages all processes (current default)
- `aw-tauri/` - Tauri-based tray + WebView (future replacement for aw-qt)

**Watchers (data collectors):**
- `aw-watcher-window/` - Active window tracking (Python, cross-platform)
- `aw-watcher-afk/` - AFK detection (Python, cross-platform)
- `awatcher/` - Rust watcher for Linux with Wayland support
- `aw-watcher-input/` - Input activity tracking (NOT a keylogger)

**Utilities:**
- `aw-notify/` - Notification service (Rust implementation)

### Data Flow

```
Watcher → Heartbeat API → Server → Datastore (SQLite)
                               ↓
                          Query API → Visualization
```

### Event Structure

```python
{
    "timestamp": "2024-01-01T00:00:00Z",
    "duration": 30.0,
    "data": {
        "app": "Firefox",
        "title": "GitHub - ActivityWatch"
    }
}
```

**Bucket:** Container for events grouped by source (e.g., "aw-watcher-window.hostname")

## Development Quickstart

### Prerequisites

- Python 3.8+ (up to 3.13 for aw-qt)
- Rust toolchain (for aw-server-rust, aw-notify, awatcher)
- Node.js 22+ (for web UI)
- Poetry (Python dependency management)

### Setup

```bash
# Initialize submodules (ONE TIME)
git submodule update --init --recursive

# Create and activate venv
python3 -m venv venv
source venv/bin/activate  # Linux/macOS
# Windows: venv\Scripts\activate

# Install dependencies
pip install poetry
poetry install

# Build everything
make build
```

### Common Commands

```bash
# Build all components
make build

# Build specific component
make -C aw-core build
make -C aw-server-rust build

# Test all components
make test

# Test specific component
poetry run make -C aw-core test
cargo test -C aw-server-rust

# Lint
make lint
ruff check .  # in specific module directory

# Type check
make typecheck
mypy aw_core  # in specific module directory
```

### Running Components

```bash
# Server (testing mode - uses port 5666)
aw-server --testing

# Watchers
aw-watcher-window --testing
aw-watcher-afk --testing

# Full suite (manages all processes)
aw-qt --testing
```

## Module Layout

**Python modules use FLAT layout** (NOT src layout):

```
module-name/
├── module_name/      # Source code
├── pyproject.toml
├── Makefile
└── tests/
```

**Exception:** `aw-watcher-input` uses src layout:

```
aw-watcher-input/
├── src/
│   └── aw_watcher_input/
├── pyproject.toml
└── Makefile
```

## Code Patterns

### Writing a Watcher

1. Import aw-client
2. Create bucket with heartbeat API
3. Send periodic heartbeats
4. Handle platform-specific window detection

See `aw-watcher-window/` for examples.

### Query Pattern

```
Filter → Merge → Transform → Bucket
```

See `aw-core/aw_query/` and `aw-core/aw_transform/`.

### Event Creation

```python
from aw_core import Event
from datetime import datetime

event = Event(
    timestamp=datetime.now(),
    duration=30.0,
    data={"app": "Firefox", "title": "GitHub"}
)
```

## Testing

**Python:** pytest  
**Rust:** cargo test

Watchers typically use `--help` as smoke test. Integration tests run full server+watcher stacks.

## Important Files

- `Makefile` (root) - Orchestration of all builds
- `aw.spec` - PyInstaller configuration for bundling
- `.github/workflows/build.yml` - CI/CD pipeline
- Each module has its own `pyproject.toml` and `Makefile`

## Resources

- Forum: https://forum.activitywatch.net/
- Docs: https://docs.activitywatch.net
- Issues: https://github.com/ActivityWatch/activitywatch/issues
