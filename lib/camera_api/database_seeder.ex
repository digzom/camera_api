defmodule CameraApi.DatabaseSeeder do
  alias CameraApi.Repo
  alias CameraApi.Accounts.User
  alias CameraApi.Devices.Camera
  import Logger

  @brands ["Intelbras", "Hikvision", "Giga", "Vivotek", "Dahua", "Axis"]
  @batch_size 100

  def run(opts \\ []) do
    total_users = Keyword.get(opts, :total_users, 1000)
    max_concurrency = Keyword.get(opts, :max_concurrency, System.schedulers_online())

    info("Starting seeder with total_users: #{total_users}, max_concurrency: #{max_concurrency}")

    users = insert_users_in_batches(total_users, max_concurrency)
    cameras = insert_cameras_in_batches(users, max_concurrency)

    info("Seeder finished. Created #{length(users)} users and #{length(cameras)} cameras.")
    {length(users), length(cameras)}
  end

  defp insert_users_in_batches(total_users, max_concurrency) do
    total_users
    |> Stream.unfold(fn
      0 -> nil
      remaining -> {min(remaining, @batch_size), remaining - @batch_size}
    end)
    |> Task.async_stream(
      fn batch_size -> insert_users(Repo, batch_size) end,
      max_concurrency: max_concurrency,
      ordered: false
    )
    |> Enum.reduce([], fn {:ok, {:ok, users}}, acc -> acc ++ users end)
  end

  defp insert_users(repo, batch_size) do
    now = DateTime.utc_now() |> DateTime.truncate(:second)

    users =
      Enum.map(1..batch_size, fn _ ->
        %{
          name: Faker.Person.name(),
          ended_at: if(Enum.random(1..10) == 1, do: now, else: nil),
          inserted_at: now,
          updated_at: now,
          external_id: Ecto.UUID.generate()
        }
      end)

    case repo.insert_all(User, users, returning: [:id]) do
      {^batch_size, inserted_users} -> {:ok, inserted_users}
      {count, _} -> {:error, "Expected to insert #{batch_size} users, but inserted #{count}"}
    end
  end

  defp insert_cameras_in_batches(users, max_concurrency) do
    users
    |> Stream.chunk_every(@batch_size)
    |> Task.async_stream(
      fn user_batch -> insert_cameras(Repo, user_batch) end,
      max_concurrency: max_concurrency,
      ordered: false
    )
    |> Enum.reduce([], fn {:ok, {:ok, cameras}}, acc -> acc ++ cameras end)
  end

  defp insert_cameras(repo, users) do
    now = DateTime.utc_now() |> DateTime.truncate(:second)

    cameras =
      Enum.flat_map(users, fn user ->
        Enum.map(1..50, fn _ ->
          %{
            brand: Enum.random(@brands),
            name: "CAM_#{Faker.Internet.user_name()}",
            active: Enum.random([true, false]),
            user_id: user.id,
            inserted_at: now,
            updated_at: now,
            external_id: Ecto.UUID.generate()
          }
        end)
        |> ensure_active_camera()
      end)

    case repo.insert_all(Camera, cameras, returning: [:id]) do
      {count, inserted_cameras} when count == length(users) * 50 ->
        {:ok, inserted_cameras}

      {count, _} ->
        {:error, "Expected to insert #{length(users) * 50} cameras, but inserted #{count}"}
    end
  end

  defp ensure_active_camera(cameras) do
    if Enum.any?(cameras, & &1.active) do
      cameras
    else
      List.update_at(cameras, 0, &Map.put(&1, :active, true))
    end
  end
end

