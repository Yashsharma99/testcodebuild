resource "aws_kms_key" "kms" {
  
  bypass_policy_lockout_safety_check = "false"
  #customer_master_key_spec           = "null"
  deletion_window_in_days            = "20"
  description                        = "Test-KSM-Key"
  enable_key_rotation                = "false"
  is_enabled                         = "true"
  multi_region                       = "false"
  #policy                             = aws_iam_policy.cluster_encryption_policy.arn
   tags = {
    Name = "Test-KSM-Key"
  }

}



resource "aws_kms_key_policy" "key_policy"{
    key_id   = aws_kms_key.kms.id
    policy   = jsonencode({
    "Id": "key-consolepolicy-3",
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "Enable IAM User Permissions",
            "Effect": "Allow",
            "Principal": {
                "AWS": "arn:aws:iam::014230232703:root"
            },
            "Action": "kms:*",
            "Resource": "*"
        },
        {
            "Sid": "Allow access for Key Administrators",
            "Effect": "Allow",
            "Principal": {
                "AWS": "arn:aws:iam::014230232703:user/Yash_Sharma"
            },
            "Action": [
                "kms:Create*",
                "kms:Describe*",
                "kms:Enable*",
                "kms:List*",
                "kms:Put*",
                "kms:Update*",
                "kms:Revoke*",
                "kms:Disable*",
                "kms:Get*",
                "kms:Delete*",
                "kms:TagResource",
                "kms:UntagResource",
                "kms:ScheduleKeyDeletion",
                "kms:CancelKeyDeletion"
            ],
            "Resource": "*"
        }
        
    ]
  })
}
