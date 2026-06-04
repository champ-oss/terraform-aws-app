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
  for_each = var.enabled && var.enable_efs ? {
    for index, sg_id in var.security_groups : index => sg_id
  } : {}

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
  for_each = var.enabled && var.enable_efs ? {
    for ap in var.efs_access_points : ap.path => ap
  } : {}

  file_system_id = aws_efs_file_system.this[0].id

  root_directory {
    path = each.value.path

    creation_info {
      owner_uid   = each.value.owner_uid
      owner_gid   = each.value.owner_gid
      permissions = each.value.permissions
    }
  }

  dynamic "posix_user" {
    for_each = (
    each.value.posix_uid != null &&
    each.value.posix_gid != null
    ) ? [1] : []

    content {
      uid = each.value.posix_uid
      gid = each.value.posix_gid
    }
  }

  tags = merge(local.tags, var.tags)
}
