# dax
variable dax_cluster_name {
    description = "The name of the DAX cluster"
    type        = string
}

variable node_type {
    description = "The node type of the DAX cluster"
    type        = string
    default     = "dax.t2.small"
}

variable region {
    description = "The region of the DAX cluster"
    type        = string
    default     = "ap-south-1"
}

variable dax_vpc_id {
    description = "The id of the VPC for the DAX cluster"
    type        = string
}

variable dax_subnet_id {
    description = "The id of the subnet for the DAX cluster"
    type        = list(string)
}

variable server_side_encryption {
    description = "Whether to enable server side encryption"
    type        = bool
    default     = false
}

variable parameter_group_name {
    description = "The name of the parameter group"
    type        = string
  
}

variable dynamodb_table_name {
    description = "The name of the DynamoDB table"
    type        = string
  
}

variable "replication_factor" {
    description = "The number of nodes in the DAX cluster"
    type        = number
    default     = 1
  
}

variable dax_assumable_iam_role_arn {
    description = "The ARN of the IAM role"
    type        = string
  
}

variable aws_dax_subnet_group_name {
    description = "The name of the DAX subnet group"
    type        = string
  
}

variable "query_ttl_millis" {
    description = "The query ttl in milliseconds"
    type        = number
    default     = 300000
  
}

variable "vpc_id" {
    description = "The vpc for the DAX cluster"
    type        = string
  
}

variable "record_ttl_milli" {
  description = "value of the record ttl in milliseconds"
    type        = number
    default     = 300000
}

variable "dynamodb_rw_role_arn" {
  description = "dynamodb read write role arn for dax to access dynamodb"
    type        = string
}