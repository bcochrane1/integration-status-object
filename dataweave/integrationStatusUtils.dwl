/**
 * integrationStatusUtils.dwl
 *
 * Reusable DataWeave functions for building and inspecting integration status objects.
 * Use this module to produce consistent status payloads across async flows, batch jobs,
 * sagas, and any integration that needs to surface processing state to a caller,
 * an Object Store, or an audit log.
 *
 * Status lifecycle:
 *   PENDING → IN_PROGRESS → SUCCESS | FAILED | PARTIAL
 *
 * Usage:
 *   %dw 2.0
 *   import * from dataweave::integrationStatusUtils
 *   var t0 = startTimer()
 *   ---
 *   withDuration(buildSuccessStatus(vars.correlationId, "process-order-flow", "Order processed."), t0)
 *
 * Tags: dataweave, status, async, batch, saga, audit
 */
%dw 2.0
//import toISO8601, diffInSeconds from dataweave::dateUtils
import mergeWith from dw::core::Objects
// ─────────────────────────────────────────────
// IMPORTANT: STATUS OBJECT MAINTENANCE
// ─────────────────────────────────────────────

/**
 * IMPORTANT: Maintains the canonical integration status object shape and field order
 * while applying partial updates.
 *
 * Use this when a flow has an existing status object and receives an update payload
 * containing one or more status fields in any order. Only keys already present in the
 * current status object are applied. Unknown keys are ignored so caller payloads cannot
 * change the status contract or append unexpected fields.
 *
 * This function rebuilds the object from the current status object instead of merging,
 * which preserves the current object's key order and makes manual validation easier.
 *
 * Explicit null values in updates are treated as intentional updates. Filter nulls before
 * calling this function if null should mean "leave the current value unchanged".
 *
 * Canonical example object:
 *   https://github.com/bcochrane1/integration-status-object/blob/main/integration-status-object-example.json
 *
 * Example:
 *   updateKnownFields(statusObject, { status: "failed", retryCount: 4 })
 *   → returns statusObject with only status and retryCount replaced.
 */
fun updateKnownFields(current: Object, updates: Object): Object =
  current mapObject ((currentValue, currentKey) ->
    {
      (currentKey): if (keysOf(updates) contains currentKey)
        updates[currentKey]
      else
        currentValue
    }
  )

/**
 * Convenience overload for Mule flows where the current integration status object
 * is stored in vars.statusObject.
 *
 * Use this when vars.statusObject contains the canonical status object and the
 * argument is a partial update object. This keeps the call site short:
 *
 *   updateKnownFields({ status: "completed", endTime: now() })
 *
 * Equivalent to:
 *
 *   updateKnownFields(vars.statusObject, { status: "completed", endTime: now() })
 *
 * Do not use this overload unless vars.statusObject has already been set. If the
 * current status object is stored somewhere else, call updateKnownFields(current, updates)
 * explicitly.
 */
fun updateKnownFields(updates: Object): Object =
  updateKnownFields(vars.statusObject, updates)


// ─────────────────────────────────────────────
// STATUS CONSTANTS
// ─────────────────────────────────────────────

/**
 * Valid status values for the integration status object.
 * Use these constants instead of raw strings to avoid typos.
 *
 * STATUS_SUCCESS    — all records processed without error
 * STATUS_FAILED     — processing did not complete; no records were committed
 * STATUS_PARTIAL    — some records succeeded, others failed (batch contexts)
 * STATUS_IN_PROGRESS — processing has started but not yet completed
 * STATUS_PENDING    — queued but not yet started
 *
 * These values are defined in common.yaml (they do not vary by environment).
 * Override in an environment file only if a specific environment requires
 * non-standard contract strings (e.g. a legacy integration).
 *   integration.status.success:     SUCCESS
 *   integration.status.failed:      FAILED
 *   integration.status.partial:     PARTIAL
 *   integration.status.inProgress:  IN_PROGRESS
 *   integration.status.pending:     PENDING
 */
var STATUS_SUCCESS     = 
  p('integration.status.success')    default 
  "SUCCESS"
var STATUS_FAILED      = 
  p('integration.status.failed')     default 
  "FAILED"
var STATUS_PARTIAL     = 
  p('integration.status.partial')    default 
  "PARTIAL"
var STATUS_IN_PROGRESS = 
  p('integration.status.inProgress') default 
  "IN_PROGRESS"
