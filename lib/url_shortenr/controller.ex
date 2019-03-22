defmodule UrlShortenr.Controller do
  def redirect_to_long_url(conn, short_url) do
    case UrlShortenr.Data.get(short_url) do
      {_short_url, long_url, _count} ->
        UrlShortenr.Data.update_count(short_url)

        conn
        |> Plug.Conn.resp(301, "Redirecting")
        |> Plug.Conn.put_resp_header("location", long_url)

      nil ->
        Plug.Conn.send_resp(conn, 404, "Not Found")
    end
  end

  def generate_short_url(conn, long_url) do
    short_url = short_url(long_url)
    valid? = valid_url?(long_url)
    exists? = UrlShortenr.Data.long_url_exists?(long_url)

    cond do
      !valid? ->
        Plug.Conn.send_resp(conn, 422, "Invalid URL")

      exists? ->
        Plug.Conn.send_resp(conn, 200, short_url)

      true ->
        UrlShortenr.Data.add({short_url, long_url, 0})
        Plug.Conn.send_resp(conn, 200, short_url)
    end
  end

  def stats(conn) do
    resp =
      UrlShortenr.Data.get()
      |> Enum.map(fn {_key, {short_url, long_url, count}} ->
        %{short_url: short_url, long_url: long_url, count: count}
      end)
      |> Jason.encode!()

    Plug.Conn.send_resp(conn, 200, resp)
  end

  defp short_url(long_url) do
    long_url
    |> URI.encode()
    |> :erlang.md5()
    |> Base.encode16()
    |> String.slice(0..7)
  end

  defp valid_url?(url) when is_binary(url) do
    %{scheme: scheme, host: host} = URI.parse(url)
    !is_nil(scheme) and !is_nil(host)
  end

  defp valid_url?(_url), do: false
end
