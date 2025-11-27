class MessagesController < ApplicationController

  SYSTEM_PROMPT = "Your are an expert event planner. Based on the following details, create a detailed and engaging roadmap for the user.
      Provide suggestions for restaurants, activities, and places to visit that align with the user's preferences.
      give only max 3 options.
      Make sure to consider the number of persons, the city, the context, the event length, and the date.
      When the them is family don't forget to give options where kids will have a good time.
      When is morning, it means from 8am to 12am, afternoon means from 2pm to 6pm, evening means from 6pm to 11pm.
      You can also give a price range.
      Format the roadmap in a clear and organized manner, using sections and bullet points where appropriate."

  def create
    @chat = current_user.chats.find(params[:chat_id])
    @plan = @chat.plan

    @message = Message.new(message_params)
    @message.chat = @chat
    @message.role = "user"

    if @message.save
      ruby_llm_chat = RubyLLM.chat
      build_conversation_history
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

  def build_conversation_history
    @chat.messages.each do |message|
    @ruby_llm_chat.add_message(message)
    end
  end

end
