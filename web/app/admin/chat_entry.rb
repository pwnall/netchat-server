ActiveAdmin.register ChatEntry do
  index do
    column :user
    column :other_user
    column :match_id
    column :created_at
    column :closed_at
    default_actions
  end

  filter :email

  form do |f|
    f.inputs "ChatEntry Details" do
      f.input :user_id
      f.input :other_user_id
      f.input :match_id
      f.input :created_at, as: :datetime
      f.input :closed_at, as: :datetime
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
