/**
 * integrationStatusUtilsTest.dwl
 *
 * Test script for integrationStatusUtils.dwl module.
 * Run in the DataWeave Playground or Anypoint Studio to validate all functions.
 *
 * Output: JSON report with validation results, actuals, and expecteds.
 */
%dw 2.0
output application/json
import * from dataweave::integrationStatusUtils

  /*
 * Development reference payloads for validation/testing.
 * expectedResult uses static or type-based validation for dynamic fields.
 */

var expectedResult = {
  updateKnownStatusFields_singleField: {
    applicationName: "example-application-papi",
    channelId: "contactEventChannel",
    correlationId: "4f6cbddc-be0c-4795-8e0a-edbe542e076b",
    dataSource: "Salesforce",
    dataTarget: "Salesforce",
    startTime: "2024-04-18T20:32:54.444689Z",
    endTime: "2024-04-18T20:32:54.444689Z",
    message: "error.description",
    platform: "mulesoft",
    processName: "Contact compliance status",
    relatedRecordId: "984267",
    salesforceRecordId: "uF83g000000c5mPCAQ",
    status: "failed",
    type: "REST",
    replayId: "5256",
    retryCount: 3,
    retryDelay: 1000,
    retryDelayUnit: "ms",
    dataUrl: "https://example.com/(relatedRecordId)"
  },

  updateKnownStatusFields_multipleFields: {
    applicationName: "example-application-papi",
    channelId: "contactEventChannel",
    correlationId: "4f6cbddc-be0c-4795-8e0a-edbe542e076b",
    dataSource: "Salesforce",
    dataTarget: "Salesforce",
    startTime: "2024-04-18T20:32:54.444689Z",
    endTime: "2024-04-18T20:32:54.444689Z",
    message: "completed",
    platform: "mulesoft",
    processName: "Contact compliance status",
    relatedRecordId: "984267",
    salesforceRecordId: "uF83g000000c5mPCAQ",
    status: "completed",
    type: "REST",
    replayId: "5256",
    retryCount: 4,
    retryDelay: 1000,
    retryDelayUnit: "ms",
    dataUrl: "https://example.com/(relatedRecordId)"
  },

  updateKnownStatusFields_ignoresUnknownKeys: {
    applicationName: "example-application-papi",
    channelId: "contactEventChannel",
    correlationId: "4f6cbddc-be0c-4795-8e0a-edbe542e076b",
    dataSource: "Salesforce",
    dataTarget: "Salesforce",
    startTime: "2024-04-18T20:32:54.444689Z",
    endTime: "2024-04-18T20:32:54.444689Z",
    message: "error.description",
    platform: "mulesoft",
    processName: "Contact compliance status",
    relatedRecordId: "984267",
    salesforceRecordId: "uF83g000000c5mPCAQ",
    status: "started",
    type: "REST",
    replayId: "5256",
    retryCount: 3,
    retryDelay: 1000,
    retryDelayUnit: "ms",
    dataUrl: "https://example.com/(relatedRecordId)"
  },

  buildStatus_basic: {
    correlationId: "corr-001",
    status: "SUCCESS",
    flowName: "process-order-flow",
    message: "Order processed successfully.",
    startedAt: "DateTime",
    completedAt: null,
    durationMs: null,
    processedCount: 10,
    failedCount: 0,
    skippedCount: 1,
    error: null
  },

  buildSuccessStatus_basic: {
    status: "SUCCESS"
  },

  buildFailedStatus_basic: {
    status: "FAILED",
    error: {
      code: "HTTP:TIMEOUT"
    }
  },

  buildBatchStatus_success: {
    status: "SUCCESS",
    processedCount: 5,
    failedCount: 0
  },

  buildBatchStatus_failed: {
    status: "FAILED",
    processedCount: 0,
    failedCount: 4
  },

  buildBatchStatus_partial: {
    status: "PARTIAL",
    processedCount: 7,
    failedCount: 2
  },

  aggregateBatchCounts_basic: {
    processedCount: 12,
    failedCount: 6,
    skippedCount: 2
  },

  isSuccess_true: true,
  isSuccess_false: false,
  isFailed_true: true,
  isFailed_false: false,
  isPartial_true: true,
  isPartial_false: false,
  isPending_true: true,
  isPending_false: false,
  isTerminal_true: true,
  isTerminal_false: false
}

