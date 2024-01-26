

resource "aws_s3_bucket" "ece_install" {
  bucket = "ece-install-${random_id.ece_bucket.hex}"
}

resource "random_id" "ece_bucket" {
  byte_length = 8
}

resource "aws_s3_object" "management_instance_files_1" {
  bucket     = aws_s3_bucket.ece_install.id
  key        = "management_instance_files_1.zip"
  source     = data.archive_file.management_instance_files_1.output_path
  etag       = data.archive_file.management_instance_files_1.output_sha256
  depends_on = [data.archive_file.management_instance_files_1]
}

resource "aws_s3_object" "management_instance_files_2" {
  bucket     = aws_s3_bucket.ece_install.id
  key        = "management_instance_files_2.zip"
  source     = data.archive_file.management_instance_files_2.output_path
  etag       = data.archive_file.management_instance_files_2.output_sha256
  depends_on = [data.archive_file.management_instance_files_2]
}
