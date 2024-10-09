defmodule CameraApiWeb.NotificationControllerTest do
  use CameraApiWeb.ConnCase
  alias CameraApi.Repo
  alias CameraApi.Account.User
  alias CameraApi.Devices.Camera
  import Swoosh.TestAssertions

  setup do
    Repo.delete_all(Camera)
    Repo.delete_all(User)

    :ok
  end

  describe "notify_users/2" do
    setup do
      {:ok, user1} = Repo.insert(%User{name: "John Doe", email: "john@example.com"})
      {:ok, user2} = Repo.insert(%User{name: "Jane Doe", email: "jane@example.com"})
      {:ok, user3} = Repo.insert(%User{name: "Bob Smith", email: "bob@example.com"})

      {:ok, _camera1} =
        Repo.insert(
          Camera.changeset(%Camera{}, %{
            brand: "Hikvision",
            name: "Cam1",
            active: true,
            user_id: user1.id
          })
        )

      {:ok, _camera2} =
        Repo.insert(
          Camera.changeset(%Camera{}, %{
            brand: "Intelbras",
            name: "Cam2",
            active: true,
            user_id: user1.id
          })
        )

      {:ok, _camera3} =
        Repo.insert(
          Camera.changeset(%Camera{}, %{
            brand: "Hikvision",
            name: "Cam3",
            active: false,
            user_id: user2.id
          })
        )

      {:ok, _camera4} =
        Repo.insert(
          Camera.changeset(%Camera{}, %{
            brand: "Hikvision",
            name: "Cam4",
            active: true,
            user_id: user2.id
          })
        )

      {:ok, _camera5} =
        Repo.insert(
          Camera.changeset(%Camera{}, %{
            brand: "Giga",
            name: "Cam5",
            active: true,
            user_id: user3.id
          })
        )

      :ok
    end

    test "sends notifications to users with active Hikvision cameras", %{conn: conn} do
      conn = post(conn, ~p"/api/notify_users")

      assert json_response(conn, 200)["message"] == "Notifications processed"

      results = json_response(conn, 200)["results"]
      assert length(results) == 2

      user_names = Enum.map(results, & &1["user"])
      assert "John Doe" in user_names
      assert "Jane Doe" in user_names
      refute "Bob Smith" in user_names

      assert Enum.all?(results, &(&1["status"] == "sent"))
    end

    test "handles case when no users have active Hikvision cameras", %{conn: conn} do
      Repo.update_all(Camera, set: [active: false])

      conn = post(conn, ~p"/api/notify_users")

      assert json_response(conn, 200)["message"] == "Notifications processed"
      assert json_response(conn, 200)["results"] == []
    end

    test "emails are sent", %{conn: conn} do
      post(conn, ~p"/api/notify_users")

      assert_email_sent(to: {"John Doe", "john@example.com"})
      assert_email_sent(to: {"Jane Doe", "jane@example.com"})
      refute_email_sent(to: {"Bob Smith", "bob@example.com"})
    end
  end
end

