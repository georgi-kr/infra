variable "project" {
  type        = string
  description = "GCP Project Name"
}

variable "region" {
  type        = string
  default     = "us-west1-a"
  description = "Region for gcp resources. Possible values https://cloud.google.com/compute/docs/regions-zones"
}

variable "inna_db" {
  type = object({
    tier           = string
    slow_query_log = number
  })
  description = <<-INNA_DB
    Configuration object for a postgres database:
      tier: Database tier
      slow_query_log: Milliseconds of execution time, after which a query is considered slow and logged
INNA_DB
}

variable "berglas" {
  type = list(object({
    key    = string
    bucket = string
    env    = optional(string)
  }))
  description = <<-BERGLAS

  An array for configuration for berglas, docs: https://github.com/GoogleCloudPlatform/berglas"

    key: The full path to the berglas kms key, for example: 'projects/schemes-nonprod/locations/us-west1-a/keyRings/berglas/cryptoKeys/berglas-key'
    bucket: The name of the bucket where berglas secrets will be stored.
    env: Environment suffix, used to differentiate between them for small amount of resources

  This would be displayed when bootstrapping berglas with

    berglas bootstrap --project $PROJECT --bucket $BUCKET --bucket-location us-west1-a --kms-location us-west1-a
BERGLAS
}