var STATUS_PENDING     = 
  p('integration.status.pending')    default 
  "PENDING"

var DEFAULT_APPLICATION_NAME =
  p('integration.status.applicationName') default
  "example-application-papi"
var DEFAULT_CHANNEL_ID =
  p('integration.status.channelId') default
  null
var DEFAULT_DATA_SOURCE =
  p('integration.status.dataSource') default
  null
var DEFAULT_DATA_TARGET =
  p('integration.status.dataTarget') default
  null
var DEFAULT_PLATFORM =
  p('integration.status.platform') default
  "mulesoft"
var DEFAULT_TYPE =
  p('integration.status.type') default
  "REST"
var DEFAULT_RETRY_COUNT =
  (p('integration.status.retryCount') default 0) as Number
var DEFAULT_RETRY_DELAY_VALUE =
  p('integration.status.retryDelay') default null
var DEFAULT_RETRY_DELAY =
  if (DEFAULT_RETRY_DELAY_VALUE == null) null else DEFAULT_RETRY_DELAY_VALUE as Number
var DEFAULT_RETRY_DELAY_UNIT =
  p('integration.status.retryDelayUnit') default
  "ms"

// ─────────────────────────────────────────────
// CORE BUILDERS
// ─────────────────────────────────────────────

/**
 * Builds the base integration status object.
 * All other builders delegate to this function.
 *
 * @param correlationId   - Request correlation ID for tracing
 * @param status          - One of the STATUS_* constants
 * @param flowName        - Name of the Mule flow that produced this status
 * @param message         - Human-readable description of the current state
 * @param processedCount  - Number of records successfully processed (null if not applicable)
 * @param failedCount     - Number of records that failed (null if not applicable)
 * @param skippedCount    - Number of records skipped (null if not applicable)
 * @param error           - Error sub-object built with buildStatusError(), or null
 *
 * Output matches the canonical integration status object:
 * {
 *   "applicationName": "example-application-papi",
 *   "channelId": null,
 *   "correlationId": "abc-123",
 *   "dataSource": null,
 *   "dataTarget": null,
 *   "startTime": "2026-04-08T14:32:00Z",
 *   "endTime": null,
 *   "message": "Order processed successfully.",
 *   "platform": "mulesoft",
 *   "processName": "process-order-flow",
 *   "relatedRecordId": null,
 *   "salesforceRecordId": null,
 *   "status": "SUCCESS",
 *   "type": "REST",
 *   "replayId": null,
 *   "retryCount": 0,
 *   "retryDelay": null,
 *   "retryDelayUnit": "ms",
 *   "processedCount": null,
 *   "failedCount": null,
 *   "skippedCount": null,
 *   "dataUrl": null
 * }
 */
fun buildStatus(
  correlationId:  String,
  status:         String,
  flowName:       String,
  message:        String,
  processedCount: Number | Null,
  failedCount:    Number | Null,
  skippedCount:   Number | Null,
  error:          Object | Null
): Object = {
  applicationName:    DEFAULT_APPLICATION_NAME,
  channelId:          DEFAULT_CHANNEL_ID,
  correlationId:  correlationId,
  dataSource:         DEFAULT_DATA_SOURCE,
  dataTarget:         DEFAULT_DATA_TARGET,
  startTime:          now(),
  endTime:            null,
  message:            message,
  platform:           DEFAULT_PLATFORM,
  processName:        flowName,
  relatedRecordId:    null,
  salesforceRecordId: null,
  status:         status,
  type:              DEFAULT_TYPE,
  replayId:          null,
  retryCount:        DEFAULT_RETRY_COUNT,
  retryDelay:        DEFAULT_RETRY_DELAY,
  retryDelayUnit:    DEFAULT_RETRY_DELAY_UNIT,
  processedCount:    processedCount,
  failedCount:       failedCount,
  skippedCount:      skippedCount,
  dataUrl:           null
}

/**
 * Builds a SUCCESS status. Use when all processing completed without error.
 *
 * @param correlationId - Request correlation ID
 * @param flowName      - Mule flow name
 * @param message       - Human-readable success message
 *
 * Output: integration status object with status = "SUCCESS"
 */
fun buildSuccessStatus(correlationId: String, flowName: String, message: String): Object =
  buildStatus(correlationId, STATUS_SUCCESS, flowName, message, null, null, null, null)

