defmodule CameraApiWeb.CamerasControllerTest do
  use CameraApiWeb.ConnCase

  alias CameraApi.Devices.Camera
  alias CameraApi.Account
  alias CameraApi.Devices
  alias CameraApi.Repo
  alias CameraApi.Account.User

  setup %{conn: conn} do
    Repo.delete_all(Camera)
    Repo.delete_all(User)

    now = DateTime.utc_now() |> DateTime.truncate(:second)
    user1 = Repo.insert!(%Account.User{name: "User 1"})
    user2 = Repo.insert!(%Account.User{name: "User 2", ended_at: now})

    Repo.insert!(%Devices.Camera{
      name: "Cam B",
      brand: "Intelbras",
      active: true,
      user_id: user1.id
    })

    Repo.insert!(%Devices.Camera{
      name: "Cam A",
      brand: "Hikvision",
      active: true,
      user_id: user1.id
    })

    Repo.insert!(%Devices.Camera{name: "Cam C", brand: "Giga", active: false, user_id: user1.id})

    Repo.insert!(%Devices.Camera{name: "Cam D", brand: "Vivotek", active: true, user_id: user2.id})

    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all users with active cameras", %{conn: conn} do
      conn = get(conn, ~p"/api/cameras")
      assert %{"data" => users} = json_response(conn, 200)
      assert length(users) == 2

      [user1, user2] = users
      assert user1["name"] == "User 1"
      assert length(user1["cameras"]) == 2
      assert user2["name"] == "User 2"
      assert length(user2["cameras"]) == 1
    end

    test "filters users by camera name", %{conn: conn} do
      conn = get(conn, ~p"/api/cameras?camera_name=Cam A")
      assert %{"data" => users} = json_response(conn, 200)
      assert length(users) == 1
      [user] = users
      assert user["name"] == "User 1"
      assert length(user["cameras"]) == 1
      [camera] = user["cameras"]
      assert camera["name"] == "Cam A"
    end

    test "orders cameras by name ascending", %{conn: conn} do
      conn = get(conn, ~p"/api/cameras?order=asc")
      assert %{"data" => users} = json_response(conn, 200)
      user_with_multiple_cameras = Enum.find(users, fn user -> length(user["cameras"]) > 1 end)
      camera_names = Enum.map(user_with_multiple_cameras["cameras"], & &1["name"])
      assert camera_names == Enum.sort(camera_names)
    end

    test "orders cameras by name descending", %{conn: conn} do
      conn = get(conn, ~p"/api/cameras?camera_order=desc")
      assert %{"data" => users} = json_response(conn, 200)
      user_with_multiple_cameras = Enum.find(users, fn user -> length(user["cameras"]) > 1 end)
      camera_names = Enum.map(user_with_multiple_cameras["cameras"], & &1["name"])
      assert camera_names == Enum.sort(camera_names, :desc)
    end

    test "returns empty list for non-existent camera name", %{conn: conn} do
      conn = get(conn, ~p"/api/cameras?camera_name=NonExistent")
      assert %{"data" => users} = json_response(conn, 200)
      assert users == []
    end

    test "includes ended_at for inactive users", %{conn: conn} do
      conn = get(conn, ~p"/api/cameras")
      assert %{"data" => users} = json_response(conn, 200)
      user2 = Enum.find(users, &(&1["name"] == "User 2"))
      assert user2["ended_at"] != nil
    end
  end
end

