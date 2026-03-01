## ADDED Requirements

### Requirement: Health handler returns SERVING by default
The `HealthService` handler SHALL return `SERVING_STATUS_SERVING` when no subsystem checks are configured. Future stories will add dependency checks (database, workers) that can change the status.

#### Scenario: Default health check
- **WHEN** a client calls the `Check` RPC on a freshly started server with no dependency checks configured
- **THEN** the response status is `SERVING_STATUS_SERVING`

#### Scenario: Extensible for future dependency checks
- **WHEN** future stories add database or worker health checks
- **THEN** the handler can be updated to check those dependencies and return `SERVING_STATUS_NOT_SERVING` when they fail, without changing the RPC signature
