# Monitoring and Notification System

**Revision:** 0.2  
**Last Updated:** 2026-07-20  
**Status:** Draft

---

# Purpose

This document describes how the outdoor hydroponic system monitors its operating condition, detects abnormal behavior, records significant operational events, and notifies the operator when intervention may be required.

The monitoring system is intended to detect equipment failures, sensor faults, abnormal operating conditions, communication failures, and inventory shortages before they negatively impact plant health or system reliability.

This document also defines the monitoring architecture, notification strategy, event logging philosophy, and the responsibilities of the various software components that together provide operational awareness of the hydroponic system.

---

# Design Goals

The monitoring and notification system is intended to:

- Detect equipment failures.
- Detect abnormal operating conditions.
- Detect communication failures between system components.
- Prevent crop loss through early fault detection.
- Verify that automated controller operations complete as expected.
- Notify the operator only when action is required.
- Minimize nuisance alarms and notification fatigue.
- Record significant operational events and engineering observations.
- Support long-term reliability analysis and troubleshooting.
- Provide clear operator awareness of current system status.

---

# Monitoring Philosophy

The monitoring system is intended to provide timely and meaningful operator awareness without creating unnecessary alarms.

Monitoring is based on the principle that not every unusual condition requires immediate operator intervention. Instead, the system continuously evaluates operating conditions, verifies expected controller behavior, and determines whether an event should be logged, displayed for operator awareness, or generate an active notification.

The monitoring strategy is based on the following principles:

- Detect abnormal operating conditions as early as practical.
- Verify that automatic controller operations complete as expected.
- Distinguish between informational events, warnings, and critical faults.
- Notify the operator only when corrective action may be required.
- Minimize nuisance alarms and notification fatigue through appropriate validation and debounce periods.
- Record significant operational events and engineering observations for historical analysis.
- Provide sufficient information for troubleshooting without requiring direct review of ESPHome logs, Home Assistant traces, Node-RED flows, or database queries.

By combining real-time monitoring with permanent historical records, the system supports both reliable day-to-day operation and long-term engineering evaluation of controller performance.

---

# System Architecture

The hydroponic monitoring system is implemented as a distributed architecture in which multiple software components cooperate to monitor equipment, evaluate operating conditions, record engineering data, and notify the operator.

Each component has a distinct responsibility:

### ESPHome

ESPHome interfaces directly with the physical hardware and provides real-time monitoring of sensors, pumps, valves, and controller inputs and outputs. It performs hardware-level control, safety interlocks, and reports device status to Home Assistant.

### Home Assistant

Home Assistant serves as the primary monitoring and decision engine. It combines sensor data, controller configuration, helper entities, and automation logic to evaluate operating conditions, determine the current controller state, maintain dashboard entities, and initiate controller actions when required.

### Node-RED

Node-RED orchestrates workflows that extend beyond immediate controller operation. Its responsibilities include coordinating delayed processing, collecting stabilized measurements after controller actions, generating engineering event records, maintaining historical activity, and producing completion notifications for multi-step operations.

### MariaDB

MariaDB provides permanent storage for engineering records, operational history, inventory transactions, handheld reference measurements, and other historical data used for analysis, troubleshooting, and long-term system evaluation.

Together these components provide a monitoring system that combines real-time operational awareness with permanent engineering documentation, allowing the operator to understand both the current state of the controller and its historical performance without interacting directly with the underlying implementation.

---

# System Status Monitoring

The controller continuously monitors the overall operating state of the hydroponic system to verify that normal operation is maintained and that automatic control functions are operating as expected.

System status monitoring combines measurements from ESPHome, controller logic within Home Assistant, workflow status from Node-RED, and historical operating information to present a unified view of current system operation.

Current system status monitoring includes:

- Controller operating mode.
- Current controller state.
- Reservoir volume.
- Water temperature.
- Analog conductivity sensor measurements.
- Estimated Tank EC.
- Circulation flow rates.
- Fill system status.
- Nutrient dosing activity.
- Automatic maintenance dosing status.
- Automation enable/disable status.
- Equipment availability and communication status.

The purpose of system status monitoring is to provide the operator with an accurate understanding of what the controller is doing at any moment while also supplying the information needed by the monitoring and notification system to detect abnormal operating conditions.

---

# Reservoir Monitoring

The reservoir is continuously monitored to ensure that sufficient nutrient solution is available for normal operation and that fill operations complete safely and as expected.

