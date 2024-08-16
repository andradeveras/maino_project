require "shrine"
require "shrine/storage/file_system"
#require "shrine/storage/s3" # Se usar S3

Shrine.storages = {
  # Armazenamento local para desenvolvimento
  cache: Shrine::Storage::FileSystem.new("public", prefix: "uploads/cache"),
  store: Shrine::Storage::FileSystem.new("public", prefix: "uploads/store"),

  # Armazenamento no Amazon S3 para produção (descomente se usar)
  # cache: Shrine::Storage::S3.new(...),
  # store: Shrine::Storage::S3.new(...)
}

Shrine.plugin :activerecord
Shrine.plugin :cached_attachment_data
Shrine.plugin :restore_cached_data
