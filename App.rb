require 'sinatra'
require 'sinatra/reloader'
require 'pry'

require 'json'

# JSON and DATABASE are constants
rating_questions = []

before do
  response.headers["Access-Control-Allow-Methods"] = "GET", "POST", "PUT", "PATCH", "DELETE", "OPTIONS"
  response.headers["Access-Control-Allow-Headers"] = "Authorization", "Content-Type", "Accept", "X-User-Email", "X-Auth-Token"
  response.headers['Access-Control-Allow-Origin'] = "http://localhost:3000"
  content_type :json
  rating_questions = JSON.parse(File.read('db.json'))['ratingQuestions']

end
# * means any route
options "*" do 
  200
end

# def return_response(response, status, body)
#   response.status = status
#   response.body = body.To_json
#   response
# end

get '/ratingQuestions' do
  rating_questions.to_json
end

get '/ratingQuestions/:id' do
  this_id = params[:id]
  single = []
  rating_questions.each_with_index { |q, i| single.push(q.to_json) if q["id"] == this_id.to_i }
  if single == [] 
    return response.status = 404
  end
  
  if single 
    response.status = 200
  end
  single
end

post '/ratingQuestions' do
  error = {"errors"=>{"title"=>["cannot be blank"]}}
  if request.body.size.zero?
    return 400
  end
  json_params = JSON.parse(request.body.read)
  question = {
    "title": json_params["title"],
    "link": json_params["link"],
    "id": rating_questions.any? ? rating_questions.last["id"]+1 : 1
    
  }
  if question[:title] == '' 
    response.body = error.to_json
    response.status = 422 
    return response
  end
  question.merge!(json_params) 
  # ask Ryan
  updated_data = rating_questions.push(question)
  File.open("db.json", 'w') do |file|
    file.write(JSON.pretty_generate({ratingQuestions: updated_data}) )
  end
  response.status = 201
  response.body = question.to_json
  response
end

delete '/ratingQuestions/:id' do
  this_id = params[:id]
  single = rating_questions.find { |q| q["id"] == this_id.to_i }
  if !single
    response.status = 404
    response.body = single.to_json
    return response
  end
  rating_questions.delete(single)
  File.open("db.json", 'w') do |file|
    file.write(JSON.pretty_generate({ratingQuestions: rating_questions}) )
  end
  #  must return 204 because we are not expacting any answer
  response.status = 204 
  response.body = rating_questions.to_json
  response
end

put '/ratingQuestions/:id' do
  if request.body.size.zero?
    return 404
  end
  this_id = params[:id]
  json_params = JSON.parse(request.body.read)

  single = rating_questions.find { |q| q["id"] == this_id.to_i }
  single["title"] = json_params["title"]
  File.open("db.json", 'w') do |file|
    file.write(JSON.pretty_generate({ratingQuestions: rating_questions}) )
  end
  response.status = 200
  response.body = single.to_json
  response
end

patch '/ratingQuestions/:id' do
  if request.body.size.zero? 
    response.status = 404
    response.body = {}.to_json
    return response
  end  
  this_id = params[:id]
  json_params = JSON.parse(request.body.read)
  single = rating_questions.find { |q| q["id"] == this_id.to_i }
  if !single
    response.status = 404
    response.body = {}.to_json
    return response
  end 
  single.merge!(json_params)
  File.open("db.json", 'w') do |file|
    file.write(JSON.pretty_generate({ratingQuestions: rating_questions}) )
  end
  response.status = 200
  response.body = single.to_json
  response
end
