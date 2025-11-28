class ChatsController < ApplicationController

def create
  @chat = current_user.chats.find(params[:chat_id])
  @plan = @chat.plan

  @message = Message.new(message_params)
  @message.chat = @chat
  @message.role = "user"

  if @message.save
    @ruby_llm_chat = RubyLLM.chat
    build_conversation_history
    response = @ruby_llm_chat.with_instructions(SYSTEM_PROMPT).ask(@message.content)

    Message.create(role: "assistant", content: response.content, chat: @chat)

    redirect_to chat_path(@chat)
  else
    render "chats/show", status: :unprocessable_entity
  end
end

def show
  @chat = Chat.find(params[:id])
  @message = @chat.messages.new
  @plan = @chat.plan
  @chats = @plan.chats.where(user: current_user)

  llm_response = RubyLLM.chat
    .with_instructions("Extract the LAST roadmap from the following conversation and return ONLY valid JSON.
    JSON FORMAT:
    {
      \"title\": string,
      \"price_range\": string,
      \"roadmap\": [
        {
          \"time\": string,
          \"title\": string,
          \"description\": string,
          \"pricing\": string,
          \"options\": [string]
        }
      ]
    }
    Conversation:
    #{@chat.messages.map { |m| "#{m.role}: #{m.content}" }.join(' ')}")
    .ask("Return the LAST roadmap only.")
    .content

  @roadmap_json = JSON.parse(llm_response)

  session[:last_roadmap] = @roadmap_json

rescue JSON::ParserError
  @roadmap_json = nil
end


def save_roadmap
  @chat = Chat.find(params[:id])
  @plan = @chat.plan

  last_assistant_message = @chat.messages.where(role: "assistant").last

  unless last_assistant_message.present?
    redirect_to chat_path(@chat), alert: "No roadmap to save."
    return
  end


  @plan.update!(
    title: @plan.title.presence,
    roadmap: last_assistant_message.content,
    roadmap_date: @plan.roadmap_date
  )

  redirect_to plans_path, notice: "Roadmap saved successfully!"
end


private

  def build_conversation_history
    @chat.messages.each do |message|
      @ruby_llm_chat.add_message(message)
    end
  end

end