Reservoir monitoring combines continuous volume measurements, rainfall information, controller state, and operating history to identify abnormal conditions that could affect system performance or indicate equipment malfunction.

Reservoir monitoring includes:

- Low reservoir volume.
- High reservoir volume.
- Automatic fill threshold detection.
- Unexpected changes in reservoir volume.
- Fill progress monitoring.
- Fill timeout detection.
- Fill failure detection.
- Reservoir overfill protection.
- Rainfall event detection.
- Rainfall accumulation and estimated dilution tracking.

Rainfall monitoring provides additional engineering context for interpreting changes in reservoir volume and nutrient concentration. Rain events and estimated dilution are also recorded with handheld EC reference measurements to support long-term evaluation of the EC estimation model.

Reservoir conditions may result in informational events, operator warnings, or critical notifications depending on the severity of the condition and the current controller operating state.

Significant reservoir events are recorded in the historical database to support troubleshooting, operational review, and long-term analysis of system performance.

---

# Nutrient Monitoring

The nutrient management system is continuously monitored to verify that nutrient concentration remains within the intended operating range and that automatic maintenance dosing operates correctly.

Nutrient monitoring combines live analog sensor measurements, Estimated Tank EC, controller state, dosing activity, and historical operating data to detect conditions that may require operator attention.

Nutrient monitoring includes:

- Analog sensor measurements outside the expected operating range.
- Estimated Tank EC outside the expected operating range.
- Automatic maintenance dose requests.
- Maintenance dosing activity and completion.
- Maximum maintenance dose cycle limits.
- Failed or incomplete maintenance dosing cycles.
- Automatic maintenance dosing disabled.
- Manual nutrient dosing and ESP-Override operations.
- Nutrient inventory warnings.
- Validation of handheld EC reference measurements against installed sensors.

Nutrient-related conditions may generate informational events, operator warnings, or critical notifications depending on the operating mode and the severity of the detected condition.

All significant nutrient management events are recorded in the historical database to support troubleshooting, long-term performance evaluation, and continuous improvement of the nutrient management system.

### Engineering Investigation (TODO)

Current automatic maintenance dosing is based primarily on measured nutrient concentration. However, seasonal changes in plant growth may provide additional insight into nutrient demand.

As plants mature and transition from vegetative growth to heavy fruit production, water consumption increases, resulting in more frequent automatic refill events. Future analysis should determine whether refill frequency, refill volume, or cumulative daily water usage can serve as indicators of increased nutrient consumption.

Historical operating data should be evaluated to determine whether periods of sustained high water consumption justify increasing the maintenance dosing target or modifying automatic dosing behavior during peak fruit production.

No adaptive control strategy has been implemented at this time. The objective of this investigation is to determine whether a measurable relationship exists between water consumption and nutrient demand before incorporating these factors into the production controller.

---

# Flow Monitoring

Continuous circulation is essential for maintaining a stable nutrient solution throughout the hydroponic system. Flow monitoring verifies that nutrient solution is being delivered to both growing channels and that the circulation system is operating as expected.

Flow monitoring combines measurements from the East Channel, West Channel, and Fill flow sensors with controller state to detect abnormal operating conditions and potential equipment failures.

Flow monitoring includes:

- East channel flow.
- West channel flow.
- Total circulation flow.
- Flow imbalance between growing channels.
- Zero-flow detection.
- Low-flow detection.
- Unexpected flow interruptions.
- Flow sensor failure or abnormal readings.

Flow monitoring is also used to verify that automatic fill and nutrient dosing operations are followed by adequate circulation and mixing before subsequent controller actions are performed.

Flow-related conditions may generate informational events, operator warnings, or critical notifications depending on the operating mode and the severity of the detected condition.

Significant flow events are recorded in the historical database to support troubleshooting, reliability analysis, and long-term evaluation of circulation system performance.

### Engineering Investigation (TODO)

Current flow monitoring verifies that circulation is present and reasonably balanced between the East and West growing channels. Future analysis should evaluate long-term flow trends to identify gradual reductions caused by root growth, debris accumulation, biofilm formation, or pump wear before they become operational problems.

---

# Equipment Monitoring

The controller continuously monitors the health and availability of the hardware devices required for safe and reliable system operation.

Equipment monitoring verifies that sensors, actuators, and controller hardware remain operational and that failures are detected as early as practical.

Equipment monitoring includes:

