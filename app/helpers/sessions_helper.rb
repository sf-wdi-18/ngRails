module SessionsHelper

  def login(store)
    session[:store_id] = store.id
    @current_store = store
  end

  def current_store
    @current_store ||= Store.find_by_id(session[:store_id])
  end

  def logged_in?
    !current_store.nil?
  end

  def require_login
    if !logged_in?
      redirect_to "/login"
    end
  end

  def logout
    @current_store = session[:store_id] = nil
  end

end
