collection :@stores

attributes :name, :api_key

child :currency do
  attributes :id, :name, :unit, :code, :separator, :delimiter, :format, :precision
end
