Rails.application.routes.draw do

  post 'file', to: "documents#create"

  get 'files/:tag_search_query/:page', to: 'documents#search'

end
