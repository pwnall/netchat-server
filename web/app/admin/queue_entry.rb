ActiveAdmin.register QueueEntry do
  index do
    column :user
    column :entered_at
    column :left_at
    default_actions
  end

  filter :email

  form do |f|
    f.inputs "QueueState Details" do
      f.input :user_id
      f.input :entered_at, as: :datetime
      f.input :left_at, as: :datetime
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