/**
 * Builds a FAILED status. Use when processing did not complete and nothing was committed.
 *
 * @param correlationId - Request correlation ID
 * @param flowName      - Mule flow name
 * @param message       - Human-readable failure summary
 * @param errorCode     - Mule error type or application error code (e.g. "HTTP:TIMEOUT")
 * @param errorDetail   - Additional context about the failure (e.g. the error message string)
 *
 * Output: integration status object with status = "FAILED" and an error sub-object
 */
fun buildFailedStatus(
  correlationId: String,
  flowName:      String,
  message:       String,
  errorCode:     String,
  errorDetail:   String | Null
): Object =
  buildStatus(
    correlationId,
    STATUS_FAILED,
    flowName,
    message,
    null, null, null,
    buildStatusError(errorCode, errorDetail)
  )

/**
 * Builds an IN_PROGRESS status. Use when publishing an async acknowledgement before
 * the processing flow has completed (e.g. 202 Accepted response body, Object Store write).
 *
 * @param correlationId - Request correlation ID
 * @param flowName      - Mule flow name
 * @param message       - Human-readable progress message (e.g. "Order queued for processing.")
 *
 * Output: integration status object with status = "IN_PROGRESS"
 */
fun buildInProgressStatus(correlationId: String, flowName: String, message: String): Object =
  buildStatus(correlationId, STATUS_IN_PROGRESS, flowName, message, null, null, null, null)

/**
 * Builds a PENDING status. Use when a job has been queued but not yet picked up.
 *
 * @param correlationId - Request correlation ID
 * @param flowName      - Mule flow name
 *
 * Output: integration status object with status = "PENDING"
 */
fun buildPendingStatus(correlationId: String, flowName: String): Object =
  buildStatus(correlationId, STATUS_PENDING, flowName, "Queued and awaiting processing.", null, null, null, null)

// ─────────────────────────────────────────────
// BATCH BUILDERS
// ─────────────────────────────────────────────

/**
 * Builds a batch status with record counts. Derives the status automatically:
 *   - failedCount == 0                         → SUCCESS
 *   - processedCount == 0 and failedCount > 0  → FAILED
 *   - processedCount > 0 and failedCount > 0   → PARTIAL
 *
 * @param correlationId  - Request correlation ID
 * @param flowName       - Mule flow name
 * @param processedCount - Records that succeeded
 * @param failedCount    - Records that failed
 * @param skippedCount   - Records that were skipped (filtered, duplicates, etc.)
 *
 * Output: integration status object with derived status and record counts populated
 */
fun buildBatchStatus(
  correlationId:  String,
  flowName:       String,
  processedCount: Number,
  failedCount:    Number,
  skippedCount:   Number
): Object =
  do {
    var derivedStatus =
      if (failedCount == 0)               STATUS_SUCCESS
      else if (processedCount == 0)       STATUS_FAILED
      else                                STATUS_PARTIAL
    var summary =
      "Processed: $(processedCount), Failed: $(failedCount), Skipped: $(skippedCount)."
    ---
    buildStatus(correlationId, derivedStatus, flowName, summary, processedCount, failedCount, skippedCount, null)
  }

/**
 * Aggregates record counts from an array of batch status objects.
 * Use when a parent flow needs to roll up results from parallel child batches.
 *
 * @param statuses - Array of status objects produced by buildBatchStatus()
 *
 * Output: { processedCount: Number, failedCount: Number, skippedCount: Number }
 */
fun aggregateBatchCounts(statuses: Array<Object>): Object = {
  processedCount: (statuses map (s) -> s.processedCount default 0) reduce (a, b) -> a + b,
  failedCount:    (statuses map (s) -> s.failedCount    default 0) reduce (a, b) -> a + b,
  skippedCount:   (statuses map (s) -> s.skippedCount   default 0) reduce (a, b) -> a + b
}

// ─────────────────────────────────────────────
// TIMING
// ─────────────────────────────────────────────

/**
 * Returns the current DateTime for use as a start timer.
 * Store the result in a Set Variable at the beginning of the flow,
 * then pass it to withDuration() when the flow completes.
 *
 * Example (Set Variable — name: "flowStartTime"):
 *   #[import * from dataweave::integrationStatusUtils
 *     ---
 *     startTimer()]
 *
 * Output: DateTime — current UTC instant
 */
