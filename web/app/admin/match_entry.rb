ActiveAdmin.register MatchEntry do
  index do
    column :user
    column :other_user
    column :created_at
    column :closed_at
    column :rejected
    default_actions
  end

  filter :email

  form do |f|
    f.inputs "MatchEntry Details" do
      f.input :user_id
      f.input :other_user_id
      f.input :created_at, as: :datetime
      f.input :closed_at, as: :datetime
      f.input :rejected, as: :checkbox
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


