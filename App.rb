require 'sinatra'
require 'sinatra/reloader'
require 'pry'

require 'json'

# JSON and DATABASE are constants
rating_questions = []

before do
  response.headers["Access-Control-Allow-Methods"] = "GET", "POST", "PUT", "DELETE", "OPTIONS"
  response.headers["Access-Control-Allow-Headers"] = "Authorization", "Content-Type", "Accept", "X-User-Email", "X-Auth-Token"
  response.headers['Access-Control-Allow-Origin'] = "*"
  content_type :json
  rating_questions = JSON.parse(File.read('db.json'))['ratingQuestions']

end
options "*" do
  200
end


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
    "link": json_params["link"],
    "id": rating_questions.any? ? rating_questions.last["id"]+1 : 1
    
  }
  updated_data = rating_questions.push(question)
  File.open("db.json", 'w') do |file|
    file.write(JSON.pretty_generate({ratingQuestions: updated_data}) )
  end
  204
end

delete '/ratingQuestions/:id' do
  this_id = params[:id]
  rating_questions.each_with_index { |q, i| rating_questions.delete_at(i) if q["id"] == this_id.to_i }
  File.open("db.json", 'w') do |file|
    file.write(JSON.pretty_generate({ratingQuestions: rating_questions}) )
  end
  response.status = 200
  response
end

put '/ratingQuestions/:id' do
  this_id = params[:id]
  json_params = JSON.parse(request.body.read)
  rating_questions.each_with_index { |q,i| q["title"] = json_params["title"] if q["id"] == this_id.to_i}
  File.open("db.json", 'w') do |file|
    file.write(JSON.pretty_generate({ratingQuestions: rating_questions}) )
  end
  response.status = 200
  response
end
