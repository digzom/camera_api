defmodule CameraApi.SeederBenchmark do
  def run do
    CameraApi.Repo.query!("SELECT 1")

    {parallel_time, parallel_result} = :timer.tc(fn ->
      CameraApi.DatabaseSeeder.run(total_users: 20000)
    end)

    clear_database()

    {sequential_time, sequential_result} = :timer.tc(fn ->
      CameraApi.SyncDatabaseSeeder.run(total_users: 20000)
    end)

    IO.puts("Parallel Seeder:")
    IO.puts("  Time: #{parallel_time / 1_000_000} seconds")
    IO.puts("  Users: #{elem(parallel_result, 0)}")
    IO.puts("  Cameras: #{elem(parallel_result, 1)}")

    IO.puts("\nSequential Seeder:")
    IO.puts("  Time: #{sequential_time / 1_000_000} seconds")
    IO.puts("  Users: #{elem(sequential_result, 0)}")
    IO.puts("  Cameras: #{elem(sequential_result, 1)}")

    speedup = sequential_time / parallel_time
    IO.puts("\nSpeedup: #{speedup}x")
  end

  defp clear_database do
    CameraApi.Repo.delete_all(CameraApi.Devices.Camera)
    CameraApi.Repo.delete_all(CameraApi.Account.User)
  end
end
