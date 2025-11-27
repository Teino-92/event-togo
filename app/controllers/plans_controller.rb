class PlansController < ApplicationController

  def index
    @plans = Plan.all
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

      @chat = @plan.chats.create!(
        title: "New Roadmap"
      )

      @message = @chat.messages.create!(
        role: "user",
        content: first_prompt
      )

      ruby_llm_chat = RubyLLM.chat
      ruby_llm_chat.add_message(@message)

      response = ruby_llm_chat.
        with_instructions(instructions).
        ask("Can you suggest a plan?")


      @chat.messages.create!(
        role: "assistant",
        content: response.content
      )

      #@chat.generate_title_from_first_message

      redirect_to chat_path(@chat)
    else
      render :new, status: :unprocessable_entity
    end
  end

  def show
    @plan = Plan.find(params[:id])
    @chats = @plan.chats.where(user: current_user)
  end

  def save_roadmap
    @plan = Plan.find(params[:id])
    @chat = @plan.chats.last

     roadmap_content = @chat.messages.where(role: "assistant").order(:created_at).pluck(:content).join("\n\n")

     if @plan.update(roadmap: roadmap_content)
      redirect_to plans_path, notice: "Roadmap saved successfully!"
    else
      redirect_to plans_path, alert: "Error saving roadmap."
    end
  end

  private

  def generate_title_from_first_message

  end


  def instructions
    <<~TEXT
      Your are an expert event planner. Based on the following details, create a detailed and engaging roadmap for the user.
      Provide suggestions for restaurants, activities, and places to visit that align with the user's preferences.
      Make sure to consider the number of persons, the city, the context, the event length, and the date.
      Format the roadmap in a clear and organized manner, using sections and bullet points where appropriate.
      Here are the details:
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
      :roadmap_dates
    )
  end
end
