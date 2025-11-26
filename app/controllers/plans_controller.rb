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
      first_message: first_prompt,
      title: "New AI Roadmap"
    )

    @message = @chat.messages.create!(
      role: "user",
      content: first_prompt
    )

    ruby_llm_chat = RubyLLM.chat
    ruby_llm_chat.add_message(@message)

    response = ruby_llm_chat.with_instructions(instructions).ask(@message.content)

    @chat.messages.create!(
      role: "assistant",
      content: response.content
    )

    @chat.generate_title_from_first_message

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

  def plan_params
    params.require(:plan).permit(:theme, :number_persons, :city, :context, :event_lenght, :roadmap_date)
  end
end
