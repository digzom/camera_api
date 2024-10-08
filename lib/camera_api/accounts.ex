defmodule CameraApi.Accounts do
  import Ecto.Query
  alias CameraApi.Repo
  alias CameraApi.Accounts.User

  def list_users_with_active_cameras(params) do
    query =
      from u in User,
        left_join: c in assoc(u, :cameras),
        on: c.active == true,
        group_by: u.id,
        select: %{
          id: u.id,
          name: u.name,
          ended_at: u.ended_at,
          cameras:
            fragment(
              "array_agg(json_build_object('id', ?, 'name', ?, 'brand', ?))",
              c.id,
              c.name,
              c.brand
            )
        }

    query = apply_filters(query, params)

    Repo.all(query)
  end

  defp apply_filters(query, params) do
    query
    |> filter_by_camera_name(params["camera_name"])
    |> order_by_camera_name(params["order"])
  end

  defp filter_by_camera_name(query, nil), do: query

  defp filter_by_camera_name(query, camera_name) do
    where(query, [u, c], ilike(c.name, ^"%#{camera_name}%"))
  end

  defp order_by_camera_name(query, "asc"), do: order_by(query, [u, c], asc: c.name)
  defp order_by_camera_name(query, "desc"), do: order_by(query, [u, c], desc: c.name)
  defp order_by_camera_name(query, _), do: query
end
