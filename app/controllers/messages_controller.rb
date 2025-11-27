class MessagesController < ApplicationController

  SYSTEM_PROMPT = "<<~TEXT
    You are an expert event planner.
    Your task:
    - Generate a short catchy TITLE from the details.
    - Generate a detailed ROADMAP.
    - Give a maximum of 3 options per section.
    - Suggest restaurants, activities, and places.
    - Always consider:
      - city
      - context
      - number of persons
      - event length
      - date
    - If the theme is 'family', include kid-friendly options.
    - Time rules:
      - Morning = 8am to 12pm
      - Afternoon = 2pm to 6pm
      - Evening = 6pm to 11pm
    - Include a price range.
    You MUST return ONLY valid JSON.
    NO text outside JSON.
    NO markdown.
      JSON FORMAT:
    { 'roadmap': [
        {
          'time': string,
          'title': string,
          'description': string,
          'pricing': string,
          'options': [string]
        }
      ]
    }

  TEXT"

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
