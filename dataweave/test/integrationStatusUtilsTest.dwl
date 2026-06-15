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
  updateKnownFields_singleField: {
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
    processedCount: null,
    failedCount: null,
    skippedCount: null,
    dataUrl: "https://example.com/(relatedRecordId)"
  },

  updateKnownFields_multipleFields: {
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
    processedCount: null,
    failedCount: null,
    skippedCount: null,
    dataUrl: "https://example.com/(relatedRecordId)"
  },

  updateKnownFields_ignoresUnknownKeys: {
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
    processedCount: null,
    failedCount: null,
    skippedCount: null,
    dataUrl: "https://example.com/(relatedRecordId)"
  },

  updateStatusMessage_string: "completed",

  updateStatusMessage_object:
    write({ code: "HTTP:TIMEOUT", detail: "timeout" }, "application/json"),

  updateStatus_generic: "SUCCESS",

  updateStatusFailed_named: "FAILED",

  updateEndTime_customFormatLength: 10,

  buildStatus_basic: {
    applicationName: "example-application-papi",
    channelId: null,
    correlationId: "corr-001",
    dataSource: null,
    dataTarget: null,
    startTime: "DateTime",
    endTime: null,
    message: "Order processed successfully.",
    platform: "mulesoft",
    processName: "process-order-flow",
    relatedRecordId: null,
    salesforceRecordId: null,
    status: "SUCCESS",
    type: "REST",
    replayId: null,
    retryCount: 0,
    retryDelay: null,
    retryDelayUnit: "ms",
    processedCount: 10,
    failedCount: 0,
    skippedCount: 1,
    dataUrl: null
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
    message: "Processed: 5, Failed: 0, Skipped: 1.",
    processedCount: 5,
    failedCount: 0,
    skippedCount: 1
  },

  buildBatchStatus_failed: {
    status: "FAILED",
    message: "Processed: 0, Failed: 4, Skipped: 0.",
    processedCount: 0,
    failedCount: 4,
    skippedCount: 0
  },

  buildBatchStatus_partial: {
    status: "PARTIAL",
    message: "Processed: 7, Failed: 2, Skipped: 1.",
    processedCount: 7,
    failedCount: 2,
    skippedCount: 1
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
  processedCount: null,
  failedCount: null,
  skippedCount: null,
  dataUrl: "https://example.com/(relatedRecordId)"
}

var actualResult = {
  updateKnownFields_singleField:
    updateKnownFields(statusObject, { status: "failed" }),

  updateKnownFields_multipleFields:
    updateKnownFields(statusObject, { retryCount: 4, message: "completed", status: "completed" }),

  updateKnownFields_ignoresUnknownKeys:
    updateKnownFields(statusObject, { ignoredField: "do not include", unknownCount: 99 }),

  updateStatusMessage_string:
    updateStatusMessage(statusObject, "completed"),

  updateStatusMessage_object:
    updateStatusMessage(statusObject, { code: "HTTP:TIMEOUT", detail: "timeout" }),

  updateEndTime_basic:
    updateEndTime(statusObject),

  updateEndTime_customFormat:
    updateEndTime(statusObject, "yyyy-MM-dd"),

  updateStatus_generic:
    updateStatus(statusObject, "SUCCESS"),

  updateStatusFailed_named:
    updateStatusFailed(statusObject),

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
      { processedCount: 5, failedCount: 1, skippedCount: 0 },
      { processedCount: 7, failedCount: 5, skippedCount: 2 }
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
    updateKnownFields_singleField_valid:
      actualResult.updateKnownFields_singleField == expectedResult.updateKnownFields_singleField,

    updateKnownFields_multipleFields_valid:
      actualResult.updateKnownFields_multipleFields == expectedResult.updateKnownFields_multipleFields,

    updateKnownFields_ignoresUnknownKeys_valid:
      actualResult.updateKnownFields_ignoresUnknownKeys == expectedResult.updateKnownFields_ignoresUnknownKeys and
      !(keysOf(actualResult.updateKnownFields_ignoresUnknownKeys) contains "ignoredField") and
      !(keysOf(actualResult.updateKnownFields_ignoresUnknownKeys) contains "unknownCount"),

    updateStatusMessage_string_valid:
      actualResult.updateStatusMessage_string.message == expectedResult.updateStatusMessage_string,

    updateStatusMessage_object_valid:
      actualResult.updateStatusMessage_object.message == expectedResult.updateStatusMessage_object,

    updateEndTime_basic_valid:
      actualResult.updateEndTime_basic.endTime is String,

    updateEndTime_customFormat_valid:
      sizeOf(actualResult.updateEndTime_customFormat.endTime) == expectedResult.updateEndTime_customFormatLength,

    updateStatus_generic_valid:
      actualResult.updateStatus_generic.status == expectedResult.updateStatus_generic,

    updateStatusFailed_named_valid:
      actualResult.updateStatusFailed_named.status == expectedResult.updateStatusFailed_named,

    buildStatus_basic_valid:
      actualResult.buildStatus_basic.correlationId == expectedResult.buildStatus_basic.correlationId and
      actualResult.buildStatus_basic.status == expectedResult.buildStatus_basic.status and
      actualResult.buildStatus_basic.processName == expectedResult.buildStatus_basic.processName and
      actualResult.buildStatus_basic.platform == expectedResult.buildStatus_basic.platform and
      (actualResult.buildStatus_basic.startTime is DateTime),

    buildBatchStatus_success_valid:
      actualResult.buildBatchStatus_success.status == expectedResult.buildBatchStatus_success.status and
      actualResult.buildBatchStatus_success.message == expectedResult.buildBatchStatus_success.message and
      actualResult.buildBatchStatus_success.processedCount == expectedResult.buildBatchStatus_success.processedCount,

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
