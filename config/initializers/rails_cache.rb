# See: http://aaronvb.com/articles/37-rails-caching-and-undefined-class-module

# if Rails.env == "development"
#   Dir.glob("#{Rails.root}/app/models/**/*.rb") do |model_name|
#     require_dependency model_name
#   end 
# end