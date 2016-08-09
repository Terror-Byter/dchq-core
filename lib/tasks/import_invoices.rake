require 'invoices'

task :import_invoices, [:file_path, :dive_shop_id] => :environment do |t, args|
  Invoices.new(args.file_path, args.dive_shop_id).import
end
