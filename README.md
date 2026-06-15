# Integration Status Object

Salesforce metadata and DataWeave utilities for a canonical MuleSoft integration status object.

The canonical object shape is defined in:

- `integration-status-object.raml`
- `integration-status-object-example.json`
- `integration-status-object.schema.json`
- `integration-status-object.openapi.yaml`
- `salesforce/force-app/main/default/objects/Integration_Status__c/`

## Salesforce Deployment

This repo includes Salesforce DX source for the `Integration_Status__c` custom object.

Validate without deploying:

```bash
cd salesforce
sf project deploy validate --manifest manifest/package.xml --target-org <alias-or-username>
```

Deploy:

```bash
cd salesforce
sf project deploy start --manifest manifest/package.xml --target-org <alias-or-username>
```

## Required Properties

Add these to your shared `common.yaml` or `commons.yaml` file. These values are intentionally environment-neutral defaults; override in an environment file only when a specific environment needs a different contract value.

```yaml
integration:
  status:
    success: SUCCESS
    failed: FAILED
    partial: PARTIAL
    inProgress: IN_PROGRESS
    pending: PENDING
    dateTimeFormat: "yyyy-MM-dd'T'HH:mm:ssXXX"
    platform: mulesoft
    type: REST
    retryCount: 0
    retryDelay: 1000
    retryDelayUnit: ms
    sources:
      default: Salesforce
      salesforce: Salesforce
      database: Database
      platformEvent: Salesforce Platform Event
    targets:
      default: Salesforce
      salesforce: Salesforce
      database: Database
      objectStore: Object Store
```

## DataWeave Utilities

Use `dataweave/integrationStatusUtils.dwl`.

The two most important functions for maintaining the status object are:

```dataweave
initializeStatusObject(processName: String): Object
initializeStatusObject(sourceKey: String, targetKey: String, processName: String): Object
initializeStatusObject(sourceKey: String, targetKey: String, processName: String, channelId: String): Object
updateKnownFields(current: Object, updates: Object): Object
updateKnownFields(updates: Object): Object
updateStatusMessage(current: Object, message: Any): Object
updateStatusMessage(message: Any): Object
updateEndTime(current: Object): Object
updateEndTime(): Object
updateStatus(current: Object, status: String): Object
updateStatus(status: String): Object
updateStatusSuccess(current: Object): Object
updateStatusSuccess(): Object
updateStatusFailed(current: Object): Object
updateStatusFailed(): Object
updateStatusPartial(current: Object): Object
updateStatusPartial(): Object
updateStatusInProgress(current: Object): Object
updateStatusInProgress(): Object
updateStatusPending(current: Object): Object
updateStatusPending(): Object
```

### `initializeStatusObject(sourceKey, targetKey, processName)`

Use this at the start of a flow to create the canonical status object while keeping flow-specific values in the calling script.

```dataweave
%dw 2.0
output application/json
import initializeStatusObject from dataweave::integrationStatusUtils

var sourceKey =
  vars.integrationStatusSourceKey default "default"
var targetKey =
  vars.integrationStatusTargetKey default "default"
var processName =
  vars.processName default app.name

---
initializeStatusObject(sourceKey, targetKey, processName)
```

This keeps flow-specific source, target, and process name selection in the calling script while the utility function builds the object. The function uses `app.name`, `correlationId`, and the `integration.status.*` properties.

If the flow has a channel identifier, pass it as the fourth parameter:

```dataweave
initializeStatusObject(sourceKey, targetKey, processName, vars.integrationStatusChannelId default "")
```

### `initializeStatusObject(processName)`

Use this when the default source and target properties are correct.

```dataweave
%dw 2.0
output application/json
import initializeStatusObject from dataweave::integrationStatusUtils

var processName =
  vars.processName default app.name

---
initializeStatusObject(processName)
```

### `updateKnownFields(current, updates)`

Use this when you have both the current status object and a partial update object.

```dataweave
%dw 2.0
output application/json
import updateKnownFields from dataweave::integrationStatusUtils

---
updateKnownFields(vars.statusObject, payload default {})
```

This preserves the current object's field order, updates only matching keys, and ignores unknown keys.

### `updateKnownFields(updates)`

