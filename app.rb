require 'sinatra'
require 'haml'
require './shift_generator'

set :haml,    :escape_html => true
set :server,  :thin

configure do
  set     :MAX_ASSIGNMENT_COUNT, 3
  disable :show_exceptions
end

helpers ShiftGenerator

get '/' do
  haml :index
end

get '/shiftgen.css' do
  scss :'scss/shiftgen'
end

get '/generate' do
  @assignment_count = settings.MAX_ASSIGNMENT_COUNT
  haml :generate
end

post '/shift' do
  @members      = params[:members].gsub(/\r\n|\r|\n/, ",").split(",").to_a
  @count        = params[:count].to_i
  @start        = params[:start].to_i
  @assignments  = Array.new(settings.MAX_ASSIGNMENT_COUNT)
  @mark         = params[:mark].to_s
  @DECORATED_CEL= { color: ["#487ca3", "#6c5776", "#499475"], characters: ["●", "▲", "△"] }

  @max_time_length = 0
  @assignments.size.times do |i|
    assignment_name     = params["assignment_name#{i}"]
    member_assignments  = params["member_assignments#{i}"].split(",").map{|s|Integer s}
    time_assignments    = params["time_assignments#{i}"].split(",").map{|s|Integer s}
    @assignments[i]     = ShiftGenerator::Assignment.new(assignment_name, member_assignments, time_assignments)

    cur_time_length   = time_assignments.inject(0) { |sum, i| sum + i }
    @max_time_length  = cur_time_length if cur_time_length > @max_time_length
  end

  @shifts = generate_shifts(@members, @count, @assignments)
  haml :shift
end

get '/help' do
  haml :help
end

not_found do
  @error_message = "PAGE NOT FOUND"
  haml :error
end

error RuntimeError do
  @error_message = request.env['sinatra.error'].to_s +
    " Please go back to the previous page and retry."
  haml :error
end