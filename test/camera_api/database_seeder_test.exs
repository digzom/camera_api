defmodule CameraApi.DatabaseSeederTest do
  use CameraApi.DataCase, async: false
  alias CameraApi.Repo
  alias CameraApi.Accounts.User
  alias CameraApi.Devices.Camera

  @total_users 100

  @expected_brands ["Intelbras", "Hikvision", "Giga", "Vivotek", "Dahua", "Axis"]

  setup do
    :ok
  end

  describe "run/0" do
    test "creates the correct number of users and cameras" do
      assert Repo.aggregate(User, :count) == 0
      assert Repo.aggregate(Camera, :count) == 0

      {users_created, cameras_created} = CameraApi.DatabaseSeeder.run(total_users: @total_users)

      assert users_created == @total_users
      assert cameras_created == @total_users * 50
      assert Repo.aggregate(User, :count) == @total_users
      assert Repo.aggregate(Camera, :count) == @total_users * 50
    end

    test "ensures each non-ended user has at least one active camera" do
      CameraApi.DatabaseSeeder.run(total_users: @total_users)

      query =
        from u in User,
          where: is_nil(u.ended_at),
          left_join: c in assoc(u, :cameras),
          group_by: u.id,
          having: sum(fragment("CASE WHEN ? THEN 1 ELSE 0 END", c.active)) > 0,
          select: u.id

      users_with_active_cameras = Repo.all(query)
      total_active_users = from(u in User, where: is_nil(u.ended_at)) |> Repo.aggregate(:count)

      assert length(users_with_active_cameras) == total_active_users
    end

    test "creates cameras with the correct brands" do
      CameraApi.DatabaseSeeder.run(total_users: @total_users)

      brands = from(c in Camera, distinct: true, select: c.brand) |> Repo.all()
      assert Enum.sort(brands) == Enum.sort(@expected_brands)
    end

    test "creates some ended users" do
      CameraApi.DatabaseSeeder.run(total_users: @total_users)

      ended_users_count = from(u in User, where: not is_nil(u.ended_at)) |> Repo.aggregate(:count)
      assert ended_users_count > 0
      assert ended_users_count <= @total_users
    end

    test "generates unique external_ids for users and cameras" do
      CameraApi.DatabaseSeeder.run(total_users: @total_users)

      user_external_ids = from(u in User, select: u.external_id) |> Repo.all()
      camera_external_ids = from(c in Camera, select: c.external_id) |> Repo.all()

      assert length(Enum.uniq(user_external_ids)) == length(user_external_ids)
      assert length(Enum.uniq(camera_external_ids)) == length(camera_external_ids)
    end
  end
end

