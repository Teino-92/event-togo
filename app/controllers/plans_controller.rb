class PlansController < ApplicationController
  before_action :set_plan, only: %i[show destroy]
  before_action :authorize_plan, only: %i[show destroy]

  def index
    @plans = current_user.plans.where.not(roadmap: nil).order(created_at: :desc)
  end

  def new
    @plan = Plan.new
  end

  def create
    @plan = current_user.plans.build(plan_params)

    if @plan.save
      process_new_plan
    else
      render :new, status: :unprocessable_entity
    end
  end

  def show
    @chats = @plan.chats.order(created_at: :desc)
  end

  def destroy
    @plan.destroy
    redirect_to plans_path, notice: "Plan deleted successfully."
  end

  private

  def process_new_plan
    chat = @plan.chats.create!(title: "New Roadmap")
    generator = RoadmapGeneratorService.new(@plan)

    result = generator.generate_initial_roadmap

    if result[:error]
      @plan.destroy
      Rails.logger.error("Roadmap generation failed: #{result[:error]}")
      flash[:alert] = "#{result[:error]} This is usually a temporary issue. Please try again in a moment."
      redirect_to new_plan_path
      return
    end

    if result["roadmap"].blank?
      @plan.destroy
      Rails.logger.error("Roadmap generation returned no roadmap data")
      flash[:alert] = "Failed to generate roadmap. Please try again."
      redirect_to new_plan_path
      return
    end

    update_plan_with_result(result)
    create_initial_messages(chat, result)

    redirect_to chat_path(chat), notice: "Your event plan has been generated! 🎉"
  rescue StandardError => e
    Rails.logger.error("Plan creation error: #{e.class} - #{e.message}")
    Rails.logger.error(e.backtrace.join("\n"))
    @plan.destroy if @plan.persisted?
    flash[:alert] = "Failed to create plan: #{e.message}. Please try again."
    redirect_to new_plan_path
  end

  def update_plan_with_result(result)
    @plan.update(title: result["title"]) if result["title"].present?
  end

  def create_initial_messages(chat, result)
    user_message_content = build_user_message_content
    chat.messages.create!(role: "user", content: user_message_content)

    roadmap = result.slice("roadmap")
    chat.messages.create!(role: "assistant", content: roadmap.to_json) if roadmap.present?
  end

  def build_user_message_content
    <<~TEXT
      Theme: #{@plan.theme}
      City: #{@plan.city}
      Context: #{@plan.context}
      Number of persons: #{@plan.number_persons}
      Event length: #{@plan.event_lenght}
      Date: #{@plan.roadmap_date}
    TEXT
  end

  def set_plan
    @plan = Plan.find(params[:id])
  end

  def authorize_plan
    redirect_to plans_path, alert: "Unauthorized access" unless @plan.user == current_user
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
