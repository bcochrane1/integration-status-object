/**
 * updateIntegrationStatusExample.dwl
 *
 * Example usage for integrationStatusUtils.dwl.
 *
 * Expected Mule variables:
 *   vars.statusObject - current canonical integration status object
 *
 * Expected payload:
 *   Partial update object containing one or more known integration status fields.
 */
%dw 2.0
output application/json
import updateKnownFields from dataweave::integrationStatusUtils

---
{
  // Preferred generic helper. Uses vars.statusObject as the current object.
  updatedStatus: updateKnownFields(payload default {}),

  // Explicit form. Use this when the current object is not stored in vars.statusObject.
  explicitUpdate: updateKnownFields(vars.statusObject, payload default {}),

  // Batch example. Only fields already present on vars.statusObject are updated.
  batchProgress: updateKnownFields(vars.statusObject, {
    status: "PARTIAL",
    processedCount: 25,
    failedCount: 2,
    skippedCount: 1,
    message: "Processed: 25, Failed: 2, Skipped: 1."
  })
}
