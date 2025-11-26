class PlansController < ApplicationController
  before_action :authenticate_user!
  before_action :set_plan, only: [:show, :update]

  def index
    @plans = current_user.plans
  end

  def new
    @plan = Plan.new
  end

  def create
    @plan = current_user.plans.build(plan_params)

    if @plan.save
      redirect_to @plan, notice: "Plan créé avec succè."
    else
      render :new, status: :unprocessable_entity
    end
  end

def update
    if @plan.update(plan_params)
      redirect_to @plan, notice: "Plan mis à jour."
    else
      render :show, status: :unprocessable_entity
    end
  end


  def show
    @plan = current_user.plans.find(params[:id])
  end

  private

  def set_plan
    @plan = current_user.plans.find(params[:id])
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
