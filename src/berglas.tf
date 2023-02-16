# This is the bucket that berglas uses to store its secrets in.
# We need to give ourselves permission to access its contents.
# We also need to give the cloud run user access to it so our instances so when they run, they can also decrypt the secrets.
resource "google_storage_bucket_iam_member" "devs_berglas" {
  count  = length(var.berglas)
  bucket = var.berglas[count.index].bucket
  role   = "roles/storage.objectAdmin"
  member = "group:" // out team group goes here
}
