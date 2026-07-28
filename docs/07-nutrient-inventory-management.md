# Nutrient Inventory Management

**Revision:** 0.1  
**Last Updated:** 2026-07-01  
**Status:** Outline

---

# Purpose

This document describes how raw nutrients, prepared nutrient stock solutions, and nutrient batches are managed throughout the hydroponic system.

The objective is to maintain sufficient nutrient inventory for uninterrupted operation while providing complete traceability of nutrient purchases, batch preparation, inventory movement, consumption, and operating costs.

This document defines the nutrient inventory architecture, including the management of raw chemical inventory, prepared backup stock, production nutrient containers, and the inventory workflows that connect them.

Preparation of nutrient stock solutions is documented separately in the **Nutrient Solution Mixing SOP**. Automatic nutrient dosing and reservoir EC control are documented in **05 – Nutrient Management and EC Control**.

---

# Design Goals

The nutrient inventory system is intended to:

- Maintain sufficient nutrient inventory for uninterrupted hydroponic operation.
- Track raw chemical inventory.
- Track prepared backup nutrient inventory.
- Track production nutrient container inventory.
- Record nutrient purchases.
- Record nutrient batch preparation.
- Record nutrient transfers from backup inventory to production containers.
- Automatically account for nutrient consumption through controller dosing.
- Maintain complete traceability from raw chemical purchase through nutrient consumption.
- Support nutrient batch traceability and cost analysis.
- Predict future inventory requirements and remaining batch capacity.
- Provide proactive notifications when additional nutrient batches or chemical purchases are required.
- Support long-term engineering analysis of nutrient usage, inventory, and operating costs.

---

# Inventory Philosophy

The nutrient inventory system is based on the principle that the operator records **physical inventory events**, while the system derives the resulting inventory state.

Rather than manually updating inventory levels, the operator records only the activities that physically change the system. The inventory management system automatically calculates current inventory, historical consumption, operating costs, and future inventory requirements from those recorded events.

The inventory lifecycle consists of four primary activities:

1. Purchase raw nutrient chemicals.
2. Prepare a new nutrient stock solution batch.
3. Refill the production nutrient containers from prepared backup inventory.
4. Consume nutrients through automatic controller dosing.

Inventory is managed at three distinct levels:

- **Raw Chemical Inventory** – Dry chemicals used to prepare nutrient stock solutions.
- **Prepared Backup Inventory** – Mixed nutrient stock solutions stored for future production container refills.
- **Production Inventory** – Nutrient stock solutions connected directly to the dosing pumps and consumed during automatic nutrient dosing.

Each inventory level changes only through specific physical events:

| Inventory | Increased By | Decreased By |
|-----------|--------------|--------------|
| Raw Chemicals | Chemical Purchases | Batch Preparation |
| Prepared Backup Inventory | Batch Preparation | Production Container Refills |
| Production Inventory | Production Container Refills | Automatic Nutrient Dosing |

This architecture provides complete traceability from raw chemical purchase through final nutrient consumption while minimizing operator workload and eliminating manual inventory calculations.

Long-term inventory history supports batch traceability, cost analysis, consumption forecasting, and proactive nutrient purchasing without requiring duplicate data entry.

---

# Dry Nutrient Inventory

Dry nutrient inventory represents the raw chemical inventory used to prepare nutrient stock solution batches.

Each chemical is tracked independently from the time it is purchased until it is consumed during batch preparation. Inventory quantities are automatically updated as purchases and batch preparation events are recorded.

The system maintains inventory information for each chemical, including:

- Current quantity on hand
- Unit of measure
- Purchase history
- Supplier
- Current unit cost
- Inventory value
- Minimum desired inventory level
- Reorder quantity

The initial implementation will include the chemicals used by the MasterBlend nutrient recipe:

- MasterBlend 4-18-38
- Calcium Nitrate
- Magnesium Sulfate (Epsom Salt)

Future nutrient formulations may introduce additional chemicals without requiring changes to the inventory architecture.

---

# Nutrient Purchases