// Canonical source:
// https://github.com/bcochrane1/integration-status-object/blob/main/integration-status-object-example.json
var statusObject = {
  applicationName: "example-application-papi",
  channelId: "contactEventChannel",
  correlationId: "4f6cbddc-be0c-4795-8e0a-edbe542e076b",
  dataSource: "Salesforce",
  dataTarget: "Salesforce",
  startTime: "2024-04-18T20:32:54.444689Z",
  endTime: "2024-04-18T20:32:54.444689Z",
  message: "error.description",
  platform: "mulesoft",
  processName: "Contact compliance status",
  relatedRecordId: "984267",
  salesforceRecordId: "uF83g000000c5mPCAQ",
  status: "started",
  type: "REST",
  replayId: "5256",
  retryCount: 3,
  retryDelay: 1000,
  retryDelayUnit: "ms",
  dataUrl: "https://example.com/(relatedRecordId)"
}

var actualResult = {
  updateKnownStatusFields_singleField:
    updateKnownStatusFields(statusObject, { status: "failed" }),

  updateKnownStatusFields_multipleFields:
    updateKnownStatusFields(statusObject, { retryCount: 4, message: "completed", status: "completed" }),

  updateKnownStatusFields_ignoresUnknownKeys:
    updateKnownStatusFields(statusObject, { ignoredField: "do not include", unknownCount: 99 }),

  buildStatus_basic:
    buildStatus("corr-001","SUCCESS","process-order-flow","Order processed successfully.",10,0,1,null),

  buildSuccessStatus_basic:
    buildSuccessStatus("corr-002","flow","ok"),

  buildFailedStatus_basic:
    buildFailedStatus("corr-003","flow","fail","HTTP:TIMEOUT","timeout"),

  buildBatchStatus_success:
    buildBatchStatus("corr-006","batch-flow",5,0,1),

  buildBatchStatus_failed:
    buildBatchStatus("corr-007","batch-flow",0,4,0),

  buildBatchStatus_partial:
    buildBatchStatus("corr-008","batch-flow",7,2,1),

  aggregateBatchCounts_basic:
    aggregateBatchCounts([
      buildBatchStatus("a","f",5,1,0),
      buildBatchStatus("b","f",7,5,2)
    ]),

  isSuccess_true:
    isSuccess(buildSuccessStatus("1","f","ok")),
  isSuccess_false:
    isSuccess(buildFailedStatus("2","f","bad","ERR","x")),

  isFailed_true:
    isFailed(buildFailedStatus("3","f","bad","ERR","x")),
  isFailed_false:
    isFailed(buildSuccessStatus("4","f","ok")),

  isPartial_true:
    isPartial(buildBatchStatus("5","f",3,1,0)),
  isPartial_false:
    isPartial(buildBatchStatus("6","f",3,0,0)),

  isPending_true:
    isPending(buildPendingStatus("7","f")),
  isPending_false:
    isPending(buildSuccessStatus("8","f","done")),

  isTerminal_true:
    isTerminal(buildSuccessStatus("9","f","done")),
  isTerminal_false:
    isTerminal(buildInProgressStatus("10","f","working"))
}

/*
 * Validation (structural comparison for dynamic fields)
 */
fun validate() =
  {
    updateKnownStatusFields_singleField_valid:
      actualResult.updateKnownStatusFields_singleField == expectedResult.updateKnownStatusFields_singleField,

    updateKnownStatusFields_multipleFields_valid:
      actualResult.updateKnownStatusFields_multipleFields == expectedResult.updateKnownStatusFields_multipleFields,

    updateKnownStatusFields_ignoresUnknownKeys_valid:
      actualResult.updateKnownStatusFields_ignoresUnknownKeys == expectedResult.updateKnownStatusFields_ignoresUnknownKeys and
      !(keysOf(actualResult.updateKnownStatusFields_ignoresUnknownKeys) contains "ignoredField") and
      !(keysOf(actualResult.updateKnownStatusFields_ignoresUnknownKeys) contains "unknownCount"),

    buildStatus_basic_valid:
      actualResult.buildStatus_basic.correlationId == expectedResult.buildStatus_basic.correlationId and
      actualResult.buildStatus_basic.status == expectedResult.buildStatus_basic.status and
      (actualResult.buildStatus_basic.startedAt is DateTime),

    buildBatchStatus_success_valid:
      actualResult.buildBatchStatus_success.status == expectedResult.buildBatchStatus_success.status and
      actualResult.buildBatchStatus_success.processedCount == 5,

    aggregate_valid:
      actualResult.aggregateBatchCounts_basic.processedCount == 12,

    boolean_checks_valid:
      actualResult.isSuccess_true and
      !actualResult.isSuccess_false and
      actualResult.isFailed_true and
      !actualResult.isFailed_false
  }

---
{
  validation: validate(),
  actualResult: actualResult,
  expectedResult: expectedResult
}
