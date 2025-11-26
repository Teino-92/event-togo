class AddSystemPromptToPlans < ActiveRecord::Migration[7.1]
  def change
    add_column :plans, :system_prompt, :text
  end
end
