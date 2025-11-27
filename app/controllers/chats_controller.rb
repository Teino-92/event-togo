class ChatsController < ApplicationController
  SYSTEM_PROMPT = "You are an expert event planner. Based on the following details, create a detailed and engaging roadmap for the user.
      Provide suggestions for restaurants, activities, and places to visit that align with the user's preferences.
      Make sure to consider the number of persons, the city, the context, the event length, and the date.
      Format the roadmap in a clear and organized manner, using sections and bullet points where appropriate."


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

  full_history = @chat.messages.order(:created_at).pluck(:content).join("\n")

  ruby_llm_chat = RubyLLM.chat
  response = ruby_llm_chat.with_instructions(SYSTEM_PROMPT).ask(full_history)

  if @plan.update(roadmap: response.content)
    redirect_to plans_path, notice: "Roadmap saved successfully!"
  else
    redirect_to chat_path(@chat), alert: "Error saving roadmap."
  end
end

private

  def build_conversation_history
    @chat.messages.each do |message|
      @ruby_llm_chat.add_message(message)
    end
  end

end
