output "dax_cluster_name_endpoint" {
  description = "value of the DAX cluster name endpoint"
    value       = aws_dax_cluster.this.configuration_endpoint
}