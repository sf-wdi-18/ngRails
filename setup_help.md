# Simple Reciepts Solution



## Generating A Store

Let's generate our store

```ruby
rails g store_owner name:string email:string password_digest:string
```

And with that we can begin our canonical user logic.

* Add `bcrypt` to gemfile
* Structure `store_owner.rb` to have secure password

```ruby
class StoreOwner < ActiveRecord::Base

  has_secure_password
  
  def self.confirm(params)
    store_owner = self.find_by!(email: params[:email])
    store_owner.authenticate(params[:password])
  end

end

```
* Create a `store_owners` controller

```
rails g controller store_owners
```

* Create a `sessions_controller`

```
rails g controller sessions
```

* Create a `sites_controller`.

```
rails g controller sites home
```

----

* Throw down some bootstrap into your assets

```
npm install -g bower // if you don't have bower

touch .bowerrc 
subl .bowerrc
```
  * You can quickly format you `.bowerrc` file to put assets in your vendor folder
  
  ```
  {
    "directory": "vendor/assets/components"
  }
  ```
  * Then just install bootstrap
  
  ```
  bower install --save bootstrap
  ```
  * Then just load boostrap from your `app/assets/stylesheets/application.css`
  
  ```
  *= require bootstrap/dist/css/bootstrap.min
  ```

----


* Let's create some canonical routes for signup and login

  ```
  root to: "sites#home"
  
  get "/signup", to: "store_owners#new"
  post "/signup", to: "stores_owners#create"
  get "/account", to: "store_owners#show"
  
  get "/login", to: "sessions#new"
  post "/login", to: "sessions#create"
  
  ```

* Then create the `sessions_helper`

  ```ruby
  def login(store_owner)
    session[:owner_id] = store_owner.id
    @current_owner = store_owner
  end
  
  def logout
    @current_owner = session[:owner_id] = nil
  end
  
  def current_owner
    @current_owner ||= User.find_by(id: session[:owner_id])
  end
  
  def logged_in?
    !current_owner.nil?
  end
  
  def require_login
    if !logged_in?
      redirect_to "/login"
    end
  end
  ```

* Then we add that to `application_controller`

  ```
  class ApplicationController < ActionController::Base
    ...
    
    include SessionsHelper
  end
  ```

* Then we add the appropriate logic to our `store_owners_controller`

```ruby
before_action :require_login, only: [:show]
rescue_from ActiveRecord::RecordInvalid, with: :invalid_signup

def new
  @store_owner = StoreOwner.new
end

def create
  @store_owner = StoreOwner.create!(owner_params)
  login(@store_owner)
  redirect_to "/account"
end

def show
  @store_owner = current_owner
end

protected
  
  def invalid_signup(e)
    flash[:error]= e.message
    redirect_to "/signup"
  end

private

  def owner_params
    params.require(:store_owner).permit(:name, :email, :password, :password_digest)
  end
```

* Then we add our simple `login` logic to `sessions_controller`

```ruby
rescue_from ActiveRecord::RecordNotFound, with: :failed_login

def new
  @store_owner = StoreOwner.new
end

def create
  @store_owner = StoreOwner.confirm(params)
  login(@store_owner)
  redirect_to "/account"
end

protected

  def failed_login(e)
    flash[:error] = "Failed Login"
    redirect_to "/login"
  end

```

* This assumes you have the appropriate views.


## Tokens!

* Then we can add a migration to create the `api_token` column on the store owner.

```
rails g migration add_api_token_to_store_owners api_token:string
```

* Then be sure to edit the migration you created so that it also has an index, because you'll be using this column A LOT!

```ruby
class AddApiTokenToStoreOwners < ActiveRecord::Migration
  def change
    add_column :store_owners, :api_token, :string
    add_index(:store_owners, :api_token, unique: true)
  end
end

```
* Then you'll need to create the token when someone signs up for the first time. This means we will need a new method in `StoreOwner`.

