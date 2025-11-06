##############################################################################
# Outputs
##############################################################################

##############################################################################

# Next steps
output "next_steps_text" {
  value       = "Your Public Certificates Engine is ready."
  description = "Next steps text"
}

output "next_step_primary_label" {
  value       = "Go to Secrets Manager Public Certificates Engine"
  description = "Primary label"
}

output "next_step_primary_url" {
  value       = "https://cloud.ibm.com/services/secrets-manager/${var.existing_secrets_manager_crn}?paneId=publicCertificates#/publicCertificates"
  description = "Primary URL"
}
