# Nutrient Inventory Management

**Revision:** 0.1  
**Last Updated:** 2026-07-01  
**Status:** Outline

---

# Purpose

This document describes how dry nutrients, prepared stock solutions, and nutrient batches are managed throughout the hydroponic system.

The objective is to maintain sufficient inventory for uninterrupted operation while providing long-term records of nutrient purchases, batch preparation, consumption, and operating costs.

---

# Design Goals

The nutrient inventory system is intended to:

- Track dry nutrient inventory
- Track prepared stock solution inventory
- Record nutrient purchases
- Record batch preparation
- Monitor nutrient consumption
- Estimate remaining operating time
- Predict future inventory requirements
- Support production cost analysis

---

# Inventory Philosophy

(TODO)

Describe the inventory management strategy.

Topics:

- Separate dry inventory from stock solution inventory
- Batch traceability
- Long-term consumption tracking
- Forecast future inventory needs

---

# Dry Nutrient Inventory

(TODO)

Track raw chemical inventory.

Examples:

- MasterBlend
- Calcium Nitrate
- Epsom Salt

Topics:

- Current quantity
- Purchase history
- Cost
- Supplier
- Storage location

---

# Nutrient Purchases

(TODO)

Document nutrient purchases.

Topics:

- Purchase date
- Vendor
- Quantity
- Cost
- Lot information (optional)

---

# Nutrient Batch Management

(TODO)

Describe preparation of stock solution batches.

Topics:

- Build batch
- Batch identifier
- Batch date
- Ingredients consumed
- Remaining dry inventory
- Batch assignment

Reference the SOP for preparation procedures.

---

# Stock Solution Inventory

(TODO)

Track prepared Part A and Part B stock solutions.

Each container maintains:

- Current batch
- Container capacity
- Empty container weight
- Full container weight
- Current measured weight
- Estimated remaining volume
- Percent remaining

---

# Manual Inventory Updates

(TODO)

Initially, stock solution inventory is updated manually.

Operator records:

- Current Part A weight
- Current Part B weight

System calculates:

- Remaining volume
- Remaining percentage
- Estimated doses remaining
- Estimated operating days

---

# Automatic Inventory Updates

(TODO)

Describe planned automation.

Examples:

- Update inventory after automatic dosing
- Update inventory after manual dosing
- Update inventory after batch replacement

---

# Future Load Cell Monitoring

(TODO)

Future versions may install load cells beneath the Part A and Part B containers.

Potential benefits:

- Continuous inventory monitoring
- Automatic leak detection
- Accurate consumption tracking
- Eliminate manual weight entry

---

# Inventory Forecasting

(TODO)

Estimate future inventory requirements.

Examples:

- Days remaining
- Doses remaining
- Next batch required
- Purchase recommendations

---

# Dashboard Integration

(TODO)

Planned dashboard features include:

- Dry inventory status
- Current Part A inventory
- Current Part B inventory
- Active nutrient batch
- Estimated operating days
- Low inventory warnings

---

# Database Design

(TODO)

Reference related database objects.

Examples:

- ingredients
- inventory_ledger
- nutrient_batches
- nutrient_batch_ingredients
- dry_chem_purchases_legacy

Implementation details are documented in:

- 01-database-design.md

---

# Future Enhancements

(TODO)

Potential future capabilities include:

- Automatic purchase reminders
- Batch performance history
- Inventory forecasting
- Nutrient cost per harvest
- Nutrient cost per season
- Vendor comparison
- Barcode or QR code inventory management

---

# Navigation

**Previous**

- [06 – Monitoring & Notification System](06-monitoring-and-notification-system.md)

**Next**

- [99 – Disaster Recovery](99-disaster-recovery.md)

**Related Documentation**

- [00 – System Overview](00-system-overview.md)
- [01 – Database Design](01-database-design.md)
- [05 – Nutrient Management & EC Control](05-nutrient-management-and-ec-control.md)
- [Nutrient Solution Mixing SOP](sop/hydroponics-nutrient-solution-mixing.md)

---

# Revision History

| Date | Revision | Description |
|------|----------|-------------|
| 2026-07-01 | 0.1 | Initial document outline. |