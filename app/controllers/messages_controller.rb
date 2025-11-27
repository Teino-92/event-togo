class MessagesController < ApplicationController
  SYSTEM_PROMPT = "You are an expert event planner. Based on the following details, create a detailed and engaging roadmap for the user.
Provide suggestions for restaurants, activities, and places to visit that align with the user's preferences.
Make sure to consider the number of persons, the city, the context, the event length, and the date.
Format the response in a clear and organized manner, using sections and bullet points where appropriate.
Do NOT save the response automatically into the Plan."

  def create
    @chat = current_user.chats.find(params[:chat_id])
    @plan = @chat.plan

    # Crée le message utilisateur
    @message = Message.new(message_params)
    @message.chat = @chat
    @message.role = "user"

    if @message.save
      # Génère la réponse de l'IA comme avant
      ruby_llm_chat = RubyLLM.chat
      response = ruby_llm_chat.with_instructions(SYSTEM_PROMPT).ask(@message.content)

      # Crée le message assistant dans le chat
      @chat.messages.create!(
        role: "assistant",
        content: response.content
      )

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
