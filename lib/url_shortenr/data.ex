defmodule UrlShortenr.Data do
  use Agent

  def start_link(_init) do
    Agent.start_link(fn -> %{} end, name: __MODULE__)
  end

  def add({short_url, long_url, 0}) do
    Agent.update(__MODULE__, fn state ->
      Map.put(state, short_url, {short_url, long_url, 0})
    end)
  end

  def get(short_url) do
    Agent.get(__MODULE__, fn state ->
      Map.get(state, short_url)
    end)
  end

  def get() do
    Agent.get(__MODULE__, fn state -> state end)
  end

  def long_url_exists?(long_url) do
    Agent.get(__MODULE__, fn state ->
      exists? =
        Enum.find(state, fn {_key, {_short_url, existing_long_url, _count}} ->
          existing_long_url == long_url
        end)

      !is_nil(exists?)
    end)
  end

  def update_count(short_url) do
    Agent.update(__MODULE__, fn state ->
      {short_url, long_url, count} = Map.get(state, short_url)
      Map.replace!(state, short_url, {short_url, long_url, count + 1})
    end)
  end
end
