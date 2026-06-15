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
import initializeStatusObject from dataweave::integrationStatusUtils

/**
  * Set value for Source and Target systems
  * Recommended to use properties
*/
var sourceKey =
  vars.integrationStatusSourceKey default "default"
var targetKey =
  vars.integrationStatusTargetKey default "default"

---
initializeStatusObject(sourceKey, targetKey)
