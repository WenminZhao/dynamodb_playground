variable environment {
    description = "The environment in which the resources will be created"
    type        = string
}

variable name {
    description = "The name of the DynamoDB table"
    type        = string
}

variable pk {
    description = "The primary key of the table"
    type        = string
}

variable sk {
    description = "The sort key of the table"
    type        = string 
}

variable billing_mode {
    description = "The billing_mode mode of the table"
    type        = string
    default     = "PAY_PER_REQUEST"
}

variable read_capacity {
    description = "The number of read units for this table"
    type        = number
}

variable write_capacity {
    description = "The number of write units for this table"
    type        = number

}

variable table_class {
    description = "The class of the table"
    type        = string
    default     = "STANDARD_INFREQUENT_ACCESS"
}

variable ttl_enabled {
    description = "Whether to enable ttl"
    type        = bool
    default     = true
}

variable ttl_attribute_name {
    description = "The name of the ttl attribute"
    type        = string
    default     = "ttl"
}

variable dynamodb_rw_access_role_name {
    description = "The name of the IAM role to have full access to the DynamoDB table"
    type        = string
}