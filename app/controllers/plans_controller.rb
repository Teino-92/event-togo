class PlansController < ApplicationController

  def index
    @plans = Plan.where(user: current_user).where.not(roadmap: nil)
  end

  def new
    @plans = Plan.new
  end

  def create
    @plan = Plan.new(plan_params)
    @plan.user = current_user

    if @plan.save
      first_prompt = <<~TEXT
        Theme: #{@plan.theme}
        City: #{@plan.city}
        Context: #{@plan.context}
        Number of persons: #{@plan.number_persons}
        Event length: #{@plan.event_lenght}
        Date: #{@plan.roadmap_date}
      TEXT

      @chat = @plan.chats.create!(title: "New Roadmap")

      @message = @chat.messages.create!(role: "user", content: first_prompt)

      ruby_llm_chat = RubyLLM.chat
      ruby_llm_chat.add_message(@message)

      response = ruby_llm_chat.with_instructions(instructions).ask("Can you suggest a plan?")
      parsed_response = JSON.parse(response.content)
      title = parsed_response["title"]
      @plan.update(title: title) if title.present?

      roadmap = parsed_response.slice("roadmap")
      @chat.messages.create!(role: "assistant", content: roadmap.to_json) if roadmap.present?

      redirect_to chat_path(@chat)
    else
      render :new, status: :unprocessable_entity
    end
  end

  def show
    @plan = Plan.find(params[:id])
    @chats = @plan.chats.where(user: current_user)
  end

  
  private

  def generate_title_from_first_message
    first_user_message = @chat.messages.find_by(role: "user")
    return unless first_user_message

    ruby_llm_chat = RubyLLM.chat

  end


  def instructions
    <<~TEXT
    You are an expert event planner. Based on the user's details, you will create a detailed and structured roadmap for their event.
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
    - If the theme is "family", include kid-friendly options.
    - Time rules:
      - Morning = 8am to 12pm
      - Afternoon = 2pm to 6pm
      - Evening = 6pm to 11pm
    - Include a price range.
    RULE:
    You MUST return ONLY valid JSON.
    NO text outside JSON.
    NO markdown.
    JSON FORMAT:
    {
      "title": string,
      "roadmap": [
        {
          "time": string,
          "title": string,
          "description": string,
          "pricing": string,
          "options": [string]
        }
      ]
    }
    User details:
    Theme: #{@plan.theme}
    City: #{@plan.city}
    Context: #{@plan.context}
    Number of persons: #{@plan.number_persons}
    Event length: #{@plan.event_lenght}
    Date: #{@plan.roadmap_date}
  TEXT
  end

  def plan_params
    params.require(:plan).permit(
      :theme,
      :number_persons,
      :city,
      :context,
      :event_lenght,
      :roadmap_date
    )
  end
end