fun startTimer(): DateTime = now()

/**
 * Adds endTime to an existing status object.
 * Call this just before returning or publishing the final status.
 *
 * @param status    - A status object built by any builder in this module
 * @param startTime - The DateTime captured by startTimer() at flow entry
 *
 * Output: the same status object with endTime set.
 */
fun withDuration(status: Object, startTime: DateTime): Object =
  status mergeWith {
    endTime: now()
  }

// ─────────────────────────────────────────────
// ERROR SUB-OBJECT
// ─────────────────────────────────────────────

/**
 * Builds the error sub-object embedded inside a FAILED status.
 * Called internally by buildFailedStatus(); can also be used directly
 * if constructing a status with buildStatus().
 *
 * @param errorCode   - Mule error type or application code (e.g. "HTTP:TIMEOUT", "VALIDATION_FAILED")
 * @param errorDetail - Additional context such as the raw error message (nullable)
 *
 * Output:
 * {
 *   "code": "HTTP:TIMEOUT",
 *   "detail": "Read timed out after 30000ms"
 * }
 */
fun buildStatusError(errorCode: String, errorDetail: String | Null): Object = {
  code:   errorCode,
  detail: errorDetail
}

// ─────────────────────────────────────────────
// STATUS CHECKS
// ─────────────────────────────────────────────

/**
 * Returns true if the status object represents a successful outcome.
 * Input:  Object — a status object produced by this module
 * Output: Boolean
 */
fun isSuccess(status: Object): Boolean =
  status.status == STATUS_SUCCESS

/**
 * Returns true if the status object represents a complete failure.
 * Input:  Object — a status object produced by this module
 * Output: Boolean
 */
fun isFailed(status: Object): Boolean =
  status.status == STATUS_FAILED

/**
 * Returns true if the status object represents partial success (some records failed).
 * Input:  Object — a status object produced by this module
 * Output: Boolean
 */
fun isPartial(status: Object): Boolean =
  status.status == STATUS_PARTIAL

/**
 * Returns true if processing is still active (IN_PROGRESS or PENDING).
 * Input:  Object — a status object produced by this module
 * Output: Boolean
 */
fun isPending(status: Object): Boolean =
  status.status == STATUS_PENDING or status.status == STATUS_IN_PROGRESS

/**
 * Returns true if the status is terminal (SUCCESS, FAILED, or PARTIAL).
 * Use this to decide whether a polling loop should stop.
 * Input:  Object — a status object produced by this module
 * Output: Boolean
 */
fun isTerminal(status: Object): Boolean =
  status.status == STATUS_SUCCESS or
  status.status == STATUS_FAILED  or
  status.status == STATUS_PARTIAL

// ─────────────────────────────────────────────
// AUDIT
// ─────────────────────────────────────────────

/**
 * Converts a status object to a flat structured log record.
 * Designed to be passed directly to a Logger component or written to an audit store.
 * Uses the canonical integration status object field names.
 *
 * @param status - A status object produced by any builder in this module
 *
 * Output:
 * {
 *   "level": "INFO",
 *   "applicationName": "example-application-papi",
 *   "correlationId": "abc-123",
 *   "status": "SUCCESS",
 *   "processName": "process-order-flow",
 *   "message": "Order processed successfully.",
 *   "startTime": "2026-04-08T14:32:00Z",
 *   "endTime": "2026-04-08T14:32:02Z",
 *   "platform": "mulesoft",
 *   "type": "REST",
 *   "processedCount": 25,
 *   "failedCount": 2,
 *   "skippedCount": 1
 * }
 */
fun toAuditLog(status: Object): Object =
  do {
    var level = if (isFailed(status)) "ERROR"
                else if (isPartial(status)) "WARN"
                else "INFO"
    ---
    {
      level:         level,
      applicationName: status.applicationName,
      correlationId: status.correlationId,
      status:        status.status,
      processName:   status.processName,
      message:       status.message,
      startTime:     status.startTime,
      endTime:       status.endTime,
      platform:      status.platform,
      type:          status.type,
      (processedCount: status.processedCount) if status.processedCount != null,
      (failedCount:    status.failedCount)    if status.failedCount != null,
      (skippedCount:   status.skippedCount)   if status.skippedCount != null
    }
  }
