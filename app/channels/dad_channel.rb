class DadChannel < ApplicationChannel
  def subscribed
    str = "dad_#{params[:id]}"
    stream_from str
    ActionCable.server.broadcast(str, Rails.cache.read(str))
  end
end
