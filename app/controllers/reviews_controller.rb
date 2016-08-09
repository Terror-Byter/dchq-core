class ReviewsController < InheritedResources::Base
  # load_and_authorize_resource

  respond_to :html

  def index
    params[:page] ||= 1
    @reviews = ScubaTribe.new(current_store.scuba_tribe.api_key).reviews(page: params[:page].to_i)
    @reviews.instance_eval <<-EVAL
      def limit
        15.0
      end

      def current_page
        #{params[:page] || 1}
      end

      def limit_value
        limit
      end

      def total_pages
        (self['num_records_total'] / limit).ceil
      end
EVAL
  end
end
