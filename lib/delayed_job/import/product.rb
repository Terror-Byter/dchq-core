class DelayedJob::Import::Product < Struct.new(:data, :store, :user, :params)
  def perform
    errors = []
    Product.transaction do
      data.each_with_index do |record, index|
        next if index.zero?

        @product = store.products.build
        @product.build_logo

        import( record )
        unless @product.save
          errors << "#{I18n.t("controllers.on_line")} #{index + 1}: #{@product.errors.full_messages.join(", ")}"
        end
      end
    end
    if errors.blank?
      ImportMailer.success(user, I18n.t('activerecord.models.product.one')).deliver
    else
      ImportMailer.rejected(user, I18n.t('activerecord.models.product.one'), errors).deliver
    end
  end

  private
  def import record
    record.each_with_index do |item, i|
      next if params["fields_#{i + 1}"].blank? or params["fields_#{i + 1}"] == "id" or item.blank?

      case params["fields_#{i + 1}"]
      when "brand_id" then @product[params["fields_#{i + 1}"]]           = find_or_create_brand( item )
      when "category_id" then @product[params["fields_#{i + 1}"]]        = find_or_create_category( item )
      when "supplier_id" then @product[params["fields_#{i + 1}"]]        = find_or_create_supplier( item )
      when "tax_rate_id" then @product[params["fields_#{i + 1}"]]        = find_or_create_tax_rate( item )
      when "commission_rate_id" then @product[params["fields_#{i + 1}"]] = find_or_create_commission_rate( item )
      when "image" then @product.logo.upload_image_from_url item
      else @product[params["fields_#{i + 1}"]] = item.force_encoding('UTF-8').strip

      end
    end
  end

  def find_or_create_brand brand_name
    unless brand = store.brands.find_by_name(brand_name)
      brand = store.brands.create(name: brand_name)
    end
    brand.id
  end

  def find_or_create_category category_name
    unless category = store.categories.find_by_name(category_name)
      category = store.categories.create(name: category_name)
    end
    category.id
  end

  def find_or_create_supplier supplier_name
    unless supplier = store.company.suppliers.find_by_name(supplier_name)
      supplier = store.company.suppliers.create(name: supplier_name)
    end
    supplier.id
  end

  def find_or_create_tax_rate amount
    unless tax_rate = store.tax_rates.find_by_amount(amount)
      tax_rate = store.tax_rates.create(amount: amount)
    end
    tax_rate.id
  end

  def find_or_create_commission_rate amount
    unless commission_rate = store.commission_rates.find_by_amount(amount)
      commission_rate = store.commission_rates.create(amount: amount)
    end
    commission_rate.id
  end
end
