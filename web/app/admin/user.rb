ActiveAdmin.register User do
  index do
    column :email
    column :admin
    default_actions
  end

  filter :email

  form do |f|
    f.inputs "User Details" do
      f.input :email
      f.input :admin
      f.input :password
      f.input :password_confirmation
    end
    f.actions
  end

  controller do
    actions :all, except: [:show]

    def permitted_params
      params.permit user: [:email, :password, :password_confirmation, :admin]
    end
  end
end