Use this inside a Mule flow when the current object is already stored in `vars.statusObject`.

```dataweave
%dw 2.0
output application/json
import updateKnownFields from dataweave::integrationStatusUtils

---
updateKnownFields(payload default {})
```

This is equivalent to:

```dataweave
updateKnownFields(vars.statusObject, payload default {})
```

### `updateStatusMessage(message)`

Use this when only the `message` field needs to change and the current object is already stored in `vars.statusObject`. String messages are applied directly. Object messages are serialized to JSON text before calling `updateKnownFields`.

```dataweave
%dw 2.0
output application/json
import updateStatusMessage from dataweave::integrationStatusUtils

---
updateStatusMessage(payload.message default "completed")
```

Explicit current-object form:

```dataweave
updateStatusMessage(vars.statusObject, { code: error.errorType as String, detail: error.description })
```

### `updateEndTime()`

Use this when the current object is already stored in `vars.statusObject` and the flow is ending. It updates only `endTime` using `now()`.

```dataweave
%dw 2.0
output application/json
import updateEndTime from dataweave::integrationStatusUtils

---
updateEndTime()
```

Explicit current-object form:

```dataweave
updateEndTime(vars.statusObject)
```

### `updateStatus<status>()`

Use the named helpers when setting a standard status value. Each helper updates only `status` and reuses `updateKnownFields`.

```dataweave
%dw 2.0
output application/json
import updateStatusSuccess from dataweave::integrationStatusUtils

---
updateStatusSuccess()
```

Available helpers:

```dataweave
updateStatusSuccess()
updateStatusFailed()
updateStatusPartial()
updateStatusInProgress()
updateStatusPending()
```

Use the generic form when the status value is already calculated:

```dataweave
updateStatus(vars.statusObject, payload.status)
```

## Reusable Example

Copy or adapt these examples:

```text
dataweave/examples/initializeIntegrationStatusExample.dwl
dataweave/examples/updateIntegrationStatusExample.dwl
```

The initialize example creates a new canonical status object using Mule predefined variables:

- `app.name` for `applicationName`
- `correlationId` for `correlationId`
- `now()` formatted with `integration.status.dateTimeFormat` for `startTime`
- `integration.status.sources.<key>` and `integration.status.targets.<key>` for per-flow source/target values

The update example shows the main update forms:

- `updateKnownFields(payload default {})`
- `updateKnownFields(vars.statusObject, payload default {})`
- batch progress updates with `processedCount`, `failedCount`, and `skippedCount`

## Builder Output

`buildStatus(...)`, `buildSuccessStatus(...)`, `buildFailedStatus(...)`, `buildInProgressStatus(...)`, `buildPendingStatus(...)`, and `buildBatchStatus(...)` now return the same canonical data model as `integration-status-object-example.json`.

`buildStatus(...)` uses the properties above for default values such as application name, platform, integration type, and retry settings.

Batch-capable builders and updates can populate:

```yaml
processedCount: 25
failedCount: 2
skippedCount: 1
```

## Field Mapping

| RAML Field | Salesforce Field |
|---|---|
| `applicationName` | `Application_Name__c` |
| `channelId` | `Channel_Id__c` |
| `correlationId` | `Correlation_Id__c` |
| `dataSource` | `Data_Source__c` |
| `dataTarget` | `Data_Target__c` |
| `startTime` | `Start_Time__c` |
| `endTime` | `End_Time__c` |
| `message` | `Message__c` |
| `platform` | `Platform__c` |
| `processName` | `Process_Name__c` |
| `relatedRecordId` | `Related_Record_Id__c` |
| `salesforceRecordId` | `Salesforce_Record_Id__c` |
| `status` | `Status__c` |
| `type` | `Type__c` |
| `replayId` | `Replay_Id__c` |
| `retryCount` | `Retry_Count__c` |
| `retryDelay` | `Retry_Delay__c` |
| `retryDelayUnit` | `Retry_Delay_Unit__c` |
| `processedCount` | `Processed_Count__c` |
| `failedCount` | `Failed_Count__c` |
| `skippedCount` | `Skipped_Count__c` |
| `dataUrl` | `Data_Url__c` |
