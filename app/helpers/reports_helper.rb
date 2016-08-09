module ReportsHelper
  def show_months_head
    heads = []
    heads << content_tag(:th, nil, class: 'first')
    @duration.times do |index|
      heads << content_tag(:th, nil) do
        haml_tag :span, class: 'border'
        haml_tag :span, "#{ Date::MONTHNAMES[(@date + index.month).month] } #{ (@date + index.months).year }", style: Date::MONTHNAMES[(@date + index.month).month].eql?(Date::MONTHNAMES[Date.today.month]) ? 'color:yellow' : nil
      end
    end

    content_tag(:tr, heads.join.html_safe)
  end

  def show_table_row_with_currency title, collection, options = {}
    show_table_row "#{title} (#{current_store.currency.unit})".html_safe, collection, options = {}
  end

  def show_table_row title, collection, options = {}
    heads = []
    heads << content_tag(:td, title, class: 'important')
    collection.each do |price|
      heads << content_tag(:td, formatted_currency(price))
    end

    content_tag(:tr, heads.join.html_safe, options.merge!(:class => cycle(nil, "color")))
  end
end
