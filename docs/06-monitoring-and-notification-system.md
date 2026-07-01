# Monitoring and Notification System

**Revision:** 0.1  
**Last Updated:** 2026-07-01  
**Status:** Outline

---

# Purpose

This document describes how the hydroponic system monitors its operating condition, detects abnormal behavior, and notifies the operator when intervention may be required.

The monitoring system is intended to detect equipment failures, sensor faults, abnormal operating conditions, and inventory shortages before they negatively impact plant health.

---

# Design Goals

The monitoring system is intended to:

- Detect equipment failures
- Detect abnormal operating conditions
- Prevent crop loss
- Notify the operator only when action is required
- Reduce nuisance alarms
- Record significant events
- Support long-term reliability analysis

---

# Monitoring Philosophy

(TODO)

Describe the overall monitoring strategy.

Topics:

- Detect abnormal conditions early
- Verify expected system behavior
- Notify only when necessary
- Avoid alarm fatigue
- Record significant events in the database

---

# System Status Monitoring

(TODO)

Monitor current operating conditions.

Examples:

- Controller mode
- Reservoir volume
- Water temperature
- Probe voltage
- Estimated EC
- Flow rates
- Pump status
- Solenoid status
- Automation status

---

# Reservoir Monitoring

(TODO)

Monitor tank operating conditions.

Topics:

- Low reservoir volume
- High reservoir volume
- Unexpected volume changes
- Fill timeout
- Fill failure
- Reservoir overfill protection

---

# Nutrient Monitoring

(TODO)

Monitor nutrient management.

Topics:

- Probe voltage outside expected range
- EC below target
- EC above target
- Automatic dosing activity
- Failed dosing cycle
- Manual override detection

---

# Flow Monitoring

(TODO)

Monitor circulation performance.

Topics:

- East channel flow
- West channel flow
- Flow imbalance
- Zero flow
- Low flow
- Sensor failure

---

# Equipment Monitoring

(TODO)

Monitor hardware operation.

Examples:

- Fill solenoid
- Nutrient Pump A
- Nutrient Pump B
- Flow sensors
- HX711
- Temperature sensor
- Conductivity probe
- ESP32 status

---

# Inventory Monitoring

(TODO)

Monitor nutrient inventory.

Examples:

- Part A stock solution low
- Part B stock solution low
- Dry nutrient inventory low
- Batch nearly empty
- Estimated days remaining

---

# Communication Monitoring

(TODO)

Monitor system communications.

Topics:

- ESPHome offline
- MQTT unavailable
- Node-RED unavailable
- Database connectivity
- Home Assistant integration

---

# Notification Strategy

(TODO)

Describe notification philosophy.

Topics:

- Dashboard alerts
- Mobile notifications
- Persistent notifications
- Warning versus critical alerts
- Notification suppression
- Automatic clearing

---

# Alarm Priorities

(TODO)

Define alarm severity.

Examples:

## Information

Operator awareness only.

## Warning

Operator attention recommended.

## Critical

Immediate action required.

---

# Event Logging

(TODO)

Describe how alarms and notifications are recorded.

Topics:

- Maintenance history
- Equipment failures
- Operator acknowledgement
- Resolution notes

---

# Dashboard Integration

(TODO)

Planned dashboard capabilities.

Examples:

- Current system status
- Active alarms
- Notification history
- Equipment health
- Inventory warnings
- Communication status

---

# Database Design

(TODO)

Reference related database objects.

Examples:

- maintenance_log
- inventory_ledger
- nutrient_batches

Implementation details are documented in:

- 01-database-design.md

---

# Future Enhancements

(TODO)

Potential future capabilities include:

- Predictive failure detection
- Leak detection
- Pump performance trends
- Sensor health scoring
- Notification escalation
- Maintenance reminders
- Automatic fault recovery

---

# Navigation

**Previous**

- [05 – Nutrient Management & EC Control](05-nutrient-management-and-ec-control.md)

**Next**

- [07 – Nutrient Inventory Management](07-nutrient-inventory-management.md)

**Related Documentation**

- [00 – System Overview](00-system-overview.md)
- [01 – Database Design](01-database-design.md)
- [04 – Dashboard & History Design](04-dashboard-history-design.md)

---

# Revision History

| Date | Revision | Description |
|------|----------|-------------|
| 2026-07-01 | 0.1 | Initial document outline. |