class RoadmapGeneratorService
  SYSTEM_PROMPT = <<~TEXT.freeze
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
  TEXT

  REFINEMENT_PROMPT = <<~TEXT.freeze
    You are an expert event planner.
    Your task:
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
    - If the theme is 'family', include kid-friendly options.
    - Time rules:
      - Morning = 8am to 12pm
      - Afternoon = 2pm to 6pm
      - Evening = 6pm to 11pm
    - Include a price range.

    You MUST return ONLY valid JSON.
    NO text outside JSON.
    NO markdown.

    JSON FORMAT:
    {
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
  TEXT

  EXTRACTION_PROMPT = <<~TEXT.freeze
    Extract the LAST roadmap from the following conversation and return ONLY valid JSON.
    JSON FORMAT:
    {
      "title": string,
      "price_range": string,
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
  TEXT

  def initialize(plan)
    @plan = plan
    @llm_chat = RubyLLM.chat
  end

  def generate_initial_roadmap
    user_details = build_plan_details
    @llm_chat.add_message(role: "user", content: user_details)

    response = @llm_chat.with_instructions(SYSTEM_PROMPT).ask("Can you suggest a plan?")
    parse_response(response.content)
  rescue JSON::ParserError => e
    Rails.logger.error("Failed to parse LLM response: #{e.message}")
    { error: "Failed to generate roadmap. Please try again." }
  rescue StandardError => e
    Rails.logger.error("LLM generation error: #{e.message}")
    { error: "An error occurred while generating the roadmap." }
  end

  def refine_roadmap(messages, user_message)
    build_conversation_history(messages)
    @llm_chat.add_message(role: "user", content: user_message)

    response = @llm_chat.with_instructions(REFINEMENT_PROMPT).ask(user_message)
    parse_response(response.content)
  rescue JSON::ParserError => e
    Rails.logger.error("Failed to parse LLM response: #{e.message}")
    { error: "Failed to refine roadmap. Please try again." }
  rescue StandardError => e
    Rails.logger.error("LLM refinement error: #{e.message}")
    { error: "An error occurred while refining the roadmap." }
  end

  def extract_latest_roadmap(messages)
    conversation = messages.map { |m| "#{m.role}: #{m.content}" }.join("\n")
    full_prompt = "#{EXTRACTION_PROMPT}\n\nConversation:\n#{conversation}"

    response = @llm_chat.with_instructions(full_prompt).ask("Return the LAST roadmap only.")
    parse_response(response.content)
  rescue JSON::ParserError => e
    Rails.logger.error("Failed to parse roadmap extraction: #{e.message}")
    nil
  rescue StandardError => e
    Rails.logger.error("Roadmap extraction error: #{e.message}")
    nil
  end

  private

  def build_plan_details
    <<~TEXT
      Theme: #{@plan.theme}
      City: #{@plan.city}
      Context: #{@plan.context}
      Number of persons: #{@plan.number_persons}
      Event length: #{@plan.event_lenght}
      Date: #{@plan.roadmap_date}
    TEXT
  end

  def build_conversation_history(messages)
    messages.each do |message|
      @llm_chat.add_message(message)
    end
  end

  def parse_response(content)
    JSON.parse(content)
  end
end
