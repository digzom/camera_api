defmodule CameraApi.Account do
  import Ecto.Query
  alias CameraApi.Pagination
  alias CameraApi.Repo
  alias CameraApi.Account.User
  alias CameraApi.Devices.Camera

  def list_users_with_hikvision_cameras do
    User
    |> join(:inner, [u], c in Camera, on: c.user_id == u.id)
    |> where([u, c], c.brand == "Hikvision" and c.active == true)
    |> group_by([u], u.id)
    |> select([u, c], %{
      id: u.id,
      name: u.name,
      email: u.email,
      hikvision_cameras:
        fragment(
          "array_agg(json_build_object('id', ?, 'name', ?, 'brand', ?, 'active', ?))",
          c.id,
          c.name,
          c.brand,
          c.active
        )
    })
    |> Repo.all()
  end

  def list_users_with_active_cameras(params) do
    query =
      from u in User,
        preload: [cameras: ^active_cameras_query()]

    users =
      query
      |> filter_by_user_name(params)
      |> filter_by_user_external_id(params)
      |> filter_by_user_ended_at(params)
      |> order_by(^build_order_by(params))
      |> Pagination.new(params)

    users =
      users.entries
      |> Enum.map(&filter_user_cameras(&1, params))
      |> Enum.filter(&(!Enum.empty?(&1.cameras)))
      |> Enum.map(&format_user/1)

    {:ok, users}
  end

  defp active_cameras_query do
    from c in Camera,
      where: c.active == true
  end

  defp filter_by_user_name(query, %{"name" => name}) when is_binary(name) and name != "" do
    from u in query, where: fragment("LOWER(?) LIKE LOWER(?)", u.name, ^"%#{name}%")
  end

  defp filter_by_user_name(query, _), do: query

  defp filter_by_user_external_id(query, %{"external_id" => id})
       when is_binary(id) and id != "" do
    from u in query, where: u.external_id == ^id
  end

  defp filter_by_user_external_id(query, _), do: query

  defp filter_by_user_ended_at(query, %{"starting_date" => start, "ending_date" => end_date}) do
    query
    |> filter_by_user_ended_at_start(start)
    |> filter_by_user_ended_at_end(end_date)
  end

  defp filter_by_user_ended_at(query, _), do: query

  defp filter_by_user_ended_at_start(query, date) when is_binary(date) and date != "" do
    case parse_date(date) do
      {:ok, datetime} ->
        from u in query, where: u.ended_at >= ^datetime

      _ ->
        query
    end
  end

  defp filter_by_user_ended_at_start(query, _), do: query

  defp filter_by_user_ended_at_end(query, date) when is_binary(date) and date != "" do
    case parse_date(date) do
      {:ok, datetime} ->
        from u in query, where: u.ended_at <= ^datetime

      _ ->
        query
    end
  end

  defp filter_by_user_ended_at_end(query, _), do: query

  defp filter_user_cameras(user, params) do
    filtered_cameras =
      user.cameras
      |> Enum.filter(&filter_camera(&1, params))
      |> Enum.sort_by(& &1.name, build_camera_sort_fun(params))

    %{user | cameras: filtered_cameras}
  end

  defp filter_camera(camera, params) do
    filter_camera_by_name(camera, params) and
      filter_camera_by_brand(camera, params) and
      filter_camera_by_external_id(camera, params)
  end

  defp filter_camera_by_name(camera, %{"camera_name" => name})
       when is_binary(name) and name != "" do
    String.contains?(String.downcase(camera.name), String.downcase(name))
  end

  defp filter_camera_by_name(_, _), do: true

  defp filter_camera_by_brand(camera, %{"camera_brand" => brand})
       when is_binary(brand) and brand != "" do
    String.contains?(String.downcase(camera.brand), String.downcase(brand))
  end

  defp filter_camera_by_brand(_, _), do: true

  defp filter_camera_by_external_id(camera, %{"camera_external_id" => id})
       when is_binary(id) and id != "" do
    camera.external_id == id
  end

  defp filter_camera_by_external_id(_, _), do: true

  defp build_order_by(%{"order" => "desc"}), do: [desc: :name]
  defp build_order_by(_), do: [asc: :name]

  defp build_camera_sort_fun(%{"camera_order" => "desc"}), do: &>/2
  defp build_camera_sort_fun(_), do: &<=/2

  defp format_user(user) do
    %{
      id: user.id,
      name: user.name,
      external_id: user.external_id,
      ended_at: user.ended_at,
      cameras: Enum.map(user.cameras, &format_camera/1)
    }
  end

  defp format_camera(camera) do
    %{
      id: camera.id,
      name: camera.name,
      brand: camera.brand,
      active: camera.active,
      external_id: camera.external_id
    }
  end

  defp parse_date(date_string) do
    case DateTime.from_iso8601(date_string) do
      {:ok, datetime, _} -> {:ok, datetime}
      _ -> :error
    end
  end
end
