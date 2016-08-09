object :@user

attributes :id, :full_name, :created_at, :sale_target

node(:sales) do
  { current_sale_target: @user.sales.completed.for_this_period(Date.today.beginning_of_month).sum(:grand_total),
    last_week: @user.sales.completed.sales_without_refunded_childs_for_last_week.sum(:grand_total),
    this_week: @user.sales.completed.sales_without_refunded_childs_all_time.created_this_week.sum(:grand_total) }
end
