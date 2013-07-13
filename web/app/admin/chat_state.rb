ActiveAdmin.register ChatState do
  index do
    column :match_id
    column :room_key
    column :user1
    column :join_key1
    column :user2
    column :join_key2
    column :backend_url
    column :backend_http_url
    column :created_at
    default_actions
  end

  filter :email

  form do |f|
    f.inputs "ChatState Details" do
      f.input :user_id
      f.input :backend_url, as: :url
      f.input :backend_http_url, as: :url
      f.input :join_key
      f.input :match_key
    end
    f.actions
  end

  controller do
    actions :all, except: [:show]

    def permitted_params
      params.permit backend: [:backend_url, :join_key, :match_key, :user_id]
    end
  end
end

