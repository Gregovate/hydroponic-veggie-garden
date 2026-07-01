# Harvest and Waste Tracking

**Revision:** 0.1  
**Last Updated:** 2026-07-01  
**Status:** Outline

---

# Purpose

This document describes how harvested produce and crop losses are recorded throughout each growing season.

The objective is to build a long-term production history that supports yield analysis, crop performance comparisons, production cost calculations, and continuous improvement of the hydroponic system.

---

# Design Goals

The harvest tracking system is intended to:

- Record every harvest event
- Record crop losses and waste
- Associate harvests with a growing season
- Associate harvests with planting locations
- Track crop varieties
- Analyze production trends over time
- Support production cost calculations
- Improve future planting decisions

---

# Harvest Workflow

(TODO)

Document the process for recording harvested produce.

Topics:

- Select season
- Select planting location
- Select crop variety
- Record harvest date
- Record harvested quantity
- Record units
- Optional notes

---

# Waste Tracking

(TODO)

Document crop losses that occur before harvest.

Examples:

- Plant disease
- Pest damage
- Heat stress
- Nutrient deficiency
- Mechanical damage
- Poor germination
- End-of-season removal

---

# Harvest Measurements

(TODO)

Describe supported measurement types.

Examples:

- Weight
- Count
- Individual items
- Bunches
- Custom units

Future support may include automatic unit conversions for reporting.

---

# Production Analysis

(TODO)

Describe planned reporting capabilities.

Examples:

- Yield by crop variety
- Yield by growing position
- Yield by season
- Harvest frequency
- Average production per plant
- Total annual production

---

# Cost Analysis

(TODO)

Long-term reporting will combine harvest records with operational costs.

Potential calculations include:

- Cost per harvest
- Cost per pound
- Cost per crop
- Nutrient cost
- Water consumption
- Seasonal operating cost

---

# Dashboard Integration

(TODO)

Planned Home Assistant workflows include:

- Record harvest
- Record waste
- Harvest history
- Seasonal production summary
- Crop performance dashboard

---

# Database Design

(TODO)

Reference related database tables.

Examples:

- hydro_harvest
- hydro_waste
- hydro_season
- hydro_season_planting
- crop_variety
- hydro_position

Implementation details are documented in:

- 01-database-design.md

---

# Future Enhancements

(TODO)

Potential future capabilities include:

- Barcode or QR code harvest entry
- Harvest photos
- Quality grading
- Market value calculations
- Production forecasting
- Yield comparisons between seasons
- Variety performance rankings

---

# Navigation

**Previous**

- [02 – Season & Layout](02-season-and-layout.md)

**Next**

- [04 – Dashboard & History Design](04-dashboard-history-design.md)

**Related Documentation**

- [00 – System Overview](00-system-overview.md)
- [01 – Database Design](01-database-design.md)

---

# Revision History

| Date | Revision | Description |
|------|----------|-------------|
| 2026-07-01 | 0.1 | Initial document outline. |