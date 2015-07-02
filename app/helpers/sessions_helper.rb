module SessionsHelper

  def login(store)
    session[:store_id] = store.id
    @current_store = store
  end

  def current_store
    @current_store ||= Store.find_by_id(session[:store_id])
  end

  # def logged_in?
  #   if current_user == nil
  #     redirect_to login_path
  #   end
  # end

  def logout
    @current_store = session[:store_id] = nil
  end

end
