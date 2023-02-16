resource "google_dns_managed_zone" "team" {
  name        = "team"
  dns_name    = "${var.team_subdomain.name}.ovotech.org.uk."
  description = "Innaculator Team root subdomain"
}
# TODO add more resources
