# Plugin's routes
# See: http://guides.rubyonrails.org/routing.html
get 'webhook', :to => 'webhook#index'
post 'webhook', :to => 'webhook#create'