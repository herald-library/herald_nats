defmodule MyApp.Router do
  use Herald.Router

  route "user:created",
    schema: MyApp.UserMessage,
    processor: &MyApp.UserMessage.process/1
end
