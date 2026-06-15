/**
 * initializeIntegrationStatusExample.dwl
 *
 * Initializes the canonical integration status object at the start of a Mule flow.
 *
 * Mule predefined variables used:
 *   app.name      - Mule application name
 *   correlationId - Mule event correlation ID
 *
 * Expected optional variables:
 *   vars.integrationStatusSourceKey - selects source from integration.status.sources.*
 *   vars.integrationStatusTargetKey - selects target from integration.status.targets.*
 *   vars.integrationStatusChannelId - channel identifier when applicable
 *   vars.integrationStatusType      - integration type override, defaults to property/default REST
 *   vars.processName                - business process name, defaults to app.name
 */
%dw 2.0
output application/json

var dateTimeFormat =
  p("integration.status.dateTimeFormat") default "yyyy-MM-dd'T'HH:mm:ssXXX"
var sourceKey =
  vars.integrationStatusSourceKey default "default"
var targetKey =
  vars.integrationStatusTargetKey default "default"

---
{
  applicationName: app.name,
  channelId: vars.integrationStatusChannelId default "",
  correlationId: correlationId,
  dataSource: p("integration.status.sources." ++ sourceKey) default "",
  dataTarget: p("integration.status.targets." ++ targetKey) default "",
  startTime: now() as String {format: dateTimeFormat},
  endTime: null,
  message: "",
  platform: p("integration.status.platform") default "mulesoft",
  processName: vars.processName default app.name,
  relatedRecordId: null,
  salesforceRecordId: null,
  status: p("integration.status.inProgress") default "IN_PROGRESS",
  type: vars.integrationStatusType default (p("integration.status.type") default "REST"),
  replayId: null,
  retryCount: 0,
  retryDelay: 0,
  retryDelayUnit: p("integration.status.retryDelayUnit") default "ms",
  processedCount: 0,
  failedCount: 0,
  skippedCount: 0,
  dataUrl: null
}
