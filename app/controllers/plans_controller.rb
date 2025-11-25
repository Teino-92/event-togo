class PlansController < ApplicationController

  def new
    @plans = Plan.new
  end

  def create
    @plans = Plan.new(plan_params)
    @plans.user = current_user
    if @plans.save
      redirect_to plan_path(@plans)
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def plan_params
    params.require(:plan).permit(:theme, :number_persons, :city, :context, :event_lenght, :roadmap_date)
  end
end
