# Harvest and Waste Tracking

**Revision:** 0.2
**Last Updated:** 2026-07-22
**Status:** Draft

---

# Purpose

This document describes how harvested produce and crop losses are recorded throughout each growing season.

The objective is to build a long-term production history that supports yield analysis, crop performance comparisons, production cost calculations, and continuous improvement of the hydroponic system.

---

# Design Goals

Harvest and waste records reference a planting assignment rather than
independently storing season, position, crop, or variety information. This
ensures production records remain consistent while simplifying harvest entry.

The harvest tracking system is intended to:

- Record every harvest event
- Record crop losses and waste
- Associate harvests with the originating planting
- Preserve complete production history throughout the growing season
- Support multiple harvests from a single planting
- Analyze production trends over time
- Support production cost calculations

---

# Harvest Workflow

Harvest events are recorded against an existing planting assignment.

The operator does not manually select the season, crop, or variety during
harvest entry because that information is already associated with the selected
planting.

The harvest workflow consists of:

1. Select the planted growing position.
2. Confirm the displayed crop and variety.
3. Record the harvest date.
4. Record the harvested quantity.
5. Record the measurement units.
6. Optionally record harvest quality or operator notes.
7. Save the harvest record.

Each harvest is associated with the selected planting, allowing multiple
harvests to be recorded throughout the life of the crop.

The planting remains active until it is intentionally removed or replaced at
the end of its production cycle.

# Harvest Measurements

Harvest quantity may be recorded using the measurement most appropriate for the
crop.

Examples include:

- Weight
    - grams
    - ounces
    - pounds
    - kilograms

- Count
    - each
    - peppers
    - tomatoes
    - cucumbers

The selected unit is stored with each harvest record, allowing production
reports to summarize harvests using the original measurement units.

---

# Waste Tracking

Waste events record plant material or production that is removed without being
recorded as a harvest.

Waste records are associated with an existing planting assignment, preserving
the complete production history for each crop.

The waste workflow consists of:

1. Select the planted growing position.
2. Confirm the displayed crop and variety.
3. Record the waste date.
4. Select the primary waste reason.
5. Optionally record the quantity affected.
6. Optionally record operator notes.
7. Save the waste record.

Common waste reasons include:

- Plant disease
- Pest damage
- Heat stress
- Nutrient deficiency
- Mechanical damage
- Poor germination
- Storm damage
- Animal damage
- End-of-season removal
- Crop replacement

Waste records support long-term analysis of crop failures, environmental
conditions, and production losses while documenting the complete lifecycle of
each planting.

---

# Harvest Measurements

Harvest quantity is recorded together with the measurement unit appropriate for
the harvested crop.

Supported measurement types include:

### Weight

- grams (g)
- ounces (oz)
- pounds (lb)
- kilograms (kg)

### Count

- each
- fruit
- pepper
- tomato
- cucumber
- head
- pod

### Bundle

- bunch
- bundle

Additional measurement units may be added as new crops are introduced.

Harvest records preserve the original quantity and units entered by the
operator. Future reporting may optionally support unit conversion and
normalization for cross-season production analysis.

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

Cost analysis is planned for a future development phase.

Harvest records will eventually be combined with operational data to evaluate
production efficiency and growing costs.

Potential reporting includes:

- Cost per harvest
- Cost per pound
- Cost per crop
- Nutrient cost
- Water consumption
- Seasonal operating cost

Implementation of production cost reporting is intentionally deferred until
harvest and waste tracking have been validated during an entire growing season.

---

# Dashboard Integration

Home Assistant provides the operator interface for recording harvest and waste
events.

Planned dashboard functions include:

- Select an active planting
- Record a harvest
- Record a waste event
- Review planting history
- Launch related maintenance workflows

Detailed dashboard layout, popup forms, history browsing, and production
summaries are documented in:

- [04 – Dashboard & History Design](04-dashboard-history-design.md)

---

# Database Design

Harvest and waste tracking uses the following database tables:

- `hydro_harvest`
- `hydro_waste`
- `hydro_season`
- `hydro_season_planting`
- `crop_variety`
- `hydro_position`

Harvest and waste records reference the originating planting assignment,
allowing season, position, crop, and variety information to be derived through
the database relationships.

Detailed table definitions, indexes, relationships, and business rules are
documented in:

- [01 – Database Design](01-database-design.md)
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
| 2026-07-22 | 0.2 | Completed harvest workflow, waste tracking, harvest measurements, dashboard integration, and database design. Updated the design to reference planting assignments rather than independently selecting season, position, crop, and variety. Deferred cost analysis until production data is available. |
| 2026-07-01 | 0.1 | Initial document outline. |