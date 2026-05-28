resource "aws_efs_file_system" "this" {
  count     = var.enabled && var.enable_efs ? 1 : 0
  encrypted = true

  tags = merge(local.tags, var.tags, {
    Name = "${var.git}-${var.name}"
  })
}

resource "aws_security_group" "efs" {
  count       = var.enabled && var.enable_efs ? 1 : 0
  name        = "${var.git}-${var.name}-efs"
  description = "Allow ECS tasks to mount EFS"
  vpc_id      = var.vpc_id

  tags = merge(local.tags, var.tags)
}

resource "aws_security_group_rule" "efs_from_ecs" {
  for_each = var.enabled && var.enable_efs ? toset(var.security_groups) : []

  type                     = "ingress"
  security_group_id        = aws_security_group.efs[0].id
  source_security_group_id = each.value
  from_port                = 2049
  to_port                  = 2049
  protocol                 = "tcp"
}

resource "aws_efs_mount_target" "this" {
  for_each = var.enabled && var.enable_efs ? toset(var.subnets) : []

  file_system_id  = aws_efs_file_system.this[0].id
  subnet_id        = each.value
  security_groups  = [aws_security_group.efs[0].id]
}

resource "aws_efs_access_point" "this" {
  count          = var.enabled && var.enable_efs ? 1 : 0
  file_system_id = aws_efs_file_system.this[0].id

  root_directory {
    path = var.efs_root_directory

    creation_info {
      owner_uid   = 1000
      owner_gid   = 1000
      permissions = "0755"
    }
  }

  posix_user {
    uid = 1000
    gid = 1000
  }

  tags = merge(local.tags, var.tags)
}
