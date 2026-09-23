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
  subnet_id       = each.value
  security_groups = [aws_security_group.efs[0].id]
}

resource "aws_efs_access_point" "this" {
  for_each = var.enabled && var.enable_efs ? {
    for mount in var.efs_mounts : mount.path => mount
  } : {}

  file_system_id = aws_efs_file_system.this[0].id

  root_directory {
    path = each.value.path

    creation_info {
      owner_uid   = try(each.value.user.uid, 0)
      owner_gid   = try(each.value.user.gid, 0)
      permissions = "0755"
    }
  }

  dynamic "posix_user" {
    for_each = try(each.value.user, null) != null ? [each.value.user] : []

    content {
      uid = posix_user.value.uid
      gid = posix_user.value.gid
    }
  }

  tags = merge(local.tags, var.tags)
}