Nutrient purchases increase the available inventory of raw chemicals.

Each purchase is recorded as a single inventory transaction containing one or more purchased chemicals. This allows both individual chemical purchases and bundled nutrient kits to be handled using the same inventory workflow while maintaining accurate inventory records for each raw material.

The following information is recorded for each purchase:

- Purchase date
- Vendor
- Product description
- One or more purchased chemicals
- Quantity of each chemical
- Unit of measure
- Purchase cost of each chemical (when available)
- Total purchase cost
- Lot or batch number (optional)
- Operator notes (optional)

Current vendors include:

- Amazon
- Walmart

When a bundled nutrient kit is purchased, each included chemical is added individually to raw inventory. Whenever possible, the actual purchase cost of each chemical is recorded to provide accurate inventory valuation, nutrient batch costing, and long-term operating cost analysis.

If only the total purchase price of the kit is available, the system allocates the total cost among the included chemicals in proportion to their packaged quantities. This provides a consistent estimated unit cost until actual component pricing is available.

---

# Nutrient Batch Management

Nutrient batch preparation converts raw chemical inventory into prepared backup nutrient stock solution inventory.

Each batch is recorded as a separate production event, providing complete traceability between the purchased raw chemicals and the prepared stock solutions used by the hydroponic controller.

When a new batch is prepared, the system:

- Creates a unique batch record.
- Records the batch preparation date.
- Records the nutrient formulation used.
- Records the quantity of stock solution produced.
- Records the raw chemicals consumed.
- Automatically deducts the consumed quantities from raw chemical inventory.
- Calculates the batch production cost.
- Increases the available prepared backup inventory.
- Preserves complete batch traceability for future inventory and cost analysis.

Each prepared batch remains identifiable throughout its lifecycle until it has been completely transferred into production nutrient containers.

Detailed mixing procedures, measurements, and safety practices are documented separately in the **Nutrient Solution Mixing SOP** and are not duplicated here.

---

# Stock Solution Inventory

Prepared stock solution inventory consists of two distinct inventory levels:

- **Prepared Backup Inventory** – Freshly prepared nutrient stock solutions available for future use.
- **Production Inventory** – Nutrient stock solutions contained within the controller dosing reservoirs and available for immediate automatic dosing.

## Prepared Backup Inventory

Prepared backup inventory is created during nutrient batch preparation and remains in storage until transferred into a production container.

Each backup batch maintains:

- Batch identifier
- Batch preparation date
- Nutrient formulation
- Batch production cost
- Quantity prepared
- Quantity remaining
- Assigned production container (when transferred)

## Production Inventory

Production inventory consists of the Part A and Part B containers connected directly to the dosing pumps.

Each production container maintains:

- Current batch identifier
- Container capacity
- Empty container weight
- Full container weight
- Current measured weight
- Estimated remaining volume
- Percent remaining

When a production container is refilled, inventory is transferred from the prepared backup inventory to the production container while preserving complete batch traceability.

---

# Manual Inventory Updates

Under normal operation, inventory is updated automatically from recorded physical events and does not require manual adjustment.

Manual inventory updates are intended only for inventory verification, reconciliation, or recovery following unexpected events such as spills, measurement errors, or system maintenance.

When performed, the operator records the current weight of the production nutrient containers. The system compares the measured inventory with the calculated inventory and reports any significant discrepancy.

Routine inventory management is performed through:

- Nutrient purchases
- Nutrient batch preparation
- Production container refills
- Automatic nutrient dosing

Future versions of the system may incorporate permanently installed load cells to automate inventory verification and eliminate manual measurements.

---

# Automatic Inventory Updates

The inventory management system automatically updates inventory levels whenever a recorded physical event changes the state of the nutrient inventory.

No manual inventory calculations are required during normal operation.

Automatic inventory updates occur after:

- Recording a nutrient purchase
- Completing a nutrient batch
- Refilling a production nutrient container
- Automatic nutrient dosing
- Manual nutrient dosing

For each event, the system updates the appropriate inventory levels, preserves complete inventory traceability, and records the resulting inventory history for future analysis.

