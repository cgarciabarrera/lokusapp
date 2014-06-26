json.array!(@devices) do |device|
  json.extract! device, :id, :name, :user_id, :type_id, :last_lat, :last_lon, :last_fix, :active, :available
  json.url device_url(device, format: :json)
end
