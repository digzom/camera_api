defmodule CameraApi.EmailNotifier do
  use Phoenix.Swoosh,
    template_root: "lib/camera_api_web/templates",
    layout: {CameraApi.EmailNotifier, :_layout}

  def send_notification(email, name) do
    sender = Application.get_env(:camera_api, CameraApi.Mailer) |> Keyword.fetch!(:sender)

    new()
    |> to({name, email})
    |> from({"Camera API", sender})
    |> subject("Welcome!")
    |> render_body("welcome.html", %{name: name})
    |> CameraApi.Mailer.deliver()
  end
end
