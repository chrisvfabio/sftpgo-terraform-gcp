resource "google_dns_record_set" "frontend" {
  for_each = { for k, v in var.domains : k => v }

  name = "${each.value}."
  type = "A"
  ttl  = 300

  managed_zone = var.dns_managed_zone_name
  rrdatas      = [module.load-balancer.load_balancer_ip_address]
}
