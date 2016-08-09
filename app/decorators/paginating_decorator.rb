class PaginatingDecorator < Draper::CollectionDecorator
  delegate :current_page, :total_entries, :total_count, :per_page, :offset, :paginate
end