```ruby
class StoreOwner < ActiveRecord::Base

  has_secure_password
  
  before_validation :on => :create, :gen_api_token
  
  validates :api_token,
            :uniqueness => true
  
  validates :email,
            :presence => true,
            :uniqueness => true
  
  valdates :email_confirmation,
           :presence => true
  
  def self.confirm(params)
    store_owner = self.find_by!(email: params[:email])
    store_owner.authenticate(params[:password])
  end
  
  def gen_api_token
    token = SecureRandom.uuid
    
    # run simple validation
    until StoreOwner.find_by(api_token: token).nil?
      token = SecureRandom.uuid
    end
    
    self.api_token = token
  end
  
end

```

* Token Reset, we can add a token reset method in our store_owners controller

```ruby

before_action :require_login, only: [:show, :reset_token]

rescue_from ActiveRecord::RecordInvalid, with: :invalid_signup

def new
  @store_owner = StoreOwner.new
end

def create
  @store_owner = StoreOwner.create!(owner_params)
  login(@store_owner)
  redirect_to "/account"
end

## add this to before_action list
def token_reset
  current_owner.gen_api_token
  current_owner.save
  redirect_to "/account"
end

protected
  
  def invalid_signup(e)
    flash[:error]= e.message
    redirect_to "/signup"
  end

private

  def owner_params
    params.require(:store_owner).permit(:name, :email, :password, :password_digest)
  end

```

* A logged in user can reset their token by posting to this method so we should add a route that call this method

```ruby
...
post "/account/token_reset", to: "store_owners#token_reset"
```

## Simple Receipts

Let's add a model for this.

```ruby
rails g model simple_receipts store_owner:references total:decimal amount:decimal tip:decimal transaction_num:string 
```

Then you should setup the association between the `StoreOwner` and `SimpleReceipt` models


Then lets add a controller for `simple_receipts`

```ruby
class SimpleReceipts < ApplicationController
 
  before_action :require_token
  
  # view all receipts at
  #   localhost:3000/simple_receipts?api_token=YOUR_TOKEN
  def index
    @receipts = current_owner.simple_receipts
    respond_to do |f|
      f.json { render json: @receipts }
    end
  end
  
  def create
    @receipt = current_owner.simple_receipts.create(receipt_params)
    respond_to do |f|
      f.json { render json: @receipt }
    end
  end
  
  private
  
    def require_token
      api_token = params[:api_token]
      @current_owner = StoreOwner.find_by!(api_token: api_token)
    end
    
    def receipt_params
      params.require(:receipt).permit(:transaction_num, :total, :amount, :tip)
    end
end
```


The only thing that could be added is some clean up around looking for the token. Let's add it to our model.

```ruby
class StoreOwner < ActiveRecord::Base

  has_secure_password
  
  before_validation :on => :create, :gen_api_token
  
  validates :api_token,
            :uniqueness => true
  
  validates :email,
            :presence => true,
            :uniqueness => true
  
  valdates :email_confirmation,
           :presence => true
  
  def self.confirm(params)
    store_owner = self.find_by!(email: params[:email])
    store_owner.authenticate(params[:password])
  end
  
  def gen_api_token
    token = SecureRandom.uuid
    
    # run simple validation
    until StoreOwner.find_by(api_token: token).nil?
      token = SecureRandom.uuid
    end
    
    self.api_token = token
  end
  
  
  def confirm_token(params)
    token = params[:api_token]
    store_owner = StoreOwner.find_by!(api_token: token)
  end
end
```


Then we can refactor the `simple_receipts` controller to do the following.

```ruby
class SimpleReceipts < ApplicationController
 
  before_action :require_token
  
  rescue_from ActiveRecord::RecordNotFound, with: :bad_token
  
  # view all receipts at
  #   localhost:3000/simple_receipts?api_token=YOUR_TOKEN
  def index
    @receipts = current_owner.simple_receipts
    respond_to do |f|
      f.json { render json: @receipts }
    end
  end
  
  def create
    @receipt = current_owner.simple_receipts.create(receipt_params)
    respond_to do |f|
      f.json { render json: @receipt }
    end
  end
  
  
  protected
  
    def bad_token(e)
      render json: { status: 401,  errors: e.message }, status: 401
    end
  
  private
  
    def require_token
      @current_owner = StoreOwner.confirm_token(params)
    end
    
    def receipt_params
      params.require(:receipt).permit(:transaction_num, :total, :amount, :tip)
    end
end
```

