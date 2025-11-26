class ChatsController < ApplicationController


def show
  @chat = Chat.find(params[:id])
  @message = @chat.messages.new  
  @plan = @chat.plan
  @chats = @plan.chats.where(user: current_user)
end

private

  def build_conversation_history
    @chat.messages.each do |message|
      @ruby_llm_chat.add_message(message)
    end
  end

end
