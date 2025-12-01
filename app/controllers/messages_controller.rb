class MessagesController < ApplicationController
  before_action :set_chat
  before_action :authorize_chat

  def create
    @message = @chat.messages.build(message_params.merge(role: "user"))
    @plan = @chat.plan

    if @message.save
      process_message
    else
      render "chats/show", status: :unprocessable_entity
    end
  end

  private

  def set_chat
    @chat = Chat.find(params[:chat_id])
  end

  def authorize_chat
    plan = @chat.plan
    redirect_to plans_path, alert: "Unauthorized access" unless plan.user == current_user
  end

  def process_message
    generator = RoadmapGeneratorService.new(@plan)
    result = generator.refine_roadmap(@chat.messages, @message.content)

    if result[:error]
      flash.now[:alert] = result[:error]
      respond_with_error
      return
    end

    create_assistant_message(result)
    respond_with_success
  rescue StandardError => e
    Rails.logger.error("Message processing error: #{e.message}")
    flash.now[:alert] = "Failed to process message. Please try again."
    respond_with_error
  end

  def create_assistant_message(result)
    content = result["roadmap"] ? { roadmap: result["roadmap"] }.to_json : result.to_json
    @chat.messages.create!(role: "assistant", content: content)
  end

  def respond_with_success
    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to chat_path(@chat) }
    end
  end

  def respond_with_error
    respond_to do |format|
      format.turbo_stream { render turbo_stream: turbo_stream.replace("flash", partial: "shared/flash") }
      format.html { render "chats/show", status: :unprocessable_entity }
    end
  end

  def message_params
    params.require(:message).permit(:content)
  end
end
