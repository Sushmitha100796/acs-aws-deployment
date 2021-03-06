### egress to allow all outgoing traffic ###
resource "aws_security_group" "rds-sg" {
  name = "${var.resource-prefix}-rds-sg"
  description = "RDS security group"
  vpc_id = "${var.vpc-id}"

  ingress {
    from_port       = "${var.rds-port}"
    to_port         = "${var.rds-port}"
    protocol        = "tcp"
    security_groups = ["${var.rds-repo-security-group}"]
  }

  ingress {
    from_port       = "${var.rds-port}"
    to_port         = "${var.rds-port}"
    protocol        = "tcp"
    security_groups = ["${var.rds-solr-security-group}"]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name = "${var.resource-prefix}-rds-sg"
    Environment = "${var.resource-prefix}"
    Owner = "${var.resource-owner}"
    Customer = "${var.resource-customer}"
  }
}

### subnet group for the db ###
resource "aws_db_subnet_group" "rds-subnet-group" {
  name = "${var.resource-prefix}-rds_subnet_group"
  description = "RDS subnet group"
  subnet_ids = ["${var.private-subnet-1-id}", "${var.private-subnet-2-id}"]
}

# Creation from a snapshot
resource "aws_rds_cluster" "default" {
  cluster_identifier = "${var.resource-prefix}-cluster"  
  database_name      = "${var.rds-name}"
  engine             = "${var.rds-engine}"
  master_username    = "${var.rds-username}"
  master_password    = "${var.rds-password}"
  db_subnet_group_name = "${aws_db_subnet_group.rds-subnet-group.id}"
  skip_final_snapshot = true
  final_snapshot_identifier = "${var.resource-prefix}-snapshot"
  port = "${var.rds-port}"
  vpc_security_group_ids = ["${aws_security_group.rds-sg.id}"]
  tags {
    Name = "${var.resource-prefix}-cluster"
    Environment = "${var.resource-prefix}"
    Owner = "${var.resource-owner}"
    Customer = "${var.resource-customer}"
  }
}

# resource "aws_rds_cluster" "default" {
#   cluster_identifier = "${var.resource-prefix}-cluster"
#   # availability_zones = ["${var.aws-availability-zones}"]
#   database_name      = "${var.rds-name}"
#   engine             = "${var.rds-engine}"
#   master_username    = "${var.rds-username}"
#   master_password    = "${var.rds-password}"
#   db_subnet_group_name = "${aws_db_subnet_group.rds-subnet-group.id}"
#   skip_final_snapshot = true
#   final_snapshot_identifier = "${var.resource-prefix}-snapshot"
#   port = "${var.rds-port}"
#   vpc_security_group_ids = ["${aws_security_group.rds-sg.id}"]
#   tags {
#     Name = "${var.resource-prefix}-cluster"
#     Environment = "${var.resource-prefix}"
#     Owner = "${var.resource-owner}"
#     Customer = "${var.resource-customer}"
#   }
# }

### DB instance ####
resource "aws_rds_cluster_instance" "db" {
  count = "${var.rds-instance-count}"
  identifier = "${var.resource-prefix}-db-${count.index}"
  cluster_identifier = "${aws_rds_cluster.default.id}"
  # allocated_storage = "${var.rds-storage-size}"
  # storage_type= "${var.rds-storage-type}"
  engine = "${var.rds-engine}"
  engine_version = "${var.rds-engine-version}"
  instance_class = "${var.rds-instance-class}"
  # name = "${var.rds-name}"
  # username = "${var.rds-username}"
  # password = "${var.rds-password}"
  # port = "${var.rds-port}"
  # vpc_security_group_ids = ["${aws_security_group.rds-sg.id}"]
  db_subnet_group_name = "${aws_db_subnet_group.rds-subnet-group.id}"
  # skip_final_snapshot = true
  # lifecycle {
  #   prevent_destroy = false
  # }

  tags {
    Name = "${var.resource-prefix}-db-${count.index}"
    Environment = "${var.resource-prefix}"
    Owner = "${var.resource-owner}"
    Customer = "${var.resource-customer}"
  }

}
