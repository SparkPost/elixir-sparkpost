defmodule SparkPost.EndpointTest do
  @moduledoc false
  use ExUnit.Case, async: false

  alias SparkPost.Endpoint
  alias SparkPost.MockServer

  import Mock

  defmodule Headers do
    @moduledoc false
    def for_method(method) do
      if method in [:post, :put] do
        Map.merge(for_body_requests(), core())
      else
        core()
      end
    end

    defp for_body_requests do
      %{"Content-Type" => &(&1 == "application/json")}
    end

    def core do
      %{
        "Authorization" => &(Application.get_env(:sparkpost, :api_key) == &1),
        "User-Agent" => &Regex.match?(~r/elixir-sparkpost\/\d+\.\d+\.\d+/, &1)
      }
    end
  end

  test "Endpoint.request succeeds with Endpoint.Response" do
    with_mock HTTPoison,
      request: fn _, _, _, _, _ ->
        r = MockServer.mk_resp()
        r.(nil, nil, nil, nil, nil)
      end do
      Endpoint.request(:get, "transmissions", %{})
    end
  end

  test "Endpoint.request populates Endpoint.Response" do
    status_code = 200
    results = Poison.decode!(MockServer.create_json(), %{keys: :atoms}).results

    with_mock HTTPoison, request: MockServer.mk_resp() do
      resp = %Endpoint.Response{} = Endpoint.request(:get, "transmissions", %{}, %{}, [])
      assert %Endpoint.Response{status_code: ^status_code, results: ^results} = resp
    end
  end

  test "Endpoint.request fails with Endpoint.Error" do
    with_mock HTTPoison, request: MockServer.mk_fail() do
      %Endpoint.Error{} =
        Endpoint.request(
          :get,
          "transmissions",
          []
        )
    end
  end

  test "Endpoint.request populates Endpoint.Error" do
    status_code = 400
    errors = Poison.decode!(MockServer.create_fail_json(), %{keys: :atoms}).errors

    with_mock HTTPoison, request: MockServer.mk_fail() do
      resp =
        %Endpoint.Error{} =
        Endpoint.request(
          :get,
          "transmissions",
          []
        )

      assert %Endpoint.Error{status_code: ^status_code, errors: ^errors} = resp
    end
  end

  test "Endpoint.request includes the core HTTP headers" do
    respfn = MockServer.mk_resp()

    with_mock HTTPoison,
      request: fn method, url, body, headers, opts ->
        Enum.each(Headers.for_method(method), fn {header, tester} ->
          header_atom = String.to_atom(header)

          assert Map.has_key?(headers, header_atom),
                 "#{header} header required for #{method} requests"

          assert tester.(headers[header_atom]),
                 "Malformed header: #{header}.  See Headers module in #{__ENV__.file} for formatting rules."
        end)

        respfn.(method, url, body, headers, opts)
      end do
      Enum.each([:get, :post, :put, :delete], fn method ->
        Endpoint.request(method, "transmissions", %{}, %{}, [])
      end)
    end
  end

  test "Endpoint.request includes request bodies for appropriate methods" do
    respfn = MockServer.mk_resp()

    with_mock HTTPoison,
      request: fn method, url, body, headers, opts ->
        assert body == ""
        respfn.(method, url, body, headers, opts)
      end do
      Endpoint.request(:post, "transmissions", %{}, %{}, [])
      Endpoint.request(:put, "transmissions", %{}, %{}, [])
    end
  end

  test "Endpoint.request includes request timeout" do
    respfn = MockServer.mk_resp()

    with_mock HTTPoison,
      request: fn method, url, body, headers, opts ->
        assert Keyword.has_key?(opts, :timeout)
        respfn.(method, url, body, headers, opts)
      end do
      Endpoint.request(:post, "transmissions", %{}, %{}, [])
      Endpoint.request(:put, "transmissions", %{}, %{}, [])
      Endpoint.request(:get, "transmissions", %{}, %{}, [])
    end
  end

  test_with_mock "Endpoint request can handle httpoison timeouts", HTTPoison,
    request: fn method, url, body, headers, opts ->
      fun = MockServer.mk_error(:timeout)
      fun.(method, url, body, headers, opts)
    end do
    assert %Endpoint.Error{errors: [:timeout], status_code: nil, results: nil} ==
             Endpoint.request(:post, "transmissions", %{}, %{}, [])
  end

  test_with_mock "Endpoint request can handle blank map as response", HTTPoison,
    request: fn method, url, body, headers, opts ->
      fun = MockServer.mk_http_resp(200, "{}")
      fun.(method, url, body, headers, opts)
    end do
    assert %Endpoint.Response{status_code: 200, results: %{}} ==
             Endpoint.request(:post, "transmissions", %{}, %{}, [])
  end
end
