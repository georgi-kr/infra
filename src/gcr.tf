# We need to manually create the gcloud build storage bucket in our location (EU)
# Otherwise the default US location will be used, and the build will fail due to location constraints
# https://stackoverflow.com/questions/53206667/cloud-build-fails-with-resource-location-constraint
resource "google_storage_bucket" "cloudbuild_storage" {
  name     = "${var.project}_cloudbuild"
  location = "US"
}

# We need to give access to the cloudbuild user access to create images in the "cloudbuild_storage" bucket we just created
# Usually it should have this by default, but that's only if you're in the default US location
resource "google_storage_bucket_iam_member" "gcr_images" {
  bucket = google_storage_bucket.cloudbuild_storage.name
  role   = "roles/storage.admin"
  member = "serviceAccount:${data.google_project.project.number}@cloudbuild.gserviceaccount.com"
}