- ESP32 controller availability.
- Fill solenoid operation.
- Nutrient Pump A operation.
- Nutrient Pump B operation.
- East, West, and Fill flow sensor health.
- Reservoir load cell (HX711) operation.
- Water temperature sensor operation.
- Analog conductivity sensor operation.
- ADS1115 analog-to-digital converter operation.
- Communication with external devices and integrations.

Equipment failures may generate informational events, operator warnings, or critical notifications depending on the importance of the affected device and the impact on automatic controller operation.

Hardware faults that could compromise automatic operation may inhibit automatic controller functions until the fault is corrected.

Significant equipment events are recorded in the historical database to support troubleshooting, reliability analysis, and long-term evaluation of system hardware.

---

# Inventory Monitoring

The nutrient inventory system is continuously monitored to ensure that sufficient nutrient solution and raw materials are available to support uninterrupted automatic controller operation.

Inventory monitoring combines cumulative dosing history, batch records, and operator-entered inventory information to estimate current inventory levels and provide advance warning before replenishment is required.

Inventory monitoring includes:

- Nutrient Part A stock solution level.
- Nutrient Part B stock solution level.
- Dry nutrient inventory.
- Active nutrient batch availability.
- Estimated remaining stock solution.
- Estimated remaining dry nutrients.
- Inventory low warnings.
- Inventory depletion predictions.

Inventory warnings are intended to provide sufficient notice for preparing additional nutrient batches before automatic maintenance dosing is affected.

Inventory-related conditions may generate informational events, operator warnings, or critical notifications depending on the estimated remaining inventory and the potential impact on automatic controller operation.

Significant inventory events are recorded in the historical database to support inventory management, nutrient consumption analysis, purchasing decisions, and long-term operational planning.

---

# Communication Monitoring

Reliable communication between system components is essential for proper controller operation.

Communication monitoring verifies that data continues to flow correctly between ESPHome, Home Assistant, Node-RED, MariaDB, and the operator dashboard. Monitoring includes both component availability and the successful exchange of operational information.

Communication monitoring includes:

- ESPHome controller availability.
- MQTT broker connectivity.
- Home Assistant integration status.
- Node-RED availability.
- MariaDB database connectivity.
- Sensor update frequency.
- Controller heartbeat monitoring.
- Loss of communication between system components.

Communication failures may reduce monitoring capability, inhibit automatic controller functions, prevent historical event logging, delay operator notifications, or reduce dashboard visibility into current controller operation.

The monitoring system distinguishes between temporary communication interruptions and sustained failures to minimize nuisance alarms while ensuring that significant communication problems are promptly reported.

Whenever practical, communication failures are recorded in the historical database to support troubleshooting, reliability analysis, and continuous improvement of the controller.

### Future Enhancement

Future controller revisions may automatically detect recovery from communication failures and restore suspended monitoring, logging, or automation functions without requiring operator intervention whenever it is safe to do so.

---

# Notification Strategy

The notification system is intended to keep the operator informed without creating unnecessary interruptions.

Not every event requires a notification. Many normal controller operations are recorded in the historical database or displayed on the dashboard without generating an alert. Notifications are reserved for situations where operator awareness or intervention may be required.

The notification strategy uses multiple methods of communication depending on the significance of the event:

- Dashboard status indicators for normal operating information.
- Dashboard alerts for conditions requiring operator awareness.
- Mobile notifications for important events and warnings.
- Persistent notifications for conditions requiring operator action.
- Historical event logging for engineering analysis and troubleshooting.

Notification priority is determined by the potential impact on system operation, plant health, and automatic controller functionality.

To minimize nuisance alarms, notifications may be delayed, suppressed, or automatically cleared when:

- The condition resolves without operator intervention.
- A temporary operating condition is expected.
- The controller is intentionally operating in a manual or maintenance mode.
- Validation periods or debounce timers are active.

Whenever practical, notifications should clearly describe:

- What occurred.
- Why the notification was generated.
- The current controller status.
- Any recommended operator action.

The objective is to ensure that notifications are timely, meaningful, and actionable while avoiding unnecessary interruptions during normal controller operation.

---

# Alarm Priorities

The monitoring system classifies events according to their potential impact on controller operation, plant health, and the urgency of operator response.

## Information

Informational events are provided for operator awareness only.

These events indicate normal controller operation or significant milestones that do not require corrective action.

Examples include:

- Automatic maintenance dose completed.
- Reservoir fill completed.
- Handheld EC reference recorded.
- Inventory updated.
- Controller mode changed.

