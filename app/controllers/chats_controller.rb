class ChatsController < ApplicationController
  before_action :set_chat, only: %i[show save_roadmap]
  before_action :authorize_chat, only: %i[show save_roadmap]

  def create
    @plan = current_user.plans.find(params[:plan_id])
    chat_number = @plan.chats.count + 1
    @chat = @plan.chats.create!(title: "Refinement Chat ##{chat_number}")

    redirect_to chat_path(@chat), notice: "New chat created! Start refining your event plan."
  rescue ActiveRecord::RecordNotFound
    redirect_to plans_path, alert: "Plan not found"
  end

  def show
    @message = @chat.messages.new
    @plan = @chat.plan
    @chats = @plan.chats.order(created_at: :desc)
    @roadmap_json = extract_roadmap
  end

  def save_roadmap
    last_assistant_message = @chat.messages.where(role: "assistant").last

    unless last_assistant_message.present?
      redirect_to chat_path(@chat), alert: "No roadmap to save."
      return
    end

    @plan = @chat.plan

    if @plan.update(roadmap: last_assistant_message.content, roadmap_date: @plan.roadmap_date)
      redirect_to plans_path, notice: "Roadmap saved successfully!"
    else
      redirect_to chat_path(@chat), alert: "Failed to save roadmap."
    end
  end

  private

  def set_chat
    @chat = Chat.find(params[:id])
  end

  def authorize_chat
    plan = @chat.plan
    redirect_to plans_path, alert: "Unauthorized access" unless plan.user == current_user
  end

  def extract_roadmap
    generator = RoadmapGeneratorService.new(@chat.plan)
    generator.extract_latest_roadmap(@chat.messages)
  rescue StandardError => e
    Rails.logger.error("Roadmap extraction error: #{e.message}")
    nil
  end
end
