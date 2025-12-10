# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Event-to-go is a Rails 7.1 application for AI-powered event planning. Users create event plans, interact with an AI assistant via chat to refine roadmaps, and save finalized event plans. The application uses the ruby_llm gem to integrate with OpenAI's API for generating event suggestions.

## Core Architecture

### Data Model Hierarchy

The application follows a nested resource pattern:

```
User (Devise authentication)
  └─ Plan (event details: theme, city, context, number of persons, length, date)
      └─ Chat (conversation thread for refining the plan)
          └─ Message (user/assistant messages with 10 message limit per chat)
```

**Key relationships:**
- Plans store the final `roadmap` JSON in a text column
- Chats contain the conversation history used to generate/refine roadmaps
- Messages have a `MAX_USER_MESSAGES = 10` limit enforced by validation in app/models/message.rb:6

### LLM Integration Pattern

The application uses `RubyLLM.chat` (ruby_llm gem ~> 1.2.0) for OpenAI integration:

1. **Initial Plan Creation** (app/controllers/plans_controller.rb:29-38):
   - Creates first user message with plan parameters
   - Uses structured instructions (lines 63-106) to generate JSON roadmap
   - Parses response to extract title and roadmap
   - Stores roadmap in Chat messages

2. **Refinement Flow** (app/controllers/messages_controller.rb:39-62):
   - User sends refinement message
   - Full conversation history is rebuilt via `build_conversation_history`
   - AI generates new roadmap based on entire conversation context
   - Supports Turbo Stream for real-time updates

3. **Roadmap Extraction** (app/controllers/chats_controller.rb:30-51):
   - On chat show, LLM extracts the LAST roadmap from full conversation
   - Parses JSON to display structured roadmap
   - Falls back gracefully on JSON parse errors

### JSON Response Format

All LLM responses must follow this strict JSON structure:

```json
{
  "title": "string",
  "roadmap": [
    {
      "time": "string (Morning/Afternoon/Evening)",
      "title": "string",
      "description": "string",
      "pricing": "string",
      "options": ["string"]
    }
  ]
}
```

**Important:** Instructions emphasize returning ONLY valid JSON with NO markdown or extra text (see app/controllers/plans_controller.rb:83-84 and messages_controller.rb:22-24).

## Development Commands

### Setup
```bash
bundle install
rails db:create db:migrate
```

### Running the Application
```bash
rails server
# or
rails s
```

### Database
```bash
rails db:migrate           # Run pending migrations
rails db:rollback          # Rollback last migration
rails db:reset             # Drop, create, migrate, seed
rails db:schema:load       # Load schema without running migrations
```

### Testing
```bash
rails test                 # Run all tests
rails test test/models/message_test.rb  # Run specific test file
rails test test/models/message_test.rb:6  # Run specific test at line 6
```

### Console
```bash
rails console
# or
rails c
```

### Code Quality
```bash
rubocop                    # Run RuboCop linter
rubocop -a                 # Auto-correct offenses
```

RuboCop configuration in .rubocop.yml has many cops disabled (documentation, metrics, etc.) and sets line length max to 120.

## Key Technical Patterns

### Authentication
- Uses Devise gem for user authentication
- Current user accessible via `current_user` in controllers
- Routes: `devise_for :users` (login, signup, password reset)

### Frontend Stack
- **Hotwire:** Turbo Rails and Stimulus for SPA-like behavior
- **Bootstrap 5.3:** UI framework with Font Awesome icons
- **Simple Form:** Form builder
- **Importmap:** JavaScript management (no Node.js/npm)

### Routing Structure
```
root -> pages#home
/plans -> Plans index (saved roadmaps)
/plans/new -> Create new plan
/plans/:id -> Show plan with chats
/plans/:id/chats -> Create new chat for plan
/chats/:id -> Show chat with messages and roadmap
/chats/:id/messages -> Create message in chat
/chats/:id/save_roadmap -> Save roadmap to plan
```

## Important Constraints

1. **Message Limit:** Users can only send 10 messages per chat (Message::MAX_USER_MESSAGES)
2. **Environment Variable:** OPENAI_API_KEY must be set (currently in .env, should use .env.local for development)
3. **JSON Parsing:** ChatsController#show rescues JSON::ParserError when LLM doesn't return valid JSON
4. **User Scoping:** Always scope chats/plans to `current_user` to prevent unauthorized access

## Common Issues

### LLM Response Format
If the LLM returns markdown code blocks or extra text, the JSON parser will fail. The system prompts explicitly instruct "NO markdown" but this can still occur. Check:
- app/controllers/plans_controller.rb:83-98 for initial roadmap instructions
- app/controllers/messages_controller.rb:3-37 for refinement instructions

### Association Access
- Chats belong to Plans, not Users directly
- To access user's chats: `current_user.plans.flat_map(&:chats)` or via plan: `@plan.chats`
- ChatsController line 28 has incorrect query: `@chats = @plan.chats.where(user: current_user)` but chats don't have user_id

### Time Period Definitions
The system uses specific time ranges (app/controllers/plans_controller.rb:77-80):
- Morning: 8am - 12pm
- Afternoon: 2pm - 6pm
- Evening: 6pm - 11pm

## Testing Notes

- Test framework: Rails default Test::Unit (minitest)
- System tests use Capybara + Selenium WebDriver
- Test files excluded from RuboCop
- No fixtures are generated (config.generators.test_framework :test_unit, fixture: false)
