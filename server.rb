require "sinatra"

class Server < Sinatra::Application

  get "/" do
    "Hello world!"
  end

  get "/election/new/:sender_id" do
    logger.info("kvik")
    "o'hai, #{params[:sender_id]}!"
  end

end
