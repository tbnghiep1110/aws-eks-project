resource "aws_eks_cluster" "eks_cluster" { 
  name     = var.cluster_name
  role_arn = local.cluster_role
  version  = var.cluster_version
  vpc_config {
    security_group_ids      = compact(distinct(concat(var.cluster_additional_security_group_ids, [var.cluster_security_group_id])))
    subnet_ids              = coalescelist(var.control_plane_subnet_ids, var.private_subnet_ids)
    endpoint_private_access = var.cluster_endpoint_private_access
    endpoint_public_access  = var.cluster_endpoint_public_access
    public_access_cidrs     = var.cluster_endpoint_public_access_cidrs
  }
  depends_on = [
    aws_iam_role_policy_attachment.node_groups,
    aws_iam_role_policy_attachment.cni_policy,
    aws_security_group_rule.cluster,
    aws_security_group.cluster
  ]
}

resource "aws_iam_role" "eks_cluster_role" {
  count = local.create_iam_role ? 1 : 0

  name        = var.iam_role_use_name_prefix ? null : local.iam_role_name
  name_prefix = var.iam_role_use_name_prefix ? "${local.iam_role_name}" : null
  path        = var.iam_role_path
  description = var.iam_role_description

  assume_role_policy    = data.aws_iam_policy_document.assume_role_policy[0].json
  permissions_boundary  = var.iam_role_permissions_boundary
  force_detach_policies = true

  tags = merge(var.tags, var.iam_role_tags)
}

resource "aws_iam_role_policy_attachment" "node_groups" {
  for_each = { for k, v in({
    "EKSClusterPolicy"             = "${local.iam_role_policy_prefix}/AmazonEKSClusterPolicy",
    "EKSWorkerNodePolicy"          = "${local.iam_role_policy_prefix}/AmazonEKSWorkerNodePolicy",
    "EC2ContainerRegistryReadOnly" = "${local.iam_role_policy_prefix}/AmazonEC2ContainerRegistryReadOnly",
    }
  ) : k => v if local.create_iam_role }


  policy_arn = each.value
  role       = aws_iam_role.eks_cluster_role[0].name

  depends_on = [aws_iam_role.eks_cluster_role]
}

resource "aws_iam_role_policy_attachment" "cni_policy" {
  for_each = { for k, v in [var.iam_role_attach_cni_policy ? local.cni_policy : ""] : k => v if local.create_iam_role }

  policy_arn = each.value
  role       = aws_iam_role.eks_cluster_role[0].name

  depends_on = [aws_iam_role.eks_cluster_role]
}



resource "aws_eks_node_group" "node_groups" {
  count = var.create ? 1 : 0

  cluster_name    = aws_eks_cluster.eks_cluster.name
  node_group_name = var.node_group_name
  node_role_arn   = var.create_iam_role ? aws_iam_role.eks_cluster_role[0].arn : var.iam_role_arn
  subnet_ids      = var.public_subnet_ids
  ami_type        = var.ami_type[0]
  instance_types  = var.instance_type
  capacity_type   = var.capacity_type[0]
  disk_size       = var.disk_size
  tags = {
    "Name" = var.node_group_name
  }

  scaling_config {
    min_size     = var.min_size
    max_size     = var.max_size
    desired_size = var.desired_size
  }
}

resource "aws_security_group" "cluster" {
  count = local.create_cluster_sg ? 1 : 0

  name        = var.cluster_security_group_use_name_prefix ? null : local.cluster_sg_name
  name_prefix = var.cluster_security_group_use_name_prefix ? "${local.cluster_sg_name}" : null
  description = var.cluster_security_group_description
  vpc_id      = var.vpc_id

  tags = merge(
    var.tags,
    { "Name" = local.cluster_sg_name },
    var.cluster_security_group_tags
  )

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group_rule" "cluster" {
  for_each = { for k, v in merge(
    local.cluster_security_group_rules,
    var.cluster_security_group_additional_rules
  ) : k => v if local.create_cluster_sg }

  security_group_id = aws_security_group.cluster[0].id
  protocol          = each.value.protocol
  from_port         = each.value.from_port
  to_port           = each.value.to_port
  type              = each.value.type

  cidr_blocks              = lookup(each.value, "cidr_blocks", null)
  ipv6_cidr_blocks         = lookup(each.value, "ipv6_cidr_blocks", null)
  prefix_list_ids          = lookup(each.value, "prefix_list_ids", null)
  self                     = lookup(each.value, "self", null)
  source_security_group_id = try(each.value.source_node_security_group, false) ? local.node_security_group_id : lookup(each.value, "source_security_group_id", null)
}

