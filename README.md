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
    applicationName: example-application-papi
    channelId: contactEventChannel
    dataSource: Salesforce
    dataTarget: Salesforce
    platform: mulesoft
    type: REST
    retryCount: 0
    retryDelay: 1000
    retryDelayUnit: ms
```

## DataWeave Utilities

Use `dataweave/integrationStatusUtils.dwl`.

The two most important functions for maintaining the status object are:

```dataweave
updateKnownFields(current: Object, updates: Object): Object
updateKnownFields(updates: Object): Object
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

## Reusable Example

Copy or adapt:

```text
dataweave/examples/updateIntegrationStatusExample.dwl
```

The example shows the main update forms:

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
