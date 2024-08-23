# spec/support/shrine.rb
require "shrine"
require "shrine/storage/memory"

Shrine.storages = {
  cache: Shrine::Storage::Memory.new, # armazenamento temporário
  store: Shrine::Storage::Memory.new  # armazenamento permanente
}

Shrine.plugin :activerecord
Shrine.plugin :cached_attachment_data
Shrine.plugin :restore_cached_data
