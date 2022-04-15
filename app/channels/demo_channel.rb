# frozen_string_literal: true

class DemoChannel < ApplicationCable::Channel
  def subscribed
    str = "demo_#{params[:id]}"
    stream_from str
    ActionCable.server.broadcast(str, Rails.cache.read(str))
  end
end
