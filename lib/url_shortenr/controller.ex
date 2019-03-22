defmodule UrlShortenr.Controller do
  def redirect_to_long_url(conn, short_url) do
    case UrlShortenr.Data.get(short_url) do
      {long_url, _count} ->
        UrlShortenr.Data.update_count(short_url)

        conn
        |> Plug.Conn.resp(301, "Redirecting")
        |> Plug.Conn.put_resp_header("location", "http://" <> long_url)

      nil ->
        Plug.Conn.send_resp(conn, 404, "Not Found")
    end
  end

  def generate_short_url(conn, long_url) do
    short_url = short_url(long_url)
    UrlShortenr.Data.add({short_url, long_url, 0})
    Plug.Conn.send_resp(conn, 200, short_url)
  end

  def stats(conn) do
    data = UrlShortenr.Data.get()
    {long_url, count} = Enum.at(data, 0)
    # TODO: iterate all values and build response
    Plug.Conn.send_resp(conn, 200, Jason.encode!(long_url))
  end

  defp short_url(long_url) do
    long_url
    |> URI.encode()
    |> :erlang.md5()
    |> Base.encode16()
    |> String.slice(0..7)
  end
end
