output "management_server_url" {
  value = "https://${google_compute_instance.mx_instance.network_interface[0].network_ip}:8083"
  depends_on = [
    # The Management Server URL should be made accessible only once the auto-FTL has finished
    time_sleep.await_mx_ftl
  ]
  description = "The URL to access the WAF Management Server user interface. Use this URL to log in with the admin user and the password you provided."
}

output "management_server_ip" {
  value = google_compute_instance.mx_instance.network_interface[0].network_ip
  depends_on = [
    # The Management Server IP should be made accessible only once the auto-FTL has finished
    time_sleep.await_mx_ftl
  ]
  description = "The internal IP address of the WAF Management Server instance. Use this IP to register Gateways to your Management Server."
}

output "network_tag" {
  value = local.mx_tag
  description = "The network tag assigned to the Management Server instance. Use this tag to allow traffic from Gateways to the Management Server."
}