## Warning

Warning events indicate an abnormal condition that should be investigated but does not require immediate intervention.

The controller may continue operating normally while the operator evaluates the condition.

Examples include:

- Low nutrient inventory.
- Reservoir approaching refill threshold.
- Flow imbalance.
- Sensor operating outside the expected range.
- Communication interruptions.
- Maximum maintenance dosing cycles reached.

## Critical

Critical events indicate a condition that may prevent normal controller operation or place plant health at risk.

Immediate operator attention is recommended.

Examples include:

- Controller offline.
- Complete loss of circulation.
- Fill failure or timeout.
- Reservoir overfill protection activated.
- Automatic maintenance dosing unavailable.
- Hardware failures that prevent automatic operation.

Alarm priority determines the type of notification generated, whether the notification remains active until acknowledged, and the level of operator response expected.

---

# Event Logging

The hydroponic controller maintains a permanent engineering history of significant operational events to support troubleshooting, performance analysis, and long-term system development.

The event logging system is a coordinated process involving multiple system components:

- **ESPHome** executes physical controller operations and reports hardware status.
- **Home Assistant** initiates controller actions, maintains controller state, and provides operational context.
- **Node-RED** coordinates multi-step logging workflows, collects delayed measurements when required, assembles complete engineering event records, and generates completion notifications.
- **MariaDB** provides permanent storage for engineering records and historical operating data.

Not every monitored condition is permanently recorded. Event logging is intended to capture information that helps explain controller behavior, validate engineering changes, diagnose problems, and document system operation over time.

Examples of logged events include:

- Automatic reservoir fill operations.
- Automatic and manual nutrient dosing.
- Handheld EC reference measurements.
- Equipment faults and communication failures.
- Flow-related events.
- Inventory updates and nutrient batch changes.
- Controller state transitions.
- Operator field notes and engineering observations.

Whenever practical, logged events include supporting operating data such as:

- Date and time.
- Current controller state.
- Reservoir volume.
- Analog conductivity sensor measurements.
- Estimated Tank EC.
- Water temperature.
- Rainfall and estimated dilution.
- Operator notes.

Some controller operations cannot be completely documented until the physical process has finished and the system has stabilized. In these cases, Node-RED performs delayed processing to capture final operating conditions, assemble the complete engineering record, and generate any required completion notifications before the event is permanently recorded.

The historical database provides a permanent engineering record that supports troubleshooting, controller validation, performance analysis, and continuous improvement of the hydroponic system.

### Future Enhancement

Future revisions may expand event records to include operator acknowledgement, fault resolution tracking, maintenance reminders, and additional service documentation to further support long-term system maintenance.

---

# Dashboard Integration

**TODO – Complete after Controller State Machine (ISSUE-005) implementation**

The dashboard will provide the primary operator interface for the hydroponic monitoring and notification system.

Rather than displaying individual sensors, the dashboard should present the overall operational state of the controller, allowing the operator to quickly determine:

- What is the controller doing?
- Is the system operating normally?
- Does the controller require operator attention?
- What happened most recently?

The dashboard integrates information produced throughout the monitoring architecture:

- **ESPHome** provides hardware status and real-time sensor data.
- **Home Assistant** provides controller state, operating mode, calculated entities, and automation status.
- **Node-RED** provides engineering activity, completed operations, delayed measurements, and historical event summaries.
- **MariaDB** provides permanent engineering records and historical data used for reporting and analysis.

Planned dashboard capabilities include:

- Current controller state.
- Overall system health.
- Active alarms and notifications.
- Recent controller activity.
- Equipment health.
- Reservoir status.
- Nutrient management status.
- Flow system status.
- Inventory warnings.
- Communication status.
- Historical engineering events.

The completed dashboard should present a single, consistent operational view of the distributed controller without requiring the operator to review ESPHome logs, Home Assistant traces, Node-RED workflows, or database records.

The final dashboard design will be completed after implementation of the Controller State Machine (ISSUE-005) to ensure that controller state, monitoring, notifications, and historical activity are presented through a unified operator interface.


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
| 2026-07-20 | 0.2 | Expanded the monitoring architecture, defined subsystem responsibilities (ESPHome, Home Assistant, Node-RED, and MariaDB), documented monitoring philosophy, communication monitoring, event logging, notification strategy, alarm priorities, dashboard integration, and subsystem monitoring requirements. |
| 2026-07-01 | 0.1 | Initial document outline. |