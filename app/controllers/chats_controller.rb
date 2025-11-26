class ChatsController < ApplicationController


def show
    @chat = Chat.find(params[:id])
    @messages = @chat.messages
end

private

  def build_conversation_history
    @chat.messages.each do |message|
      @ruby_llm_chat.add_message(message)
    end
  end

end
