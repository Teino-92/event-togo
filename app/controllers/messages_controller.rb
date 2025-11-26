class MessagesController < ApplicationController

  SYSTEM_PROMPT = "You are an expert event planner. Based on the following details, create a detailed and engaging roadmap for the user.
      Provide suggestions for restaurants, activities, and places to visit that align with the user's preferences.
      Make sure to consider the number of persons, the city, the context, the event length, and the date.
      Format the roadmap in a clear and organized manner, using sections and bullet points where appropriate."

  def create
    @chat = current_user.chats.find(params[:chat_id])
    @challenge = @chat.challenge

    @message = Message.new(message_params)
    @message.chat = @chat
    @message.role = "user"

    if @message.save
      ruby_llm_chat = RubyLLM.chat
      response = ruby_llm_chat.with_instructions(SYSTEM_PROMPT).ask(@message.content)
      Message.create(role: "assistant", content: response.content, chat: @chat)

      redirect_to chat_path(@chat)
    else
    render "chats/show", status: :unprocessable_entity
    end
  end

  private

  def message_params
  params.require(:message).permit(:content)
  end
end