Future enhancements may include automatic verification of production inventory using permanently installed load cells to compare measured inventory against calculated inventory.

---

# Future Load Cell Monitoring

Future versions of the nutrient inventory system may incorporate load cells beneath the production nutrient containers to provide automatic inventory verification.

Potential benefits include:

- Continuous production inventory monitoring
- Automatic inventory reconciliation
- Early leak or abnormal consumption detection
- Improved nutrient consumption analysis
- Elimination of manual inventory verification

Load cells are considered an enhancement to inventory verification only. The inventory system will continue to derive inventory primarily from recorded physical events, with load cells providing independent confirmation of calculated inventory levels.

---

# Inventory Forecasting

Inventory forecasting uses current inventory levels and historical consumption data to estimate future nutrient requirements.

The objective is to provide sufficient advance notice to prepare additional nutrient batches or purchase raw chemicals before inventory becomes critically low.

Forecast information may include:

- Estimated remaining production inventory
- Estimated remaining backup inventory
- Estimated batches remaining
- Estimated days of operation remaining
- Recommended date to prepare the next nutrient batch
- Recommended raw chemical purchases
- Low inventory notifications

Forecasts are based on current inventory levels and recent nutrient consumption trends and will continue to improve as additional operating history is collected.

---

# Dashboard Integration

The nutrient inventory dashboard provides a real-time summary of inventory status and highlights any actions required to maintain uninterrupted operation.

The dashboard may include:

- Raw chemical inventory levels
- Prepared backup inventory status
- Production container inventory (Part A and Part B)
- Active nutrient batch
- Current batch cost
- Estimated remaining batches
- Estimated operating days remaining
- Recommended time to prepare the next nutrient batch
- Raw chemical purchase recommendations
- Low inventory and reorder notifications

The dashboard is intended to provide operators with sufficient information to maintain nutrient inventory without reviewing individual purchase records, batch history, or inventory transactions.

---

# Database Design

The nutrient inventory system uses database records to preserve purchase history, batch traceability, inventory movement, consumption, and cost information.

This document defines the functional ownership of the nutrient inventory data. Detailed table structures, columns, relationships, indexes, and database views are documented separately in **01 – Database Design**.

Related database objects include:

- `ingredients`  
  Defines the raw chemicals used to prepare nutrient stock solutions.

- `inventory_ledger`  
  Records inventory increases, decreases, transfers, adjustments, and the event responsible for each change.

- `nutrient_batches`  
  Records each prepared nutrient stock solution batch, including its identifier, preparation date, quantity produced, and calculated cost.

- `nutrient_batch_ingredients`  
  Records the raw chemical quantities and costs consumed by each prepared batch.

- `dry_chem_purchases_legacy`  
  Preserves historical dry chemical purchase records created before the current inventory architecture.

The database supports the complete inventory lifecycle:

    Nutrient Purchase
            ↓
    Raw Chemical Inventory
            ↓
    Nutrient Batch Preparation
            ↓
    Prepared Backup Inventory
            ↓
    Production Container Refill
            ↓
    Production Inventory
            ↓
    Nutrient Dosing

Inventory balances displayed in Home Assistant are derived from recorded inventory events rather than maintained through routine manual edits.

The database design must preserve:

- Complete transaction history
- Raw chemical purchase traceability
- Nutrient batch traceability
- Backup-to-production inventory transfers
- Automatic and manual dosing consumption
- Ingredient and batch cost calculations
- Historical records when database structures are revised

Implementation details are documented in:

- **01 – Database Design**

---

# Future Enhancements

Potential future enhancements include:

- Automated purchase reminders based on forecast inventory levels
- Vendor price comparison and historical cost trends
- Barcode or QR code support for inventory transactions
- Integration with online supplier catalogs

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
| 2026-07-27 | 0.2 | Expanded into a complete nutrient inventory management design document. Documented inventory architecture, purchasing, batch management, production inventory, forecasting, dashboard integration, and database responsibilities. |
| 2026-07-01 | 0.1 | Initial document outline. |