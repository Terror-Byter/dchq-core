module Settings
  class ScubatribesController < InheritedResources::Base
    def create
      scubatribe = Stores::ScubaTribe.new

      scubatribe_service = ScubaTribe.new(params[:api_key])
      account = scubatribe_service.account

      if account['status'] == 'OK'
        scubatribe.api_key = params[:api_key]
        scubatribe.store = current_store
        scubatribe.user_id = account['account']['user_id']
        scubatribe.save
        redirect_to integrations_settings_path, notice: 'Integration has beed added'
      else
        redirect_to integrations_settings_path, notice: 'Wrong api key'
      end
    end

    def new
      @form = ScubaTribeForm.new
    end

    def signup
      @form = ScubaTribeForm.new(params[:scuba_tribe_form].merge(current_store: current_store))

      if @form.save
        redirect_to integrations_settings_path, notice: 'Integration has beed added'
      else
        render :new
      end
    end
  end
end
