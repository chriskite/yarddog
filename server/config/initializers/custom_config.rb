APP_CONFIG = YAML.load_file(Rails.root.join('config', 'config.yml'))[Rails.env]

required_keys = [
  'aws_key',
  'aws_secret_key',
  'ami_id',
  'subnet_id',
  'security_group_ids',
  'aws_private_key_path',
  'aws_public_key_path'
]
