# Season and Layout

**Revision:** 0.1  
**Last Updated:** 2026-07-01  
**Status:** Outline

---

# Purpose

This document describes how the hydroponic system organizes growing seasons, planting layouts, and crop locations.

The goal is to provide complete traceability from a planting event through harvest while allowing production to be analyzed by season, crop variety, and physical growing location.

---

# Design Goals

The seasonal layout system is intended to:

- Organize production into discrete growing seasons
- Track what crop is planted in each position
- Record planting dates
- Track crop varieties
- Support crop rotation planning
- Associate harvests and waste with the original planting
- Provide long-term production history

---

# Seasonal Organization

(TODO)

Describe how seasons are created and managed.

Topics:

- Spring
- Summer
- Fall
- Winter
- Indoor vs. outdoor production
- Season status (planned, active, completed)

---

# Growing Layout

(TODO)

Describe the physical layout of the hydroponic system.

Examples:

- East channel
- West channel
- Plant positions
- Position numbering
- Reserved positions

---

# Planting Workflow

(TODO)

Document the workflow for creating a planting event.

Topics:

- Select season
- Select crop variety
- Assign growing position
- Record planting date
- Initial notes

---

# Crop Variety Management

(TODO)

Describe how crop varieties are identified.

Examples:

- Lettuce
- Tomatoes
- Peppers
- Herbs

---

# Position Tracking

(TODO)

Describe how individual growing positions are tracked throughout the season.

Topics:

- Position availability
- Replanting
- Crop replacement
- Multiple harvests

---

# Dashboard Integration

(TODO)

Describe planned Home Assistant workflows.

Examples:

- Season selection
- Planting dashboard
- Position map
- Crop lookup

---

# Database Design

(TODO)

Reference related database tables.

Examples:

- hydro_season
- hydro_position
- hydro_season_planting
- crop_variety

Implementation details are documented in:

- 01-database-design.md

---

# Future Enhancements

(TODO)

Potential future capabilities include:

- Visual planting maps
- QR code plant identification
- Growth stage tracking
- Variety performance comparisons
- Yield by position
- Crop rotation recommendations

---

# Navigation

**Previous**

- [01 – Database Design](01-database-design.md)

**Next**

- [03 – Harvest & Waste Tracking](03-harvest-and-waste-tracking.md)

**Related Documentation**

- [00 – System Overview](00-system-overview.md)
- [04 – Dashboard & History Design](04-dashboard-history-design.md)

---

# Revision History

| Date | Revision | Description |
|------|----------|-------------|
| 2026-07-01 | 0.1 | Initial document outline. |