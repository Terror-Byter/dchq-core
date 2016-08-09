class CustomerSmartList
  def initialize company, smart_list
    @company = company
    @smart_list  = smart_list
  end

  def process
    @customers = {}

    @smart_list.smart_list_conditions.each_with_index do |condition, index|
      @customers[index] = []
      case condition.resource
      when 'product_purchased'     then filter_purchased_products(condition, index)
      when 'product_not_purchased' then filter_not_purchased_products(condition, index)
      when 'event_completed'       then filter_purchased_events(condition, index)
      when 'event_not_completed'   then filter_not_purchased_events(condition, index)
      when 'course_completed'      then filter_purchased_courses(condition, index)
      when 'course_not_completed'  then filter_not_purchased_courses(condition, index)
      when 'rental_completed'      then filter_rentals(condition, index)
      when 'servicing_completed'   then filter_services(condition, index)
      end
    end
    return [] if @customers.blank?


    result = @customers[0].map(&:id)
    @customers.map{ |i| result = eval("#{ result } #{ @smart_list.join_operator } #{ i.last.map(&:id) } ") unless i.last.blank? }
    Customer.where(id: result).order('given_name, family_name')
  end

  private
  def filter_purchased_products condition, index
    time_condition = condition.when.blank? ? '' : "AND sales.created_at > '#{ Date.today - eval(condition.when.gsub('_', '.')) }'"
    specific_item  = condition.which == 'any' ? '' : "AND sale_products.sale_productable_id = #{ condition.value }"
    how_much       = condition.which == 'any' ? "HAVING SUM(sale_products.smart_line_item_price) #{ condition.how_many } #{ condition.value }" : ''

    @customers[index] << Customer.find_by_sql("
                           SELECT
                             customers.id
                           FROM
                             customers
                           INNER JOIN
                             sale_customers ON sale_customers.customer_id = customers.id
                           INNER JOIN
                             sales ON sales.id = sale_customers.sale_id AND sales.status = 'complete' #{ time_condition }
                           INNER JOIN
                             sale_products ON sale_products.sale_id = sales.id AND
                             sale_products.sale_productable_type = 'StoreProduct' #{ specific_item }
                           WHERE
                             customers.deleted_at IS NULL AND customers.company_id = #{ @company.id } AND
                             customers.email <> '#{ Figaro.env.walk_in_email }'
                           GROUP BY
                             customers.id
                           #{ how_much }")
    @customers[index].flatten!
  end

  def filter_not_purchased_products condition, index
    time_condition = condition.when.blank? ? '' : "AND sales.created_at > '#{ Date.today - eval(condition.when.gsub('_', '.')) }'"
    specific_item  = condition.which == 'any' ? '' : "AND sale_products.sale_productable_id = #{ condition.value }"
    how_much       = condition.which == 'any' ? "HAVING SUM(sale_products.smart_line_item_price) #{ condition.how_many } #{ condition.value }" : ''

    @customers[index] << Customer.find_by_sql("
                           SELECT
                             customers.id
                           FROM
                             customers
                           WHERE
                             customers.id NOT IN (
                               SELECT
                                 customers.id
                               FROM
                                 customers
                               INNER JOIN
                                 sale_customers ON sale_customers.customer_id = customers.id
                               INNER JOIN
                                 sales ON sales.id = sale_customers.sale_id AND sales.status = 'complete' #{ time_condition }
                               INNER JOIN
                                 sale_products ON sale_products.sale_id = sales.id AND
                                 sale_products.sale_productable_type = 'StoreProduct' #{ specific_item }
                               WHERE
                                 customers.company_id = #{ @company.id }
                               GROUP BY
                                 customers.id
                               #{ how_much }) AND
                             customers.deleted_at IS NULL AND customers.company_id = #{ @company.id } AND
                             customers.email <> '#{ Figaro.env.walk_in_email }'
                          ")
    @customers[index].flatten!
  end

  def filter_purchased_events condition, index
    time_condition = condition.when.blank? ? '' : "AND sales.created_at > '#{ Date.today - eval(condition.when.gsub('_', '.')) }'"
    specific_item  = condition.which == 'any' ? '' : "AND event_customer_participants.event_id = #{ condition.value }"
    how_much       = condition.which == 'any' ? "HAVING SUM(event_customer_participants.smart_line_item_price) #{ condition.how_many } #{ condition.value }" : ''

    @customers[index] = Customer.find_by_sql("
                           SELECT
                             customers.id
                           FROM
                             customers
                           INNER JOIN
                             sale_customers ON sale_customers.customer_id = customers.id
                           INNER JOIN
                             sales ON sales.id = sale_customers.sale_id AND sales.status = 'complete' #{ time_condition }
                           INNER JOIN
                             sale_products ON sale_products.sale_id = sales.id
                           INNER JOIN
                             event_customer_participants ON event_customer_participants.id = sale_products.sale_productable_id #{ specific_item }
                           INNER JOIN
                             events ON events.id = event_customer_participants.event_id AND events.type = 'OtherEvent'
                           WHERE
                             customers.deleted_at IS NULL AND customers.company_id = #{ @company.id } AND
                             customers.email <> '#{ Figaro.env.walk_in_email }'
                           GROUP BY
                             customers.id
                           #{ how_much }")
    @customers[index].flatten!
  end

  def filter_not_purchased_events condition, index
    time_condition = condition.when.blank? ? '' : "AND sales.created_at > '#{ Date.today - eval(condition.when.gsub('_', '.')) }'"
    specific_item  = condition.which == 'any' ? '' : "AND event_customer_participants.event_id = #{ condition.value }"
    how_much       = condition.which == 'any' ? "HAVING SUM(event_customer_participants.smart_line_item_price) #{ condition.how_many } #{ condition.value }" : ''

    @customers[index] = Customer.find_by_sql("
                           SELECT
                             customers.id
                           FROM
                             customers
                           WHERE
                             customers.id NOT IN (
                                  SELECT
                                    customers.id
                                  FROM
                                    customers
                                  INNER JOIN
                                    sale_customers ON sale_customers.customer_id = customers.id
                                  INNER JOIN
                                    sales ON sales.id = sale_customers.sale_id AND sales.status = 'complete' #{ time_condition }
                                  INNER JOIN
                                    sale_products ON sale_products.sale_id = sales.id
                                  INNER JOIN
                                    event_customer_participants ON event_customer_participants.id = sale_products.sale_productable_id #{ specific_item }
                                  INNER JOIN
                                    events ON events.id = event_customer_participants.event_id AND events.type = 'OtherEvent'
                                  WHERE
                                    customers.company_id = #{ @company.id }
                                  GROUP BY
                                    customers.id
                                  #{ how_much }) AND
                             customers.deleted_at IS NULL AND customers.company_id = #{ @company.id } AND
                             customers.email <> '#{ Figaro.env.walk_in_email }'")
    @customers[index].flatten!
  end

  def filter_purchased_courses condition, index
    time_condition = condition.when.blank? ? '' : "AND sales.created_at > '#{ Date.today - eval(condition.when.gsub('_', '.')) }'"
    specific_item  = condition.which == 'any' ? '' : "AND events.certification_level_id = #{ condition.value }"
    how_much       = condition.which == 'any' ? "HAVING SUM(event_customer_participants.smart_line_item_price) #{ condition.how_many } #{ condition.value }" : ''

    @customers[index] = Customer.find_by_sql("
                           SELECT
                             customers.id
                           FROM
                             customers
                           INNER JOIN
                             sale_customers ON sale_customers.customer_id = customers.id
                           INNER JOIN
                             sales ON sales.id = sale_customers.sale_id AND sales.status = 'complete' #{ time_condition }
                           INNER JOIN
                             sale_products ON sale_products.sale_id = sales.id
                           INNER JOIN
                             event_customer_participants ON event_customer_participants.id = sale_products.sale_productable_id
                           INNER JOIN
                             events ON events.id = event_customer_participants.event_id AND events.type = 'CourseEvent' #{ specific_item }
                           WHERE
                             customers.deleted_at IS NULL AND customers.company_id = #{ @company.id } AND
                             customers.email <> '#{ Figaro.env.walk_in_email }'
                           GROUP BY
                             customers.id
                           #{ how_much }")
    @customers[index].flatten!
  end

  def filter_not_purchased_courses condition, index
    time_condition = condition.when.blank? ? '' : "AND sales.created_at > '#{ Date.today - eval(condition.when.gsub('_', '.')) }'"
    specific_item  = condition.which == 'any' ? '' : "AND events.certification_level_id = #{ condition.value }"
    how_much       = condition.which == 'any' ? "HAVING SUM(event_customer_participants.smart_line_item_price) #{ condition.how_many } #{ condition.value }" : ''

    @customers[index] = Customer.find_by_sql("
                           SELECT
                             customers.id
                           FROM
                             customers
                           WHERE
                             customers.id NOT IN (
                                  SELECT
                                    customers.id
                                  FROM
                                    customers
                                  INNER JOIN
                                    sale_customers ON sale_customers.customer_id = customers.id
                                  INNER JOIN
                                    sales ON sales.id = sale_customers.sale_id AND sales.status = 'complete' #{ time_condition }
                                  INNER JOIN
                                   sale_products ON sale_products.sale_id = sales.id
                                  INNER JOIN
                                    event_customer_participants ON event_customer_participants.id = sale_products.sale_productable_id
                                  INNER JOIN
                                    events ON events.id = event_customer_participants.event_id AND events.type = 'CourseEvent' #{ specific_item }
                                  WHERE
                                    customers.company_id = #{ @company.id }
                                  GROUP BY
                                    customers.id
                                  #{ how_much }) AND
                             customers.deleted_at IS NULL AND customers.company_id = #{ @company.id } AND
                             customers.email <> '#{ Figaro.env.walk_in_email }'")
    @customers[index].flatten!
  end


  def filter_rentals condition, index
    time_condition = condition.when.blank? ? '' : "AND rentals.created_at > '#{ Date.today - eval(condition.when.gsub('_', '.')) }'"
    specific_item  = condition.which == 'any' ? '' : "AND renteds.rental_product_id = #{ condition.value }"
    how_much       = condition.which == 'any' ? "HAVING SUM(renteds.smart_line_item_price) #{ condition.how_many } #{ condition.value }" : ''

    @customers[index] = Customer.find_by_sql("
                          SELECT
                            customers.id
                          FROM
                            customers
                          INNER JOIN
                            rentals ON rentals.customer_id = customers.id AND rentals.status = 'complete' #{ time_condition }
                          INNER JOIN
                            renteds ON renteds.rental_id = rentals.id #{ specific_item }
                          WHERE
                            customers.deleted_at IS NULL AND customers.company_id = #{ @company.id } AND
                            customers.email <> '#{ Figaro.env.walk_in_email }'
                          GROUP BY
                            customers.id
                          #{ how_much }")
    @customers[index].flatten!
  end

  def filter_services condition, index
    time_condition = condition.when.blank? ? '' : "AND sales.created_at > '#{ Date.today - eval(condition.when.gsub('_', '.')) }'"
    specific_item  = condition.which == 'any' ? '' : "AND services.type_of_service_id = #{ condition.value }"
    how_much       = condition.which == 'any' ? "HAVING SUM(sale_products.smart_line_item_price) #{ condition.how_many } #{ condition.value }" : ''

    @customers[index] = Customer.find_by_sql("
                          SELECT
                            customers.id
                          FROM
                            customers
                          INNER JOIN
                            sale_customers ON sale_customers.customer_id = customers.id
                          INNER JOIN
                            sales ON sales.id = sale_customers.sale_id AND sales.status = 'complete' #{ time_condition }
                          INNER JOIN
                            sale_products ON sale_products.sale_id = sales.id AND sale_products.sale_productable_type = 'Service'
                          INNER JOIN
                            services ON services.id = sale_products.sale_productable_id #{ specific_item }
                          WHERE
                            customers.deleted_at IS NULL AND customers.company_id = #{ @company.id } AND
                            customers.email <> '#{ Figaro.env.walk_in_email }'
                          GROUP BY
                            customers.id
                          #{ how_much } ")
    @customers[index].flatten!
  end
end
