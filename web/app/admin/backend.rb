ActiveAdmin.register Backend do
  index do
    column :kind
    column :url
    column :http_url
    default_actions
  end

  filter :email

  form do |f|
    f.inputs "Backend Details" do
      f.input :kind, as: :select, collection: ['queue', 'chat']
      f.input :url, as: :url
      f.input :http_url, as: :url
    end
    f.actions
  end

  controller do
    actions :all, except: [:show]

    def permitted_params
      params.permit backend: [:kind, :url, :http_url]
    end
  end
end

