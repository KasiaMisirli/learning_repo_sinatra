require 'sinatra'
require 'sinatra/reloader'

require 'json'

# JSON and DATABASE are constants
before do
  response.headers["Allow"] = "GET, POST, OPTIONS"
  response.headers["Access-Control-Allow-Headers"] = "Authorization, Content-Type, Accept, X-User-Email, X-Auth-Token"
  response.headers['Access-Control-Allow-Origin'] = 'http://localhost:3000'
  content_type :json
end

options "*" do
  200
end

rating_questions = JSON.parse(File.read('db.json'))['ratingQuestions']

get '/ratingQuestions' do
  rating_questions.to_json
end

get '/ratingQuestions/:id' do
  this_id = params[:id]
  rating_questions[this_id.to_i].to_json
end

post '/ratingQuestions' do
  json_params = JSON.parse(request.body.read)
  question = {
    "title": json_params["title"],
    "link": json_params["link"]
  }
  updated_data = rating_questions.push(question)
  File.open("db.json", 'w') do |file|
    file.write(JSON.pretty_generate({ratingQuestions: updated_data}) )
  end
  question.to_json
end

# delete '/ratingQuestion/:id' do
#   this_id = params[:id]
#   rating_questions.delete([this_id.to_i])
# end


   